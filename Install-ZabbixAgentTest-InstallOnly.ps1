#Enable-PSRemoting -Force

#$promptedCreds = get-credential -Message "Please enter your credentials to generate a DSC MOF:"

Configuration ZabbixAgentTestInstall
{

    # Import the module that contains the resources we're using.
    # ���� ������ �� ���� �� ������� �������, �� ����� ���������� ��������� Warning ��� ����������.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    Node $AllNodes.Where{$_.Role -eq "TestServer"}.NodeName 
    {

	#Install Zabbix Agent
	Package ZabbixAgent
    {
		Name = "ZabbixAgent"
        ProductId = " "
        Path = "C:\zabbix_agent\zabbix_agentd.exe"
        Arguments = "--config C:\zabbix_agent\conf\zabbix_agentd.win.conf --install"
        Ensure = "Present"
    }

    }

} 
ZabbixAgentTestInstall -ConfigurationData E:\DSC_Configuration\AllNodesTest.psd1

#Start configuration -create MOF file
Start-DscConfiguration –Path E:\DSC_Configuration\ZabbixAgentTestInstall -Wait -Verbose -Force

