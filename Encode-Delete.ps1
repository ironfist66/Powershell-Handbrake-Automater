# -------------------------------------- VARIABLES --------------------------------------
# These are the variables that you need to set before the script can work.
# I have tried to get as many up here as possible so that you don't have to search 
# through the script to change anything.  

$sourcefolder = "P:\Downloads\Shows\Re-encode"
$destinationfolder = "P:\Downloads\Shows\Ready for Sonarr"
$destinationlog = "P:\Downloads\Shows\Re-encode\encoded.txt"
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





# CHECK HNADBRAKE ISN'T ALREADY RUNNING
# This checks to make sure that handbrake CLI isn't already running so that we don't have
# multiple handbrake conversions going on at the same time.
# it checks every 2 seconds until handbrake CLI is no longer running.


do { Start-Sleep -s 20 } until ((get-process HandBrakeCLI -ea SilentlyContinue) -eq $Null)


# CHECK FOR FILES AND CONVERT
# This part of the script checks for files in the source folder and writes them in to a 
# variable to pass in to handbrake CLI using the arguments and destination folder set above.
# It also outputs a log of when something has been started and finished.


$filelist = Get-ChildItem $sourcefolder -filter *.mkv
$num = $filelist | measure
$filecount = $num.count
$i = 0;

ForEach ($file in $filelist)
{
    $i++;
    do { Start-Sleep -s 5 } until ((get-process HandBrakeCLI -ea SilentlyContinue) -eq $Null)
    $date1 = Get-Date
    $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
    $newfile = $destinationfolder + "\" + $file.BaseName + ".$newfileextension";
    $output1 = "-------------------------------------------------------------------------------"
    $output2 = "Handbrake Automated Encoding"
    $output3 = "$date1 `| Processing - $file"
    
    $output1 | Out-File -append $destinationlog                                                   #              V !HANDBRAKE ARGUMENTS HERE! V
    $output2 | Out-File -append $destinationlog                                                   #              V !HANDBRAKE ARGUMENTS HERE! V
    $output3 | Out-File -append $destinationlog                                                   #       V !LEAVE `"oldfile`" AND `"newfile`" HERE! V 
         
    Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -WindowStyle Hidden -ArgumentList "--preset-import-gui --preset Default-720p-RF22 -i `"$oldfile`" -o `"$newfile`""
    
    do { Start-Sleep -s 1 } until ((get-process HandBrakeCLI -ea SilentlyContinue) -eq $Null)
    
    $date2 = Get-Date
    $output4 = "$date2 `| Finished - $file"
    $output4 | Out-File -append $destinationlog
    
    Remove-Item -literalpath "$oldfile" -force
    $date3 = Get-Date
    $output5 = "$Date3 `| Deleted File - $oldfile"
    $output5 | Out-File -append $destinationlog
    $output1 | Out-File -append $destinationlog

}




# MEDIA MANAGER INTEGRATION SCRIPT
# This part of the script tells the programs set above to search their folders for
# new content.
# You may need to set your media manager to look at $destinationfolder if it
# doesn't already.


if ($sonarr = 1){

$url = "$sonarrURL/api/command"
$json = "{ ""name"": ""downloadedepisodesscan"" }"

Write-Host "Publishing update $version ($branch) to: $url"
Invoke-RestMethod -Uri $url -Method Post -Body $json -Headers @{"X-Api-Key"="$sonarrAPI"}
}