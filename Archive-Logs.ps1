<#
.SYNOPSIS
Archive-Logs.ps1 - Log File archiving Script

.DESCRIPTION 
A PowerShell script to acrhive and ship various log files to cetralized location.

This script will check the folders that you specify, and any files, that have .log extention and their last write time is ealier than you specify will be deleted


.PARAMETER paths
The paths to logfile folders, use comma (,) as delimeter and (') at the beginning and and of each path.

.PARAMETER retentiondays
All logs older than count of days you specify will be deleted by script, by default that parameter equals 2 days

.PARAMETER archivepath
Path to the folder, where logfile archives will be stored, it can be local folder or network share in the same active directory domain

.EXAMPLE
.\Archive-Logs.ps1 -Logpath "D:\IIS Logs\W3SVC1"
This example will archive the log files in "D:\IIS Logs\W3SVC1".

.EXAMPLE
.\Archive-Logs.ps1 -Logpath "D:\IIS Logs\W3SVC1" -retentiondays 14
This example will archive the log files in "D:\IIS Logs\W3SVC1" older than 14 days.

.EXAMPLE
.\Archive-Logs.ps1 -Logpath "D:\IIS Logs\W3SVC1" -retentiondays 14 -ArchivePath \\someserver\logs
This example will archive the log files in "D:\IIS Logs\W3SVC1" older than 14 days and ship them to network share "\\someserver\logs"
NOTICE: Moving the archive will work only if server, where you are launching the script and server, on which the network share is located are members of the same active directory domain

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
    $retentiondays
    	)

#Load .NET assembly for file zipping
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null

#Specifing the default log archiving interval
if ($retentiondays -eq $null) {
    $retentiondays = 2
}  

$date = Get-Date -Format yyyyMMddHmm

#Checking the exsistance of folder in which logs will be stored, and creating it, if needed
if ((Test-Path "$ArchivePath") -ne $true){
                New-Item -ItemType Directory -Path "$ArchivePath" -ErrorAction STOP | Out-Null
                }
            
#Parsing the logfolders
foreach ($path in $paths){
#Creating appender for IIS log folder
    $logfoldername = $path.Split("\")[-1]
        if ($path -like "*inetpub*"){
            $logfoldername = "IIS_"+ $($logfoldername)   
        }

    $logFiles = $null
    $logFiles = Get-ChildItem -Path $path -Recurse

#Parsing log files in each folder and adding them to archive
    foreach ($logfile in $logFiles){
        if (($logfile.extension -eq ".log") -and (([DateTime]::Now).AddDays(-($retentiondays)) -gt $item.LastWriteTime)){ 
            if (!(Test-Path "$($path)\Archive")){
                New-Item -ItemType Directory -Path "$($path)\Archive" -ErrorAction STOP | Out-Null
                }               
         Move-Item $logfile.FullName -Destination "$($path)\Archive"   
        }
    }
    [IO.Compression.ZipFile]::CreateFromDirectory("$($path)\Archive","$($path)\$computername-$logfoldername-$($date)_Archive.zip") | Out-Null
    Remove-Item "$($path)\Archive" -Recurse -Force
    
#Checking the exsistance of folder in which logs from each $path will be stored, and creating it, if needed
    if ((Test-Path "$ArchivePath\$computername\$logfoldername") -ne $true)
            {                     
                New-Item -ItemType Directory -Path "$ArchivePath\$computername\$logfoldername" -ErrorAction STOP  | Out-Null
            }
#Moving the log archives to destination
    $ArchiveFiles = Get-ChildItem -Path $path -Recurse
    foreach ($ArchiveFile in $ArchiveFiles){
        If ($ArchiveFile.extension -eq ".zip"){
            Move-Item $ArchiveFile.FullName -Destination "$ArchivePath\$computername\$logfoldername"
        }
    }
    
}
