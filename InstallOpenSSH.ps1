# Create folder location
New-Item -Path c:\ -Name temp -ItemType Directory
# Download openssh
(New-Object System.Net.WebClient).DownloadFile('https://github.com/PowerShell/Win32-OpenSSH/releases/download/v7.9.0.0p1-Beta/OpenSSH-Win64.zip','C:\temp\OpenSSH-Win64.zip')
# Unzip the files
Expand-Archive -Path "c:\temp\OpenSSH-Win64.Zip" -DestinationPath "C:\Program Files\OpenSSH"
# Install service
. "C:\Program Files\OpenSSH\OpenSSH-Win64\install-sshd.ps1"
# Set firewall permissions
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Set service startup
Set-Service sshd -StartupType Automatic
Start-Service sshd

# Set Authentication to public key
((Get-Content -path C:\ProgramData\ssh\sshd_config -Raw) `
-replace '#PubkeyAuthentication yes','PubkeyAuthentication yes' `
-replace '#PasswordAuthentication yes','PasswordAuthentication no' `
-replace 'Match Group administrators','#Match Group administrators' `
-replace 'AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys','#AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys') | Set-Content -Path C:\ProgramData\ssh\sshd_config

# Restart after changes
Restart-Service sshd

# force file creation
New-item -Path $env:USERPROFILE -Name .ssh -ItemType Directory -force

# Copy key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZqVWBrcbiRcmmoPnrjwB8LF/aY2Bco1mJluS22mtgxNu3pN2YeewJwjiRBhCBQqtAuR/8HmQFd6ioJbWoWKfiAVvJ9nv0+JIjMbn56C8Tf931o5kFIf/QTxbC9BHSjzl07AOZ2hUYaRnrwwZvOOEdsYkD2oCp3Z6dyGwI8DmxEf8e7YiXMoJXC+3YZaSeb7Z3ex05+0LivWNdXbrwy9TUb5t8TkSm8sIvN4nM4ntxMBC5ZlTcQMhVJqjqGUha7hPvGKl3/PT26CCZIwE9g1KkbKI9myP2iJbl0NUixXtXYH4vP/JDXKRivuaz75bAVls5JoGL6RdBiCaYYR0F+tsv john@uMac" | Out-File $env:USERPROFILE\.ssh\authorized_keys -Encoding ascii
