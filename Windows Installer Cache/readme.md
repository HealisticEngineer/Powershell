# Restore-InstallerFiles.ps1

## Description

`Restore-InstallerFiles.ps1` is a PowerShell script designed to restore missing Windows Installer Package (`*.msi`) and Patch (`*.msp`) files from another source folder(s) or machine(s). This script helps fix issues related to missing installer files by identifying and restoring them from specified locations.

## Author

- **Name:** Ahmad Gad
- **Contact Email:** [ahmad.gad@jemmpress.com](mailto:ahmad.gad@jemmpress.com), [ahmad.adel@jemmail.com](mailto:ahmad.adel@jemmail.com)
- **Website:** [http://ahmad.jempress.com](http://ahmad.jempress.com)

## Requirements

- **Minimum PowerShell Version:** 2.0
- **Minimum CLR Version:** 2.0

## Parameters

- **`SourceMachine`** (Alias: `M`): The name of the source machine(s) where the script can find the missing files and restore them to the target machine with the correct names. This parameter is mandatory if `SourceFolder` is not specified.
- **`SourceFolder`** (Alias: `F`): The source folder(s) where the script can find the missing files and restore them to the target machine with the correct names. This parameter is mandatory if `SourceMachine` is not specified.
- **`ScanOnly`** (Alias: `S`): Only scan for the missing files and display them without attempting to fix. This parameter is mandatory and cannot be combined with `SourceMachine` or `SourceFolder`.
- **`LogFile`** (Alias: `L`): The location of the output transcript logging file. This parameter is optional.

## Usage

### Examples

1. Restore missing files from specified machines:
    ```powershell
    .\Restore-InstallerFiles.ps1 -SourceMachine "Machine1", "Machine2", "Machine3"
    ```

2. Restore missing files from specified folders:
    ```powershell
    .\Restore-InstallerFiles.ps1 -SourceFolder "D:\InstallerFiles", "E:\InstallerFiles", "\\MachineX\D$\MSI Files"
    ```

3. Restore missing files from specified folders with logging:
    ```powershell
    .\Restore-InstallerFiles.ps1 -SourceFolder "D:\InstallerFiles", "E:\InstallerFiles", "D:\InstallerFiles2" -LogFile "D:\Log.txt"
    ```

4. Scan only for missing files and display them:
    ```powershell
    .\Restore-InstallerFiles.ps1 -ScanOnly
    ```

5. Scan only for missing files with verbose output and logging:
    ```powershell
    .\Restore-InstallerFiles.ps1 -ScanOnly -Verbose -LogFile "D:\Log.txt"
    ```

## Functions

### Public Functions

- **`Restore-InstallerFiles`**: Main function to restore missing installer files.

### Private Functions

- **`Copy-MissingFiles`**: Copies missing files from the source to the destination.
- **`Copy-TheMissingFile`**: Helper function to copy a single missing file.
- **`Get-MissingFiles`**: Retrieves the list of missing files.
- **`Get-FileSubject`**: Gets the subject property of a file.
- **`Get-FileRevisionNumber`**: Gets the revision number of a file.
- **`Get-ProductCodeGuid`**: Converts a compressed GUID to a standard GUID format.
- **`Assert-LogFile`**: Validates and creates the log file.
- **`Start-Logging`**: Starts logging the script output.
- **`Stop-Logging`**: Stops logging the script output.

## License

This script is provided as-is without any warranty. Use at your own risk.

For further details, please run:
```powershell
Get-Help .\Restore-InstallerFiles.ps1 -Detailed
```