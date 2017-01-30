### nimraynnTools PowerShell Module Pack

### Function: Connect-Office365
### Version: 1.1
### Updated: 27/01/2017

function Connect-Office365 {
    
    <#
    .Synopsis
        Creates a connection to Office 365 for PowerShell remote administration.
        
    .Description
        Creates a connection to Office 365 for PowerShell remote administration.
        
    .Example
        Connect-Office365
    
    #>
    
    # Write a message to say we're testing connectivity
    Write-Host "Checking Office 365 connectivity ... " -NoNewLine
    
    # Start error handling
    try {
        
        # Test if we have a command called Get-Mailbox
        # If we do, we've already connected in this session
        $connCheck = Get-Command Get-Mailbox -ErrorAction Stop
        
        # Check if we returned a $true result
        if ($connCheck) {
            
            # Write a message to say we're already connected
            Write-Host "Already connected!" -ForegroundColor Green
            
            # Kill the function
            Return
            
        }
    
    # Catch any errors    
    } catch [System.Exception] {
        
        # If we caught an error, we're not connected.
        # Write a yellow message to say we're not connected
        Write-Host "Not connected!" -ForegroundColor Yellow -BackgroundColor Black
        
        # Write a message to tell us we're trying to connect
        Write-Host "Connecting to Office 365 ... " -NoNewLine
        
        # Start error handling
        try {
            
            # Prompt the user for credentials
            $UserCredential = Get-Credential -Credential $null -ErrorAction Stop
        
            # Create an Exchange session to https://outlook.office365.com/powershell-liveid/
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
        
            # Import the session
            $StartSession = Import-PSSession $Session -ErrorAction Stop
        
        } catch [System.Exception] {
            
            # Write red error message to the console
            Write-Host "Error! $_" -ForegroundColor Red -BackgroundColor Black
            
            # Kill the function
            Return
            
        }
        # Start error handling
        try {
            
            # Check again if we have the Get-Mailbox command to prove we connected OK
            $connCheck2 = Get-Command Get-Mailbox -ErrorAction Stop
            
            # Check if we returned a $true result
            if ($connCheck2) {
                
                # Write a green message to say we're OK
                Write-Host "Connected!" -ForegroundColor Green
                
                # Kill the function
                Return
                
            }
        
        # Catch any errors    
        } catch [System.Exception] {
            
            # Write a red message to state the error
            Write-Host "Unable to connect! $_" -ForegroundColor Red -BackgroundColor Black
            
            # Kill the function
            Return
            
        }
        
    }
        
}