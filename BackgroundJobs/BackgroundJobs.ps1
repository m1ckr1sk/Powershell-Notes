#Enable-PSRemoting

Start-Job -ScriptBlock {Get-ChildItem c:\ -Recurse} -Name LocalDir

Invoke-Command -ScriptBlock { Get-EventLog -LogName Security -Newest 100 } `
  -ComputerName machine1,machine2 -JobName RemoteLogs

Get-Job

Get-Job -Name LocalDir | Stop-Job

Receive-Job -Name LocalDir

Wait-Job -name RemoteLogs

Get-Job

$Id = Get-Job -Name RemoteLogs -IncludeChildJob | Where-Object location -EQ 'machine1' | select -ExpandProperty ID

Get-Job -ID $Id | Receive-Job -keep

Receive-Job -Name RemoteLogs

Remove-Job -Name RemoteLogs
Remove-Job -Name LocalDir