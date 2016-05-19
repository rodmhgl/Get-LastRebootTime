$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\$sut"

Describe Get-LastRebootTime {  
    Context "Help and Parameter checks" {
        Set-StrictMode -Version latest
       
        It 'Should have inbuilt help along with Description and examples' {
            $helpinfo = Get-Help Get-LastRebootTime
            $helpinfo.examples | Should not BeNullOrEmpty  # Should have examples
            $helpinfo.Details | Should not BeNullOrEmpty   # Should have Details in the Help
            $helpinfo.Description | Should not BeNullOrEmpty # Should have a Description for the Function
        }
    
        It 'Should not accept Null ComputerName Mandatory params' {
            #{Get-LastRebootTime} | Should Throw
            {Get-LastRebootTime -computername $null } | Should throw
        }

        It 'Should return a System.DateTime object' {
            $var = Get-LastRebootTime -ComputerName localhost
            $var.gettype() | Should be "DateTime"
        }
       
        It 'Should accept ServerName as an alias for ComputerName' {
            {Get-LastRebootTime -servername localhost } | Should not throw 
        }

        It 'Should accept pipeline input' {
            "localhost","localhost","localhost" | Get-LastRebootTime
        }

        It 'Should accept pipeline input by property name' {
            $object = new-object -TypeName PSObject | select fake, unnecessary, computername
            $object.computername = 'localhost'
            $object | Get-LastRebootTime
        }

        It 'Should accept parameters by position' {
            $var = Get-LastRebootTime localhost
            $var.gettype() | Should be "DateTime"
        }

        It 'Should default ComputerName to localhost' {
            Mock -CommandName Get-CIMInstance `
            -Verifiable `
            -ParameterFilter {
                'computername' -eq 'localhost';
                'class' -eq 'Win32_ComputerSystem';
                'ErrorAction' -eq 'Stop'; 
            }
            Get-LastRebootTime #} | Should not throw 
            Assert-VerifiableMocks
        }
    } # end Context
    Context "CIM Commands Available" {
        
        Set-StrictMode -Version latest
        
        It "Should Fail if the CIM commands are not present" {
            #Mock -CommandName Import-Module -ParameterFilter {$name -eq 'ActiveDirectory'} -MockWith {Throw (New-Object -TypeName System.IO.FileNotFoundException)} -Verifiable
            #-ParameterFilter {$Class -eq 'Win32_OperatingSystem';$computername -eq 'localhost'}
            $throwBlock = { Throw (New-Object -TypeName System.Management.Automation.CommandNotFoundException) }
            $params = @{'commandname' = 'Get-CIMInstance'; 'mockWith' = $throwblock; 'Verifiable' = $true} 
            Mock @params
            {Get-LastRebootTime -ComputerName localhost } | Should throw
            Assert-VerifiableMocks
        }
        
        It "Should fail if you query a Powershell 2.0 Host" {
            $throwBlock = { Throw (New-Object -TypeName Microsoft.Management.Infrastructure.CimException) }
            $params = @{'commandname' = 'Get-CIMInstance'; 'mockWith' = $throwblock; 'Verifiable' = $true} 
            Mock @params
           {Get-LastRebootTime -ComputerName localhost } | Should throw
            Assert-VerifiableMocks
        }
        
    }
}
