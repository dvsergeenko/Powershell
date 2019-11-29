#Enable-PSRemoting -Force

#$promptedCreds = get-credential -Message "Please enter your credentials to generate a DSC MOF:"

Configuration ZabbixAgentTest
{

    # Import the module that contains the resources we're using.
    # ���� ������ �� ���� �� ������� �������, �� ����� ���������� ��������� Warning ��� ����������.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    #������ ������ �� ������ � �����, � ����� ������ ��� ���������� ������ Firewall
    Import-DscResource -Module xNetworking


    Node $AllNodes.Where{$_.Role -eq "TestServer"}.NodeName 
    {

	#Copy Zabbix_agent installation file 1c_*.ps1
	File ZabbixAgentInstaller 
	{ 
	    Ensure = "Present" 
	    Type = "Directory" 
	    SourcePath = "\\firstform-test2.gksm.local\DSC\zabbix_agent\" 
	    DestinationPath = "C:\zabbix_agent\" 
	    Recurse = $true
	}		 

    xFirewall ZabbixTCP 
    { 
        Name        = "Zabbix Agent to Server TCP" 
        DisplayName = "Zabbix (TCP-in)" 
        Ensure      = "Present"
        Enabled     = "True" 
        Direction   = "Inbound" 
        LocalPort   = ("10050") 
        Protocol    = "TCP" 
        Profile     = "Any" 
        Description = "Allow Zabbix Agent Communication"
    } 


	#Install Zabbix Agent
	Package ZabbixAgent
    {
		Name = "ZabbixAgent"
        ProductId = " "
        Path = "C:\zabbix_agent\zabbix_agentd.exe"
        Arguments = "--config C:\zabbix_agent\conf\zabbix_agentd.win.conf --install"
        Ensure = "Present"
        DependsOn = "[File]ZabbixAgentInstaller"
    }

    }

} 
ZabbixAgentTest -ConfigurationData E:\DSC_Configuration\AllNodesTest.psd1

#Start configuration -create MOF file
Start-DscConfiguration –Path E:\DSC_Configuration\ZabbixAgentTest -Wait -Verbose -Force

