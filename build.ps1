Import-Module PowerShellGet

#Publish to PSGallery and install/import locally

Publish-Module -Path .\poshFreshdesk -Repository PSGallery -Verbose
Install-Module -Name poshFreshdesk -Repository PSGallery -Force
Import-Module -Name poshFreshdesk -Force