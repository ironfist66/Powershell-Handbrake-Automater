# HandBrakeCLI-Auto

This script is to automate re-encoding downloads before sending to sonarr for import.

To use this script, first run Setup.ps1 from an elevated powershell session.

The Setup.ps1 will create a new registry key with 2 DWords inside that the script uses to check if it is being run or not, and sets the permissions to Builin\Users - Full Control

Open the Encode-Delete-Github.ps1 and change the details at the top to your own,

Amend the example .bat file to the call the Encode-Delete-Github.ps1 script from the location that you have saved it, and then set your download client to open the bat file on download completion.

The .bat will open the powershell script in the background, and then the powershell script will open HandBrakeCLI in the background as well.
