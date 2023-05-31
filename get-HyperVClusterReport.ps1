$cluster=get-cluster
$filepath="C:\$cluster-ClusterVMReport.csv"

Write-host "Collecting below cluster node information........."
Get-ClusterNode | Select-Object @{label = 'VM Name'; expression = { $_.Name } }
Write-Host "Generating "$cluster.name" VM list....... Check path $filepath"

Get-VM –ComputerName (Get-ClusterNode) | `
% { $VMinst = Get-VHD -ComputerName $_.ComputerName -VmId $_.VmId; $VMinst | `
Add-Member -NotePropertyName "Name" -NotePropertyValue $_.Name; $VMinst | `
Add-Member -NotePropertyName "ProcessorCount" -NotePropertyValue $_.ProcessorCount; $VMinst | `
Add-Member -NotePropertyName "MemoryStartup" -NotePropertyValue $_.MemoryStartup; $VMinst | `
Add-Member -NotePropertyName "NetworkAdapters" -NotePropertyValue $_.NetworkAdapters.IPAddresses; $VMinst | `
Add-Member -NotePropertyName "State" -NotePropertyValue $_.state; $VMinst } | `
Select-Object @{label = 'VM Name'; expression = { $_.Name } }, @{label = 'vCPU'; expression = { $_.ProcessorCount } }, `
@{label = 'vMem (GB)'; expression = { $_.MemoryStartup / 1gb –as [int] } }, `
@{label = 'IP Addresses'; expression = { $_.NetworkAdapters } }, @{label = 'Host Name'; expression = { $_.ComputerName } }, `
Path, VhdFormat, VhdType, @{label = 'Datastore (GB)'; expression = { $_.FileSize / 1gb –as [int] } }, `
@{label = 'Max Disk Size (GB)'; expression = { $_.Size / 1gb –as [int] } }, `
@{label = 'Remaining Space (GB)'; expression = { ($_.Size / 1gb - $_.FileSize / 1gb) –as [int] } }, `
@{label = 'State'; expression = { ($_.State) } } | `
Export-Csv -Path $filepath -NoTypeInformation
