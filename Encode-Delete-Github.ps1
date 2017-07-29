# _______________________________________________________________________________________ #
#                                                                                         #
#                                        VARIABLES                                        #
# _______________________________________________________________________________________ #
#                                                                                         #
# These are the variables that you need to set before the script can work.                #
# I have tried to get as many up here as possible so that you don't have to search        #
# through the script to change anything.                                                  #
# _______________________________________________________________________________________ #


$sourcefolder = "C:\YOUR\SOURCE\FOLDER\HERE"
$destinationfolder = "C:\YOUR\OUTPUT\FOLDER\HERE"
$destinationlog = "C:\YOUR\LOGFILE\HERE.txt"

$newfileext = "mkv" # <----------------- choose mkv or mp4 
$recursive = 0 # <---------------------- set to 1 to enable recursive source folder scan
$remold = 0 # <------------------------- set to 1 to delete source files after re-encode
$clrrcl = 0 # <------------------------- set to 1 to clear recycle bin after script finishes

$sonarr = "0"    # <------ set these to 1 if you want them search for content after conversion.
$radarr = "0"    # <--/    Then set the relevant fields below.

$sonarrURL = "http://localhost:8989"
$radarrURL = "http://localhost:8989"

$sonarrAPI = "YOUR API HERE"
$radarrAPI = "YOUR API HERE"

$changeaffinity = 0 # <------ if you want to change the affinity of handbrakeCLI set this to 1 and change the decimal values below
$decimal = 255 # <----------- decimal values available via google or here: https://stackoverflow.com/questions/19187241/change-affinity-of-process-with-windows-script
#                        \--- This will vary depending on how many cores/threads your processor has. i.e. a Ryzen 8C/16T CPU will be 65535 but an i7 4C/8T CPU will be 255 for all cores

# HANDBRAKE ARGUMENTS AND SETTINGS MUST BE SET BELOW. THESE CANNOT BE MADE IN TO A
# VARIABLE WITHOUT BREAKING THE SCRIPT
# IT IS MARKED UP BELOW FOR EASY SPOTTING





# _______________________________________________________________________________________ #
#                                                                                         #
#                                      SCRIPT START                                       #
# _______________________________________________________________________________________ #
#                                                                                         #
# CHECK SCRIPT ISN'T ALREADY RUNNING                                                      #
#                                                                                         #
# This checks to make sure that the script isn't already running so that we don't have    #
# multiple powershell re-encodes happening at the same time.                              #
# _______________________________________________________________________________________ #


do { $randomtime = Get-Random -Minimum 100 -Maximum 20000
Start-Sleep -m $randomtime } 
until ((Get-ItemProperty 'HKCU:\SOFTWARE\Scripts' -name Running | select -exp Running) -eq 0)

Set-ItemProperty HKCU:\SOFTWARE\Scripts -Name Running -Value 1


# _______________________________________________________________________________________ #
#                                                                                         #
# CHECK FOR FILES AND CONVERT                                                             #
#                                                                                         #
# This will delete all .txt and .nfo files, then make a list of all remaining files to    #
# give to handbrake, using the source and destination fields set above.                   #
# It also checks to make sure handbrake isn't already running, and creates a log of       #
# actions taken (the log file set above)                                                  #
# Afterwards, it deletes the source (if set above)                                        #
# _______________________________________________________________________________________ #


Get-ChildItem $sourcefolder -Filter *.txt -Recurse | foreach ($_) {Remove-Item -LiteralPath $_.fullname}
Get-ChildItem $sourcefolder -Filter *.nfo -Recurse | foreach ($_) {Remove-Item -LiteralPath $_.fullname}

if ($recursive -eq 1) { $filelist = Get-ChildItem $sourcefolder -Filter *.* -Recurse -Exclude "*In Progress*", "*!ut*" | where { ! $_.PSIsContainer } | Where {$_.FullName -notlike "*\In Progress\*"}
$num = $filelist | measure
$filecount = $num.count }
else { $filelist = Get-ChildItem $sourcefolder -Filter *.* -Exclude "*In Progress*", "*!ut*" | where { ! $_.PSIsContainer } | Where {$_.FullName -notlike "*\In Progress\*"}
$num = $filelist | measure
$filecount = $num.count }

if ($num.count -eq "0"){ Set-ItemProperty HKCU:\SOFTWARE\Scripts -Name Running -Value 0 
Exit }

$i = 0;

ForEach ($file in $filelist)
{
    $i++;

    $randomtime = Get-Random -Minimum 1000 -Maximum 4000
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
}

Get-ChildItem $sourcefolder -Recurse | Where-Object -FilterScript {$_.PSIsContainer -eq $True} | Where-Object -FilterScript {($_.GetFiles().Count -eq 0) -and $_.GetDirectories().Count -eq 0} | foreach ($_) {remove-item -LiteralPath $_.fullname}

$progressroot = $sourcefolder + "\" + "In Progress"
$filelist = Get-ChildItem $progressroot -Filter *.* -Recurse | where { ! $_.PSIsContainer }
$num = $filelist | measure
$filecount = $num.count

$i = 0;

ForEach ($file in $filelist)
{
    $i++;

    $randomtime = Get-Random -Minimum 100 -Maximum 4000
    Start-Sleep -m $randomtime

    do { $randomtime = Get-Random -Minimum 10 -Maximum 2000
    Start-Sleep -m $randomtime } 
    until ((Get-ItemProperty 'HKCU:\SOFTWARE\Scripts' -Name Encoding | select -exp Encoding) -eq 0)

    Set-ItemProperty HKCU:\SOFTWARE\Scripts -Name Encoding -Value 1

    $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
    $newfile = $destinationfolder + "\" + $file.BaseName + ".$newfileext";
    $oldfilebase = $file.BaseName + $file.Extension;

    $date = Get-Date    
    $output1 = "-------------------------------------------------------------------------------"
    $output2 = "Handbrake Automated Encoding `r`n"
    $output3 = "$date `| Processing:    `| $oldfilebase"                                          #        _________________  | |  _________________
                                                                                                  #                         \ | | /
    $output1 | Out-File -Append $destinationlog                                                   #                         | | | |
    $output2 | Out-File -Append $destinationlog                                                   #                         V V V V
    $output3 | Out-File -Append $destinationlog                                                   #              V !HANDBRAKE ARGUMENTS HERE! V
                                                                                                  #       V !LEAVE `"oldfile`" AND `"newfile`" HERE! V 
    Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -WindowStyle Hidden -ArgumentList "-i `"$oldfile`" -o `"$newfile`""
    
    Start-Sleep -s 1

    if ($changeaffinity -eq 1) { $affinity=Get-Process HandBrakeCLI
    $affinity.ProcessorAffinity=$decimal }
    
    do { Start-Sleep -s 1 } until ((get-process HandBrakeCLI -ea SilentlyContinue) -eq $Null)
    
    $date = Get-Date
    $output5 = "$date `| Finished:      `| $newfile"
    $output5 | Out-File -Append $destinationlog
    
    if ($remold -eq 1) { Remove-Item -LiteralPath "$oldfile" -force
    $output6 = "                    `| Deleted File:  `| $oldfile `r`n"
    $output6 | Out-File -Append $destinationlog }
    
    Set-ItemProperty HKCU:\SOFTWARE\Scripts -Name Encoding -Value 0
}


# _______________________________________________________________________________________ #
#                                                                                         #
# MEDIA MANAGER INTEGRATION SCRIPTS                                                       #
#                                                                                         #
# This part of the script tells the programs set above to search their folders for        #
# new content.                                                                            #
# You may need to set your media manager to look at $destinationfolder if it              #
# doesn't already.                                                                        #
# _______________________________________________________________________________________ #


if ($sonarr -eq 1){

$url = "$sonarrURL/api/command"
$json = "{ ""name"": ""downloadedepisodesscan"" }"

Write-Host "Publishing update $version ($branch) to: $url"
Invoke-RestMethod -Uri $url -Method Post -Body $json -Headers @{"X-Api-Key"="$sonarrAPI"}
}


# _______________________________________________________________________________________ #
#                                                                                         #
# CLEANUP                                                                                 #
#                                                                                         #
# This section deletes any empty folders created during the re-encode, clears the recycle # 
# bin (if set) and sets the script registry value back to 0 so the script can be run      #
# again.                                                                                  #
# _______________________________________________________________________________________ #


Set-ItemProperty HKCU:\SOFTWARE\Scripts -Name Running -Value 0
Get-ChildItem $sourcefolder -Recurse | Where-Object -FilterScript {$_.PSIsContainer -eq $True} | Where-Object -FilterScript {($_.GetFiles().Count -eq 0) -and $_.GetDirectories().Count -eq 0} | foreach ($_) {remove-item $_.fullname}
Get-ChildItem $sourcefolder -Recurse | Where-Object -FilterScript {$_.PSIsContainer -eq $True} | Where-Object -FilterScript {($_.GetFiles().Count -eq 0) -and $_.GetDirectories().Count -eq 0} | foreach ($_) {remove-item $_.fullname}

if ($clrrcl -eq 1) { Clear-RecycleBin -Confirm:$False }