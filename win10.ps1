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
$computerName = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName></ComputerName>
        </component>
    </settings>
</unattend>
"@

#################################Checking if laptop or desktop
if (Get-WmiObject -Class win32_battery -ComputerName .)
{
    $hardware = "LAP"
}
else 
{
    $hardware = "WKS"
}

##############################
# Checkingcountry
##############################
Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Please select your country code'
$main_form.Width = 400
$main_form.Height = 300
$main_form.AutoSize = $true
$main_form.StartPosition = 'CenterScreen'


$flp = New-Object System.Windows.Forms.FlowLayoutPanel
$flp.Name = 'ISO Country codes'
$flp.Size = "100,250"
$flp.FlowDirection = 'TopDown'
$flp.Location = '10,10'
$main_form.Controls.Add($flp)

'AZ','CH','CO','ES','FR','IN','PL','RU' | ForEach-Object {
	$rb = New-Object System.Windows.Forms.RadioButton
	$rb.Text = $_
	$rb.AutoSize = $true
    $flp.Controls.Add($rb)
}

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Name = 'Existing name'
$textBox.Location = '120,55'
$textBox.Size = '30,20'
$main_form.Controls.Add($textBox)

$label = New-Object System.Windows.Forms.label
$label.Location = '120,10'
$label.Size = '310,500'
$label.AutoSize = $true
$label.BackColor = "Transparent"
$label.Text = "If reimaging your computer `n- please enter existing computer number:"
$main_form.Controls.Add($label)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = 'OK'
$btn.DialogResult = 'OK'
$btn.Location = '300,230'
$main_form.Controls.Add($btn)

$main_form.ShowDialog()
$country = $main_form.Controls['ISO Country codes'].Controls | Where-Object{ $_.Checked } | Select-Object Text
$existingName = $main_form.Controls['Existing name'] | Select-Object Text

#combining name
$newComputerName = ("INEXTO" + $country.Text + $hardware + $existingName.Text)

#updating xml file
$xmlFile = "C:\Windows\Panther\Invoke-OSDSpecialize.xml"
[xml]$parent = Get-Content -Path $xmlFile
$parentnode = $parent.unattend.settings

$child = [xml] ($computerName)
$childNode = $child.SelectSingleNode("/*/*/*")
$childNode.ComputerName = $newComputerName
$importedNode = $parent.ImportNode($childNode,$true)
$parentnode.InsertAfter($importedNode, $parentnode.LastChild)
Write-Host("Modified XML to: $($parent.OuterXML)")
$parent.Save($xmlFile)


########################


#wpeutil reboot

