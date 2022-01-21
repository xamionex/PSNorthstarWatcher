#Todo: Mod support, add all Override Vars, Serverbrowser / MS Connectivity, actual monitor, restart button for server
#show IPs in monitor (LAN, WAN, Router, ..?), show historical numbers on ram etc (max/min/avg/??)
#=> IDea: add slider with time to "go back", 
#browse button for paths
#=> only restart server if it was empty the last 15 minutes

#Add to use forms, probably obsolete by now, remove later!
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#detect script path because $PSScriptRoot does not work in ps2exe
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript"){
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
 else { $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
     if (!$ScriptPath){ $ScriptPath = "." }
}

#region global vars
#get Northstar root folders/files WITHOUT bin folder
$global:northstarrootitems = @("R2Northstar","legal.txt","MinHook.x64.dll","Northstar.dll","NorthstarLauncher.exe","ns_startup_args.txt","ns_startup_args_dedi.txt","r2ds.bat")


#endregion global vars

#region functions

#
function Check-Adminrights{
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
        Write-Host "Running with administrator privileges."
        return $true
    }else{
        Write-Host "Not running with administrator privileges."
        #Start-Process powershell.exe -WorkingDirectory $PSScriptRoot -ArgumentList "-File `"$($PSScriptRoot)\PSNorthstarSetup.ps1`"" -Verb runas 
        #throw "notadmin"
        return $false
    }
}

function Write-FileUtf8{
    param(
        #[string]$InputVar will convert arrays to strings/newlines
        [string]$InputVar,[string]$Filepath,[bool]$Append
    )
    if($Append){
        $InputVar | Out-File -Append -Encoding utf8 -FilePath $Filepath
    }else{
        $InputVar | Out-File -Encoding utf8 -FilePath $Filepath
    }
}

#puts user inputs from UI to [NorthstarServer] objects
function UItoNS{
	param(
		[System.Collections.ArrayList]$NorthstarServers,
		[System.Collections.ArrayList]$userinputarray
		#[int]$ServerID
	)
    $ServerID = 0
    if($NorthstarServers.count -eq 0){
        throw "NorthstarServers array given to UItoNS has no entries/objects! Please initialize server.NorthstarServers[0], [1] etc first"
    }
	ForEach($NorthstarServer in $NorthstarServers){
		$NorthstarServer.AbsolutePath = $serverdirectory.Text + $NorthstarServer.Directory

		$NorthstarServer.ns_server_name = $userinputarray[$ServerID].servername
		$NorthstarServer.UDPPort = $userinputarray[$ServerID].udpport
		$NorthstarServer.ns_player_auth_port = $userinputarray[$ServerID].tcpport
		$NorthstarServer.ns_auth_allow_insecure = $userinputarray[$ServerID].allowinsecure
		$NorthstarServer.ns_report_server_to_masterserver = $userinputarray[$ServerID].reporttomasterserver
		#Password missing
		#lastmap missing
		$NorthstarServer.ns_private_match_last_mode = $userinputarray[$ServerID].gamemode
		$NorthstarServer.ns_should_return_to_lobby = $userinputarray[$ServerID].returntolobby
		if($userinputarray[$ServerID].playercanchangemap -eq 1){
			$NorthstarServer.ns_private_match_only_host_can_change_settings = 1
		}else{
			$NorthstarServer.ns_private_match_only_host_can_change_settings = 2
		}
		if($userinputarray[$ServerID].playercanchangemode -eq 1){
			$NorthstarServer.ns_private_match_only_host_can_change_settings = 0
		}
		#everything unlocked missing
		$NorthstarServer.SetplaylistVarOverrides.custom_air_accel_pilot = $userinputarray[$ServerID].airacceleration
		$NorthstarServer.SetplaylistVarOverrides.roundscorelimit = $userinputarray[$ServerID].roundscorelimit
		$NorthstarServer.SetplaylistVarOverrides.scorelimit = $userinputarray[$ServerID].scorelimit
		$NorthstarServer.SetplaylistVarOverrides.timelimit = $userinputarray[$ServerID].timelimit
		$NorthstarServer.SetplaylistVarOverrides.max_players = $userinputarray[$ServerID].maxplayers
		$NorthstarServer.SetplaylistVarOverrides.pilot_health_multiplier = $userinputarray[$ServerID].playerhealthmulti
		$NorthstarServer.SetplaylistVarOverrides.riff_player_bleedout = $userinputarray[$ServerID].playerbleed
		$NorthstarServer.SetplaylistVarOverrides.classic_mp = $userinputarray[$ServerID].classicmp
		$NorthstarServer.SetplaylistVarOverrides.aegis_upgrades = $userinputarray[$ServerID].aegisupgrade
		$NorthstarServer.SetplaylistVarOverrides.boosts_enabled = $userinputarray[$ServerID].boosts
		$NorthstarServer.SetplaylistVarOverrides.run_epilogue = $userinputarray[$ServerID].epilogue
		$NorthstarServer.SetplaylistVarOverrides.riff_floorislava = $userinputarray[$ServerID].floorislava
		#missing some more overridevars

		#Starting Arguments to string 
		$NorthstarServer.StartingArgs = "+setplaylist private_match -dedicated -multiple"
		if($userinputarray[$ServerID].softwared3d11){
			$NorthstarServer.StartingArgs = $NorthstarServer.StartingArgs + " -softwared3d11"
		}

		$overridevars = ""
		ForEach ($varname in ($NorthstarServer.SetplaylistVarOverrides|gm -MemberType Property).Name){
			if($NorthstarServer.SetplaylistVarOverrides."$varname" -ne 0){
				$NorthstarServer.PlaylistVarOverrides = $True
				$overridevars = $overridevars + "$varname " + $Northstarserver.SetplaylistVarOverrides."$varname" + " "
			}
		}
		$overridevars = $overridevars -replace ".$"
		if($NorthstarServer.PlaylistVarOverrides -eq $True){
			$playlistvaroverridestring = " +setplaylistvaroverrides `" "
			$playlistvaroverridestring = $playlistvaroverridestring + $overridevars + '"'
			if($NorthstarServer.SetplaylistVarOverrides.max_players -gt 0){
				$playlistvaroverridestring = $playlistvaroverridestring + " -maxplayersplaylist"
			}
			$NorthstarServer.StartingArgs = $NorthstarServer.StartingArgs + " " + $playlistvaroverridestring
		}
        $NorthstarServer.StartingArgs = $NorthstarServer.StartingArgs + " -port " + $NorthstarServer.UDPPort
		$ServerID++
		Write-Host ($NorthstarServer |fl|out-string)
	}
}
#load all variables into forms in window
#this function puts cvars from an array of [UserInputConfig] to the form. [UserInputConfig] property names, form variables MUST have the same name.
function CvarsToForm{
    param(
        [System.Collections.ArrayList]$cvararray ,
        $dropdown
    )
    if($cvararray){
        $userinputcvars = (($cvararray | Get-Member) | where-object -Property MemberType -eq Property).name #| foreach-object{$($_.Definition).split(" ")[1]}
    }
    
    ForEach($cvar in $userinputcvars){
        if(((Get-Variable "$cvar").Value).gettype().Name -eq "Checkbox"){
            (Get-Variable "$cvar").Value.isChecked = $cvararray[$dropdown.SelectedIndex]."$cvar"
        }else{
            if(((Get-Variable "$cvar").Value).gettype().Name -eq "Slider"){
                ((Get-Variable "$cvar").value).value = [double]$cvararray[$dropdown.SelectedIndex]."$cvar"
            }else{
               if(((Get-Variable "$cvar").Value).gettype().Name -eq "Label"){
                    ((Get-Variable "$cvar").value).content = [string]$cvararray[$dropdown.SelectedIndex]."$cvar"
               }else{
                    (Get-Variable "$cvar").value.text = [string]$cvararray[$dropdown.SelectedIndex]."$cvar" 
               }
            }
        }
    }
}


#endregion functions

#region classes
class NorthstarServer {
    [int]$ProcessID = 0
    [int64]$VirtualMemory = 0
    [int64]$Memory = 0

    [string]$ns_server_name = "Northstar Server generated by PSNorthstarWatcher."
    [string]$ns_server_desc = "This is the default description generated by PSNorthstarWatcher."
    [int]$ns_player_auth_port = 8081 #default 8081
    [int]$UDPPort = 37015
    [string]$Directory = "1"
    [string]$AbsolutePath = ""
    [string]$BinaryFileName = "NorthstarLauncher.exe"
    [string]$ns_masterserver_hostname = 'https://northstar.tf' 
    [string]$StartingArgs = "+setplaylist private_match -dedicated -multiple -softwared3d11"
    [ValidateSet(0,1)][int]$ns_report_server_to_masterserver = 1 
    [ValidateSet(0,1)][int]$ns_auth_allow_insecure = 0 
    
    [string]$ns_server_password = '' #cfg
    [bool]$PlaylistVarOverrides = $false
    [SetplaylistVarOverrides]$SetplaylistVarOverrides = [SetplaylistVarOverrides]::new() #
    [Tickrate]$TickRate = [Tickrate]::new()#cf

    [ValidateSet(
        "mp_angel_city","mp_black_water_canal","mp_grave","mp_colony02","mp_complex3","mp_crashsite3","mp_drydock","mp_eden","mp_thaw","mp_forwardbase_kodai","mp_glitch","mp_homestead","mp_relic02","mp_rise","mp_wargames","mp_lobby","mp_lf_deck","mp_lf_meadow","mp_lf_stacks","mp_lf_township","mp_lf_traffic","mp_lf_uma","mp_coliseum","mp_coliseum_column"
    )][string]$ns_private_match_last_map = "mp_glitch"

    [ValidateSet(
        "tdm", "cp","ctf","lts","ps","ffa","speedball","mfd","ttdm","fra","gg","inf","tt","kr","fastball","arena","ctf_comp","attdm"
    )][string]$ns_private_match_last_mode = "tdm"

    [ValidateSet(0,1)][int]$ns_should_return_to_lobby = 0 
    [ValidateSet(0,1,2)][int]$ns_private_match_only_host_can_change_settings = 2 

    [int]$net_chan_limit_mode = 2
    [int]$net_chan_limit_msec_per_sec = 100
    [int]$sv_querylimit_per_sec = 15
    [ValidateSet(0,1)][int]$net_data_block_enabled = 0
    [ValidateSet(0,1)][int]$host_skip_client_dll_crc = 1
    [ValidateSet(0,1)][int]$everything_unlocked = 1
    [ValidateSet(0,1)][int]$ns_erase_auth_info = 1
    [ValidateSet(0,1)][int]$ns_report_sp_server_to_masterserver = 0

    #each object in this array contains 1 line of the config file
    [System.Collections.ArrayList]$autoexec_ns_server = @()

    #will write configuration to config file autoexec_ns_server.cfg based on the class' property names (ns_*, sv_*, host_*, ...)
    <#[void]WriteConfiguration(){
        $CVarArray = (($this | Get-Member) | where-object -Property MemberType -eq Property) | foreach-object{$($_.Definition).split(" ")[1]}
        ForEach($Cvar in $CVarArray){
            if($Cvar -match 'ns_' -or $Cvar -match 'host_' -or $Cvar -match 'everything_' -or $Cvar -match 'sv_' -or $Cvar -match 'net_'){
                $this.autoexec_ns_server.Add($Cvar +" "+ $this."$Cvar")
            }
        }
        $CVarArrayTickrate = (($this.TickRate | Get-Member) | where-object -Property MemberType -eq Property) | foreach-object{$($_.Definition).split(" ")[1]}
        ForEach($CVar in $CVarArrayTickrate){
            $this.autoexec_ns_server.Add($Cvar +" "+ $this.Tickrate."$Cvar")
        }
        $this.autoexec_ns_server.RemoveAt(0)
        Write-FileUtf8 -FilePath "$($this.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg" -InputVar $this.autoexec_ns_server
    }#>

    [void]Start(){
        
    }
}

class Server{
    [string]$BasePath
    [System.Collections.ArrayList]$NorthstarServers = @()
}

class SetplaylistVarOverrides {
    #[string]$maxplayersplaylist = "-maxplayersplaylist" # should always be "-maxplayersplaylist"
    [int]$max_players
    [int]$custom_air_accel_pilot
    [double]$pilot_health_multiplier
    [int]$run_epilogue
    [int]$respawn_delay

    [int]$boosts_enabled
    [int]$earn_meter_pilot_overdrive 
    [double]$earn_meter_pilot_multiplier

    [double]$earn_meter_titan_multiplier
    [int]$aegis_upgrades  
    [int]$infinite_doomed_state
    [int]$titan_shield_regen  

    [int]$scorelimit
    [int]$roundscorelimit
    [int]$timelimit
    [int]$oob_timer_enabled
    [int]$roundtimelimit

    [int]$classic_rodeo
    [int]$classic_mp
    [int]$fp_embark_enabled
    [int]$promode_enable

    [int]$riff_floorislava
    [int]$featured_mode_all_holopilot
    [int]$featured_mode_all_grapple
    [int]$featured_mode_all_phase
    [int]$featured_mode_all_ticks
    [int]$featured_mode_tactikill
    [int]$featured_mode_amped_tacticals
    [int]$featured_mode_rocket_arena
    [int]$featured_mode_shotguns_snipers
    [int]$iron_rules

    [int]$riff_player_bleedout
    [int]$player_bleedout_forceHolster
    [int]$player_bleedout_forceDeathOnTeamBleedout
    [int]$player_bleedout_bleedoutTime
    [int]$player_bleedout_firstAidTime
    [int]$player_bleedout_firstAidTimeSelf
    [int]$player_bleedout_firstAidHealPercent
    [int]$player_bleedout_aiBleedingPlayerMissChance
}

class TickRate {
    [double]$base_tickinterval_mp = 0.016666667 # default for 60  tick server / 20 tick client
    [int]$rate = 786432
    [int]$sv_updaterate_mp = 20 # default for 60  tick server / 20 tick client
    [int]$sv_minupdaterate = 20 # default for 60  tick server / 20 tick client
    [int]$sv_max_snapshots_multiplayer = 300 # updaterate * 15
}

Class UserInputConfig{
    [string]$servername = "new Server"
    [string]$gamemode = "tdm"
    [string]$udpport = "37015"
    [bool]$epilogue = $false
    [bool]$boosts = $false
    #[bool]$overridemaxplayers = $false
    [bool]$floorislava = $false
    [string]$airacceleration
    [string]$roundscorelimit
    [string]$scorelimit
    [string]$timelimit
    [string]$maxplayers
    [string]$playerhealthmulti
    [bool]$aegisupgrade = $false
    [bool]$classicmp = $false
    [bool]$playerbleed = $false
    [string]$tcpport = "8081"
    [bool]$reporttomasterserver = $true
    [bool]$softwared3d11 = $true
    [bool]$allowinsecure = $false
    [bool]$returntolobby = $false
    [bool]$playercanchangemap = $false
    [bool]$playercanchangemode = $false
    [double]$tickrate = 60
}

class MonitorVars{
    [string]$MONramlimit = "8"
    [string]$MONvmemlimit = "25"
    [string]$MONrestarthours = "4"
    [double]$MONrefreshrate = "10"
    [string]$MONservernamelabel = "servernamelabel"
}

$global:server = [Server]::new() # global var => easier to debug

#region XAML

[xml]$global:xmlWPF = Get-Content -Path "$ScriptPath\window.xaml"
#Add WPF and Windows Forms assemblies
try{
	Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
}catch {
	Throw "Failed to load Windows Presentation Framework assemblies."
}

#Create the XAML reader using a new XML node reader
$global:reader = New-Object System.Xml.XmlNodeReader $xmlWPF 
$global:xamGUI = [Windows.Markup.XamlReader]::Load( $reader )
#$Global:xamGUI = [Windows.Markup.XamlReader]::Load((new-object System.Xml.XmlNodeReader $xmlWPF))

#Create hooks to each named object in the XAML

$xmlWPF.SelectNodes("//*[@Name]") | %{
	Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global
} 

[xml]$global:xmlWPF2 = Get-Content -Path "$ScriptPath\monitor.xaml"
$global:reader2 = New-Object System.Xml.XmlNodeReader $xmlWPF2 
$global:xamGUI2 = [Windows.Markup.XamlReader]::Load( $reader2 )
$xmlWPF2.SelectNodes("//*[@Name]") | %{
	Set-Variable -Name ($_.Name) -Value $xamGUI2.FindName($_.Name) -Scope Global
} 
#endregion XAML

#region window logic
$titanfall2path.text = (Get-ItemProperty -Path "hklm:\SOFTWARE\Respawn\Titanfall2" -ErrorAction SilentlyContinue).'Install Dir'
$northstarpath.text = "Northstar\"
$serverdirectory.text = "$($env:LOCALAPPDATA)\NorthstarServer\"
#[System.Collections.ArrayList]$userinputarray = @()
[System.Collections.ArrayList]$monitorvararray = @()
#[System.Collections.ArrayList]$userinputconfignames = @("servername","gamemode","epilogue","boosts","overridemaxplayers","floorislava","airacceleration","roundscorelimit","scorelimit","timelimit","maxplayers","playerhealthmulti","aegisupgrade","classicmp","playerbleed","tcpport","udpport","reporttomasterserver","softwared3d11","allowinsecure","returntolobby","playercanchangemap","playercanchangemode","tickrate")


$northstarpath.add_LostFocus({
    if($northstarpath.text -ne "Northstar\"){
        [System.Windows.Forms.MessageBox]::Show("Northstar source path changed. This is not recommended!","Northstar Source Path",0)
    }
})


#Click on Add Server
$addserver.add_Click({
    $userinputarray.add([UserInputConfig]::new())
    $serverdropdown.Items.add([System.Windows.Controls.ListBoxItem]::new())
    $serverdropdown.Items[$serverdropdown.Items.Count-1].Content = "new Server"
    [string]$servercount.Content = [int]$servercount.content +1
})

$removeserver.add_Click({
    if(($servercount.content -gt 0) -and $serverdropdown.SelectedItem){
        $userinputarray.RemoveAt(($serverdropdown.SelectedIndex))
        $serverdropdown.Items.RemoveAt(($serverdropdown.SelectedIndex))
        [string]$servercount.Content = [int]$servercount.content -1
    }
})


#update window after servername change
$servername.add_LostFocus({
    $serverdropdown.Items[$serverdropdown.SelectedIndex].Content = $servername.text
    #$serverdropdown.UpdateLayout()
})

#update config after servername change
$servername.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].servername = $servername.Text
})


$Gamemode.add_DropDownClosed({
    $userinputarray[$serverdropdown.SelectedIndex].gamemode = $Gamemode.Text
})

#server selection was changed using combobox/dropdown. update all values
$serverdropdown.add_DropDownClosed({
    <#$userinputcvars = (($userinputarray[0] | Get-Member) | where-object -Property MemberType -eq Property) | foreach-object{$($_.Definition).split(" ")[1]}
    ForEach($cvar in $userinputcvars){
         (Get-Variable "$cvar").value.text = [string]$userinputarray[$serverdropdown.SelectedIndex]."$cvar"
    }#>
    CvarsToForm -cvararray $userinputarray -dropdown $serverdropdown
})

$epilogue.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].epilogue = $epilogue.IsChecked
})

$boosts.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].boosts = $boosts.IsChecked
})

<#$overridemaxplayers.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].overridemaxplayers = $overridemaxplayers.IsChecked
})#>

$floorislava.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].floorislava = $floorislava.IsChecked
})

$aegisupgrade.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].aegisupgrade = $aegisupgrade.IsChecked
})

$classicmp.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].classicmp = $classicmp.IsChecked
})

$playerbleed.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].playerbleed = $playerbleed.IsChecked
})

$reporttomasterserver.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].reporttomasterserver = $reporttomasterserver.IsChecked
})

$softwared3d11.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].softwared3d11 = $softwared3d11.IsChecked
})

$allowinsecure.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].allowinsecure = $allowinsecure.IsChecked
})

$returntolobby.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].returntolobby = $returntolobby.IsChecked
})

$playercanchangemap.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].playercanchangemap = $playercanchangemap.IsChecked
})

$playercanchangemap.add_Unchecked({
    if($playercanchangemode.IsChecked -eq $True){
        $playercanchangemode.IsChecked = $False
        $userinputarray[$serverdropdown.SelectedIndex].playercanchangemap = $false
        $userinputarray[$serverdropdown.SelectedIndex].playercanchangemode = $false
    }
})

$playercanchangemode.add_Checked({
    $playercanchangemap.IsChecked = $True
    $userinputarray[$serverdropdown.SelectedIndex].playercanchangemap = $True
})

$playercanchangemode.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].playercanchangemode = $playercanchangemode.IsChecked
})

$airacceleration.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].airacceleration = $airacceleration.Text
})

$roundscorelimit.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].roundscorelimit = $roundscorelimit.Text
})

$scorelimit.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].scorelimit = $scorelimit.Text
})

$timelimit.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].timelimit = $timelimit.Text
})

$maxplayers.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].maxplayers = $maxplayers.Text
})

$playerhealthmulti.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].playerhealthmulti = $playerhealthmulti.Text
})

$tcpport.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].tcpport = $tcpport.Text
})

$udpport.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].udpport = $udpport.Text
})

$tickrate.add_ValueChanged({
    $userinputarray[$serverdropdown.SelectedIndex].tickrate = $tickrate.value
    [string]$servertickratelabel.Content = "Server Tickrate "+[string]$($tickrate.value)
})

$saveuserinput.add_Click({
    if(!(Test-Path "$env:LOCALAPPDATA\NorthstarServer\")){
        New-Item "$env:LOCALAPPDATA\NorthstarServer\" -ItemType Directory 
    }
    Export-Clixml -InputObject $userinputarray -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml" 
})

$start.add_Click({
    #save data before starting
    if(!(Test-Path "$env:LOCALAPPDATA\NorthstarServer\")){
        New-Item "$env:LOCALAPPDATA\NorthstarServer\" -ItemType Directory 
    }
    Export-Clixml -InputObject $userinputarray -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml" 

    $xmlWPF2.SelectNodes("//*[@Name]") | %{
	   Remove-Variable -Name ($_.Name) -Scope Global
    }
    Remove-Variable "xmlWPF2" -Scope Global
    Remove-Variable "reader2" -Scope Global
    Remove-Variable "xamGUI2" -Scope Global
    
    [xml]$global:xmlWPF2 = Get-Content -Path "$ScriptPath\monitor.xaml"
    $global:reader2 = New-Object System.Xml.XmlNodeReader $xmlWPF2 
    $global:xamGUI2 = [Windows.Markup.XamlReader]::Load( $reader2 )
    $xmlWPF2.SelectNodes("//*[@Name]") | %{
	    Set-Variable -Name ($_.Name) -Value $xamGUI2.FindName($_.Name) -Scope Global
    }
    ForEach($item in $serverdropdown.Items){
        $monitorvararray.add([MonitorVars]::new())
        $MONserverdrop.Items.add([System.Windows.Controls.ListBoxItem]::new())
        $MONserverdrop.Items[$MONserverdrop.Items.Count-1].Content = $item.content
        [string]$MONservercount.Content = [int]$MONservercount.content +1
        $monitorvararray[$MONserverdrop.Items.Count-1].MONservernamelabel = $item.content
    }
    #$MONservernamelabel.Content = $serverdropdown.Items[0].Content
    CvarsToForm -cvararray $monitorvararray $MONserverdrop

    $refreshrate = New-Object System.Windows.Forms.Timer
    $refreshrate.Interval = 10000
    $refreshrate.start()

    Class MonitorVars{
        [string]$serverstatuslabel
        [string]$servernamelabel
        [string]$udpport
        [string]$tcpport
        [string]$uptime # HH:MM
        [string]$map
        [string]$players #16/20
        [string]$rambar
        [string]$ram # "14.2GB"
        [string]$vmem # "64.3GB"
        [string]$vmembar
        [string]$totrambar
        [string]$totram #"31.9GB"
        [string]$totvmembar 
        [string]$totvmem # "128.3GB"
    }

    $refreshrate.add_Tick({
        Write-Host "refreshrate Tick. Next tick in $($refreshrate.interval/1000)"
        ForEach($NorthstarServer in $server.NorthstarServers){
            Write-Host "NorthstarServer.ns_server_name"
            #check PID
            try{
                Get-Process -Id $NorthstarServer.ProcessID
                $status = "Running"
            }catch{
                Write-Host "Process $NorthstarServer.ProcessID does not exist anymore."
                $status = "Stopped"
            }
            #check TCP
            try{
                Get-NetTCPConnection -LocalPort $NorthstarServer.ns_player_auth_port -LocalAddress "0.0.0.0" -OwningProcess $NorthstarServer.ProcessID
                $status = "Running"
            }
                catch{
                    Write-Host "Could not get Listen TCP Port for that process ID."
                    $status = "Stopped"
                }

            #check UDP
            try{Get-NetUDPEndpoint -LocalPort $NorthstarServer.ns_player_auth_port -OwningProcess $NorthstarServer.ProcessID}
                catch{Write-Host "Could not get Listen UDP Port for that process ID." }
            #check for window with engineerorclose

            #check RAM + total RAM
            $freeram = (Get-WmiObject -Class WIN32_OperatingSystem).freephysicalmemory
            $totalram = (Get-WmiObject -Class WIN32_OperatingSystem).totalvisiblememorysize
            $nsram = (get-process -id $NorthstarServer.ProcessID).WorkingSet64
            #check VRAM + total VRAM
            $nsvmem = (get-process -id $NorthstarServer.ProcessID).VirtualMemorySize64
            ForEach ($pagefile in (Get-WmiObject -Class Win32_PageFileUsage).AllocatedBaseSize){
                $totalnsvmem = $totalnsvmem + $pagefile
            }
            ForEach ($pagefileusage in (Get-WmiObject -Class Win32_PageFileUsage).currentusage){
                $totalusednsvmem = $totalusednsvmem + $pagefileusage
            }
            #check uptime
            $uptime = (get-date) - ((get-process -id $NorthstarServer.ProcessID).StartTime)

            #check map #check players
            $windowtitle = (get-process -id $NorthstarServer.ProcessID).MainWindowTitle
            $playerstring = $windowtitle[6]
            $players = $windowtitle[6].split("/")[0]
            $maxplayers = $windowtitle[6].split("/")[1]
            $map = $windowtitle[5]
            switch($map){
                "mp_black_water_canal"{$mapname="Black Water Canal"}
                "mp_grave"{$mapname="Boomtown"}
                "mp_colony02"{$mapname="Colony"}
                "mp_complex3"{$mapname="Complex"}
                "mp_crashsite3"{$mapname="Crashsite"}
                "mp_drydock"{$mapname="DryDock"}
                "mp_eden"{$mapname="Eden"}
                "mp_thaw"{$mapname="Exoplanet"}
                "mp_forwardbase_kodai"{$mapname="Forward Base Kodai"}
                "mp_glitch"{$mapname="Glitch"}
                "mp_homestead"{$mapname="Homestead"}
                "mp_relic02"{$mapname="Relic"}
                "mp_rise"{$mapname="Rise"}
                "mp_wargames"{$mapname="Wargames"}
                "mp_lobby"{$mapname="Lobby"}
                "mp_lf_deck"{$mapname="Deck"}
                "mp_lf_meadow"{$mapname="Meadow"}
                "mp_lf_stacks"{$mapname="Stacks"}
                "mp_lf_township"{$mapname="Township"}
                "mp_lf_traffic"{$mapname="Traffic"}
                "mp_lf_uma"{$mapname="UMA"}
                "mp_coliseum"{$mapname="The Coliseum"}
                "mp_coliseum_column"{$mapname="Pillars"}
                default{$mapname="$map"}
            }
            #set UI values 
            $MONserverstatuslabel.Content = $status
            $MONservernamelabel = $NorthstarServer
            $MONudpport
            $MONtcpport
            $MONuptime
            $MONmap
            $MONplayers
            $MONrambar
            $MONram
            $MONvmem
            $MONvmembar
            $MONtotrambar
            $MONtotram
            $MONtotvmembar
            $MONtotvmem
            
        }
        #get json and render index.html server browser
        #try{
            $serverlist = Invoke-RestMethod "http://northstar.tf/client/servers" -ErrorAction SilentlyContinue
            if(Test-Path "$ScriptPath\index.html"){Remove-Item "$ScriptPath\index.html"}
            Write-FileUtf8 -Append $True -Filepath "$ScriptPath\index.html" -InputVar "<!DOCTYPE html><head><style>table {border-collapse:collapse;}td {border: 1px solid;}th {text-align:left;}</style></head><table><tr><th>Servername</th><th>Gamemode</th><th>Map</th><th>Players</th><th>Maxplayers</th><th>Description</th></tr>"
            ForEach($filter in $server.NorthstarServers.ns_server_name){
                $serverlist = $serverlist | where -property name -match $filter
                ForEach($serverentry in $serverlist){
                   Write-FileUtf8 -Append $True -Filepath "$ScriptPath\index.html" -InputVar "<tr><td>$($serverentry.name)</td><td>$($serverentry.playlist)</td><td>$($serverentry.map)</td><td>$($serverentry.playerCount)</td><td>$($serverentry.maxPlayers)</td><td>$($serverentry.description)</td></tr>"
                }
            Write-FileUtf8 -Append $True -Filepath "$ScriptPath\index.html" -InputVar "</table></html>"
            $browser.Source = "$ScriptPath\index.html"
            }
        #}
        #catch{
            #Write-Host "Error generating HTML file."
        #}
    })

    $MONserverdrop.add_DropDownClosed({
        CvarsToForm -cvararray $monitorvararray $MONserverdrop
    })

    $MONrefreshrate.add_ValueChanged({
        [int]$refreshrate.Interval = ($MONrefreshrate.Value)*1000
        Write-Host "refreshrate is now "$refreshrate.interval
        $refreshrate.Stop()
        $refreshrate.start()
    })

    
    $server.BasePath = $serverdirectory.text

    #remove before filling otherwise we get duplicates
    ForEach($server in $server.NorthstarServers){
        $server.NorthstarServers.remove($server)
    }

    #create server object
    ForEach($item in $MONserverdrop.Items){
        $server.NorthstarServers.Add([NorthstarServer]::new())
        $server.NorthstarServers[$server.NorthstarServers.count-1].Directory = $server.NorthstarServers.count
    }

    #put all info from UI into userinputarray=>[NorthstarServer] Objects
    UItoNS -NorthstarServers $server.northstarservers -userinputarray $userinputarray
    
    #show monitor window
    ForEach($NorthstarServer in $server.NorthstarServers){
        $NorthstarServer.ProcessID = Start-Process -PassThru -FilePath "$($NorthstarServer.AbsolutePath)\NorthstarLauncher.exe" -ArgumentList $NorthstarServer.StartingArgs
    }
    $xamGUI2.ShowDialog()

    #after window was closed stop refreshrate timer
    $refreshrate.stop()
})


$buildservers.add_Click({
    try{
        $server.BasePath = $serverdirectory.text
        #put text from form to var because it can cause weird issues
        $tf2srcpath = "$($titanfall2path.text)"
        
        #remove before filling otherwise we get duplicates
        ForEach($nsserver in $server.NorthstarServers){
            $server.NorthstarServers = @()
        }
        #create server object
        ForEach($item in $serverdropdown.Items){
            $server.NorthstarServers.Add([NorthstarServer]::new())
            $server.NorthstarServers[$server.NorthstarServers.count-1].Directory = $server.NorthstarServers.count
        }
        UItoNS -NorthstarServers $server.northstarservers -userinputarray $userinputarray

        #save data before building
        if(!(Test-Path "$env:LOCALAPPDATA\NorthstarServer\")){
            New-Item "$env:LOCALAPPDATA\NorthstarServer\" -ItemType Directory 
        }
        Export-Clixml -InputObject $userinputarray -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml" 

        #$global:server = [Server]::new() # global var => easier to debug
        if(Test-Path $serverdirectory.text){
            Write-Host "Given server directory destination does exist."
        }else{
            Write-Host "Creating NorthstarServer base folder in $serverdirectory.text"
            try{New-Item -ItemType Directory -Path $serverdirectory.text}
                catch {
                    throw "could not create base NorthstarServer at $serverdirectory.text"
                    $Error
                }
        }
        $server.BasePath = $serverdirectory.text

        #check TF2 source existance

        if(!(Test-Path $tf2srcpath)){
            Throw "Titanfall2 source does not exist! $tf2srcpath"
        }else{Write-Host "Titanfall2 source exists" }
        $tffiles = Get-Childitem $tf2srcpath

        $atleastoneconfig = $false
        
        ForEach($NorthstarServer in $server.NorthstarServers){
            if(Test-Path "$($NorthstarServer.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg"){
                Write-Host "$($NorthstarServer.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg exists."
                $atleastoneconfig = $true
            }
        }
        if($atleastoneconfig){
            Write-Host "Server configs ns_autoexec_server.cfg were detected previously for at least one server."
            $overwriteconfig = [System.Windows.Forms.MessageBox]::Show("autoexec_ns_server.cfg was detected. Do you want to overwrite config files for ALL servers? You will lose all previous configuration done manually!","Server Configuration File Detected", "YesNo" , "Information" , "Button1")
        }
        if($overwriteconfig -eq "Yes"){
            ForEach($NorthstarServer in $server.NorthstarServers){
                $configfilepath = "$($NorthstarServer.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg"
                Write-Host "Overwriting autoexec_ns_server.cfg"
                Write-FileUtf8 -Append $False -InputVar "//Config file generated by PSNorthstarWatcher on $(get-date)" -Filepath $configfilepath
                #Write-FileUtf8 -Append $True -InputVar $NorthstarServer.ns_server_name -Filepath $configfilepath#>
                $nscvararray = (($server.NorthstarServers[0] | gm -MemberType Property) | Where-Object -Property Name -match "ns_").Name
                $nscvararray = $nscvararray + (($server.NorthstarServers[0] | gm -MemberType Property) | Where-Object -Property Name -match "sv_").Name
                $nscvararray = $nscvararray + (($server.NorthstarServers[0] | gm -MemberType Property) | Where-Object -Property Name -match "host_").Name
                $nscvararray = $nscvararray + (($server.NorthstarServers[0] | gm -MemberType Property) | Where-Object -Property Name -match "everything_unlocked").Name
                $nscvararray = $nscvararray -notmatch "autoexec_ns_server"
                #$nscvararray = $nscvararray.remove("autoexec_ns_server")

                ForEach($nscvar in $nscvararray){
                    if($NorthstarServer."$nscvar".gettype().Name -eq "String"){
                        Write-FileUtf8 -InputVar ("$nscvar" + " " + '"' + $NorthstarServer."$nscvar" + '"') -Append $True -Filepath $configfilepath
                    }
                    if($NorthstarServer."$nscvar".gettype().Name -eq "Int32"){
                        Write-FileUtf8 -InputVar ("$nscvar" + " " + $NorthstarServer."$nscvar") -Append $True -Filepath $configfilepath
                    }
                }
            }
        }else{
            Write-Host "Keeping old autoexec_ns_server.cfg"
        }

        ForEach($NorthstarServer in $server.NorthstarServers){
            #check if server folder exists or create it
            if(Test-Path $Northstarserver.Absolutepath){
                Write-Host "Server directory $($Northstarserver.Absolutepath) exists"
            }else{
                Write-Host "Server directory $($Northstarserver.Absolutepath) does not exists. creating"
                New-Item $Northstarserver.Absolutepath -ItemType Directory
            }

            #check if NS files exist when not copy them
            ForEach($item in $northstarrootitems){
                if(Test-Path "$($NorthstarServer.Absolutepath)\$item"){
                    Write-Host "$($NorthstarServer.Absolutepath)\$item exists."
                }else{
                    Write-Host "$($NorthstarServer.Absolutepath)\$item" "does not exist. copying"
                    Copy-Item "$ScriptPath\$($northstarpath.text)$item" -Destination $NorthstarServer.AbsolutePath -Recurse
                }
            }

            #check if it contains NS files and exclude them
            ForEach($item in $northstarrootitems){
                if(Test-Path "$($titanfall2path.Text)\$item"){ #this NS item exists!
                    Write-Host "Warning! Titanfall2 sources $item (file or folder of NorthStar)! Will try to exclude NS files and folders for symlinks."
                    $tffiles = $tffiles | Where -Property "Name" -ne $item
                }
            }  

            #bin\x64_retail\wsock32.dll
            if(Test-Path "$($titanfall2path.Text)bin\x64_retail\wsock32.dll"){
                Write-Host "wsock32.dll already in TF2 original files!"
            }else{
                Write-Host "Copying wsock32.dll to original TF2 folder to make things a bit easier"
                try {Copy-Item ($($northstarpath.text) + "bin\x64_retail\wsock32.dll") -Destination "$($titanfall2path.Text)bin\x64_retail\"}
                    catch {throw "Could not copy wsock32.dll"}
            }

            #cycle through  original TF2 folder and file (non recursive!) and create symbolic links in NS server folder
            ForEach($file in $tffiles){
                if(Test-Path "$NorthstarServer.AbsolutePath\$($file.name)"){ 
                    $target = get-item "$NorthstarServer.AbsolutePath\$($file.name)" #put target file/folder in an item object
                    Write-Host "Cannot create symbolic link at $target because it already exists."
                    if($target.LinkType -eq "SymbolicLink"){
                        Write-Host "$target is a symbolic link."
                        if($target.Target -eq $file.fullname){ #is it pointing to the right target?
                            Write-Host "$target symbolic link does point to the right file/directory."
                        }
                        else{Throw "$target link is not correct, please delete it and run setup again."}
                    }else{
                        Write-Host "Target is $target"
                        Write-Host '$target.LinkType -eq "SymbolicLink"'  + " is " + ($target.LinkType -eq "SymbolicLink")
                        Throw "$target is not a link, please inspect that file and eventually remove it. Then run setup again."}
                }else{
                    try{
                        Write-Host ("Create symbolic link from " + "$($NorthstarServer.AbsolutePath)\$($file.name)" + "to $file.fullname")
                        if(!(Check-Adminrights)){
                            [System.Windows.Forms.MessageBox]::Show("The script needs to create symbolic links. Creating symbolic link needs administrator privileges. Please restart again as administrator.","Admin Rights not Detected",0)
                            throw "Can not create symbolic links without admin permission! "
                        }
                        New-Item -ItemType SymbolicLink -Path "$NorthstarServer.AbsolutePath\$($file.name)" -Value $file.fullname
                    }catch{
                        throw "Could not create symbolic links!"
                    }
                }
            }
        }
    }catch{
        Write-Host "Error bulding servers!"
        Write-Host ($Error | Out-Host)
        [System.Windows.Forms.MessageBox]::Show("There was an error building your servers. Check debug console.","PSNorthstarWatcher Error Building Servers",0)
    }
})

#endregion window logic

#get user data from config xml
[System.Collections.ArrayList]$userinputarray = @()
if(Test-Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"){
    #TBD Add import for Titanfall2 Path, Northstar source pathh, Northstar server destination path
    [System.Collections.ArrayList]$userinputarray = Import-Clixml -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"
    $userinputcount = 0
        ForEach($userinput in $userinputarray){
        $serverdropdown.Items.add([System.Windows.Controls.ListBoxItem]::new())
        $serverdropdown.Items[$serverdropdown.Items.Count-1].Content = $userinput.servername
        [string]$servercount.Content = [int]$servercount.content +1
    }
    Remove-Variable userinputcount
}

#add first server automatically if none exists or import user config from xml
if($userinputarray.count -eq 0){
    $userinputarray.add([UserInputConfig]::new())
    $serverdropdown.Items.add([System.Windows.Controls.ListBoxItem]::new())
    $serverdropdown.Items[$serverdropdown.Items.Count-1].Content = "new Server1"
    $userinputarray[0].servername = "new Server1"
    $serverdropdown.Text = "new Server"
    #$serverdropdown.SelectedValue.Content = "new Server"
    [string]$servercount.Content = [int]$servercount.content +1
}else{ #if userinput was loaded from xml file
    CvarsToForm -cvararray $userinputarray -dropdown $serverdropdown
}

#show main window
$xamGUI.ShowDialog()