You can use the following command to setup ssh by script.
However, I recommend you replace this with your own URL and own private key.
#
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/HealisticEngineer/Powershell/master/WindowsSSH/WindowsServerSSH.ps1'))
#
