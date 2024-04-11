################################################################################################################
###                                                                                                          ###
### WARNING: This file is automatically generated DO NOT modify this file directly as it will be overwritten ###
###                                                                                                          ###
################################################################################################################

<#
.NOTES
    Author         : MyDrift @mydrift-user
    GitHub         : https://github.com/mydrift-user
    ?              : pnp powershell instead of Get-Credential?
    TODO           : create session without prequisits on remote machine
    TODO           : make locally accessable (elevated shell start fetch code from saved source instead of from the website the second time, ability to make local shortcuts)
    TODO           : if network available, show apps to install. else notify user and still let him make tweaks ...
    TODO           : delete logs older than 30 days | create config for that (checkbox in settings tab (rename sources to settings) rename sources as subtab)
    TODO           : package as .exe (github & website)
    TODO           : save an additional script and put it in task scheduler. after 30 days of not running the script it deleats the logs, the task and itself.
#>

# check if codes are running in an elevated session. if not, restart the script in an elevated session
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # If not elevated, relaunch the script in a new elevated PowerShell session
    #TODO save script in directory, change escapedcommand to run that saved script instead of rerequest code.
    $escapedCommand = 'irm mdiana.dev/win | iex'
    Start-Process PowerShell -ArgumentList "-Command", $escapedCommand -Verb RunAs
    exit
}

Write-Host "

MMMMMMMM               MMMMMMMM    DDDDDDDDDDDDDD        
M:::::::M             M:::::::M    D:::::::::::::DDD     
M::::::::M           M::::::::M    D::::::::::::::::DD   
M:::::::::M         M:::::::::M    DDD:::::DDDDD::::::D  
M::::::::::M       M::::::::::M       D:::::D   D::::::D 
M:::::::::::M     M:::::::::::M       D:::::D    D::::::D
M:::::::M::::M   M::::M:::::::M       D:::::D     D::::::D
M::::::M M::::M M::::M M::::::M       D:::::D     D::::::D
M::::::M  M::::M::::M  M::::::M       D:::::D     D::::::D
M::::::M   M:::::::M   M::::::M       D:::::D     D::::::D
M::::::M    M:::::M    M::::::M       D:::::D    D::::::D
M::::::M     MMMMM     M::::::M       D:::::D   D::::::D 
M::::::M               M::::::M    DDD:::::DDDDD::::::D  
M::::::M               M::::::M    D::::::::::::::::DD   
M::::::M               M::::::M    D:::::::::::::DDD     
MMMMMMMM               MMMMMMMM    DDDDDDDDDDDDDD        


========Mattia Diana========

=====Powershell Toolbox=====
=======Managing Device======


"


$dateTime = Get-Date -Format "dd-MM-yyyy_HH-mm-ss"

Start-Transcript -Path "C:\Windows\WinToolBox\Logs\manager_$dateTime.log" -Append
#Get-Content "C:\Windows\WinToolbox\Logs\manager_$dateTime.log"


# Load WPF and XAML libraries
Add-Type -AssemblyName PresentationFramework
# Header="Your Header Here"
# WPF GUI Design in XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PowerShell Remote Manager" Height="450" Width="800">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*" />
            <ColumnDefinition Width="2*" />
        </Grid.ColumnDefinitions>

        <Expander ExpandDirection="Right" IsExpanded="False">
            <Grid Grid.Column="0">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto" /> <!-- For static controls: TextBox and Buttons -->
                    <RowDefinition Height="*" /> <!-- For ScrollViewer, will take up remaining space -->
                </Grid.RowDefinitions>

                <StackPanel Grid.Row="0" Margin="10">
                    <TextBox Name="txtHostname" />
                    <Button Name="btnAdd" Content="Add" />
                    <Button Name="btnRemove" Content="Remove Selection" />
                </StackPanel>

                <!-- ScrollViewer in a separate row, taking up the remaining space -->
                <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Visible">
                    <StackPanel Name="panelDevices" />
                </ScrollViewer>
            </Grid>
        </Expander>
        
        <TabControl Grid.Column="1" Margin="10">
            <TabItem Header="Windows">
                <!-- Nested TabControl for the three new tabs -->
                <TabControl>
                    <TabItem Header="Applications">
                        <Grid> <!-- Ein Grid als Container für die gesamte Struktur -->
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/> <!-- Reihe für die Buttons -->
                                <RowDefinition Height="*"/> <!-- Reihe für den ScrollViewer -->
                            </Grid.RowDefinitions>

                            <!-- Buttons oben im Grid -->
                            <StackPanel Grid.Row="0" Orientation="Horizontal" HorizontalAlignment="Left" Margin="10">
                                <Button Name="btnInstallSelection" Content="Install Selection" Margin="5"/>
                                <Button Name="btnUninstallSelection" Content="Uninstall Selection" Margin="5"/>
                                <Button Name="btnUpdateSelection" Content="Update Selection" Margin="5"/>
                                <Button Name="btnShowInstalled" Content="Show Installed" Margin="5"/>
                            </StackPanel>

                            <!-- ScrollViewer für die Applikationsliste in der zweiten Reihe des Grids -->
                            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                                <StackPanel Name="appspanel">
                                    <!-- Applikationsliste -->
                                </StackPanel>
                            </ScrollViewer>
                        </Grid>
                    </TabItem>
                    <TabItem Header="Tweaks">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel Name="tweakspanel">
                                <!-- Tweaks -->
                                <TextBlock Text="Light/Dark Mode" FontWeight="Bold" Margin="5"/>
                                <Button Name="btnEnableLightDarkMode" Content="Enable Dark Mode" Margin="5"/>
                                <Button Name="btnDisableLightDarkMode" Content="Disable Dark Mode" Margin="5"/>

                                <TextBlock Text="Bing Search in Start Menu" FontWeight="Bold" Margin="5"/>
                                <Button Name="btnEnableBingSearch" Content="Enable Bing Search" Margin="5"/>
                                <Button Name="btnDisableBingSearch" Content="Disable Bing Search" Margin="5"/>

                                <TextBlock Text="Mouse Acceleration" FontWeight="Bold" Margin="5"/>
                                <Button Name="btnEnableMouseAcceleration" Content="Enable Mouse Acceleration" Margin="5"/>
                                <Button Name="btnDisableMouseAcceleration" Content="Disable Mouse Acceleration" Margin="5"/>

                                <Button Name="btnCreateShortcut" Content="Create Shortcut" Margin="5"/>
                            </StackPanel>
                        </ScrollViewer>
                    </TabItem>
                </TabControl>
            </TabItem>
            <TabItem Header="Sources">
                <StackPanel Margin="10">
                    <DockPanel LastChildFill="False">
                        <TextBox Name="txtNewSource" DockPanel.Dock="Left" Width="200" Margin="0,0,5,10"/>
                        <ComboBox Name="cmbSourceType" Width="120" Margin="0,0,5,10">
                            <ComboBoxItem Content="Application"/>
                            <ComboBoxItem Content="Tweak"/>
                        </ComboBox>
                        <Button Name="btnAddSource" Content="Add" Width="75" Margin="5,0,0,10"/>
                    </DockPanel>
                    <TextBlock Margin="0,20,0,0" FontWeight="Bold">Current Sources:</TextBlock>
                    <ScrollViewer VerticalScrollBarVisibility="Visible">
                        <StackPanel Name="panelSources" />
                    </ScrollViewer>
                    <Button Name="btnDeleteSource" Content="Delete Source" Margin="10"/>
                </StackPanel>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@

# Parse the XAML
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Access controls from the parsed XAML
$txtHostname = $window.FindName("txtHostname")
$btnAdd = $window.FindName("btnAdd")
$btnRemove = $window.FindName("btnRemove")
$panelDevices = $window.FindName("panelDevices")
$btnRun = $window.FindName("btnRun")
$txtNewSource = $window.FindName("txtNewSource")
$cmbSourceType = $window.FindName("cmbSourceType")
$btnAddSource = $window.FindName("btnAddSource")
$lstSources = $window.FindName("lstSources")
$panelSources = $window.FindName("panelSources")
$btnDeleteSource = $window.FindName("btnDeleteSource")
$btnAddSource.Add_Click({ Add-Source })
$btnDeleteSource.Add_Click({ Remove-Source })
$btnAdd.Add_Click({ Add-Device })
$btnRemove.Add_Click({ Remove-Device })
$btnInstallSelection = $window.FindName("btnInstallSelection")
$btnUninstallSelection = $window.FindName("btnUninstallSelection")
$btnUpdateSelection = $window.FindName("btnUpdateSelection")
$btnShowInstalled = $window.FindName("btnShowInstalled")
$btnInstallSelection.Add_Click({ Install-Selection })
$btnUninstallSelection.Add_Click({ Uninstall-Selection })
$btnUpdateSelection.Add_Click({ Update-Selection })
$btnShowInstalled.Add_Click({ Show-Installed })


# Light/Dark Mode
$btnEnableLightDarkMode = $window.FindName("btnEnableLightDarkMode")
$btnDisableLightDarkMode = $window.FindName("btnDisableLightDarkMode")

$btnEnableLightDarkMode.Add_Click({ Enable-DarkMode })
$btnDisableLightDarkMode.Add_Click({ Disable-DarkMode })

# Bing Search
$btnEnableBingSearch = $window.FindName("btnEnableBingSearch")
$btnDisableBingSearch = $window.FindName("btnDisableBingSearch")

$btnEnableBingSearch.Add_Click({ Enable-BingSearch })
$btnDisableBingSearch.Add_Click({ Disable-BingSearch })

# Mouse Acceleration
$btnEnableMouseAcceleration = $window.FindName("btnEnableMouseAcceleration")
$btnDisableMouseAcceleration = $window.FindName("btnDisableMouseAcceleration")

$btnEnableMouseAcceleration.Add_Click({ Enable-MouseAcceleration })
$btnDisableMouseAcceleration.Add_Click({ Disable-MouseAcceleration })

# Shortcut Creation
$btnCreateShortcut = $window.FindName("btnCreateShortcut")
$btnCreateShortcut.Add_Click({ Create-Shortcut })



if (-not(Test-Connection 8.8.8.8 -Quiet -Count 1)) {
    #hide applications tab
    Write-Host "Hide Applications Tab"
}





function Install-Selection {
    write-host "installing selection .."
}

function Uninstall-Selection {

    write-host "uninstalling selection .."
}

function Update-Selection {
    write-host "updating .."
}

function Show-Installed {
    write-host "showing installed .."
}

function Enable-DarkMode {
    $scriptBlock = {
        # PowerShell command to enable dark mode
    }
    Invoke-RemoteCommand -ScriptBlock $scriptBlock
}

function Disable-DarkMode {
    $scriptBlock = {
        # PowerShell command to disable dark mode
    }
    Invoke-RemoteCommand -ScriptBlock $scriptBlock
}

function Invoke-RemoteCommand {
    param(
        [ScriptBlock]$ScriptBlock
    )
    $selectedDevices = $panelDevices.Children | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Content }
    foreach ($device in $selectedDevices) {
        Invoke-Command -ComputerName $device -ScriptBlock $ScriptBlock
    }
}


function Create-Shortcut {
	# ************************************************
	#
	$desktopPath = "$($env:USERPROFILE)\Desktop"
	# Specify the target PowerShell command
	$command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command 'irm mdiana.dev/win | iex'"
	# Specify the path for the shortcut
	$shortcutPath = Join-Path $desktopPath 'WinToolBox.lnk'
	# Create a shell object
	$shell = New-Object -ComObject WScript.Shell
	
	# Create a shortcut object
	$shortcut = $shell.CreateShortcut($shortcutPath)

	if (Test-Path -Path "c:\Windows\WinToolBox\logo.png")
	{
		$shortcut.IconLocation = "c:\Windows\WinToolBox\logo.png"
	}
	
	# Set properties of the shortcut
	$shortcut.TargetPath = "powershell.exe"
	$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
	# Save the shortcut
	$shortcut.Save()
	Write-Host "Shortcut created at: $shortcutPath"
	# 
	# ************************************************
}





$jsonUrls = @(
    "https://raw.githubusercontent.com/ChrisTitusTech/winutil/main/config/applications.json"
    #"https://raw.githubusercontent.com/MyDrift-user/WinToolbox/main/apps.json"
)

$configPath = "C:\Windows\WinToolbox\WinToolBox.config"
if (Test-Path $configPath) {
    $savedSourceEntries = Get-Content $configPath
    foreach ($entry in $savedSourceEntries) {
        $checkbox = New-Object System.Windows.Controls.CheckBox
        $checkbox.Content = $entry
        $checkbox.Margin = New-Object System.Windows.Thickness(5)
        $panelSources.Children.Add($checkbox)
    }
}

# Initialize a hashtable to store applications by category
$appsByCategory = @{}

# Iterate over the URLs and fetch JSON content from each
foreach ($jsonUrl in $jsonUrls) {
    $jsonContent = Invoke-WebRequest -Uri $jsonUrl -UseBasicParsing | ConvertFrom-Json

    # Organize applications by category
    foreach ($app in $jsonContent.PSObject.Properties) {
        $category = $app.Value.category
        if (-not $category) {
            $category = "Uncategorized" # Assign a default category if null or empty
        }

        if (-not $appsByCategory.ContainsKey($category)) {
            $appsByCategory[$category] = @()
        }
        $appsByCategory[$category] += $app
    }
}

# Correct XML manipulation
$appspanel = $window.FindName("appspanel")



# Clear existing items in appspanel to avoid duplicates
$appspanel.Children.Clear()

# Populate the appspanel with categories and their applications, each in an Expander
foreach ($category in $appsByCategory.Keys) {
    $expander = New-Object System.Windows.Controls.Expander
    $expander.Header = $category
    $expander.IsExpanded = $true

    $stackPanel = New-Object System.Windows.Controls.StackPanel

    # Add application checkboxes under this category
    foreach ($app in $appsByCategory[$category]) {
        $checkBox = New-Object System.Windows.Controls.CheckBox

        # Create a StackPanel to hold the text and the hyperlink
        $innerStackPanel = New-Object System.Windows.Controls.StackPanel
        $innerStackPanel.Orientation = "Horizontal"

        # Create a TextBlock for the app's content
        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $app.Value.content

        # Add the TextBlock to the inner StackPanel
        $innerStackPanel.Children.Add($textBlock) | Out-Null

        # Add ToolTip
        $toolTip = New-Object System.Windows.Controls.ToolTip
        $toolTip.Content = $app.Value.description
        $checkBox.ToolTip = $toolTip

        $checkBox.Content = $innerStackPanel
        $checkBox.Margin = New-Object System.Windows.Thickness(5)
        $stackPanel.Children.Add($checkBox) | Out-Null

                # Create the hyperlink
        $hyperlink = New-Object System.Windows.Documents.Hyperlink
        $hyperlink.Inlines.Add(" ?")
        $hyperlink.NavigateUri = New-Object System.Uri($app.Value.link)

        # Attach an event handler to the hyperlink
        $hyperlink.Add_RequestNavigate({
            param($sender, $e)
            Start-Process $e.Uri.AbsoluteUri
        })
        
        # Add the Hyperlink to the TextBlock
        $textBlock.Inlines.Add($hyperlink)

        # Remove the underline from the hyperlink
        $hyperlink.TextDecorations = $null
    }

    $expander.Content = $stackPanel
    $appspanel.Children.Add($expander) | Out-Null
}


# Window-level event handler for hyperlink clicks
$window.Add_PreviewMouseLeftButtonDown({
    $pos = [Windows.Input.Mouse]::GetPosition($window)
    $hitTestResult = [Windows.Media.VisualTreeHelper]::HitTest($window, $pos)

    if ($hitTestResult -and $hitTestResult.VisualHit -is [System.Windows.Documents.Hyperlink]) {
        $hyperlink = $hitTestResult.VisualHit
        if ($hyperlink.NavigateUri) {
            Start-Process $hyperlink.NavigateUri.AbsoluteUri
        }
    }
})

function Add-Source {
    $newSource = $txtNewSource.Text
    if (-not $newSource) { return }  # Check if the new source is not empty

    # Add the new source to the configuration file
    Add-Content -Path "C:\Windows\WinToolBox.config" -Value $newSource

    # Create a new CheckBox for the new source
    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.Content = $newSource
    $checkbox.Margin = New-Object System.Windows.Thickness(5)

    # Add the CheckBox to the StackPanel for sources
    $panelSources.Children.Add($checkbox) | Out-Null

    # Clear the input field after adding the source
    $txtNewSource.Text = ""
}


function Remove-Source {
    # Create an array to hold sources that will remain
    $remainingSources = @()

    # Iterate backwards through the StackPanel children because we'll be modifying the collection
    for ($i = $panelSources.Children.Count - 1; $i -ge 0; $i--) {
        $item = $panelSources.Children[$i]
        if ($item.IsChecked) {
            # If the item is checked, remove it from the StackPanel
            $panelSources.Children.RemoveAt($i)
        } else {
            # If not checked, this source should remain in the configuration file
            $remainingSources += $item.Content
        }
    }

    # Update the configuration file with remaining sources
    Set-Content -Path "C:\Windows\WinToolBox.config" -Value $remainingSources
}

# Device management functions
function Add-Device {
    $hostname = $txtHostname.Text
    #if (-not $hostname) { return }
    #if ($env:COMPUTERNAME) { return } #TODO Better dublicate detection
    if (Test-Connection $hostname -Quiet -Count 1) { 
        $checkbox = New-Object System.Windows.Controls.CheckBox
        $checkbox.Content = $hostname
        $checkbox.Margin = New-Object System.Windows.Thickness(5)
        $panelDevices.Children.Add($checkbox) | Out-Null
    } else {
        Write-Host "Cannot reach the device"
    }
}

function Remove-Device {
    $selectedDevices = $panelDevices.Children | Where-Object { $_.IsChecked -eq $true }
    foreach ($device in $selectedDevices) {
        $panelDevices.Children.Remove($device)
    }
}


# Add the current device to the list of devices
$checkbox = New-Object System.Windows.Controls.CheckBox
$checkbox.Content = $env:COMPUTERNAME
$checkbox.Margin = New-Object System.Windows.Thickness(5)
$panelDevices.Children.Add($checkbox) | Out-Null
Write-Host "Connected with: $env:COMPUTERNAME"


# Show the GUI
$window.ShowDialog() | Out-Null


