Function Get-ServiceInfo {
[cmdletbinding()]
Param([string]$Computername)
$services=Get-WmiObject -Class Win32_Services -filter "state='Running" -computername $computernam
Write-Host "Found ($services.count) on $computername" -ForegroundColor Green
$sevices | sort -Property startname,name  Select -property startname,name,startmode,computername
}