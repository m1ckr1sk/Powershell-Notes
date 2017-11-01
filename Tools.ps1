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
    <#
    .SYNOPSIS
    Retrieves key system version and model information from one to ten computers.

    .DESCRIPTION
    Get-MachineData uses Common Information Model (CIM)  to access information 
    from one to ten computers by name or IP address.

    .PARAMETER computerNames
    One or more computer names or IP address up to a maximum of 10.

    .PARAMETER errorLog
    When used with -logErrors, can be used to specify the location of the error log.

    .PARAMETER logErrors
    Specify this switch to create a text file error log at the location specificed in -errorLog.

    .EXAMPLE
    Get-MachineData -ComputerNames 'localhost', 'WIN2012JHN' -LogErrors -ErrorLog "c:\temp\errorlog.txt

    .EXAMPLE
    Get-Content "hostnames.txt" | Get-MachineData
    #>
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   HelpMessage="Computer name or IP address")]
        [validateCount(1,10)]
        [ValidateNotNullOrEmpty()]
        [Alias('hostnames')]
        [string[]]$computerNames,
        [string]$errorLog = 'C:\Errors.txt',
        [switch]$logErrors
    )
    # Begin runs once for each object sent to the fucntion
    BEGIN{
        Write-Verbose "Error log will be $errorLog"
    }

    # Process runs for each object sent to the fucntion
    PROCESS{
      Write-Verbose "Running machine information retreival on $computerNames"

      foreach($computerName in $computerNames){
        try{
          $computerInfoSuccess = $true
          
          Write-Verbose "interrogating operating system information for $computerName ..."
          $osInfo = Get-OSInfo -computerName $computerName

          Write-Verbose "interrogating BIOS information for $computerName ..."
          $biosInfo = Get-BIOSInfo -computerName $computerName

          Write-Verbose "interrogating disk information for $computerName ..."
          $diskInfo = Get-DiskInfo -computerName $computerName

          Write-Verbose "interrogating running services information for $computerName ..."
          $serviceInfo = Get-ServiceInfo -computerName $computerName

          Write-Verbose "interrogating computer information for $computerName ..."
          $compInfo = Get-ComputerInfo -computerName $computerName

          Write-Verbose "All interrogations complete for $computerName ..."
        }
        catch{
          $msg = "Failed to get machine information for $computerName, $($_.Exception.message)"
          $computerInfoSuccess = $false
          Write-Warning $msg
          if($logErrors){
              $msg | Out-File $errorLog -Append
              Write-Warning "Written to error log $errorLog"
          }
        }

        if($computerInfoSuccess){
        
            $disksHash = Get-DisksHash -diskInfo $diskInfo
            $servicesHash = Get-ServicesHash -serviceInfo $serviceInfo
            $adminPasswordStatusText = Get-AdminPasswordStatusText -adminPasswordStatusNumber $compInfo.adminpasswordstatus  
        
                   
            $props = @{'ComputerName'=$computerName; `
                       'OSVersion'=$osInfo.version; `
                       'LastBootUpTime'=$osInfo.LastBootUpTime; `
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
    }

    # End runs once for each object sent to the fucntion
    END{}
}

#Get-MachineData -computerName 'localhost' -errorLog 'C:\Users\MButt\Source\powershell-training\errorlog.txt' -Verbose
#Get-MachineData -computerName '' -errorLog 'C:\Users\MButt\Source\powershell-training\errorlog.txt' -Verbose
#'localhost' | Get-MachineData
#'localhost','localhost' | Get-MachineData
Get-MachineData -computerName 'NO MACHINE', 'localhost','NOTONLINE' -errorLog 'C:\Users\MButt\Source\powershell-training\errorlog.txt' -LogErrors -Verbose
