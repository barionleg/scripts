#Git Chocolatey Auto-Tagger™ and other tag functions
#Created by: A.Moy
#Date Created: 1/7/2014
#Date Updated: 1/9/2014

$option = $args[0]
$PackagePath = Join-Path $(Get-Location) "\*"
$CheckPath = Test-Path -ErrorAction SilentlyContinue $PackagePath -include *.nuspec 

Function Tag_Add {
  if (($CheckPath) -eq "True") {
    $fileName = Get-ChildItem *.nuspec
    $packageID = $fileName.name -replace ".nuspec", ""
    $versionString = Select-String "$packageID.nuspec" -pattern "<version>"
    $versionID1 = $versionString.line -replace "    <version>", ""
    $versionID2 = $versionID1 -replace "</version>", ""
    $tag = "$packageid-$versionID2"
	Write-Host "`n* Tags for previous versions of this package are:`n" -foreground red -background black
    git tag -l | grep -i $packageID
    Write-Host "`n* The new tag to be added is " -nonewline -foreground red -background black
    Write-Host "* $tag *`n" -foreground green -background black
    $confirm = Read-Host "Are you sure? (y/n/e)"

    if ($confirm -eq "y") {
      git tag -a -f $tag -m $tag
      Write-Host "`n* Added tag " -nonewline -foreground blue
      Write-Host "* $tag *`n" -foreground green
	  Tag_Push
    }
    elseif ($confirm -eq "e") {
      $tag = Read-Host "Enter tag name: "
      git tag -a -f $tag -m $tag
      Write-Host "`n* Added tag " -nonewline -foreground blue -background black
      Write-Host "* $tag *`n" -foreground green -background black
      Tag_Push
	}
    else {
      Write-Host "`n* Tag addition has been aborted`n" -foreground red -background black
    }
}
  else {
    Directory_Error
  }
}

Function Tag_Find {
  if (($CheckPath) -eq "True") {
    $fileName = Get-ChildItem *.nuspec
    $packageID = $fileName.name -replace ".nuspec", ""
    Write-Host "`nRelated Tags:" -foreground yellow -background black
	git tag -l | grep -i $packageID
  }
  else {
    Directory_Error
  }
}

Function Tag_Help {
  Write-Host "* Usage: .\tag.ps1 <command>"
  Write-Host "* Available commands: add, find, del, clean, help (this screen)"
}

Function Tag_Push {
  $pushTags = Read-Host "Would you also like to push this tag upstream? (y/n)"
  if ($pushTags -eq "y") {
    git push upstream --tags
  }
  else {
    Write-Host "* Tag has not been pushed to upstream.`n" -foreground red -background black
  }
}

Function Directory_Error {
  Write-Host "* Please ensure you are in the root of your package!!" -foreground red -background black
  Write-Host "* You are currently in the directory " -foreground red -background black -nonewline
  Write-Host "$(Get-Location)" -foreground yellow -background black
}

Function Tag_Del {
  Tag_Find
  $TagDelete = Read-Host "`nEnter tag to delete (Enter any tag, above are just examples)"
  git tag -d $TagDelete
  git push origin  :$TagDelete
  $confirm = Read-Host "Would you also like to delete the tag upstream? (y/n)" 
  if ($confirm -eq "y") {  
    git push upstream  :$TagDelete
  }
}

Function Tag_Clean {
  $cleanConfirm = Read-Host "Are you sure you want to clean all your local tags that don't match the tags found upstream? (y/n)"
  if ($cleanConfirm -eq "y") {
    Write-Host "`n* Removing all local tags!" -foreground red -background black
    git tag -l | xargs git tag -d
    Write-Host "`n* Fetching tags from upstream!" -foreground red -background black
    git fetch upstream --tags
	Write-Host "* All done, your local tags should now match upstream!`n" -foreground green -background black
  }
  else {
    Write-Host "* Tag clean aborted.`n" -foreground red -background black
  }
}
  
if ($option -eq "add") {
  Tag_Add
}
elseif ($option -eq "find") {
  Tag_Find
}
elseif ($option -eq "del") {
  Tag_Del
}
elseif ($option -eq "clean") {
  Tag_Clean
}
else {
  Tag_Help
}