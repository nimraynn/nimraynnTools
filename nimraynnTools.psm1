### nimraynnTools PowerShell Module Pack

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

# Test the module manifest 
$module = Test-ModuleManifest -Path (Join-Path -Path $PSScriptRoot -ChildPath 'nimraynnTools.psd1' -Resolve)
if( -not $module )
{
    return
}

Export-ModuleMember -Alias '*' -Function ([string[]]$module.ExportedFunctions.Keys)