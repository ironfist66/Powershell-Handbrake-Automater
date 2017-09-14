# HandBrakeCLI-Auto


This is a script I created to automate re-encoding tasks before being picked up by sonarr.  
It can also be used without the sonarr integration if the sonarr option is set to 0


The script will automatically find files in the source folder, remove .nfo .txt and image files and move the grabbed files to a new 'In Progress' folder.  
This folder is picked up again by the script and passed one by one in to the handbrake CLI.


Upon completion all empty directories including the 'In Progress' directory are removed.


Sonarr is then told to do an episode scan for each of the new files in the output directory.  
This was set up to work without the use of the drone factory so that when the drone factory is removed from sonarr the script will still work.


### Handbrake Argument and Configuration


The handbrake arguments and settings can be set at the top, along with any other variables that the script needs to work.  
It also has the option to import a profile from the Handbrake GUI application if you already have a profile you would like to use.



### Variables Available  
##### Required variables

These are required for the script to work


```$sourcefolder``` - content you want to re-encode  
```$destinationfolder``` - where you want the completed files  
```$destinationlog``` - where you want the file completion log to go  
```$lockdest``` - where the script lock files go (used to determine if it is currently running or encoding)  
```$newfileext``` - your re-encoded file extension  
```$handargs``` - handbrake settings. do not add input and output arguments to this. It is filled in dynamically by the script  


##### Optional variables

set these to 0 to disable or 1 to enable functionality

```$recursive``` - recursively search source folder  
```$remold``` - remove source files after re-encode has completed  
```$clrrcl``` - clear recycle bin after script has finished  
```$sonarr``` - enable sonarr episode scan after script has finished  
   ```$sonarrurl``` - URL for sonarr (required if $sonarr enabled)  
   ```$sonarrapi``` - API for your sonarr installation (required if $sonarr enabled)  
```$changeaffinity``` - change the processor affinity for handbrake CLI  
   ```$decimal``` - choose which threads to use for the above (required if $changeaffinity enabled)  
```$import``` - import handbrake GUI profile. This overrides the $handargs variable  
   ```$handpro``` - name of the handbrake GUI profile  
```$hidden``` - hide the handbrake CLI window when re-encoding files  
