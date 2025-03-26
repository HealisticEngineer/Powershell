# .NET and ASP.NET Core Update Script

This PowerShell script automates the process of retrieving installed .NET and ASP.NET Core versions, checking for updates, and downloading and installing newer versions if available.

## Features

1. **Retrieve Installed Versions**  
   The `Get-dotnet` function scans specific directories to identify installed versions of .NET and ASP.NET Core for both x64 and x86 platforms.

2. **Check for Updates**  
   The `Update-DotNet` function checks for newer versions of .NET or ASP.NET Core by querying the official Microsoft Azure feed.

3. **Download and Install Updates**  
   The `Start-dotnetupgrade` function downloads the update files and installs them silently.

4. **Automated Workflow**  
   The script sets the working directory to `c:\temp`, retrieves installed versions, checks for updates, and installs them if available.

## Prerequisites

- PowerShell 5.1 or later.
- Administrative privileges to install updates.
- Internet access to download updates from the Microsoft Azure feed.

## Usage

1. **Run the Script**  
   Execute the script in PowerShell with administrative privileges:
   ```powershell
   .\dotnet_update.ps1
   ```

2. **Functions Overview**  
   - `Get-dotnet`: Retrieves installed .NET and ASP.NET Core versions.
   - `Update-DotNet`: Checks for updates and generates download URLs.
   - `Start-dotnetupgrade`: Downloads and installs updates.

3. **Output**  
   - If updates are available, they will be downloaded and installed automatically.
   - If no updates are available, the script will terminate without further action.

## Customization

- Modify the directory paths in the `Get-dotnet` function if your .NET or ASP.NET Core installations are in non-default locations.
- Adjust the working directory by changing the `Set-Location` command.

## Notes

- Ensure that the `Start-BitsTransfer` and `Start-Process` commands are not blocked by your system's security policies.
- The script uses silent installation (`/q` argument) for updates. Modify this behavior if you prefer interactive installations.

## Disclaimer

This script is provided as-is without any warranty. Use it at your own risk. Always test scripts in a non-production environment before deploying them in production.
