### nimraynnTools PowerShell Module Pack

### Function: Export-SecurePassword
### Version: 1.0
### Updated: 26.01.17

function Export-SecurePassword {

    <# 
    .Synopsis
        Converts a password to a SecureString, then outputs the text equivalent.

    .Description
        Converts a password to a SecureString, then outputs the text equivalent.
        Note: The SecureString can only be used by the user who generates it, on the computer
              they generated it on. It cannot be transferred to other users or computers. 

    .Parameter Password
        The plain-text password to convert.

    .Parameter File
        The file you should like to output your SecureString text to.
        
    .Parameter OutString
        Switch to output the final result to the console.
  
    .Example
        # Convert a password to a SecureString, then output the text equivalent to file.
        Export-SecurePassword -Password ThisIsAPassword -File my-secure-password.txt
        
    .Example
        # Convert a password to a SecureString, then output the text equivalent to file & console.
        Export-SecurePassword -Password ThisIsAPassword -File my-secure-password.txt -OutString

    #>
        
    # Set some avaialble paramters.
    param (
	    [Parameter(Position=1,Mandatory=$true)]     # Set the following parameter to be mandatory & make it the assumed position 1 parameter
	    [string]$Password,                          # -password: What is the password we want to convert to a SecureString?
        
        [Parameter(Position=2)]                     # Make the following parameter to be the assumed position 2 parameter
	    [string]$File = "passwd.txt",               # -file: What file name are we exporting the SecureString password to? If nothing supplied, assume "passwd.txt"
        
        [Parameter(Position=3)]                     # Make the following parameter to be the assumed position 3 parameter
        [switch]$OutString = $False                 # -OutString: Do you want to see the final string on the console?
    )

    # Tell us what we're doing
    Write-Host "Converting password to SecureString ... " -NoNewLine

    # Start error handling
    try {
        
        # Take the value of $password and convert it to a SecureString
        $securePassword = $password | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop | ConvertFrom-SecureString -ErrorAction Stop
        # Export the new $securePassword to file
        $securePassword | Out-File $file -ErrorAction Stop
       
        # Tell us everything was OK!
        Write-Host "OK!" -ForegroundColor green
        
        # Check if we need to display the string on the console
        if ($outString) {
            
            # Output the string to the console
            Write-Host "`r`nString: $securePassword"
            
        }
    
    # Catch any errors
    } catch [System.Exception] {
        
        # Output an error message 
        Write-Host "$_" -ForegroundColor Red -BackgroundColor Black   
    }

    # Write a blank line for aesthetics
    Write-Host ""

}