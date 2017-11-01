Function Get-ComputerData {

<#
.SYNOPSIS
Get computer related data

.DESCRIPTION
This command will query a remote computer and return a custom object
with system information pulled from WMI. Depending on the computer
some information may not be available.

.PARAMETER Computername
The name of a computer to query. The account you use to run this function
should have admin rights on that computer.

.PARAMETER ErrorLog
Specify a path to a file to log errors. The default is C:\Errors.txt

.EXAMPLE
PS C:\> Get-ComputerData Server01

Run the command and query Server01.

.EXAMPLE
PS C:\> get-content c:\work\computers.txt | Get-ComputerData -Errorlog c:\logs\errors.txt

This expression will go through a list of computernames and pipe each name
to the command. Computernames that can't be accessed will be written to
the log file.

#>

[cmdletbinding()]

 param(
 [Parameter(Position=0,ValueFromPipeline=$True)]
 [ValidateNotNullorEmpty()]
 [string[]]$ComputerName,
 [string]$ErrorLog="C:\Errors.txt"
 )

 Begin {
    Write-Verbose "Starting Get-Computerdata"
 }

Process {
    foreach ($computer in $computerName) {
        Write-Verbose "Getting data from $computer"
        Try {
            Write-Verbose "Win32_Computersystem"
            $cs = Get-WmiObject -Class Win32_Computersystem -ComputerName $Computer -ErrorAction Stop

            #decode the admin password status
            Switch ($cs.AdminPasswordStatus) {            
                1 { $aps="Disabled" }
                2 { $aps="Enabled" }
                3 { $aps="NA" }
                4 { $aps="Unknown" }
            }

            #Define a hashtable to be used for property names and values
            $hash=@{
                Computername=$cs.Name
                Workgroup=$cs.WorkGroup
                AdminPassword=$aps
                Model=$cs.Model
                Manufacturer=$cs.Manufacturer
            }

        } #Try

        Catch {

            #create an error message 
            $msg="Failed getting system information from $computer. $($_.Exception.Message)"
            Write-Error $msg 

            Write-Verbose "Logging errors to $errorlog"
            $computer | Out-File -FilePath $Errorlog -append
            
			} #Catch

        #if there were no errors then $hash will exist and we can continue and assume
        #all other WMI queries will work without error
        If ($hash) {
            Write-Verbose "Win32_Bios"
            $bios = Get-WmiObject -Class Win32_Bios -ComputerName $Computer 
            $hash.Add("SerialNumber",$bios.SerialNumber)

            Write-Verbose "Win32_OperatingSystem"
            $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
            $hash.Add("Version",$os.Version)
            $hash.Add("ServicePackMajorVersion",$os.ServicePackMajorVersion)

            #create a custom object from the hash table
            $obj=New-Object -TypeName PSObject -Property $hash
			#add a type name to the custom object
        	$obj.PSObject.TypeNames.Insert(0,'MOL.ComputerSystemInfo')
			
			Write-Output $obj
            #remove $hash so it isn't accidentally re-used by a computer that causes
            #an error
            Remove-Variable -name hash
        } #if $hash
    } #foreach
} #process

 End {
    Write-Verbose "Ending Get-Computerdata"
 }
}

Function Get-VolumeInfo {

<#
.SYNOPSIS
Get information about fixed volumes

.DESCRIPTION
This command will query a remote computer and return information about fixed
volumes. The function will ignore network, optical and other removable drives.

.PARAMETER Computername
The name of a computer to query. The account you use to run this function
should have admin rights on that computer.

.PARAMETER ErrorLog
Specify a path to a file to log errors. The default is C:\Errors.txt

.EXAMPLE
PS C:\> Get-VolumeInfo Server01

Run the command and query Server01.

.EXAMPLE
PS C:\> get-content c:\work\computers.txt | Get-VolumeInfo -errorlog c:\logs\errors.txt

This expression will go through a list of computernames and pipe each name
to the command. Computernames that can't be accessed will be written to
the log file.

#>
[cmdletbinding()]

 param(
 [Parameter(Position=0,ValueFromPipeline=$True)]
 [ValidateNotNullorEmpty()]
 [string[]]$ComputerName,
 [string]$ErrorLog="C:\Errors.txt",
  [switch]$LogErrors
 )

Begin {
    Write-Verbose "Starting Get-VolumeInfo"
 }

Process {
    foreach ($computer in $computerName) {
        Write-Verbose "Getting data from $computer"
        Try {
            $data = Get-WmiObject -Class Win32_Volume -computername $Computer -Filter "DriveType=3" -ErrorAction Stop
                
            Foreach ($drive in $data) {
				Write-Verbose "Processing volume $($drive.name)"
                #format size and freespace
                $Size="{0:N2}" -f ($drive.capacity/1GB)
                $Freespace="{0:N2}" -f ($drive.Freespace/1GB)

                #Define a hashtable to be used for property names and values
                $hash=@{
                    Computername=$drive.SystemName
                    Drive=$drive.Name
                    FreeSpace=$Freespace
                    Size=$Size
                }

                #create a custom object from the hash table
                $obj=New-Object -TypeName PSObject -Property $hash
				#Add a type name to the object
				$obj.PSObject.TypeNames.Insert(0,'MOL.DiskInfo')
			
				Write-Output $obj
				
            } #foreach

            #clear $data for next computer
            Remove-Variable -Name data

        } #Try

        Catch {
            #create an error message 
            $msg="Failed to get volume information from $computer. $($_.Exception.Message)"
            Write-Error $msg 

            Write-Verbose "Logging errors to $errorlog"
            $computer | Out-File -FilePath $Errorlog -append
        }
    } #foreach computer
} #Process

 End {
    Write-Verbose "Ending Get-VolumeInfo"
 }
}

Function Get-ServiceInfo {

<#
.SYNOPSIS
Get service information

.DESCRIPTION
This command will query a remote computer for running services and write
a custom object to the pipeline that includes service details as well as
a few key properties from the associated process. You must run this command
with credentials that have admin rights on any remote computers.

.PARAMETER Computername
The name of a computer to query. The account you use to run this function
should have admin rights on that computer.

.PARAMETER ErrorLog
Specify a path to a file to log errors. The default is C:\Errors.txt

.PARAMETER LogErrors
If specified, computer names that can't be accessed will be logged 
to the file specified by -Errorlog.

.EXAMPLE
PS C:\> Get-ServiceInfo Server01

Run the command and query Server01.

.EXAMPLE
PS C:\> get-content c:\work\computers.txt | Get-ServiceInfo -logerrors

This expression will go through a list of computernames and pipe each name
to the command. Computernames that can't be accessed will be written to
the log file.

#>

[cmdletbinding()]

 param(
 [Parameter(Position=0,ValueFromPipeline=$True)]
 [ValidateNotNullorEmpty()]
 [string[]]$ComputerName,
 [string]$ErrorLog="C:\Errors.txt",
 [switch]$LogErrors
 )

 Begin {
    Write-Verbose "Starting Get-ServiceInfo"

    #if -LogErrors and error log exists, delete it.
    if ( (Test-Path -path $errorLog) -AND $LogErrors) {
        Write-Verbose "Removing $errorlog"
        Remove-Item $errorlog
    }
 }

 Process {

    foreach ($computer in $computerName) {
		Write-Verbose "Getting services from $computer"
       
        Try {
            $data = Get-WmiObject -Class Win32_Service -computername $Computer -Filter "State='Running'" -ErrorAction Stop

            foreach ($service in $data) {
				Write-Verbose "Processing service $($service.name)"
                $hash=@{
                Computername=$data[0].Systemname
                Name=$service.name
                Displayname=$service.DisplayName
                }

                #get the associated process
                Write-Verbose "Getting process for $($service.name)"
                $process=Get-WMIObject -class Win32_Process -computername $Computer -Filter "ProcessID='$($service.processid)'" -ErrorAction Stop
                $hash.Add("ProcessName",$process.name)
                $hash.add("VMSize",$process.VirtualSize)
                $hash.Add("PeakPageFile",$process.PeakPageFileUsage)
                $hash.add("ThreadCount",$process.Threadcount)

                #create a custom object from the hash table
                $obj=New-Object -TypeName PSObject -Property $hash
				#add a type name to the custom object
        		$obj.PSObject.TypeNames.Insert(0,'MOL.ServiceProcessInfo')
			
				Write-Output $obj

            } #foreach service
                
            }
        Catch {
            #create an error message 
            $msg="Failed to get service data from $computer. $($_.Exception.Message)"
            Write-Error $msg 

            if ($LogErrors) {
				Write-Verbose "Logging errors to $errorlog"
            	$computer | Out-File -FilePath $Errorlog -append
            }
        }
                   
    } #foreach computer

} #process

End {
    Write-Verbose "Ending Get-ServiceInfo"
 }
    
}

