#
# Install.ps1
#

Param(
  [string]$Tenant,
  [string]$Site,
  [string]$Username,
  [string]$Password
)

begin
{
Write-Host "Tenant: $Tenant"
Write-Host "Site: $Site"
Write-Host "User: $Username"
Write-Host "Password: $Password"

Write-Host "Started installation"

}

process
{

	$path = Split-Path -parent $MyInvocation.MyCommand.Definition


	$config = [xml](Get-Content $path/config.xml -ErrorAction Stop)



	if ($env:PSModulePath -notlike "*$path\Modules\*")
	{
		"Adding ;$path\Modules to PSModulePath" | Write-Debug 
		$env:PSModulePath += ";$path\Modules\"
	}

	Write-Host $env:PSModulePath

	$url = $Tenant + $Site

	$encpassword = convertto-securestring -String $Password -AsPlainText -Force

	$cred = new-object -typename System.Management.Automation.PSCredential `
			 -argumentlist $Username, $encpassword


	Connect-PnPOnline -Url $url -Credentials $cred 
	Write-Host "Connected to PnP Online"


	$sitesConfig = $config.Configurations.Configuration.Sites.Site

	foreach ($siteConfig in $sitesConfig)
	{
		$web = Get-PnPWeb
		$template = $sitesConfig.Template
		
		Write-Host "Applying template $template to $url"
		
		Set-PnPTraceLog -On -Level Debug
				

		Apply-PnPProvisioningTemplate -Web $web -Path "$path\Templates\$template\Home.xml" -ResourceFolder "$path\Templates\$template"

	}

	
	

	
	Write-Host "Applied template"

}

end
{
    Write-Host "Completed installation"
}


