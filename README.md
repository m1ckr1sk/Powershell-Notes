# Powershell 

## Tips
* Ctrl shift enter - run as administrator
* Use out grid format for nice view
  ```
  command | ogv e.g. get-service | ogv
  ```
* Two commands on same line use ; (not recommended)
* Single quotes recommended unless embedding variable in another string
* Use sensible naming convention to avoid clashing e.g. if a function is created possibly pre fix with company name for example.
  ```
  Get-MikeSoft-OSInfo
  ```
* Can use gb, tb and mb to represent gigabyte, terrabyte and megabyte e.g.
  ```
  $freespace / 1gb
  ```
* In Powershell ISE you can use snippets in Edit->Start Snippets to provide template.
* Use Script analyser for static analysis
  ```
  Invoke-ScriptAnalyzer -Path <path to script file>
  ```
* Use Start-Transcript to record all commands and output for further reference.  Use Stop-Transcript to stop recording.

## Help  
* Get-Help - show help e.g. get-help get-service
* Get-Help get-eventlog -examples - gets examples of a command.
* [The scripting guy](https://blogs.technet.microsoft.com/heyscriptingguy/)
* [More lunches](https://morelunches.com/2012/12/01/learn-powershell-toolmaking-in-a-month-of-lunches/)
* To get the version of powershell
  ```
  $PSVersionTable
  ```
* [Lazy Win Admin](http://www.lazywinadmin.com/p/lazywinadmin-04.html)
* [Unofficial coding standards](https://github.com/PoshCode/PowerShellPracticeAndStyle)

## Alias  
* Get-Alias - lists all the aliases availbale e.g. cd -> Set-Location
* New -create but not overwrite, set -create and overwrite 
* Aliases are generally session scoped unless you use a profile to add them to each session

## Execution policy
* Usually controlled by group policy
  * Restricted - safest
  * Remote signed - trust stuff on this box
  * All signed
  * Unrestricted
* Can be set at user level

## Variables and objects
* Always start with $
* Objects can be inspected using get-Member.  e.g. $browser | get-member
* Arrays are continuous or cyclical so last element can be indexed using -1
* Use parenthesis to force execution order, e.g.
  ```
  $service = (get-service)[0].name
  ```

## Comparison operators

| Operator | Notes |
| ---------| ----------- |
| -eg      | equal     |
| -ne      | not equal |
| -like    | like |
| -gt      | greater than |
| -ge      | greater than or equal |
| -lt      | less than |
| -le      | less than or equal |
| $TRUE    | constant true |
| $FALSE   | constant false |

## Iteration
* Be careful not to use for each in instances where pipe might be easier.  e.g.
  ```
  get-service | stop-service
  ```
  
  is better than
  
  ```
  $services - get-service
  forEach ($service in $services){
    $service.stop()
  }
  ```

## CIM - Common Information Model
* New version of wmi - Windows Management Instrumentation
* Requires wsman - workstation management. Microsoft version is rmman.
* Enable -psremoting allows machine to be remotely managed.  Need to be admin.

## Scripts
* Use the back tick to escape carriage return and allow multi-line statements
* Use <# for opening a multi line comment and #> to close multi line comment.
* Formatting scripts is not enforced in powershell but very important for readability.
* Use dot sourcing to load scripts containing functions into the session.  These can then be run into powershell.
  ```
  . .\Script_With_Functions.ps1
  
  Get-A-UsefulThing -myParamter hello
  ```
  However, once a change has been made, remember to re dot source your source file otherwise changes will not show up.
* Cmdletbinding() allows the function to run as a cmdlet.
* Use write-verbose and write-debug to allow print statements that can provide levels of logging.
* Use ValueFromPipeline to allow function to take input from pipeline, e.g. 
  ```
  'localhost' | Get-A-UsefulThing
  ```
* Use comment help to provide information to help function
  ```
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
  ```
*  ErrorActionPreference defines what action powershell takes on error.  Default is continue.



## Hash table
* Key value pair set objects
  ``` 
  $person = @{Name='mike';Age='21';Friends={'Steve','Brian'}}
  Write-Host $person.Name
  ```
  
## Write to file
* Use write-content or add-content

## Function template
Good function template
```
function Get-MachineData{
    [CmdletBinding()]
    Param(
        [string]$computerName = 'localhost' 
    )
    # Begin runs once for each object sent to the fucntion
    BEGIN{}
    # Process runs for each object sent to the fucntion
    PROCESS{
      Write-Output $computerName
    # End runs once for each object sent to the fucntion
    }
    END{}
}
```
  


