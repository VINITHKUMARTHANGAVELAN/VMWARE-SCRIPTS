***********************************************************************************************************************
#This script does the following:
#Connects to VCenter server.
#Checks for Snapshot Alerts(Red Colour) in the VCenter. Ignores Snapshot warnings(Yellow).
#Checks for VMs that generated the snapshot alerts.
#Checks for the snapshots in the VMs and delete them all.
#Date of Creation: 9th OCT 2018 Vinith Kumar T 
#OS Type: Windows
#Execution: .\SnapshotDeleteFromAlerts.ps1 -VCenter vcenter
#************************************************************************************************************************
param($VCenter)
try{
Add-Pssnapin vmware.vimautomation.core
$c=Connect-VIServer -Server $VCenter -User "user" -Password "password" -ErrorAction "Stop" #Connects to VCenter
 
$VMs=Get-View -ViewType VirtualMachine -Property Name,OverallStatus,TriggeredAlarmState,Snapshot -ErrorAction "Stop"
$FaultyVMs=$VMs | where-object {$_.overallstatus -eq "RED"} #Get VMs that generated Red Alerts
$count=0;
foreach($FaultyVM in $FaultyVMs){
foreach($TriggeredAlarm in $FaultyVM.triggeredalarmstate){
$AlarmId=$TriggeredAlarm.alarm.tostring()
 
 
$AlarmCheck=(Get-AlarmDefinition -id $AlarmId -ErrorAction "Stop").Name       
 
 
if($AlarmCheck -match "SNAPSHOT_VM")   #Check if the alert is due to snapshot
{
$count=$count+1;
$v=$FaultyVM.Name
$Snapshot=Get-Snapshot -VM $FaultyVM.Name -ErrorAction "Stop"
if($Snapshot)
{
Write-Host "SNAPSHOT FOUND FOR VM $v : "
(Get-Snapshot -VM $FaultyVM.Name -ErrorAction "Stop").Name    #List out snapshots in vm
Remove-Snapshot $Snapshot -Confirm:$false -ErrorVariable Remove  #Removes all snapshot
if($Remove.count -gt 0) 
{
Write-Host "SNAPSHOT FOUND AND NOT DELETED FOR THE VM : $v "
}
else
{
Write-Host "SNAPSHOT FOUND AND SUCCESSFULLY REMOVED FOR THE VM : $v "
}

 
}
else
{
Write-Host "NO SNAPSHOT FOUND FOR THE VM : $v"
}
 
}
if($count -le 0)
{
 
Write-Host "SNAPSHOT_VM ALERT NOT FOUND FOR THE VCENTER : $VCenter"
}
}
}
 
Disconnect-Viserver -Server $VCenter -confirm:$false  #disconnects VCenter
}
catch
{
$_.exception.message
 
}
