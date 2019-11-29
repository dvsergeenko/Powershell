#Enable-PSRemoting -Force

#$promptedCreds = get-credential -Message "Please enter your credentials to generate a DSC MOF:"

Configuration InstallModule
{

    # Import the module that contains the resources we're using.
    # Этот ресурс по сути не требует импорта, но будет выкидывать противный Warning при компиляции.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node $AllNodes.Where{$_.Role -eq "Test"}.NodeName 
    {

	#Install Zabbix Agent
	Script InstallModule {
		SetScript = {
            Install-Module xNetworking -Wait -Force
			        }

		TestScript = {
            $ModuleName = "xNetwoking"
            if ( Get-Module -listAvailable | Where  {$_.Name -eq $ModuleName} ) 
                {
                Write-Host "Netwoking module already installed"
                $Return = $True
                }
            Return $False
            		}

		GetScript = {
            $ModuleName = "xNetworking"
			@{ Result = (Get-Module -listAvailable | Where  {$_.Name -eq $ModuleName}) }	
			        }
        
		            }

    }

} InstallModule -OutputPath E:\DSC_Configuration\InstallModule -ConfigurationData E:\DSC_Configuration\AllNodesTest.psd1

#Start configuration -create MOF file
Start-DscConfiguration –Path E:\DSC_Configuration\InstallModule -Wait -Verbose -Force

