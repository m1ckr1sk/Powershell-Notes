Function Get-ServiceInfo {
  [cmdletbinding()]
  Param(
    [string]$Computername
  )
  $services=Get-CimInstance -Class win32_Service -filter "state='Running'" -computername $computername
  Write-Output "Found $($services.count) on $computername" -ForegroundColor Green
  $services | Sort-Object -Property startname,name  | Select-Object -property startname,name,startmode,computername
}

Get-ServiceInfo -Computername 'localhost'