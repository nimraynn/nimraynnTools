### nimraynnTools PowerShell Module Pack

### Function: Start-Countdown
### Version: 1.0
### Updated: 30.01.17

function Start-Countdown {
    
    <# 
    .Synopsis
        Starts a live countdown to a specified time

    .Description
        Starts a live countdown to a specified time. Hit CTRL+C to quit the timer

    .Parameter Time
        The time we are counting down until

    .Parameter Message
        The message to display when the countdown completes
        
    .Example
        Start-Countdown 16:00 "Countdown completed!"

    #>
    
    # Set some available parameters
    
    param ( 
        
        [Parameter(Mandatory=$true, Position=0)]        # Set the following parameter to be mandatory & assume the 0 position
        [string]$Time,                                  # -Time: What time are we counting down to?
        
        [Parameter(Mandatory=$true, Position=1)]        # Set the following parameter to be mandatory & assume the 1 position
        [string]$Message                                # -Message: What message do you want to display when we finish counting down?
        
    )
    
    # Get today's date
    $todaysDate = Get-Date -Format "dd MMMMM yyyy"
    
    Start-Sleep -Seconds 3
    
    # Join the current date with the specified $time to make a useable string
    $endTime = "$($todaysDate) $($time)"
    
    # Start a loop to check if the time is still lower than the specified $endTime
    while ( (Get-Date) -lt $endTime ) {
       
        #Work out how long we have remaining
        $timeRemaining = ([int](New-Timespan $(Get-Date) $endTime).TotalSeconds)
        
        # Write a progress bar with our countdown
        Write-Progress -Activity "Counting down to..." -Status "$endTime" -SecondsRemaining $timeRemaining
        
        # Sleep for 1 second before triggering the loop again
        Start-Sleep -Seconds 1 
        
    }
    
}