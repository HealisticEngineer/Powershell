# Docker Swarm Installation Script for Ubuntu

## Overview

This PowerShell script automates the installation and configuration of Docker Swarm on Ubuntu systems. It sets up a Swarm Manager and joins multiple Swarm Workers to the cluster.

## Prerequisites

- PowerShell installed on your system.
- SSH access to all target Ubuntu machines.
- Ensure the target machines have internet access to download Docker.

## Parameters

| Parameter      | Description                              | Example               |
|----------------|------------------------------------------|-----------------------|
| `-Username`    | SSH username for the target machines.    | `tipsforitpros`       |
| `-SwarmManager`| IPv4 address of the Swarm Manager.       | `10.0.0.10`           |
| `-SwarmWorkers`| Array of IPv4 addresses for the workers. | `10.0.0.11,10.0.0.12` |

## Usage

Run the script using the following syntax:

```powershell
install-dockerswarm -Username <SSHUsername> -SwarmManager <ManagerIP> -SwarmWorkers <WorkerIP1>,<WorkerIP2>
```

### Example

```powershell
install-dockerswarm -Username tipsforitpros -SwarmManager 10.0.0.10 -SwarmWorkers 10.0.0.11,10.0.0.12
```

This example sets up a Docker Swarm cluster with `10.0.0.10` as the manager and `10.0.0.11` and `10.0.0.12` as workers.

## How It Works

1. Installs Docker on the Swarm Manager and initializes the Swarm.
2. Retrieves the Swarm join token and manager IP.
3. Installs Docker on each worker and joins them to the Swarm using the token and manager IP.

## Notes

- Ensure the provided IP addresses are valid and reachable.
- The script assumes passwordless SSH access is configured for the provided username.

## License

This script is provided as-is without any warranty. Use at your own risk.