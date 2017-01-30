### nimraynnTools PowerShell Module Pack

### Function: Export-ADGroup
### Version: 1.1
### Updated: 27.01.17

function Export-ADGroup {
    
    <#
    .Synopsis
        Exports members of a specified group within Active Directory to a CSV file
        
    .Description
        Exports members of a specified group within Active Directory to a CSV file
    
    .Parameter GroupName
        The name of the group you would like to export
        
    .Parameter FileName
        The filename you would like to export the list to
        
    .Parameter NoDisabled
        Exclude disabled users from the results
        
    .Example
        Export-ADGroup -Group "Beck_Desktop Support" -FileName adexport.csv
    
    #>
    
    # Set some available parameters
    param (
        
        [Parameter(Mandatory=$true,Position=0)]     # Set the following parameter to be mandatory & position 0
        [string]$GroupName,                         # -GroupName: What AD group are we looking for?
        
        [Parameter(Mandatory=$true,Position=1)]     # Set the following parameter to be mandatory & position 1
        [string]$FileName,                          # -FileName: What file are we exporting the list to?
        
        [switch]$NoDisabled = $false                # -NoDisabled: Exclude disabled users
        
    )
    
    # Write a message to tell us what we're doing
    Write-Host "Exporting group members for: " -ForegroundColor Yellow -NoNewLine
    Write-Host "$GroupName`r`n"
    
    # Start error handling
    try {
        
        # Grab a list of group members for $groupName, sort them alphabetically by name and create an array
        $GroupMembers = Get-AdGroupMember -Identity $GroupName -ErrorAction Stop| sort name
    
    # Catch any errors    
    } catch [System.Exception] {
        
        # Write a red message to tell us the error
        Write-Host "Error! $_" -ForegroundColor Red -ForegroundColor Black
        
        # Kill the function
        Return
        
    }
    
    # Write a header for the members list
    Write-Host "Members:`r`n" -ForegroundColor Cyan
    
    # Create an empty array to store the formatted list of members
    $memberObjs = @()
    
    # Start a loop to run through each member we found
    foreach ($Member in $GroupMembers) {
        
        # Using the samAccountName value, find the AD user
        $adUser = Get-ADUser $member.samAccountName
        
        # Check if the user is disabled. Also check if we asked not to display disabled users
        # If we asked not to show disabled users, this whole section will essentially be ignored
        if ( ($adUser.Enabled -eq $false) -and (!$noDisabled) ) {

            # Display the user's name & samAccountName
            Write-Host "$($adUser.Name) ($($adUser.samAccountName))" -NoNewLine
            # Add a red [Disabled] tag
            Write-Host " [Disabled]" -ForegroundColor Red
            
            # Create a new object
            $memberObj = New-Object PSObject
           
            # Add the member to our object
            $memberObj | Add-Member -MemberType NoteProperty -Name "Name" -Value "$($adUser.Name) ($($adUser.samAccountName)) [Disabled]"
        
        # Otherwise, we expect the user is enabled            
        } elseif ($adUser.Enabled -eq $true) {
            
            # Display the user's name & samAccountName
            Write-Host "$($adUser.Name) ($($adUser.samAccountName))"
            
            # Create a new object
            $memberObj = New-Object PSObject
            
            # Add the member to our object
            $memberObj | Add-Member -memberType NoteProperty -name "Name" -value "$($adUser.Name) ($($adUser.samAccountName))"
                        
        }
        
        # Add the object to our array
        $memberObjs+= $memberObj
        
    }
    
    # Select the "Name" value from our object array & export it to a CSV file
    $memberObjs | Select-Object Name | Export-CSV $FileName -NoTypeInformation
    
}