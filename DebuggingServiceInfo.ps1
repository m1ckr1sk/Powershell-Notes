Function Get-ServiceInfo {
  [cmdletbinding()]
  Param(
    [string]$Computername
  )
  $services=Get-WmiObject -Class win32_Service -filter "state='Running'" -computername $computername
  Write-Host "Found ($services.count) on $computername" -ForegroundColor Green
  $services | sort -Property startname,name  | Select -property startname,name,startmode,computername
}

Get-ServiceInfo -Computername 'localhost'