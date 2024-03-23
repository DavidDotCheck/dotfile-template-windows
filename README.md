# Dotfile Template for Windows

This repository provides a PowerShell script for managing dotfiles on a Windows system. The script includes functionality for listing, adding, and removing paths, as well as restoring paths.

## Features

- **List Paths**: Displays all the stored paths.
- **Add a Path**: Allows you to select a file using a file dialog and moves it to a managed location, creating a symbolic link at the original location.
- **Remove a Path**: Removes a selected path and cleans up any empty directories.
- **Restore Paths**: Applies all stored configurations to the host system.

## Usage

Run the [`manage.ps1`](command:_github.copilot.openRelativePath?%5B%22manage.ps1%22%5D "manage.ps1") script in a PowerShell terminal with administrative privileges. A menu will be displayed with options to list, add, remove, or restore paths.

```ps1
.\manage.ps1
```

## Functions

- `Test-Administrator`: Checks if the script is running with administrative privileges.
- `Show-Menu`: Displays the main menu.
- `Get-Paths`: Retrieves all the stored paths.
- `List-Paths`: Lists all the stored paths.
- `Create-Directories`: Creates the necessary directories for a given path.
- `Add-Path`: Adds a new path to be managed.
- `Remove-Path`: Removes a managed path.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License.
