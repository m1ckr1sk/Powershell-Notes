Import PSScheduledJob

Get-job | Remove-Job

$trigger = New-JobTrigger -Once -At (Get-Date).AddSeconds(30)

Register-ScheduledJob -Trigger $trigger -Name DemoJob -ScriptBlock { Get-EventLog -LogName Application}

Get-ScheduledJob | Select-Object -Expand JobTriggers

Get-ScheduledJob

Get-Job

Receive-Job -Name DemoJob

Get-Job -Name DemoJob | Remove-Job

Get-ScheduledJob | Unregister-ScheduledJob