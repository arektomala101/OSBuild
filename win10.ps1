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
Start-OSDCloud -OSLanguage "en-us" -OSBuild "21H1" -OSEdition Enterprise -OSLicense Volume -SkipAutopilot -ZTI
Write-Host  -ForegroundColor Cyan "DImage deployment completed. Starting OSDCloud PostAction ..."
#Anything I want  can go right here and I can change it at any time since it is in the Cloud!!!!!

##########################
# Setting up xml file
##########################
$childString = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>ArekTest</ComputerName>
        </component>
    </settings>
</unattend>
"@

$xmlFile = "C:\Windows\Panther\Invoke-OSDSpecialize.xml"
[xml]$parent = Get-Content -Path $xmlFile
$parentnode = $parent.unattend.settings

$child = [xml] ($childString)
$childnode = $child.SelectSingleNode("/*/*/*")
$importedNode = $parent.ImportNode($childNode,$true)
$parentnode.InsertAfter($importednode, $parentnode.LastChild)
Write-Host("Modified XML to: $($parent.OuterXML)")
$parent.Save($xmlFile)
########################


#wpeutil reboot

