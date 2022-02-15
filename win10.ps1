Write-Host  -ForegroundColor Cyan "Starting workstation build process ..."
Start-Sleep -Seconds 5

#Change Display Resolution for Virtual Machine
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Cyan "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}

#Make sure I have the latest OSD Content
Write-Host  -ForegroundColor Cyan "Updating OSD PowerShell Module"
Install-Module OSD -Force

Write-Host  -ForegroundColor Cyan "Importing OSD PowerShell Module"
Import-Module OSD -Force

#TODO: Spend the time to write a function to do this and put it here
Write-Host  -ForegroundColor Cyan "Ejecting ISO"
Write-Warning "That didn't work because I haven't coded it yet!"
#Start-Sleep -Seconds 5

#Start OSDCloud ZTI the RIGHT way
Write-Host  -ForegroundColor Cyan "Starting image deployment..."
Start-OSDCloud -OSLanguage "en-us" -OSBuild "21H1" -OSEdition Enterprise -OSLicense Volume -ZTI
Write-Host  -ForegroundColor Cyan "DImage deployment completed. Starting OSDCloud PostAction ..."
#Anything I want  can go right here and I can change it at any time since it is in the Cloud!!!!!

##########################
# Setting up xml file
##########################
$oobe = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-International-Core" processorArchitecture="wow64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <UserLocale>en-US</UserLocale>
    </component>
  </settings>
</unattend>
"@

#updating xml file
$xmlFile = "C:\Windows\Panther\Invoke-OSDSpecialize.xml"
[xml]$parent = Get-Content -Path $xmlFile
$parentnode = $parent.unattend.settings

$child = [xml] ($oobe)
$childNode = $child.SelectSingleNode("/*/*/*")
$importedNode = $parent.ImportNode($childNode,$true)
$parentnode.InsertAfter($importedNode, $parentnode.LastChild)
Write-Host("Modified XML to: $($parent.OuterXML)")
$parent.Save($xmlFile)
########################


#wpeutil reboot

