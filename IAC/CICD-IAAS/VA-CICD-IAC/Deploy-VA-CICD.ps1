# Requires -Version 3.0
# Content Version : 2018.02.15.001
# Creator - Steve Owens
<#
 .SYNOPSIS
    Deploy a CICD Service In Azure

 .DESCRIPTION
    Deploys a RDP and Jenkins CICD service on a Vnet within Azure
    The Powershell script and supporting ARM Template and ARM Template Parameter files must be located within the same directory.
    The run the process you must use the following command and implement the parameters based on the information below.
    
    ./Deploy-VA-CICD.ps1  

 .PARAMETER EnvName
    The enviroment name must only be DEV, UAT or PRD.

 .PARAMETER AppName
    Name of the Application to be deployed (No Spaces Allowed, please use (-) inplace of a space.

 .PARAMETER AppReleaseId
    The release version number - Rxxx.

 .PARAMETER Location

    The Microsoft Azure region to deploy the solution to - i.e WESTEUROPE.

 .PARAMETER adminUsername

    The administrator username for the virtual machines to be created.

 .PARAMETER adminPassword

    The administrator password for the virtual machines to be created.

 .PARAMETER ResourceGroupName

    A variable name made up of input parameters.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>
Param(
	[string] [Parameter(Mandatory=$true)] $EnvName,
	[string] [Parameter(Mandatory=$true)] $AppName,
    [string] [Parameter(Mandatory=$true)] $Location,
	[string] [Parameter(Mandatory=$true)] $adminUsername,
	[string] [Parameter(Mandatory=$true)] $adminPassword,
    [string] $ResourceGroupName = $EnvName + '-' + $AppName + '-RG',
    [string] $TemplateFile = 'azuredeploy.CICD.json',
    [string] $TemplateParametersFile = 'azuredeploy.CICD.parameters.json',
    [switch] $ValidateOnly
)

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ','_'), '3.0.0')
} catch { }

#Convert Password to Secure String
$SecurePassword = $adminPassword | ConvertTo-SecureString -AsPlainText -Force 

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Format-ValidationOutput {
    param ($ValidationOutput, [int] $Depth = 0)
    Set-StrictMode -Off
    return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @('  ' * $Depth + ': ' + $_.Message) + @(Format-ValidationOutput @($_.Details) ($Depth + 1)) })
}

$OptionalParameters = New-Object -TypeName Hashtable
$TemplateFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))


# Create or update the resource group using the specified template files and template parameters files
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Verbose -Force

if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                                                                  -TemplateFile $TemplateFile `
                                                                                  -TemplateParameterFile $TemplateParametersFile `
																				  -EnvName $EnvName `
																				  -AppName $AppName `
																				  -adminUsername $adminUsername `
																				  -adminPassword $SecurePassword `
                                                                                  @OptionalParameters)
    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else {
    New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                       -ResourceGroupName $ResourceGroupName `
                                       -TemplateFile $TemplateFile `
                                       -TemplateParameterFile $TemplateParametersFile `
									   -EnvName $EnvName `
									   -AppName $AppName `
									   -adminUsername $adminUsername `
									   -adminPassword $SecurePassword `
                                       @OptionalParameters `
                                       -Force -Verbose `
                                       -ErrorVariable ErrorMessages
    if ($ErrorMessages) {
        Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    }
}