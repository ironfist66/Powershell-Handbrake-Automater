# HandBrakeCLI-Auto

This script is to automate re-encoding downloads before sending to sonarr for import.

Once the variables and Handbrake settings have been set within the script, you can run this as a scheduled task or run it manually.

An impotant notice:
In order for the script to work, in the handbrake arguments you MUST use the following code for the input and output triggers:
-i `"$oldfile`" -o `"$newfile`"

Other arguments can (and should) be put before and after these (see handbrake documentation for relevant triggers and details)
