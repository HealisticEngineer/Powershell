# Uninstall Software Script

This PowerShell script provides functionality to list installed software and uninstall specific software from a Windows system.

## Features

1. **List Installed Software**  
   The `Get-InstalledSoftware` function retrieves a list of all installed software on the system.

2. **Uninstall Software**  
   The `Uninstall-Software` function allows you to uninstall specific software by name. It supports optional uninstall switches for silent or custom uninstallation.

## Usage

### Prerequisites
- Run the script with administrative privileges.
- Ensure PowerShell is installed on your system.

### Functions

#### `Get-InstalledSoftware`
Lists all installed software on the system.

```powershell
Get-InstalledSoftware
```

#### `Uninstall-Software`
Uninstalls a specific software by name.

**Parameters:**
- `-SoftwareName` (Mandatory): The name of the software to uninstall.
- `-uninstallswitch` (Optional): A custom uninstall switch (e.g., `/quiet` for silent uninstallation).

**Example Usage:**

1. Uninstall software without a custom switch:
   ```powershell
   Uninstall-Software -SoftwareName "Microsoft Visual C++ 2010"
   ```

2. Uninstall software with a custom switch:
   ```powershell
   Uninstall-Software -SoftwareName "Microsoft Visual C++ 2010" -uninstallswitch "/quiet"
   ```

## Notes
- The script automatically escapes special characters like `++` in software names.
- After uninstallation, the script verifies if the software has been successfully removed and provides feedback.

## Disclaimer
Use this script with caution. Ensure you are uninstalling the correct software to avoid accidental removal of critical applications.