<#
.SYNOPSIS
Remove-Logs.ps1 - Log File Cleanup Script

.DESCRIPTION 
A PowerShell script to delete various log files.

This script will check the folders that you specify, and any files, that have .log extention and their last write time is ealier than you specify will be deleted


.PARAMETER paths
The paths to logfile folders, use comma (,) as delimeter and (') at the beginning and and of each path.

.PARAMETER retentiondays
All logs older than count of days you specify will be deleted by script, by default that parameter equals 7 days 

.EXAMPLE
.\Remove-Logs.ps1 -Logpath "D:\IIS Logs\W3SVC1"
This example will remove the log files in "D:\IIS Logs\W3SVC1".

.EXAMPLE
.\Remove-Logs.ps1 -Logpath "D:\IIS Logs\W3SVC1" -retentiondays 14
This example will remove the log files in "D:\IIS Logs\W3SVC1" older than 14 days.

.NOTES
Written by: Dmitry Sergeenko
#>

#Specifing script parameters
[CmdletBinding()]
param (
	[Parameter( Mandatory=$true)]
    [string[]]$paths,
    [Parameter( Mandatory=$false)]
    $retentiondays
    )
#Specifing the default log deletion interval
if ($retentiondays -eq $null) {
    $retentiondays = 7
}  


#Fetching all files in $paths
foreach ($path in $paths){
    $logFiles = $null
    $logFiles = Get-ChildItem -Path $path -Recurse

#Deleting all log files
    foreach ($item in $logFiles){
        if (($item.extension -eq '.log') -or ($item.extension -eq '.xml') -and (([DateTime]::Now).AddDays(-($retentiondays)) -gt $item.LastWriteTime)){ 
                        Remove-Item $item.FullName 
        }
    }
}


