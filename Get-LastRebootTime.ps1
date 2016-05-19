#requires -version 5.0

#region Main
function Get-LastRebootTime
{
    <#
        .Synopsis
        Returns the time a server last rebooted
        .DESCRIPTION
        Returns a System.DateTime object representing the last time and date a server rebooted
        .EXAMPLE
        Get-LastRebootTime -ComputerName SERVER01
        .INPUTS
        System.String
        .OUTPUTS
        System.DateTime
    #>

    [CmdletBinding(DefaultParameterSetName='DefaultParameterSet')]
    [OutputType([System.DateTime])]
    Param
    (
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0,
                   ParameterSetName='DefaultParameterSet')]
        [ValidateNotNull()]
        [Alias("ServerName")] 
        [string[]]$ComputerName = 'localhost'
    )
    Process
    {
        foreach ($c in $ComputerName) { 
            try {
                $results = Get-CimInstance -Class Win32_OperatingSystem -ComputerName $c -ErrorAction Stop | Select-Object -ExpandProperty LastBootupTime
                return $results
            }
            catch [System.Management.Automation.CommandNotFoundException]
            {
                Write-Warning -Message $_.exception
                Throw 'Failure: CIM commands not found. Possibly running on or querying a WSMan / PowerShell 2.0 host' 
            }
            catch [Microsoft.Management.Infrastructure.CimException] { 
                Write-Warning -Message $_.exception
                Throw 'Failure: Unable to query host. Possibly querying a WSMan / PowerShell 2.0 host'
            }
        }
    }
}
#endregion

#TODO: 
# This error occurs when you run against a machine that does not have PowerShell 5
# Or maybe there's another cause - look this up
#Get-CimInstance : The WS-Management service cannot process the request. A DMTF resource URI was used to access a
#non-DMTF class. Try again using a non-DMTF resource URI.
#At C:\Scripts\Get-LastRebootTime\Get-LastRebootTime.ps1:40 char:16
#+ ...      return Get-CimInstance -Class Win32_OperatingSystem -ComputerNam ...
#+                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#    + CategoryInfo          : NotSpecified: (root\cimv2:Win32_OperatingSystem:String) [Get-CimInstance], CimException
#    + FullyQualifiedErrorId : HRESULT 0x80338139,Microsoft.Management.Infrastructure.CimCmdlets.GetCimInstanceCommand
#    + PSComputerName        : trivirt13