Function New-virtualbox{
Param (
    [Parameter(Mandatory=$True)][String]$name,
    [Parameter(Mandatory=$True)][int]$RAMGB,
    [Parameter(Mandatory=$false)][int]$vcpu=2,
    [Parameter(Mandatory=$True)][int]$diskGB
)
# Convert GB to MB
$disksize = $diskGB * 1024
$memory = $RAMGB * 1024

# Step one create VM
cd "C:\Program Files\Oracle\VirtualBox\"
.\VBoxManage createvm --name "$name" --register

# modify the vm ram and network
.\VBoxManage modifyvm "$name" --memory $memory --acpi on --boot1 dvd --cpus $vcpu
.\VBoxManage modifyvm "$name" --nic1 natnetwork --nat-network1 NatNetwork
.\VBoxManage modifyvm "$name" --ostype Ubuntu_64

# create storage
.\VBoxManage createhd --filename D:\VM\$name.vdi --size $disksize --format VDI
#.\VBoxManage createhd --filename D:\VM\io.vdi --size $OS_SIZE --format VDI
.\VBoxManage storagectl "$name" --name "IDE Controller" --add ide

# attach storage
.\VBoxManage storagectl "$name" --add sata --controller IntelAHCI --name "SATA Controller"
.\VBoxManage storageattach "$name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium D:\VM\$name.vdi

# unattending install aka user name and computer name
.\VBoxManage unattended install "$name" --iso="D:\Software\ISO\ubuntu-18.04-desktop-amd64.iso" --user=john --password=johan007 --full-user-name="Tips For IT Pros" --time-zone=UTC --hostname=$name.lab.local

# start VM
.\VBoxManage startvm "$name" 
}
