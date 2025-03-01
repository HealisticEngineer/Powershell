# Folder Permissions Scripts

This directory contains PowerShell scripts for managing folder permissions. The scripts are designed to automate the process of setting read-only permissions and modifying access across domains.

## Scripts

### `readonly.ps1`

This script sets read-only permissions on a specified folder for a specified user.

#### Usage

1. Open PowerShell with administrative privileges.
2. Navigate to the directory containing the `readonly.ps1` script.
3. Execute the script:
    ```powershell
    .\readonly.ps1
    ```

#### Script Details

- **Inputs**:
  - `$username`: The username to grant read-only access (e.g., `'j.smith'`).
  - `$folder`: The path to the folder (e.g., `"C:\Example\Folder1"`).

- **Steps**:
  1. Get the current folder permissions.
  2. Create a security group and set read-only permissions on the folder if the group does not exist.
  3. Check if the user is already a member of the group and add the user if not.

### [CrossDomainModify.ps1](http://_vscodecontentref_/1)

This script modifies folder permissions to grant a specified user modify access, even if the user is from a different domain.

#### Usage

1. Open PowerShell with administrative privileges.
2. Navigate to the directory containing the [CrossDomainModify.ps1](http://_vscodecontentref_/2) script.
3. Execute the script:
    ```powershell
    .\CrossDomainModify.ps1
    ```

#### Script Details

- **Inputs**:
  - `$user`: The username to grant modify access (e.g., `'tipsforitpros'`).
  - `$path`: The path to the folder (e.g., `'C:\temp'`).

- **Steps**:
  1. Convert the user account to a SID and compare it with existing permissions.
  2. Check if the user already has access to the folder.
  3. If the user does not have access, add modify permissions for the user to the folder.

## License

This project is licensed under the MIT License.