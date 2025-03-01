#Requires -Version 7.4

#https://mcpmag.com/articles/2017/03/16/submit-module-to-the-powershell-gallery.aspx


Function Start-VirtualBoxConfiguration {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory=$false)]
    [string]$virtualboxinstall="C:\PROGRA~1\Oracle\VirtualBox",
    [Parameter(Mandatory=$false)]
    [string]$VirtualBoxVMDirectory="D:\VM",
    [Parameter(Mandatory=$false)]
    [string]$VirtualBoxISO="C:\iso"
  )
  # Set environment variables
  [System.Environment]::SetEnvironmentVariable('VBImage', "$VirtualBoxVMDirectory",[System.EnvironmentVariableTarget]::User)
  [System.Environment]::SetEnvironmentVariable('VBPath', "$virtualboxinstall",[System.EnvironmentVariableTarget]::User)
  [System.Environment]::SetEnvironmentVariable('VBISO', "$VirtualBoxISO",[System.EnvironmentVariableTarget]::User)
  
  # make them live now
  $env:VBImage = [System.Environment]::GetEnvironmentVariable("VBImage","User")
  $env:VBPath = [System.Environment]::GetEnvironmentVariable("VBPath","User")
  $env:VBISO = [System.Environment]::GetEnvironmentVariable("VBISO","User")


  # Create Lab Network
  $lab = & $env:vbpath\VBoxManage.exe natnetwork list | Select-String "Labnetwork"
  if(!($lab)){
    .\VBoxManage natnetwork add --netname LabNetwork --network "172.16.1.0/24" --enable
    write-output "Labnetwork does not exist creating one."
  } else {
    write-output "Labnetwork already exists."
  }

}

# Import VMs from disk.
function Register-VirtualBoxImage {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false,HelpMessage="path to VM images you want to import")][String]$path
  )
  # confirm varible exist
  if(!($env:VBISO)) {Write-Output "Please run Start-VirtualBoxConfiguration before using this command"; return }
  if(!($env:VBPath)) {Write-Output "Please run Start-VirtualBoxConfiguration before using this command"; return }
  if(!($env:VBImage)) {Write-Output "Please run Start-VirtualBoxConfiguration before using this command"; return }
  
  get-childitem $env:VBImage -Recurse -filter *.vbox | foreach-object {
    & $env:vbpath\VBoxManage registervm $_ 2>&1 > $null
  }
  if($path){
    get-childitem $path -Recurse -filter *.vbox | foreach-object {
      & $env:vbpath\VBoxManage registervm $_ 2>&1 > $null
    }
  }
}

Function New-VirtualBox {
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,HelpMessage="Name of the VM Guest you are creating")][ValidatePattern("^[a-z][a-z0-9]*$")][String]$computername,
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,HelpMessage="Value can not be a negative or higher than 32")][ValidateRange(1,32)][uint]$vCPU,
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,HelpMessage="Value can not be a negative or higher than 128")][ValidateRange(1,128)][uint]$RAM,
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,HelpMessage="Value can not be a negative or higher than 512 or lower then 20")][ValidateRange(20,512)][uint]$Storage=20,
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,HelpMessage="type of OS")][ValidateSet([type])][string]$type,
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$True,HelpMessage="Name of the ISO file to use")][ValidateSet([iso])][string]$iso,
    [Parameter(ValueFromPipelineByPropertyName,Mandatory=$false,HelpMessage="Iso image number")][ValidateRange(1,5)][uint]$imageindex = 1
  )

  # Check block
  if(!($env:VBISO)) {Write-Output "Please run Start-VirtualBoxConfiguration before using this command"; return }
  if(!($env:VBPath)) {Write-Output "Please run Start-VirtualBoxConfiguration before using this command"; return }
  if(!($env:VBImage)) {Write-Output "Please run Start-VirtualBoxConfiguration before using this command"; return }

  # Step one create VM
  & $env:vbpath\VBoxManage createvm --name "$computername" --register --ostype "$type"
  # modify the vm ram, cpu and network
  & $env:vbpath\VBoxManage modifyvm "$computername" --memory ($RAM * 1024) --ioapic on --acpi on --boot1 dvd --cpus $vCPU --vram 128
  & $env:vbpath\VBoxManage modifyvm "$computername" --nictype1 82540EM --nic1 natnetwork --nat-network1 LabNetwork
  # create storage
  & $env:vbpath\VBoxManage createhd --filename $env:VBImage\$computername\$computername.vdi --size ($Storage * 1024) --format VDI
  # attach storage
  & $env:vbpath\VBoxManage storagectl "$computername" --add sata --controller IntelAHCI --name "SATA Controller"
  & $env:vbpath\VBoxManage storageattach "$computername" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $env:VBImage\$computername\$computername.vdi
  # unattending install aka user name and computer name
  if($type -match "Ubuntu") {Write-Output "OS is Ubuntu"
    $command = "sudo su -c 'bash <(wget -qO- https://raw.githubusercontent.com/HealisticEngineer/Ubuntu/master/ssh/configure.sh)' root"
  }
  if($type -match "Windows") {
    $command = @"
powershell.exe -NoProfile -InputFormat None -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" 
"@

  }
  & $env:vbpath\VBoxManage unattended install "$computername" --iso=$env:VBISO\$iso --user=tipsforitpros `
  --password=NeverSafe2Day --full-user-name="Tips For IT Pros" --country=GB --time-zone=UTC --hostname=$computername.lab.local `
  --post-install-command="$command" --image-index=$imageindex
  # start VM
  & $env:vbpath\VBoxManage startvm "$computername"
}

Export-ModuleMember -Function New-VirtualBox, Register-VirtualBoxImage, Start-VirtualBoxConfiguration