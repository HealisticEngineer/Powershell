# PowerShell VirtualBox Module

This module provides PowerShell functions to manage VirtualBox virtual machines.

## Functions

### `Start-VirtualBoxConfiguration`

Sets up the environment variables and creates a lab network if it does not exist.

#### Parameters

- `virtualboxinstall` (string): Path to the VirtualBox installation directory. Default is `C:\PROGRA~1\Oracle\VirtualBox`.
- `VirtualBoxVMDirectory` (string): Path to the directory where VM images are stored. Default is `D:\VM`.
- `VirtualBoxISO` (string): Path to the directory where ISO images are stored. Default is `C:\iso`.

### `Register-VirtualBoxImage`

Imports VM images from disk and registers them with VirtualBox.

#### Parameters

- `path` (string): Path to the VM images you want to import. Optional.

### `New-VirtualBox`

Creates a new VirtualBox VM with the specified parameters.

#### Parameters

- `computername` (string): Name of the VM Guest you are creating.
- `vCPU` (uint): Number of virtual CPUs. Value cannot be negative or higher than 32.
- `RAM` (uint): Amount of RAM in MB. Value cannot be negative or higher than 128.
- `Storage` (uint): Amount of storage in GB. Value cannot be negative or higher than 512 or lower than 20. Default is 20.
- `type` (string): Type of OS. Must be one of the predefined types.
- `iso` (string): Name of the ISO file to use.
- `imageindex` (uint): ISO image number. Default is 1.

## Usage

1. Run `Start-VirtualBoxConfiguration` to set up the environment variables and create the lab network.
2. Use `Register-VirtualBoxImage` to import and register VM images from disk.
3. Create a new VM using `New-VirtualBox` with the desired parameters.

## Example

```powershell
# Set up the environment
Start-VirtualBoxConfiguration -virtualboxinstall "C:\Program Files\Oracle\VirtualBox" -VirtualBoxVMDirectory "D:\VM" -VirtualBoxISO "C:\iso"

# Register VM images
Register-VirtualBoxImage -path "D:\VM\Images"

# Create a new VM
New-VirtualBox -computername "testvm" -vCPU 2 -RAM 2048 -Storage 50 -type "Ubuntu" -iso "ubuntu-20.04.iso"