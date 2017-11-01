<#
    .SYNOPSIS
    Retrieves list of dotnet versions installed on the local machine.

    .DESCRIPTION
    Interrogates the registry to find dotnet versions installed.

    .EXAMPLE
    Get-MachineData -ComputerNames 'localhost', 'WIN2012JHN' -LogErrors -ErrorLog "c:\temp\errorlog.txt

#>
function Get-DotNetInfo
{
    [CmdletBinding()]
    Param
    ()

    Begin
    {
    }
    Process
    {
      Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
      Get-ItemProperty -name Version,Release -EA 0 |
      Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} |
      Select-Object PSChildName, Version, Release
    }
    End
    {
    }
}

Get-DotNetInfo
