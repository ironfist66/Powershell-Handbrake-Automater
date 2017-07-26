# -------------------------------------- VARIABLES --------------------------------------
# These are the variables that you need to set before the script can work.
# I have tried to get as many up here as possible so that you don't have to search 
# through the script to change anything.  

$sourcefolder = "P:\Downloads\Shows\Re-encode"
$destinationfolder = "P:\Downloads\Shows\Ready for Sonarr"
$destinationlog = "P:\Downloads\Shows\encoded.txt"
$newfileextension = "mkv" 
#                     ^-- choose mkv or mp4 
$recursive = "0" # <----- set to 1 to enable recursive source folder scan

# set your arguments for handbrake further below. I could not make this a variable without
# breaking the ability to convert multiple files. 

$sickbeard = "0"    # <------ set these to 1 if you want them search for content after conversion.
$couchpotato = "0"  # <--/    Then set the relevant fields below.
$sonarr = "1"       # <-/
$radarr = "0"       # <-

$sickbeardURL = ""
$couchpotatoURL = ""
$sonarrURL = "http://localhost:8989/sonarr"
$radarrURL = ""

$sonarrAPI = "8adb59b653cd4d61aacf347c1320e70c"
$radarrAPI = ""



# ----------------------------------- START OF SCRIPT -----------------------------------

# WATCH FOLDER
# This part of the script creates a new folder watcher.
# When new files are detected, it starts the handbrake automated encoding part of the 
# script.




# CHECK HANDBRAKE ISN'T ALREADY RUNNING
# This checks to make sure that handbrake CLI isn't already running so that we don't have
# multiple handbrake conversions going on at the same time.
# it checks every 2 seconds until handbrake CLI is no longer running.


do { $randomtime = Get-Random -Minimum 100 -Maximum 20000
Start-Sleep -m $randomtime } 
until ((Get-ItemProperty 'HKLM:\SOFTWARE\Scripts' -name Running | select -exp Running) -eq 0)

Set-ItemProperty HKLM:\SOFTWARE\Scripts -Name Running -Value 1

# CHECK FOR FILES AND CONVERT
# This part of the script checks for files in the source folder and writes them in to a 
# variable to pass in to handbrake CLI using the arguments and destination folder set above.
# It also outputs a log of when something has been started and finished.

Get-ChildItem $sourcefolder -Filter *.txt -Recurse | foreach ($_) {Remove-Item -LiteralPath $_.fullname}
Get-ChildItem $sourcefolder -Filter *.nfo -Recurse | foreach ($_) {Remove-Item -LiteralPath $_.fullname}

$filelist = Get-ChildItem $sourcefolder -Filter *.* -Recurse -Exclude "*In Progress*" | where { ! $_.PSIsContainer } | Where {$_.FullName -notlike "*\In Progress\*"}
$num = $filelist | measure
$filecount = $num.count
$i = 0;

ForEach ($file in $filelist)
{
    $i++;

    $randomtime = Get-Random -Minimum 10 -Maximum 200
    Start-Sleep -m $randomtime

    $progressroot = $sourcefolder + "\" + "In Progress"
    if ((Test-Path $progressroot) -eq $false) { New-Item $progressroot -type directory}

    $f = 0
    do { $f++;
    $progressfolder = $progressroot + "\" + $f
    (Test-Path $progressfolder)
    } until ((Test-Path $progressfolder) -eq $false)
    New-Item $progressfolder -type Directory

    $movefile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
    Move-Item -literalpath $movefile -Destination $progressfolder 

    Get-ChildItem $progressfolder -Filter *.*

    do { $randomtime = Get-Random -Minimum 10 -Maximum 2000
    Start-Sleep -m $randomtime } 
    until ((Get-ItemProperty 'HKLM:\SOFTWARE\Scripts' -Name Encoding | select -exp Encoding) -eq 0)

    Set-ItemProperty HKLM:\SOFTWARE\Scripts -Name Encoding -Value 1

    $profile = "Default-All-RF23"

    If($file -like '*HorribleSubs*'){
    $profile = "Default-All-RF20"}

    If($file -like "*FLEET*") {
    $profile = "Default-All-RF23"}
        
    $oldfile = $progressfolder + "\" + $file.BaseName + $file.Extension;
    $newfile = $destinationfolder + "\" + $file.BaseName + ".$newfileextension";

    $date = Get-Date    
    $output1 = "-------------------------------------------------------------------------------"
    $output2 = "Handbrake Automated Encoding `r`n"
    $output3 = "$date `| Processing:    `| $file"
    $output4 = "                    `| Using Profile: `| $profile"
    
    $output1 | Out-File -Append $destinationlog                                                   #              V !HANDBRAKE ARGUMENTS HERE! V
    $output2 | Out-File -Append $destinationlog                                                   #              V !HANDBRAKE ARGUMENTS HERE! V
    $output3 | Out-File -Append $destinationlog                                                   #       V !LEAVE `"oldfile`" AND `"newfile`" HERE! V 
    $output4 | Out-File -Append $destinationlog

    Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -WindowStyle Hidden -ArgumentList "--preset-import-gui --preset $profile -i `"$oldfile`" -o `"$newfile`""
    
    Start-Sleep -s 1

    $affinity=Get-Process HandBrakeCLI
    $affinity.ProcessorAffinity=43690
    
    do { Start-Sleep -s 1 } until ((get-process HandBrakeCLI -ea SilentlyContinue) -eq $Null)
    
    $date = Get-Date
    $output5 = "$date `| Finished:      `| $newfile"
    $output5 | Out-File -Append $destinationlog
    
    Remove-Item -LiteralPath "$oldfile" -force
    $output6 = "                    `| Deleted File:  `| $oldfile `r`n"
    $output6 | Out-File -Append $destinationlog

    Set-ItemProperty HKLM:\SOFTWARE\Scripts -Name Encoding -Value 0
}




# MEDIA MANAGER INTEGRATION SCRIPT
# This part of the script tells the programs set above to search their folders for
# new content.
# You may need to set your media manager to look at $destinationfolder if it
# doesn't already.


if ($sonarr -eq 1){

$url = "$sonarrURL/api/command"
$json = "{ ""name"": ""downloadedepisodesscan"" }"

Write-Host "Publishing update $version ($branch) to: $url"
Invoke-RestMethod -Uri $url -Method Post -Body $json -Headers @{"X-Api-Key"="$sonarrAPI"}
}


Set-ItemProperty HKLM:\SOFTWARE\Scripts -Name Running -Value 0
Get-ChildItem P:\Downloads\Shows\Re-encode\ -Recurse | Where-Object -FilterScript {$_.PSIsContainer -eq $True} | Where-Object -FilterScript {($_.GetFiles().Count -eq 0) -and $_.GetDirectories().Count -eq 0} | foreach ($_) {remove-item $_.fullname}
Clear-RecycleBin -Confirm:$False