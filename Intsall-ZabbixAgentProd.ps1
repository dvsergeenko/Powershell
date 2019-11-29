#Enable-PSRemoting -Force

$promptedCreds = get-credential -Message "Please enter your credentials to generate a DSC MOF:"

Configuration ZabbixAgentProd
{

    # Import the module that contains the resources we're using.
    # Этот ресурс по сути не требует импорта, но будет выкидывать противный Warning при компиляции.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    #Импорт модуля по работе с сетью, в нашем случае для разрешения правил Firewall
    Import-DscResource -Module xNetworking


    Node $AllNodes.Where{$_.Role -eq "ProdServer"}.NodeName 
    {

	#Copy Zabbix_agent installation file
	File ZabbixAgentInstaller 
	{ 
	Ensure = "Present" 
	Type = "Directory" 
	SourcePath = "\\1c-storage01.gksm.local\DSC\src\zabbix_agent\" 
	DestinationPath = "C:\zabbix_agent\" 
	Recurse = $true
	}		 

    xFirewall ZabbixTCP 
    { 
    Name        = 'Zabbix Agent to Server TCP' 
    DisplayName = 'Zabbix (TCP-in)' 
    Ensure      = 'Present'
    State       = "Enabled" 
    Access      = 'Allow' 
    Direction   = 'Inbound' 
    LocalPort   = ('10050') 
    Protocol    = 'TCP' 
    Profile     = 'Any' 
    Description = "Allow Zabbix Agent Communication"
    } 


	#Install Zabbix Agent
	Script InstallZabbix {
		SetScript = {
            Start-Process "C:\zabbix_agent\zabbix_agentd.exe --config C:\zabbix_agent\conf\zabbix_agentd.win.conf --install" -Wait -NoNewWindow
			        }

		TestScript = {
            $ServiceName = "Zabbix Agent"
            if ( Get-Service "$ServiceName*" -Include $ServiceName ) {
                $Return = $True
                }
            Return $Return
            		}

		GetScript = {
            $ServiceName = "Zabbix Agent"
			@{ Result = ("$ServiceName*" -Include $ServiceName) }	
			        }

        DependsOn = {
            "ZabbixAgentInstaller"
                    }
        
		            }

    }

} ZabbixAgentProd -ConfigurationData .\DSC_Configuration\AllNodes.psd1

#Start configuration -create MOF file
Start-DscConfiguration –Path .\DSC_Configuration\ZabbixAgentProd -Wait -Verbose -Force

