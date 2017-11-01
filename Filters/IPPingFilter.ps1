<#
.Synopsis
   function to generate all IPs between upper and lower limits
.DESCRIPTION
   Given a static first three couplets, generate a range of IP addresses from the last couplet
.EXAMPLE
   Get-IPRange -Lower 1 -Upper 150
#>
function Get-IPRange
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Lower is the starting Host address
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Lower,

        # Upper is the ending Host address
        [int]
        $Upper
    )

    Begin
    {
      # Specify Network Address as a constant
      New-Variable -Name Network -Value "192.0.0." -Option ReadOnly
    }
    Process
    {
      # Generate IPv4 adddresses in the specified range
      for($node = $Lower; $node -le $Upper;$node++){
        $Network +$node
      }
    }
    End
    {
    }
} 
 
<#
.Synopsis
   determines if a machine is reachable
.DESCRIPTION
   Given an IP address the function uses ping and a wait to determine if the machine is online.
.EXAMPLE
   Get-PingStatus -IP 192.0.0.1
#>
function Get-PingStatus
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # the IP address of the machine to check
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $IP
    )

    Begin
    {
      # a constant that specifies how long (in milliseconds) to wait for a reply
        New-Variable -Name Wait -Value 10 -Option ReadOnly
    }
    Process
    {        
        $ping = New-Object System.Net.NetworkInformation.Ping
        $response = $ping.Send($IP, $Wait)
        if($response.Status -ieq "Success"){
          $True
        }
        else{
          $False
        }
    }
    End
    {
    }
}
 
<#
.Synopsis
   Filter to return only machines that are online
.DESCRIPTION
   Uses the Get-PingStatus to determine if the machine is online
.EXAMPLE
   Get-IPRange -Lower 60 -Upper 70 | Get-OnlineMachine
#>     
Filter Get-OnlineMachine{
  Begin
  {
  }
  Process
  {        
    if(Get-PingStatus $_){$_}
  }
  End
  {
  }
}
   
Get-IPRange -Lower 60 -Upper 70 | Get-OnlineMachine