# Powershell 

## Tips
* ctrl shift enter - run as administrator
* use out grid format for nice view
  ```
  command | ogv e.g. get-service | ogv
  ```
* two commands on same line use ; (not recommended)
* single quotes recommended unless embedding variable in another string

## Help  
* get-help - show help e.g. get-help get-service
* get-help get-eventlog -examples - gets examples of a command.
* [The scripting guy](https://blogs.technet.microsoft.com/heyscriptingguy/)

## Alias  
* get-alias - lists all the aliases availbale e.g. cd -> Set-Location
* new -create but not overwrite, set -create and overwrite 
* aliases are generally session scoped unless you use a profile to add them to each session

## Execution policy
Usually controlled by group policy
*  Restricted - safest
*  Remote signed - trust stuff on this box
*  All signed
*  Unrestricted

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
--------------------
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


