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

########################


#wpeutil reboot

