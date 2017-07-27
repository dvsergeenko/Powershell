<#
.SYNOPSIS
Remove-Logs.ps1 - Log File Cleanup Script

.DESCRIPTION 
A PowerShell script to delete various log files.

This script will check the folders that you specify, and any files, that have .log extention and their last write time is ealier than you specify will be deleted


.PARAMETER paths
The paths to logfile folders, use comma (,) as delimeter and (') at the beginning and and of each path.

.PARAMETER retentiondays
All logs older than count of days you specify will be deleted by script, by default that parameter equals 2 days 

.EXAMPLE
.\Remove-Logs.ps1 -Logpath "D:\IIS Logs\W3SVC1"
This example will remove the log files in "D:\IIS Logs\W3SVC1".

.EXAMPLE
.\Remove-Logs.ps1 -Logpath "D:\IIS Logs\W3SVC1" -retentiondays 14
This example will remove the log files in "D:\IIS Logs\W3SVC1" older than 14 days.

.NOTES
Written by: Dmitry Sergeenko
#>
[CmdletBinding()]
param (
	[Parameter( Mandatory=$true)]
    [string[]]$paths,
    [Parameter( Mandatory=$true)]
	[string]$ArchivePath,
    [Parameter( Mandatory=$false)]
    [int32]$retentiondays
    	)

#Load .NET assembly for file zipping
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null

#Specifing the default log archiving interval
if ($retentiondays -eq $null) {
    $retentiondays = 2
}  

$date = Get-Date -Format yyyyMMddHmm


if (!(Test-Path "$ArchivePath")){
                New-Item -ItemType Directory -Path "$ArchivePath" | Out-Null
                }

foreach ($path in $paths){
    $logFiles = $null
    $logFiles = Get-ChildItem -Path $path -Recurse

    foreach ($item in $logFiles){
        if (($item.extension -eq '.log') -and (([DateTime]::Now).AddDays(-($retentiondays)) -gt $item.LastWriteTime)){ #get all files older than 14 days and move them to a subdirectory 'Archive'
                        Move-Item $item.FullName -Destination "$ArchivePath\$path"
            
        }
    }
    [IO.Compression.ZipFile]::CreateFromDirectory("$($path)\Archive","$($path)\$($date)_Archive.zip")
    Remove-Item "$($path)\Archive" -Recurse -Force
}


