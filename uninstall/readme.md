# Uninstall.ps1

This PowerShell script is used to uninstall specific software packages from a Windows machine. It targets both x86 and x64 versions of the software.

## Usage

1. Open PowerShell with administrative privileges.
2. Navigate to the directory containing the `Uninstall.ps1` script.
3. Execute the script:
    ```powershell
    .\Uninstall.ps1
    ```

## Script Details

The script performs the following tasks:

1. **Get a list of installed software**:
    ```powershell
    $list = Get-WmiObject -Class Win32_Product | Select-Object -Property Name
    ```

2. **Loop over the packages to remove**:
    ```powershell
    foreach ($i in ($list.name -cmatch "Microsoft Visual C\++ 2010")) {
        $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$i"}
        $MyApp.Uninstall()
    }
    ```

3. **Cross-check if the package is uninstalled**:
    ```powershell
    if(Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$i"} -eq $null) {
        write-output "Package is not present"
    } else {
        write-output "package still installed"
    }
    ```

## Notes

- Ensure you have the necessary administrative privileges to uninstall software.
- Modify the script to target different software packages by changing the `-cmatch` pattern.

## License

This script is provided as-is without any warranty. Use at your own risk.