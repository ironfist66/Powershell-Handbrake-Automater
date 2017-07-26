# HandBrakeCLI-Auto

This script is to automate re-encoding downloads before sending to sonarr for import.

To use this script, first run Setup.ps1 from an elevated powershell session.  
You may need to use 'Set-ExecutionPolicy Unrestricted' before windows will allow the script to be run.
Alternatively, you can open the script using a .bat file and using the -ExecutionPolicy Bypass parameter.
(an example is in this repo)

The Setup.ps1 will create a new registry key with 2 DWords inside that the script uses to check if it is being run or not.

Open the Encode-Delete-Github.ps1 and change the details at the top to your own,

Amend the example .bat file to the call the Encode-Delete-Github.ps1 script from the location that you have saved it, and then set your download client to open the bat file on download completion.

The .bat will open the powershell script in the background, and then the powershell script will open HandBrakeCLI in the background as well.
