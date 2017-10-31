function Get-OSInfo{
    Param(
        [string]$computerName = 'localhost'
    )
    Get-CimInstance -ClassName Win32_OperatingSystem `
                    -ComputerName $computerName
}

function Get-ComputerInfo{
    Param(
        [string]$computerName = 'localhost'
    )
    Get-CimInstance -ClassName Win32_ComputerSystem `
                    -ComputerName $computerName
}

function Get-BIOSInfo{
    Param(
        [string]$computerName = 'localhost'
    )
    Get-CimInstance -ClassName Win32_BIOS `
                    -ComputerName $computerName
}

function Get-DiskInfo{
    Param(
        [string]$computerName = 'localhost'
    )
    Get-CimInstance -ClassName win32_logicaldisk `
                    -ComputerName $computerName `
                    -F "DriveType=3"
}

function Get-ServiceInfo{
    Param(
        [string]$computerName = 'localhost'
    )
    Get-CimInstance -ClassName win32_Service `
                    -ComputerName $computerName `
                    -Filter "State='Running'"
}

function Get-AdminPasswordStatusText{
    Param(
        [string]$adminPasswordStatusNumber
        )
    switch($adminPasswordStatusNumber){
        0 {$adminPasswordStatus = "Disabled" }
        1 {$adminPasswordStatus = "Enabled" }
        2 {$adminPasswordStatus = "NA" }
        3 {$adminPasswordStatus = "unknown" }
        }
    $adminPasswordStatus
}

function Get-DisksHash{
    Param(
        $diskInfo
    )
    $disks = @()
    foreach($disk in $diskInfo) {
      $diskProps = @{'Freespace'=($disk.FreeSpace/1GB).tostring("#.##"); `
                         'Size'=($disk.Size/1GB).tostring("#.##"); 
                         'DeviceID'=$disk.DeviceID;} 
      $diskObj = New-Object -TypeName PSObject -Property $diskProps  
      $disks += $diskObj
    }
    $disks
}

function Get-ServicesHash{
    Param(
        $serviceInfo
    )
    $services = @()
    foreach($service in $serviceInfo) {
      $serviceProps = @{'ProcessName'=$service.Name; `
                        'DisplayName'=$service.DisplayName;
                        'ProcessId'=$service.ProcessId;} 
      $serviceObj = New-Object -TypeName PSObject -Property $serviceProps 
      $services += $serviceObj
    }
    $services
}

function Get-MachineData{
    [CmdletBinding()]
    Param(
        [string[]]$computerNames = 'localhost',
        [string]$errorLog = 'C:\Errors.txt',
        [string]$logLevel = 'Error'
    )
    # Begin runs once for each object sent to the fucntion
    BEGIN{}

    # Process runs for each object sent to the fucntion
    PROCESS{
      Write-Output $computerNames
      Write-Output $errorLog
      foreach($computerName in $computerNames){
        $osInfo = Get-OSInfo -computerName $computerName
        $compInfo = Get-ComputerInfo -computerName $computerName
        $biosInfo = Get-BIOSInfo -computerName $computerName
        $diskInfo = Get-DiskInfo -computerName $computerName
        $serviceInfo = Get-ServiceInfo -computerName $computerName
        
        $disksHash = Get-DisksHash -diskInfo $diskInfo
        $servicesHash = Get-ServicesHash -serviceInfo $serviceInfo
        $adminPasswordStatusText = Get-AdminPasswordStatusText -adminPasswordStatusNumber $compInfo.adminpasswordstatus  
        
                   
        $props = @{'ComputerName'=$computerName; `
                   'OSVersion'=$osInfo.version; `
                   'SPVersion'=$osInfo.servicepackmajorversion; `
                   'BIOSSerial'=$biosInfo.serialnumber; `
                   'Manufacturer'=$compInfo.manufacturer; `
                   'Model'=$compInfo.model; `  
				   'AdminPasswordStatus'=$adminPasswordStatusText; `  
                   'Disks' = $disksHash; `
                   'RunningServices' = $servicesHash;}

        $computerObj = New-Object -TypeName PSObject -Property $props

        Write-Output $computerObj
      }
    }

    # End runs once for each object sent to the fucntion
    END{}
}

Get-MachineData -computerName 'localhost' -errorLog 'C:\Users\MButt\Source\powershell-training\errorlog.txt'