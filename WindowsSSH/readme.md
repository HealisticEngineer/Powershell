## Prerequisites

Before running the script, ensure you have the following prerequisites:

1. **Windows PowerShell**: The script is designed to run on Windows PowerShell.
2. **Administrator Privileges**: You need to run the PowerShell session as an administrator.
3. **Internet Access**: The script downloads necessary components from the internet.

## Script Details

The script performs the following actions:

1. **Install OpenSSH Client and Server**: It checks if the OpenSSH Client and Server are installed, and installs them if they are not.
2. **Start and Configure SSH Service**: It starts the SSH service and sets it to start automatically with the system.
3. **Configure Firewall**: It creates a firewall rule to allow SSH traffic.
4. **Set Default Shell**: Optionally sets PowerShell as the default shell for SSH.
5. **Configure SSH Keys**: Downloads a public key and configures it for SSH authentication.
6. **Update SSH Configuration**: Modifies the SSH configuration to enable public key authentication and disable password authentication.
7. **Restart SSH Service**: Restarts the SSH service to apply the changes.

## Usage

To use the script, open a PowerShell session with administrator privileges and run the following command:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/HealisticEngineer/Powershell/main/WindowsSSH/WindowsServerSSH.ps1'))
```

## Notes

- **Security**: Replace the URL and key in the script with your own to ensure security.
- **Customization**: You can customize the script to fit your specific requirements.

## Troubleshooting

If you encounter any issues, ensure that:

- You have internet access.
- You are running PowerShell as an administrator.
- The URLs used in the script are accessible.

For further assistance, refer to the official documentation or seek help from the community.