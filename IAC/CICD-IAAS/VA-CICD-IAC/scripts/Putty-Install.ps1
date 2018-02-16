<#
    .NOTES
    ===========================================================================
     Created with:     Visual Studio 2017
     Created on:       16/02/2018     
     Company:          BJSS Ltd
     Contact:          Steve Owens
     Filename:         Putty-Install.ps1
    ===========================================================================

    .SYNOPSIS
        Downloads, installs Putty tools

    .DESCRIPTION
        The script downloads and installs putty using the Update-OneGet powershell module.

        This script runs on Windows PowerShell 3.0 and later. 
#>

#Download and Install the Update-OneGet Powershell Module
icm $executioncontext.InvokeCommand.NewScriptBlock((New-Object Net.WebClient).DownloadString('/Update-OneGet.ps1')) -ArgumentList $home\Documents\WindowsPowerShellModules\OneGet
Import-Module $home\Documents\WindowsPowerShellModules\OneGet\OneGet.psd1

#Find and Install Putty
find-package *putty*
install-package putty -force
