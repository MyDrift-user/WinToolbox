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
    TODO           : Run on system boot -> task scheduler checks for windows version change and then runs the selected/needed tweaks.
#>


# check if codes are running in an elevated session. if not, restart the script in an elevated session
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # If not elevated, relaunch the script in a new elevated PowerShell session
    #TODO save script in directory, change escapedcommand to run that saved script instead of rerequest code.
    $escapedCommand = 'irm mdiana.win | iex'
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
Start-Transcript -Path "C:\Windows\WinToolBox\Logs\WinToolBox_$dateTime.log" -Append
#Get-Content "C:\Windows\WinToolbox\Logs\manager_$dateTime.log"


# Function to install and import PsIni module
function Ensure-PsIniModule {
    $moduleName = "PsIni"
    $module = Get-Module -ListAvailable -Name $moduleName

    # Check if the module is not installed
    if (-not $module) {
        # Install PsIni from the PowerShell Gallery
        Write-Host "Installing $moduleName module..."
        try {
            Install-Module -Name $moduleName -Repository PSGallery -Force -ErrorAction Stop
            Write-Host ""
            Write-Host "$moduleName module installed successfully."
        } catch {
            Write-Host "Failed to install $moduleName module. Error: $($_.Exception.Message)"
            return
        }
    }

    try {
        Write-Host ""
        Import-Module -Name $moduleName
        Write-Host "$moduleName module imported successfully."
    } catch {
        Write-Host ""
        Write-Host "Failed to import $moduleName module. Error: $($_.Exception.Message)"
    }
}
# Call the function to ensure PsIni module is ready
Ensure-PsIniModule

# Load WPF and XAML libraries
Add-Type -AssemblyName PresentationCore, WindowsBase, PresentationFramework
# Header="Your Header Here"
# WPF GUI Design in XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinToolbox" Height="450" Width="800">
    <Window.Resources>
        <Style x:Key="ToggleSwitchStyle" TargetType="{x:Type ToggleButton}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type ToggleButton}">
                        <Border x:Name="border" Width="50" Height="25" CornerRadius="12.5" BorderBrush="#00FFFFFF" BorderThickness="1"> <!-- or gray -->
                            <Grid x:Name="grid">
                                <!-- Toggle button (circle) is always white -->
                                <Ellipse Fill="White" Width="20" Height="20" Margin="1" HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <!-- Background changes to green when toggled on -->
                                <Setter TargetName="border" Property="Background" Value="#33a442" />
                                <Setter TargetName="grid" Property="HorizontalAlignment" Value="Right" />
                            </Trigger>
                            <Trigger Property="IsChecked" Value="False">
                                <!-- Background changes to red when toggled off -->
                                <Setter TargetName="border" Property="Background" Value="Red" />
                                <Setter TargetName="grid" Property="HorizontalAlignment" Value="Left" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <DockPanel LastChildFill="True">

        <Expander Name="DeviceMGMTexpander" ExpandDirection="Right" IsExpanded="False">
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
                <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Hidden">
                    <StackPanel Name="panelDevices" />
                </ScrollViewer>
            </Grid>
        </Expander>
        
        <TabControl Grid.Column="1" Margin="10">
            <TabItem Header="Windows">
                <!-- Nested TabControl for the three new tabs -->
                <TabControl x:Name="subTabControl">
                    <TabItem Header="Applications" x:Name="tabApplications">
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
                                <WrapPanel Name="appspanel" Orientation="Horizontal">
                                        <!-- Dynamically added CheckBoxes will be placed here -->
                                </WrapPanel>
                            </ScrollViewer>
                        </Grid>
                    </TabItem>
                    <TabItem Header="Tweaks">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel Name="tweakspanel">
                                <!-- Tweaks -->

                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Left">
                                    <ToggleButton Name="btnToggleDarkMode" Style="{StaticResource ToggleSwitchStyle}" Margin="10" IsChecked="False"/>
                                    <TextBlock Name="txtToggleStatus" VerticalAlignment="Center" Text="Systeme Theme"/>
                                </StackPanel>

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
    </DockPanel>
</Window>
"@

# Parse the XAML
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# URL to the ICO file
$iconUrl = "https://raw.githubusercontent.com/MyDrift-user/WinToolbox/main/logo.ico"
$iconPath = "C:\Windows\WinToolbox\assets\logo.ico"

# Ensure the directory exists
$directoryPath = [System.IO.Path]::GetDirectoryName($iconPath)
if (-not (Test-Path -Path $directoryPath)) {
    Write-Host "Creating directory: $directoryPath"
    New-Item -Path $directoryPath -ItemType Directory -Force
}

# Download the ICO file
try {
    Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath

    # Create an ImageSource from the ICO file
    $iconUri = New-Object System.Uri($iconPath)
    $iconBitmap = New-Object System.Windows.Media.Imaging.BitmapImage($iconUri)

    # Set the Window Icon
    $window.Icon = $iconBitmap

} catch {
    Write-Host "Failed to download & load the ICO file. Error: $($_.Exception.Message)"
}


# Access controls from the parsed XAML
$txtHostname = $window.FindName("txtHostname")
$btnAdd = $window.FindName("btnAdd")
$btnRemove = $window.FindName("btnRemove")
$panelDevices = $window.FindName("panelDevices")
$btnRun = $window.FindName("btnRun")

$subTabControl = $window.FindName("subTabControl")

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

$btnToggleDarkMode = $window.FindName("btnToggleDarkMode")

# Shortcut Creation
$btnCreateShortcut = $window.FindName("btnCreateShortcut")
$btnCreateShortcut.Add_Click({ Create-Shortcut })



$iniPath = "C:\Windows\WinToolBox\config.ini"
if (Test-Path $iniPath) {
    $iniContent = Get-IniContent -FilePath $iniPath
    $DeviceMGMTexpander = $window.FindName("DeviceMGMTexpander")
    if ($iniContent.DeviceMGMTexpander -and $iniContent.DeviceMGMTexpander.expanded -eq "True") {
        $DeviceMGMTexpander.IsExpanded = $true
    } else {
        $DeviceMGMTexpander.IsExpanded = $false
    }
    #Write-Host "Loaded expander state from $iniPath"
}





# Check for Internet connection before showing the window
$tabApplications = $window.FindName("tabApplications")  # Get the Applications tab reference

if (-not (Test-Connection 8.8.8.8 -Quiet -Count 1)) {
    $tabApplications.Visibility = [System.Windows.Visibility]::Collapsed
    $subTabControl.SelectedIndex = 1
    Write-Host "No Internet Connection: Hiding Applications Tab"
} else {
    $tabApplications.Visibility = [System.Windows.Visibility]::Visible
    $subTabControl.SelectedIndex = 0
    #Write-Host "Internet Connection Detected: Displaying Applications Tab"
}



function Install-PackageManagers {
    # Check if Chocolatey is installed
    if (-not (Get-Command "choco" -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey is not installed. Installing..."
        # Installing Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey is already installed."
    }
    
}


function Install-Selection {
    Install-PackageManagers

}

function Uninstall-Selection {

    Install-PackageManagers

}

function Update-Selection {
    Install-PackageManagers
    Write-Host ""
    Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "winget upgrade --all" -WindowStyle Minimized
    Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "choco upgrade all -y" -WindowStyle Minimized

}

function Show-Installed {
    # List all general installed applications from the registry
    Write-Host "General Installed Applications:"
    $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
            Where-Object { $_.DisplayName -ne $null } |
            Select-Object DisplayName, DisplayVersion |
            Sort-Object DisplayName

    foreach ($app in $apps) {
        Write-Host "$($app.DisplayName) - Version: $($app.DisplayVersion)"
    }


    }

$btnToggleDarkMode.Add_Checked({
    # Code to enable dark mode
    $btnToggleDarkMode.Content = "Disable Dark Mode"
})

$btnToggleDarkMode.Add_Unchecked({
    # Code to disable dark mode
    $btnToggleDarkMode.Content = "Enable Dark Mode"
})

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
    # Load Windows Forms and drawing assemblies
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Create a Save File Dialog
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.initialDirectory = [Environment]::GetFolderPath([Environment+SpecialFolder]::DesktopDirectory)
    $saveFileDialog.filter = "Shortcut files (*.lnk)|*.lnk"
    $saveFileDialog.FileName = "WinToolBox.lnk"

    # Show the Save File Dialog
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $shortcutPath = $saveFileDialog.FileName

        # Specify the target PowerShell command
        $command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command 'irm mdiana.dev/win | iex'"

        # Create a shell object
        $shell = New-Object -ComObject WScript.Shell
        
        # Create a shortcut object
        $shortcut = $shell.CreateShortcut($shortcutPath)

        if (Test-Path -Path "c:\Windows\WinToolBox\assets\logo.ico") {
            $shortcut.IconLocation = "c:\Windows\WinToolBox\assets\logo.ico"
        } else {
            $shortcut.IconLocation = "powershell.exe"
        }
        
        # Set properties of the shortcut
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"$command`""
        
        # Save the shortcut
        $shortcut.Save()
        Write-Host "Shortcut created at: $shortcutPath"
    } else {
        Write-Host "User cancelled the shortcut creation."
    }
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

# Sort categories alphabetically before creating expanders
$sortedCategories = $appsByCategory.Keys | Sort-Object

foreach ($category in $sortedCategories) {
    $expander = New-Object System.Windows.Controls.Expander
    $expander.Header = $category
    $expander.IsExpanded = $true

    $stackPanel = New-Object System.Windows.Controls.StackPanel

    # Sort apps within the category alphabetically by content
    $sortedApps = $appsByCategory[$category] | Sort-Object { $_.Value.content }

    foreach ($app in $sortedApps) {
        $checkBox = New-Object System.Windows.Controls.CheckBox

        # StackPanel to hold the text and the hyperlink
        $innerStackPanel = New-Object System.Windows.Controls.StackPanel
        $innerStackPanel.Orientation = "Horizontal"

        # TextBlock for the app's content
        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $app.Value.content
        $innerStackPanel.Children.Add($textBlock) | Out-Null

        # ToolTip
        $toolTip = New-Object System.Windows.Controls.ToolTip
        $toolTip.Content = $app.Value.description
        $checkBox.ToolTip = $toolTip

        $checkBox.Content = $innerStackPanel
        $checkBox.Margin = New-Object System.Windows.Thickness(5)
        $stackPanel.Children.Add($checkBox) | Out-Null

        # Hyperlink
        $hyperlink = New-Object System.Windows.Documents.Hyperlink
        $hyperlink.Inlines.Add(" ?")
        $hyperlink.NavigateUri = New-Object System.Uri($app.Value.link)
        $hyperlink.Add_RequestNavigate({
            param($sender, $e)
            Start-Process $e.Uri.AbsoluteUri
        })
        $textBlock.Inlines.Add($hyperlink)
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
$checkbox.IsChecked = $true  # Ensures the checkbox is checked at creation
$panelDevices.Children.Add($checkbox) | Out-Null
Write-Host "Connected with: $env:COMPUTERNAME"


$window.Add_Closing({
    $iniPath = "C:\Windows\WinToolBox\config.ini"
    $DeviceMGMTexpander = $window.FindName("DeviceMGMTexpander")
    $expanderState = $DeviceMGMTexpander.IsExpanded
    $iniContent = @{"DeviceMGMTexpander" = @{"expanded" = $expanderState}}
    $iniContent | Out-IniFile -FilePath $iniPath -Force
    #Write-Host "Saved expander state to $iniPath"
})


# Show the GUI
$window.ShowDialog() | Out-Null
