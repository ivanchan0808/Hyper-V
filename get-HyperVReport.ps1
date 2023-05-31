$computername=hostname
$filepath="C:\$computername-VHDReport.csv"
Write-Host Generating $computername VM list....... Check path $filepath

Get-VM | `
% { $vhd = Get-VHD -ComputerName $_.ComputerName -VmId $_.VmId; $vhd | `
Add-Member -NotePropertyName "Name" -NotePropertyValue $_.Name; $vhd | `
Add-Member -NotePropertyName "ProcessorCount" -NotePropertyValue $_.ProcessorCount; $vhd | `
Add-Member -NotePropertyName "MemoryStartup" -NotePropertyValue $_.MemoryStartup; $vhd | `
Add-Member -NotePropertyName "NetworkAdapters" -NotePropertyValue $_.NetworkAdapters.IPAddresses; $vhd | `
Add-Member -NotePropertyName "State" -NotePropertyValue $_.state; $vhd } | `
Select-Object @{label = 'VM Name'; expression = { $_.Name } }, @{label = 'vCPU'; expression = { $_.ProcessorCount } }, `
@{label = 'vMem (GB)'; expression = { $_.MemoryStartup / 1gb –as [int] } }, `
@{label = 'IP Addresses'; expression = { $_.NetworkAdapters } }, @{label = 'Host Name'; expression = { $_.ComputerName } }, `
Path, VhdFormat, VhdType, @{label = 'Size On Physical Disk (GB)'; expression = { $_.FileSize / 1gb –as [int] } }, `
@{label = 'Max Disk Size (GB)'; expression = { $_.Size / 1gb –as [int] } }, `
@{label = 'Remaining Space (GB)'; expression = { ($_.Size / 1gb - $_.FileSize / 1gb) –as [int] } }, `
@{label = 'State'; expression = { ($_.State) } } | `
Export-Csv -Path $filepath -NoTypeInformation
