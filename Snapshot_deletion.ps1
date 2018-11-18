#***********************************************************************************************************************
#This script does the following:
#Connects to the given VCenter.
#Reads the list of VMs for which snapshot to be deleted.
#Deletes the snapshot that was created certain days before. 
#Date of Creation: 24th March 2017 Vinith Kumar T 
#OS Type: Windows
#Execution : .\snapshot_deletion.ps1 -VCenter vcenter -Path C:\dummypath.csv -Day 3
#************************************************************************************************************************
param(
        [Parameter(mandatory=$true)]
        [string] $VCenter,
        [Parameter(mandatory=$true)]
        [string] $Path,
        [Parameter(mandatory=$true)]
        [int] $Day
        )
$ErrorActionPreference = 'Silentlycontinue' 
$var_Log=New-Item C:\Users\vt\Desktop\Snapshot.txt -type file -force  #Log file creation 
$VM=@();
if(Test-Path -path $Path)
{ 
$VM=Get-Content -Path $Path  #Get VM server list

Add-pssnapin vmware.vimautomation.core     #Adding Snapins

$Login=(Connect-VIServer -Server $VCenter -WarningAction SilentlyContinue)    #Connecting VCenter
if($Login){
$Days = (Get-Date).AddDays(-$Day)    #Calculating days before from current date
for($i=0;$i -lt $VM.Length;$i++)
{
$VMs=Get-VM | where {$_.Name -eq $VM[$i]}
if ($VMs){
$Snapshots=(Get-VM | where {$_.Name -eq $VM[$i]} | Get-Snapshot | where {$_.Created -lt $Days}) #Checking for snapshot in VM
if($Snapshots){
Remove-Snapshot $Snapshots -Confirm:$true -ErrorVariable ErrorMessage   #Removing Snapshot
$Message='Snapshot Deleted successfully for the VM'
echo $ErrorMessage
echo $VM[$i]---$Message
echo $Snapshots
Write-Output "Snapshot name : $Snapshots" >> "C:\Users\vt\Desktop\Snapshot.txt"
Write-Output "$Message" >> "C:\Users\vt\Desktop\Snapshot.txt"
}
else {
$Message='No Snapshots Found for VM'   #Snapshot not found
echo $VM[$i]---$Message
Write-Output "$Message" >> "C:\Users\vt\Desktop\Snapshot.txt"
}
}
else {
$Message='VM Not Found'       #VM not found
echo $VM[$i]---$Message
Write-Output "$Message" >> "C:\Users\vt\Desktop\Snapshot.txt"
}
}}
else
{
$Message='Vcenter Login Failed'       #VCenter login failed
echo $Message
Write-Output "$Message" >> "C:\Users\vt\Desktop\Snapshot.txt"
}
}
else
{
Write-Host "Path containing VM deosnt exist"
}

disconnect-viserver -Server $vcenter -confirm:$false