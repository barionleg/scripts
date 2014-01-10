Param($chocolateyFolder)
$chocoShare = "\\chocolatey.ise.com\ChocoTest"

Function Copy_Directory
{
  if(Test-Path $chocolateyPath)
	{
	  Remove-Item $chocolateyPath -Recurse
	  Write-Host "Warning: $chocolateyPath already exists and will be deleted and copied again!" -foregroundcolor "yellow"
	  Start-Sleep -s 2
	}
  Write-Host "* Copying $chocolateyFolder to $chocoShare" -foregroundcolor "green"
  Copy-Item $chocolateyFolder $chocoShare -Recurse -Force
  Write-Host "* Copy Complete - Happy Testing!! The chocolatey gods have answered your request!" -foregroundcolor "green"
}

if ($chocolateyFolder -eq $null) {
  $PackagePath = Join-Path $(Get-Location) "\*"
  if ((Test-Path $PackagePath -include *.nuspec) -eq "True")  {
  $chocolateyFolder = Get-Location
  $chocolateyPath = Join-Path $chocoShare (Split-Path -leaf -path (Get-Location)) 
  Copy_Directory  
  }
  else {
  Write-Host "Please specify directory or ensure you are in the root of your package!!" -foregroundcolor "red"
  Write-Host "* You are currently in the directory $(Get-Location)" -foregroundcolor "red"
  }
}

else {
  $isTrue = $chocolateyFolder.StartsWith(".\")
  if($isTrue -eq "True"){
  $chocolateyFolder = $chocolateyFolder.Replace(".\","")
  }
  $chocolateyPath = Join-Path $chocoShare $chocolateyFolder
  if(Test-Path $chocolateyFolder)
{
   Copy_Directory
}
else {
  Write-Host "FOLDER DOES NOT EXIST!" -foregroundcolor "red"
  }
}