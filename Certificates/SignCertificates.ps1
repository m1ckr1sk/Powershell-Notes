
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Invoke-SignFile
{
    Param($filename)
    Begin
    {
    }
    Process
    {
        $cert - (dir Cert:\CurrentUser\My -CodeSigningCert[0])
        Set-AuthenticodeSignature $filename -Certificate $cert
    }
    End
    {
    }
    
}