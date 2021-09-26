# inputs
$username = 'j.smith'
$folder = "C:\Example\Folder1"

# step 1) get folder permissions
$acl = get-acl $folder
$groups = $acl.access.where({$_.filesystemrights -match "ReadAndExecute" -AND $_.IdentityReference -notmatch "BUILTIN" -AND $_.IdentityReference -notmatch "$env:COMPUTERNAME" })

# step 2) create group and set permission on folder if not exist
if(!($groups)){
    # Create Group
    $name = $folder -replace ':\\','_' -replace '\\','_'
    $SAM = (-join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_}))
    New-ADGroup -Name "Read only $name" -SamAccountName $SAM -GroupCategory Security -GroupScope Global `
    -DisplayName "Read only $name" -Path "OU=Zurich,OU=Office,DC=Lab,DC=net" -Description "Members of this group have Read only to $name"
    # Set Permissions on folder
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("LAB\$SAM", "ReadAndExecute", "ContainerInherit, ObjectInherit","None","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl $folder
}

# if group was created use group name
if(!($groups)){
    $group = "$SAM"
}
# if group already exists then use group name
If($groups){
    # picking first group if more than one
    $group = ($groups[0].IdentityReference.value -split('\\'))[1]
}
# Step 3) checking if the user isn't already a member of the group
$user = Get-ADGroupMember -Identity $group | Where-Object {$_.SamAccountName -eq $username}
if($user){
    Write-output 'already member no action needed'
 }else{
    Add-ADGroupMember -Identity $group -Members $username
}
