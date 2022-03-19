# Input
$user = 'tipsforitpros'
$path = 'C:\temp'

# Convert service account to SID and compare
$id = (Get-ADUser $user -Server "trust.net").SID # could also use Get-ADGroup for security groups
Write-output "Value of SID : $id"
$ACL = (Get-Acl $path -ErrorAction Stop)

# Check service account has access to folder
if($ACL.Access.IdentityReference -contains $id)
{
    Write-Host "User ID $user already exists"
} else {
    # If account doesn't have access add to folder
    $rights = 'Modify' #Other options: [enum]::GetValues('System.Security.AccessControl.FileSystemRights')
    $inheritance = 'ContainerInherit, ObjectInherit' #Other options: [enum]::GetValues('System.Security.AccessControl.Inheritance')
    $propagation = 'None' #Other options: [enum]::GetValues('System.Security.AccessControl.PropagationFlags')
    $type = 'Allow' #Other options: [enum]::GetValues('System.Security.AccessControl.AccessControlType')
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($id,$rights,$inheritance,$propagation, $type)
    $acl.AddAccessRule($AccessRule)
    $acl | Set-Acl -Path "$path"
    Write-output "Verify user $user is added"
    $ACL = (Get-Acl $path -ErrorAction Stop)
    if($ACL.Access.IdentityReference -contains $id)
        {
            Write-Host "Success : User ID $user added"
        } else {
            Throw "User not added $($_.Exception.Message)"
        }
}
