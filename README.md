# PowerShell Scripts Collection

This repository contains a collection of PowerShell scripts for various administrative tasks, including managing VirtualBox VMs, configuring PS Remoting, setting folder permissions, and more.
This scripts and files are examples to work along with the youtube channel [Tips for IT Pros](https://www.youtube.com/c/tipsforitpros)

## Table of Contents

- [VirtualBox](#virtualbox)
- [PS Remoting](#ps-remoting)
- [Folder Permissions](#folder-permissions)
- [SQL Server Build](#sql-server-build)
- [Universal Dashboard](#universal-dashboard)
- [Install OpenSSH](#install-openssh)
- [WMI Explorer](#wmi-explorer)
- [Windows SSH](#windows-ssh)

## VirtualBox

### Functions

#### `Start-VirtualBoxConfiguration`

Sets up the environment variables and creates a lab network if it does not exist.

**Parameters:**

- `virtualboxinstall` (string): Path to the VirtualBox installation directory. Default is `C:\PROGRA~1\Oracle\VirtualBox`.
- `VirtualBoxVMDirectory` (string): Path to the directory where VM images are stored. Default is `D:\VM`.
- `VirtualBoxISO` (string): Path to the directory where ISO images are stored. Default is `C:\iso`.

#### `Register-VirtualBoxImage`

Imports VM images from disk and registers them with VirtualBox.

**Parameters:**

- `path` (string): Path to the VM images you want to import. Optional.

#### `New-VirtualBox`

Creates a new VirtualBox VM with the specified parameters.

**Parameters:**

- `computername` (string): Name of the VM Guest you are creating.
- `vCPU` (uint): Number of virtual CPUs. Value cannot be negative or higher than 32.
- `RAM` (uint): Amount of RAM in MB. Value cannot be negative or higher than 128.
- `Storage` (uint): Amount of storage in GB. Value cannot be negative or higher than 512 or lower than 20. Default is 20.
- `type` (string): Type of OS. Must be one of the predefined types.
- `iso` (string): Name of the ISO file to use.
- `imageindex` (uint): ISO image number. Default is 1.

## PS Remoting

### Scripts

#### `Red.ps1`

Configures PS Remoting over HTTPS, creates a self-signed certificate, and sets up firewall rules.

## Folder Permissions

### Scripts

#### `readonly.ps1`

Sets read-only permissions on a specified folder for a specified user.

## SQL Server Build

### Scripts

#### `sqlserverbuild.ps1`

Checks and updates SQL Server builds to the latest version.

## Universal Dashboard

### Scripts

#### `iis_script.ps1`

Configures IIS for Universal Dashboard, including enabling Windows authentication and deploying a test dashboard.

## Install OpenSSH

### Scripts

#### `InstallOpenSSH.ps1`

Installs and configures OpenSSH on Windows, including setting up firewall rules and configuring public key authentication.

## WMI Explorer

### Scripts

#### `WMIExplorer.ps1`

Provides a GUI for exploring WMI classes and instances.

## Windows SSH

### Scripts

#### `WindowsServerSSH.ps1`

Configures SSH on Windows Server, including setting up firewall rules and configuring public key authentication.

## Usage

1. Clone the repository.
2. Navigate to the script you want to use.
3. Run the script in PowerShell with the required parameters.

## License

This project is licensed under the MIT License.