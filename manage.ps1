function Show-Menu {
  param (
    [string]$MenuTitle = 'Path Manager'
  )

  Clear-Host
  Write-Host "================ $MenuTitle ================"
  Write-Host "1: List paths"
  Write-Host "2: Add a path"
  Write-Host "3: Remove a path"
  Write-Host "4: Restore paths"
  Write-Host "Q: Exit"
}


Add-Type -AssemblyName System.Windows.Forms


# Create {{drive}} folder if it doesn't exist
if (-not (Test-Path "$PSScriptRoot\{{drive}}")) {
  New-Item -ItemType Directory -Force -Path "$PSScriptRoot\{{drive}}"
}



function Get-Paths {
  $driveLetter = $PSScriptRoot.Substring(0, 1)
  Get-ChildItem -Path "$PSScriptRoot\{{drive}}" -Recurse | Where-Object { $_.PSIsContainer -eq $false } | ForEach-Object { $_.FullName.Substring($PSScriptRoot.Length + 1).Replace("{{drive}}\", $driveLetter + ":\") }
}

function List-Paths {
  Write-Host "Stored Paths:"
  Get-Paths | ForEach-Object { Write-Host $_ }
}

function Create-Directories {
  param (
    [string]$path
  )

  $directory = [System.IO.Path]::GetDirectoryName($path)
  if (-not (Test-Path $directory)) {
    New-Item -ItemType Directory -Force -Path $directory
  }
}

function Add-Path {
  
  $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $fileDialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
  $fileDialog.Filter = "All files (*.*)|*.*"
  $result = $fileDialog.ShowDialog()

  
    
  if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $origin = $fileDialog.FileName

    # Exit if the selected path already includes "{{drive}}"
    if ($origin -match "{{drive}}") {
      Write-Host "Path already added: $($origin.Substring($PSScriptRoot.Length + 1))"
      return
    }

    # Create the correct absolute paths and move the seleted file
    # $PSScriptRoot/{{drive}}/path/to/file. 
    $target = "$PSScriptRoot" + "\{{drive}}\" + $origin.Substring(3)

    # Create the directory structure if it doesn't exist
    Create-Directories -path $target

    # Move the file to the target location
    Move-Item -Path $origin -Destination $target

    # Optionally, create a symbolic link (if needed), targeting the moved file
    New-Item -ItemType SymbolicLink -Path $origin -Value $target

    Write-Host "Path added: $origin"
  }
}

function Remove-EmptyDirectories {
  param (
    [string]$Path
  )

  # Get all child directories
  $childDirs = Get-ChildItem -Path $Path -Directory -Recurse | Sort-Object -Property FullName -Descending

  foreach ($dir in $childDirs) {
    # Check if the directory is empty (no files or directories)
    if (-not (Get-ChildItem -Path $dir.FullName)) {
      # Remove the empty directory
      Remove-Item -Path $dir.FullName -Force
      Write-Host "Removed empty directory: $($dir.FullName)"
    }
  }

}

function Remove-Path {
  Get-Paths | % { $i = 0 } { Write-Host "$i`: $_"; $i++ }
  $input = Read-Host "Select a path to remove"
  # return if not a number
  if ($input -match '\D' -or $input.Length -eq 0) {
    Write-Host "Invalid input: $input"
    return
  }
  $path = Get-Paths | Select-Object -Index $input
  if ($path) {
    $confirm = Read-Host "Are you sure you want to move the file back to its original location? (Y/n)"
    if ($confirm.Length -gt 0 -and $confirm -ne 'Y') {
      Write-Host "Action cancelled"
      return
    }
    $linkTarget = (Get-Item -Path "$path").Target
    Remove-Item -Path $path
    Move-Item -Path $linkTarget -Destination $path
    Write-Host "Done"

    Write-Host "Pruining empty directories:"
    # Remove the empty directories
    Remove-EmptyDirectories -Path "$PSScriptRoot\{{drive}}"

  }
  else {
    Write-Host "Path not found: $input"
  }
}


function Restore-Paths {
  # Get all paths under the {{drive}} folder
  $paths = Get-Paths

  $timestamp = Get-Date -Format "yyyyMMddHHmmss"


  if ($confirm.Length -gt 0 -and $confirm -ne 'Y') {
    Write-Host "Action cancelled"
    return
  }

  foreach ($path in $paths) {
    echo "Restoring path: $path"
    # Determine the directory where the symbolic link should be created
    $directoryPath = [System.IO.Path]::GetDirectoryName($path)

    $dotConfigPath = "$PSScriptRoot\{{drive}}\" + $path.Substring(3)

    # Ensure the directory exists
    if (-not (Test-Path $directoryPath)) {
      New-Item -ItemType Directory -Force -Path $directoryPath
    }

    # Check if a link already exists at the target location, remove it if it does
    if (Test-Path $path) {
      Create-Directories -path "$PSScriptRoot\config\$timestamp\"
      Move-Item -Path $path -Destination "$PSScriptRoot\config\$timestamp"
    }

    # Create a symbolic link from the original location to the file in the dotfiles directory
    New-Item -ItemType SymbolicLink -Path $path -Value $dotConfigPath
  }
  if (Test-Path "$PSScriptRoot\config\$timestamp") {
    Write-Host "Some config files already existed in the target location. They have been moved to $PSScriptRoot\config\$timestamp"
  }
}
# Main loop
do {
  Show-Menu
  $input = Read-Host "Please select an option"
  switch ($input) {
    '1' {
      List-Paths
    }
    '2' {
      Add-Path
    }
    '3' {
      Remove-Path
    }
    '4' {
      Restore-Paths
    }
    'Q' {
      break
    }
    default {
      Write-Host "Invalid option, please try again."
    }
  }
  pause
} while ($input -ne 'Q')
