# Powershell 

## Tips
* ctrl shift enter - run as administrator
* use out grid format for nice view
  ```
  command | ogv e.g. get-service | ogv
  ```
* two commands on same line use ; (not recommended)
* single quotes recommended unless embedding variable in another string
* Use sensible naming convention to avoid clashing e.g. if a function is created possibly pre fix with company name for example.
* Can use gb, tb and mb to represent gigabyte, terrabyte and megabyte e.g.
  ```
  $freespace / 1gb
  ```

## Help  
* get-help - show help e.g. get-help get-service
* get-help get-eventlog -examples - gets examples of a command.
* [The scripting guy](https://blogs.technet.microsoft.com/heyscriptingguy/)
* [More lunches](https://morelunches.com/2012/12/01/learn-powershell-toolmaking-in-a-month-of-lunches/)
* To get the version of powershell
  ```
  $PSVersionTable
  ```
* [Lazy Win Admin](http://www.lazywinadmin.com/p/lazywinadmin-04.html)

## Alias  
* get-alias - lists all the aliases availbale e.g. cd -> Set-Location
* new -create but not overwrite, set -create and overwrite 
* aliases are generally session scoped unless you use a profile to add them to each session

## Execution policy
*  Usually controlled by group policy
  *  Restricted - safest
  *  Remote signed - trust stuff on this box
  *  All signed
  *  Unrestricted
*  Can be set at user level

## Variables and objects
* Always start with $
* objects can be inspected using get-Member.  e.g. $browser | get-member
* Arrays are continuous or cyclical so last element can be indexed using -1
* use parenthesis to force execution order, e.g.
  ```
  $service = (get-service)[0].name
  ```

## Comparison operators

| operator | notes |
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

## CMI
* new version of wmi
* requires wsman - workstation management. Microsoft version is rmman.
* Enable -psremoting allows machine to be remotely managed.  Need to be admin.

## Scripts
* use the back tick to escape carriage return and allow multi-line statements
* use <# for opening a multi line comment and #> to close multi line comment.
* Formatting scripts is not enforced in powershell but very important for readability.
* Use dot sourcing to load scripts containing functions into the session.  These can then be run into powershell.
  ```
  . .\Script_With_Functions.ps1
  
  Get-A-UsefulThing -myParamter hello
  ```
  However, once a change has been made, remember to re dot source your source file otherwise changes will not show up.
* Cmdletbinding() allows the function to run as a cmdlet.

## Hash table
* key value pair set objects
  ``` 
  $person = @{Name='mike';Age='21';Friends={'Steve','Brian'}}
  Write-Host $person.Name
  ```
  
## Write to file
* use write-content or add-content

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
  


