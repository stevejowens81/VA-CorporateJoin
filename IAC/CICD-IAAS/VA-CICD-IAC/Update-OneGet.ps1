<#
    .NOTES
    ===========================================================================
     Created with:     PowerShell Studio 2014, Version 4.1.74
     Created on:       11/10/2014 4:06 PM     
     Company:          SAPIEN Technologies, Inc.
     Contact:          June Blender, juneb@sapien.com, @juneb_get_help
     Filename:         Update-OneGet.ps1
    ===========================================================================

    .SYNOPSIS
        Downloads, installs, and imports the latest OneGet module from GitHub.

    .DESCRIPTION
        Update-OneGet.ps1 downloads, installs, and (optionally) imports the
        latest experimental version of the OneGet module from http://OneGet.org,
        which is linked to the OneGet project in GitHub.

        The script downloads the OneGet.zip file from OneGet.org and saves it in
        your downloads folder, $home\Downloads. It unblocks the file, unzips it,
        and installs it in the directory specified by the Path parameter.

        If you include the optional Import parameter, the script imports the module
        into the current session.

        After running the script, to import the experimental version of OneGet into 
        any session, use the following command:
            Import-Module <path>\OneGet.psd1

        This script runs on Windows PowerShell 3.0 and later. 
    .PARAMETER  Path
        Specifies a directory where the script installs the module. This parameter is
        required. Enter the path to a directory. Do not include a .zip file name extension. 

        If the directory does not exist, the script creates it. If the directory exists, 
        the script deletes the directory contents before installing the module. This lets 
        you reuse the directory when updating.

        To prevent errors, specify a subdirectory of your Documents directory or a test 
        directory.

        CAUTION: Do not specify a path in $pshome\Modules. Installing the experimental build
                 of OneGet in this directory might prevent you from installing, uninstalling, 
                 or updating the official OneGet module from Microsoft.

    .PARAMETER  Import
        Imports the module into the current session after installing it. 

    .EXAMPLE
        .\Update-OneGet.ps1 -Path $home\Documents\Test\OneGet
        
        This command installs the newest OneGet module in the $home\Documents\Test\OneGet
        directory. To import it: Import-Module $home\Documents\Test\OneGet.psd1

    .EXAMPLE
        .\Update-OneGet.ps1 -Path $home\Documents\Test\OneGet -Import
        
        This command installs the newest OneGet module in the 
        $home\Documents\Test\OneGet    directory and imports it into the
        current session. 

    .EXAMPLE
        .\Update-OneGet.ps1 -Path $home\Documents\WindowsPowerShellModules\OneGet

        This command installs the newest OneGet module in the your current-user 
        Modules    directory. Windows PowerShell imports it automatically when you use a 
        command in the module, such as Find-Package.


    .OUTPUTS
        System.Management.Automation.PSCustomObject, System.Management.Automation.PSModuleInfo
        If you use the Import parameter, Update-OneGet returns a module object. Otherwise, it
        returns a custom object with the Path and LastWriteTime of the OneGet module manifest,
        OneGet.psd1
#>

#Requires -Version 3

Param
(
    [Parameter(Mandatory = $true)]
    [ValidateScript({$_ -notlike "*.zip" -and $_ -notlike "$pshome*" -and $_ -notlike "*System32*"})]
    [System.String]
    $Path,

    [Parameter(Mandatory=$false)]
    [Switch]
    $Import
)

#***************************#
#  Helper Functions         #
#***************************#

# Use this function on systems that do not have
# the Extract-Archive cmdlet (PS 5.0)
#
function Unzip-OneGetZip
{
    $shell = New-Object -ComObject shell.application
    $zip = $shell.NameSpace("$home\Downloads\OneGet.zip")
    if (!(Test-Path $Path)) {$null = mkdir $Path}
    foreach ($item in $zip.items())
    {
        $shell.Namespace($Path).Copyhere($item)
    }
}

#***************************#
#         Main              #
#***************************#
# Remove current OneGet from session
if (Get-Module -Name OneGet) {Remove-Module OneGet}

# Create the $Path path
if (!(Test-Path $Path))
{
    try
    {
        mkdir $Path | Out-Null
    }
    catch
    {
        throw "Did not find and cannot create the $Path directory."
    }
}
else
{
    dir $Path | Remove-Item -Recurse
}

#Download the Zip file to $home\Downloads
try
{
    Invoke-WebRequest -Uri http://oneget.org/oneget.zip -OutFile $home\Downloads\OneGet.zip
}
catch
{
    throw "Cannot download OneGet zip file from http://oneget.org"
}
if (!($zip = Get-Item -Path $home\Downloads\OneGet.zip)) 
{
    throw "Cannot find OneGet zip file in $home\Downloads"
}
else
{
    $zip | Unblock-File
    if (Get-Command Expand-Archive -ErrorAction SilentlyContinue)
    {
        $zip | Expand-Archive -DestinationPath $Path
    }
    else
    {
        Unzip-OneGetZip        
    }    
    
    if (!(Test-Path $Path\OneGet.psd1))
    {
        throw "Cannot find OneGet.psd1 in $Path"
    }

    if ($Import)
    {        
        Import-Module $Path\OneGet.psd1
        if ((Get-Module OneGet).ModuleBase -ne $Path)
        {
            throw "Failed to import the new OneGet module from $Path."
        }
        else
        {
            Get-Module OneGet
        }

    }        
    else
    {
        [PSCustomObject]@{Path = "$Path\OneGet.psd1"; Date = (dir $Path\OneGet.psd1).LastWriteTime}
    }
}
