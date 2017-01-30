# nimraynnTools ChangeLog

Last Updated: 27.01.17 by @nimraynn

##### Version 1.1 - 30.0.17
* Split functions into individual script files
* Old nimraynnTools.psm1 scrapped & new file written to import modules from \functions\ directory
* Module manifest nimraynnTools.psd1 created

##### Version 1.0 - 27.01.17
* Initial version
* Contains the following functions:
    * Compare-UptimePassword
    * Connect-Office365
    * Disable-RDP
    * Enable-RDP
    * Export-ADGroup
    * Export-SecurePassword
    * Restart-UptimeWeb
    * Set-UptimePassword

## Functions

### Function: Compare-UptimePassword
Compares the currently set Uptime agent password to a supplied password.
##### Version 1.1 - 26.01.17
* Renamed from Check-UptimePassword to meet approved verb rules
* Added error hangling to the connection setup
* Tidied code & added comments

##### Version 1.0 - 09.06.16
* Initial version

### Function: Connect-Office365
Creates a connection to Office 365 for PowerShell remoe administration
##### Version 1.1 - 27.01.17
* Added connection check functionality
* Commented code

##### Version 1.0
* Initial version

### Function: Disable-RDP
Disables the remote desktop protocol on the specified machine
##### Version 1.1 - 27.01.17
* Split from one script into two individual functions (Disable-RDP & Enable-RDP)

##### Version 1.0 - 27.06.17
* Initial version

### Function: Enable-RDP
Enables the remote desktop protocol on the specified machine
##### Version 1.1 - 27.01.17
* Split from one script into two individual functions (Disable-RDP & Enable RDP)

##### Version 1.0 - 27.06.16
* Initial version

### Function: Export-ADGroup
Exports members of a specified group within Active Directory to a CSV file
##### Version 1.1 - 27.01.2017
* Renamed from AdMembers to Export-ADGroup to meet approved verb rules
* Removed redundant -AllUserInfo parameter
* Fixed bug that left a blank line in the CSV file where a disabled user would otherwise have been listed when -NoDisabled is specified
* Added parameter to specify your own filename 

##### Version 1.0 - 13.07.16
* Initial version

### Function: Export-SecurePassword
Converts a password to a SecureString, then outputs the text equivalent
##### Version 1.0 - 26.01.17
* Initial version

### Function: Restart-UptimeWeb
Restarts "Uptime Web Server" service on specified host
##### Version 1.0 - 27.01.17
* Initial version

### Function: Set-UptimePassword
Sets the Uptime agent password on the specified machine(s)
##### Version 1.3 - 27.01.17
* Added feature to specify individual or list of servers
* Added extra error handling
* Tidied code & added new comments

##### Version 1.2 - 23.06.16
* Fixed an error catching issue where Access Denied to start "Remote Registry" service was not caught and parsed accordingly
* If "Remote Registry" was stopped when the script was launched, the script now goes back and stops it again when it has completed its task, rather than leaving it running

##### Version 1.0 - 18.05.16
* Initial version
