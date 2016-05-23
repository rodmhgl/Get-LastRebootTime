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