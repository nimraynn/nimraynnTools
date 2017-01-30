### nimraynnTools PowerShell Module Pack

### Main Module File
### Module Version 1.1
### Last Updated: 30.01.2017

# $functionDir: Where are the functions stored?
$functionsDir = Join-Path -Path $PSScriptRoot -ChildPath 'Functions' -Resolve

# $doNotImport: Start an array to list the functions we don't want to import.
#               Make it blank to start with. We'll add to it later dependant on what the user wants.
$doNotImport = @{ }

# Open the $functionsDir and find all the .ps1 files present
# Check if we asked not to import it, then write a verbose message to say that we're going to import the rest
Get-ChildItem -Path $functionsDir -Filter '*.ps1' | 
    Where-Object { -not $doNotImport.Contains($_.Name) } |
        ForEach-Object {
            Write-Host ("Importing function: {0}" -f $_.Name.Split("."))
                . $_.FullName | Out-Null
        }

# Test the module manifest is correct
$module = Test-ModuleManifest -Path (Join-Path -Path $PSScriptRoot -ChildPath 'nimraynnTools.psd1' -Resolve)

# Check if a valid manifest was returned
if( -not $module )
{
    
    # If not, kill it now
    return
    
}

# If all is well, then export all the functions listed in $module
# This should be anything listed in the FunctionsToExport section of the manifest
Export-ModuleMember -Alias '*' -Function ([string[]]$module.ExportedFunctions.Keys)