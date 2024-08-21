<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2021 v5.8.192
	 Created on:   	8/12/2021 10:20 AM
	 Created by:   	Justin DeBusk
	 Organization: 	Atlas Network Services, LLC.
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



Clear-Host

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null # PowerShell only defines a default drive for HKCU & HKLM, so you have to create one for other keys

$regKey = "{22877a6d-37a1-461a-91b0-dbda5aaebc99}"
$regKeyPath01 = "HKCR:\CLSID\$regKey\ShellFolder"
$regKeyPath02 = "HKCR:\WOW6432Node\CLSID\$regKey\ShellFolder"

$currentKeyACL01 = Get-Acl -Path $regKeyPath01 | Select-Object *
$currentKeyACL02 = Get-Acl -Path $regKeyPath02 | Select-Object *

$aclRegKeyPath01 = Get-Acl -Path $regKeyPath01
$aclRegKeyPath02 = Get-Acl -Path $regKeyPath02
$group = New-Object System.Security.Principal.NTAccount ("Builtin", "Administrators")
$aclRegKeyPath01.SetOwner($group)
$aclRegKeyPath02.SetOwner($group)

Write-Host "Checking ownership of Registery Keys..." -ForegroundColor DarkBlue

if ($currentKeyACL01.Owner -eq "NT Authority\SYSTEM") { Write-Host "`nSetting ownership of HKCR:\CLSID\$regKey\ShellFolder to Administrators" -ForegroundColor DarkBlue; Set-Acl -Path $regKeyPath01 -AclObject $aclRegKeyPath01 -Verbose }
if ($currentKeyACL02.Owner -eq "NT Authority\SYSTEM") { Write-Host "`nSetting ownership of HKCR:\WOW6432Node\CLSID\$regKey\ShellFolder" -ForegroundColor DarkBlue; Set-Acl -Path $regKeyPath02 -AclObject $aclRegKeyPath02 -Verbose }

Write-Host "`nChanging the registry vaules..." -ForegroundColor DarkBlue

try
{
	Set-ItemProperty -Path $regKeyPath01 -Name "Attributes" -Value "70010020" -ErrorAction Stop
	Set-ItemProperty -Path $regKeyPath02 -Name "Attributes" -Value "70010020" -ErrorAction Stop
}
catch
{
	Write-Host "`nYou don't have permission to the registry key(s)." -ForegroundColor DarkRed
}

Start-Sleep -Seconds 20

#Get-ItemPropertyValue -Path HKCR:\CLSID\$saveAsKey\ShellFolder -Name "Attributes"
#Get-ItemPropertyValue -Path HKCR:\WOW6432Node\CLSID\$saveAsKey\ShellFolder -Name "Attributes"
#Get-Acl -Path HKCR:\WOW6432Node\CLSID\$saveAsKey\ShellFolder | Select-Object "Owner"
#Set-Acl -Path HKCR:\CLSID\$saveAsKey\ShellFolder -AclObject $acl -Verbose -WhatIf