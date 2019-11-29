#Enable-PSRemoting -Force

#$promptedCreds = get-credential -Message "Please enter your credentials to generate a DSC MOF:"

Configuration ZabbixAgentTest
{

    # Import the module that contains the resources we're using.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Import-DscResource -Module xNetworking


    Node $AllNodes.Where{$_.Role -eq "Test"}.NodeName 
    {

	#Copy Zabbix_agent installation file 
	File ZabbixAgentInstaller 
	{ 
	Ensure = "Present" 
	Type = "Directory" 
	SourcePath = "E:\DSC\zabbix_agent\" 
	DestinationPath = "C:\zabbix_agent\" 
	Recurse = $true
	}		 

    xFirewall ZabbixTCP 
    { 
    Name        = 'Zabbix Agent to Server TCP' 
    DisplayName = 'Zabbix (TCP-in)' 
    Ensure      = 'Present'
    Enabled     = 'True' 
    Direction   = 'Inbound' 
    LocalPort   = ('10050') 
    Protocol    = 'TCP' 
    Profile     = 'Any' 
    Description = "Allow Zabbix Agent Communication"
    } 

    #Change Hostname to server FQDN
    #In order to make this script work hostname parameter in zabbix config must be the last line
    Script ChangeHostname {
		SetScript = {
            $ServerFQDN = (Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
            (Get-Content "C:\zabbix_agent\conf\zabbix_agentd.win.conf").replace("server.gksm.local", "$ServerFQDN") | Set-Content "C:\zabbix_agent\conf\zabbix_agentd.win.conf"

			        }

		TestScript = {
            $ServerFQDN = (Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
            if  ((Get-Content "C:\zabbix_agent\conf\zabbix_agentd.win.conf" -Tail 1) -eq "$ServerFQDN") 
                {
                    Write-Host "Hostname already set!"
                    Return $true
                }

            Return $False

            		}

		GetScript = {
			@{ Result = Get-Content "C:\zabbix_agent\conf\zabbix_agentd.win.conf" -Tail 1 }	
			        }

        DependsOn = "[File]ZabbixAgentInstaller"
                    
		            }


	#Install Zabbix Agent
	Script InstallZabbix {
		SetScript = {
            Start-Process "C:\zabbix_agent\bin\win64\zabbix_agentd.exe" -ArgumentList "--config C:\zabbix_agent\conf\zabbix_agentd.win.conf --install" -Wait -NoNewWindow
			        }

		TestScript = {
            $ServiceName = "Zabbix Agent"
            if ( Get-Service "$ServiceName*" -ErrorAction SilentlyContinue -ErrorVariable WindowsServiceExistsError) 
                {
                    Write-Host "$ServiceName already installed "
                    Return $true
                }

            if ($WindowsServiceExistsError)
                {
                    Write-Host $WindowsServiceExistsError[0].exception.message
                }


            Return $False

            		}

		GetScript = {
            $ServiceName = "Zabbix Agent"
			@{ Result = ("$ServiceName*") }	
			        }

        DependsOn = "[Script]ChangeHostname"
                    
		            }
    #Start Zabbix Service
    Script StartZabbix {
		SetScript = {
            $ServiceName = "Zabbix Agent"
            Start-Service $ServiceName
			        }

		TestScript = {
            $ServiceName = "Zabbix Agent"
            if ( (Get-Service "$ServiceName*" -ErrorAction SilentlyContinue).Status -eq "Running") 
                {
                    Write-Host "$ServiceName already running "
                    Return $true
                }

            Return $False

            		}

		GetScript = {
            $ServiceName = "Zabbix Agent"
			@{ Result = (Get-Service "$ServiceName*") }	
			        }

        DependsOn = "[Script]InstallZabbix"
                    
		            }

    }

} ZabbixAgentTest -OutputPath E:\DSC_Configuration\ZabbixAgentTest1 -ConfigurationData E:\DSC_Configuration\AllNodesTest.psd1

#Start configuration -create MOF file
Start-DscConfiguration -Path E:\DSC_Configuration\ZabbixAgentTest1 -Wait -Verbose -Force
