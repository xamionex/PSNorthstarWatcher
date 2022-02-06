#Todo: Mod support/integrate, add all Override Vars
#show IPs in monitor (LAN, WAN, Router, ..?), show historical numbers on ram etc (max/min/avg/??)
#browse button for paths
#only restart server if it was empty the last 15 minutes
#implement update button to update already built servers to newer northstar release
#add paths input verification and add trailing backslashes
#remove folders if server was removed (cleanup)
#implement delay between server starts/server start queue
#invert ram bar (shows free memory now)$
#add build progress bar

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
$global:needsrebuild = $true
Write-Host "Protocol 1: Link to server. Protocol 2: Uphold the Network Connection. Protocol 3: Protect the Server."

#endregion global vars

#region functions

#
function Set-Build{
    param([bool]$Needed)
    if($Needed){
        #$needsrebuild = $true
        $pendingchanges.Foreground = "Red"
        $pendingchanges.Content = "Pending Save"
        Add-Servers
    }else{
        #$needsrebuild = $false
        $pendingchanges.Foreground = "Green"
        $pendingchanges.Content = "Saved!"
    }
}

function Set-Need{
    $pendingchanges.Foreground = "Red"
    $pendingchanges.Content = "Pending Save"
}

function Test-Adminrights{
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Write-Warning "You do not have Administrator rights to run this script!"
        #Start-Process powershell.exe -WorkingDirectory $PSScriptRoot -ArgumentList "-File `"$($PSScriptRoot)\PSNorthstarSetup.ps1`"" -Verb runas
        #throw "notadmin"
        return $false
    }else{
        Write-Host "Running with administrator privileges."
        return $true
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
		$NorthstarServer.AbsolutePath = $serverdirectory.Text.TrimEnd("\") + "\" + $NorthstarServer.Directory
        $NorthstarServer.Manualstart = $userinputarray[$ServerID].manualstart

		$NorthstarServer.NSStrings.ns_server_name = $userinputarray[$ServerID].servername
        $NorthstarServer.NSStrings.ns_server_desc = $userinputarray[$ServerID].description
		$NorthstarServer.UDPPort = $userinputarray[$ServerID].udpport
		$NorthstarServer.NS.ns_player_auth_port = $userinputarray[$ServerID].tcpport
		$NorthstarServer.NS.ns_auth_allow_insecure = $userinputarray[$ServerID].allowinsecure
		$NorthstarServer.NS.ns_report_server_to_masterserver = $userinputarray[$ServerID].reporttomasterserver
		$NorthstarServer.NetWork.sv_updaterate_mp = $userinputarray[$ServerID].tickrate
		$NorthstarServer.NetWork.rate = $userinputarray[$ServerID].rate
		$NorthstarServer.NetWork.net_chan_limit_mode = $userinputarray[$ServerID].net_chan_limit_mode
		$NorthstarServer.NetWork.net_chan_limit_msec_per_sec = $userinputarray[$ServerID].net_chan_limit_msec_per_sec
		$NorthstarServer.serverstartdelay = $userinputarray[$ServerID].serverstartdelay
		#Password missing
		#lastmap missing
		$NorthstarServer.NS.ns_private_match_last_mode = $userinputarray[$ServerID].gamemode
		$NorthstarServer.NS.ns_should_return_to_lobby = $userinputarray[$ServerID].returntolobby
		if($userinputarray[$ServerID].playercanchangemap -eq 1){
			$NorthstarServer.NS.ns_private_match_only_host_can_change_settings = 1
		}else{
			$NorthstarServer.NS.ns_private_match_only_host_can_change_settings = 2
		}
		if($userinputarray[$ServerID].playercanchangemode -eq 1){
			$NorthstarServer.NS.ns_private_match_only_host_can_change_settings = 0
		}
		#everything unlocked missing
		$NorthstarServer.SetplaylistVarOverrides.custom_air_accel_pilot = $userinputarray[$ServerID].airacceleration
		$NorthstarServer.SetplaylistVarOverrides.roundscorelimit = $userinputarray[$ServerID].roundscorelimit
		$NorthstarServer.SetplaylistVarOverrides.scorelimit = $userinputarray[$ServerID].scorelimit
		$NorthstarServer.SetplaylistVarOverrides.timelimit = $userinputarray[$ServerID].timelimit
		$NorthstarServer.SetplaylistVarOverrides.max_players = $userinputarray[$ServerID].maxplayers
		$NorthstarServer.SetplaylistVarOverrides.pilot_health_multiplier = $userinputarray[$ServerID].playerhealthmulti
		$NorthstarServer.SetplaylistVarOverrides.riff_player_bleedout = $userinputarray[$ServerID].playerbleed
		$NorthstarServer.override_disable_classic_mp = $userinputarray[$ServerID].classicmp
		$NorthstarServer.SetplaylistVarOverrides.aegis_upgrades = $userinputarray[$ServerID].aegisupgrade
		$NorthstarServer.SetplaylistVarOverrides.boosts_enabled = $userinputarray[$ServerID].boosts
	    $NorthstarServer.override_disable_run_epilogue = $userinputarray[$ServerID].epilogue
		$NorthstarServer.SetplaylistVarOverrides.riff_floorislava = $userinputarray[$ServerID].floorislava
		#missing some more overridevars

		#Starting Arguments to string
		$NorthstarServer.StartingArgs = "+setplaylist private_match -dedicated -multiple"
		if($userinputarray[$ServerID].softwared3d11){
			$NorthstarServer.StartingArgs = $NorthstarServer.StartingArgs + " -softwared3d11"
		}

		$overridevars = ""
		ForEach ($varname in ($NorthstarServer.SetplaylistVarOverrides|Get-Member -MemberType Property).Name){
			if($NorthstarServer.SetplaylistVarOverrides."$varname" -ne 0){
				$NorthstarServer.PlaylistVarOverrides = $True
				$overridevars = $overridevars + "$varname " + $Northstarserver.SetplaylistVarOverrides."$varname" + " "
			}
		}
        $DediArgs = ""
		ForEach ($varname in ($NorthstarServer.NS|Get-Member -MemberType Property).Name){
			#if($NorthstarServer.NS."$varname" -ne 0){
				$DediArgs = $DediArgs + "+$varname " + $Northstarserver.NS."$varname" + " "
			#}
		}
		ForEach ($varname in ($NorthstarServer.NetWork|Get-Member -MemberType Property).Name){
			#if($NorthstarServer.NetWork."$varname" -ne 0){
				$DediArgs = $DediArgs + "+$varname " + $Northstarserver.NetWork."$varname" + " "
			#}
		}
		ForEach ($varname in ($NorthstarServer.NSStrings|Get-Member -MemberType Property).Name){
			#if($NorthstarServer.NSStrings."$varname" -ne 0){
				$DediArgs = $DediArgs + "+$varname `"" + $Northstarserver.NSStrings."$varname" + "`" "
			#}
		}

        #special ifs because default is classic_mp 1 but is not overriden, to override it its actually 0 !
        if($NorthstarServer.override_disable_classic_mp){
            $overridevars = $overridevars + "classic_mp 0 "
            $NorthstarServer.PlaylistVarOverrides = $True
        }
        if($NorthstarServer.override_disable_run_epilogue){
            $overridevars = $overridevars + "run_epilogue 0 "
            $NorthstarServer.PlaylistVarOverrides = $True
        }
        #special replacements for net_chan_mode because 2=enabled and 0=disabled. needs to be in this order
        $DediArgs = $DediArgs -replace "net_chan_limit_mode 0","net_chan_limit_mode 2"
        $DediArgs = $DediArgs -replace "net_chan_limit_mode 1","net_chan_limit_mode 0"

		$overridevars = $overridevars -replace ".$"
		if($NorthstarServer.PlaylistVarOverrides -eq $True){
            $playlistvaroverridestring = " +setplaylistvaroverrides `""
			$playlistvaroverridestring = $playlistvaroverridestring + $overridevars + '"'
			if($NorthstarServer.SetplaylistVarOverrides.max_players -gt 0){
                $playlistvaroverridestring = $playlistvaroverridestring + " -maxplayersplaylist"
			}
			$NorthstarServer.StartingArgs = $NorthstarServer.StartingArgs + " " + $playlistvaroverridestring
		}
        $NorthstarServer.StartingArgs = $NorthstarServer.StartingArgs + " " + $DediArgs
        $NorthstarServer.StartingArgs = $NorthstarServer.StartingArgs + "-port " + $NorthstarServer.UDPPort
		$ServerID++
		Write-Host ($NorthstarServer |Format-List|out-string)
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


function TickOrServerselect{

    Write-Host "Refreshing. Current refresh tickrate $($refreshrate.interval/1000)"
    $refreshrateforeachcount = 0
    ForEach($NorthstarServer in $server.NorthstarServers){
        try{
            if(!$NorthstarServer.WasStarted){
                $MonitorValues[$refreshrateforeachcount].MONserverstatuslabel = "Stopped"
            }
            if($NorthstarServer.WasStarted){ #only do checks(update stuff if started
                $windowtitle = (Get-Process -ID $NorthstarServer.ProcessID).MainWindowTitle
                $MonitorValues[$refreshrateforeachcount].MONplayers = $windowtitle.split(" ")[6]
                $players = $MonitorValues[$refreshrateforeachcount].MONplayers.Split("/")[0]
                Write-Host "player count: $players"

                #Check if process is still running or responding
                if($NorthstarServer.Process.HasExited){
                    Throw $NorthstarServer.NSStrings.ns_server_name + " is not running anymore. Process has exited."
                }
                if(!($NorthstarServer.Process.Responding)){
                    Throw $NorthstarServer.NSStrings.ns_server_name + " is not responding."
                }

                #check if server should be stopped
                if($NorthstarServer.StopWhenPossible -and $players -lt 2){
                    Write-Host "Stopping server" $NorthstarServer.NSStrings.ns_server_name ". Was marked for stop because it has less than 2 players now."
                    $NorthstarServer.Stop()
                    $NorthstarServer.StopWhenPossible = $False
                }

                if($NorthstarServer.RestartWhenPossible -and $players -lt 2){
                    Write-Host "Restarting server" $NorthstarServer.NSStrings.ns_server_name ". Was marked for restart because it has less than 2 players now."
                    $NorthstarServer.Stop()
                    $NorthstarServer.RestartWhenPossible = $False
                    $NorthstarServer.Start()
                }

                if($NorthstarServer.StopWhenPossible -and ([Math]::Round(((Get-Process -ID $NorthstarServer.ProcessID).WorkingSet64/1024/1024/1024),2)) -gt $MONramlimit.Text){
                    Write-Host "Stopping server because it exceeded Ramlimit and has less than 2 players."
                    $NorthstarServer.Stop()
                    $NorthstarServer.StopWhenPossible = $False
                    $NorthstarServer.Start()
                }

                if(([Math]::Round(((Get-Process -ID $NorthstarServer.ProcessID).WorkingSet64/1024/1024/1024),2)) -gt $MONramlimitkill.Text){
                    Write-Host "Restarting server because it exceeded Ram Kill limit, even when it has players."
                    $NorthstarServer.Stop()
                    $NorthstarServer.Start()
                }

                if($NorthstarServer.StopWhenPossible -and ([Math]::Round(((Get-Process -ID $NorthstarServer.ProcessID).PagedMemorySize64/1024/1024/1024),2)) -gt $MONvmemlimit.Text){
                    Write-Host "Restarting server because it exceeded VMem Limit and has less than 2 players."
                    $NorthstarServer.Stop()
                    $NorthstarServer.Start()
                }

                if(([Math]::Round(((Get-Process -ID $NorthstarServer.ProcessID).PagedMemorySize64/1024/1024/1024),2)) -gt $MONvmemlimitkill.Text){
                    Write-Host "Restarting server because it exceeded VMem Kill Limit, even when it has players"
                    $NorthstarServer.Stop()
                    $NorthstarServer.Start()
                }
                if(((get-date)-(Get-Process -ID $NorthstarServer.ProcessID).StartTime).Totalhours -gt $MONrestarthours.Text){
                    if(!($NorthstarServer.StopWhenPossible)){
                        Write-Host $NorthstarServer.NSStrings.ns_server_name "Server reached uptimelimit. Will restart when players have left."
                        $NorthstarServer.RestartWhenPossible = $True
                    }
                }

                if($refreshrateforeachcount -eq $MONserverdrop.SelectedIndex){ #only to currently selected server
                    #Write-Host "$($NorthstarServer.ns_server_name)"
                    $MonitorValues[$refreshrateforeachcount].MONservernamelabel = $NorthstarServer.NSStrings.ns_server_name
                    $MonitorValues[$refreshrateforeachcount].MONserverstatuslabel = "Running"
                    $MonitorValues[$refreshrateforeachcount].MONpid = $NorthstarServer.ProcessID


                    #check uptime
                    $MonitorValues[$refreshrateforeachcount].MONuptime = [string]([Math]::Round(((get-date) - ((Get-Process -ID $NorthstarServer.ProcessID).StartTime)).totalhours,0)) +":"+[string](((get-date) - ((Get-Process -ID $NorthstarServer.ProcessID).StartTime)).minutes) +":"+ [string](((get-date) - ((Get-Process -ID $NorthstarServer.ProcessID).StartTime)).seconds)

                    #check these only after 60s uptime, in case for slow machines!
                    if(((get-date) - ((Get-Process -ID $NorthstarServer.ProcessID).StartTime)).TotalSeconds -gt 60){
                        #check TCP
                        try{Get-NetTCPConnection -OwningProcess $NorthstarServer.ProcessID -LocalPort $NorthstarServer.NS.ns_player_auth_port -State Listen}
                            catch{throw "Could not get listen TCP port $($NorthstarServer.NS.ns_player_auth_port) for PID $($NorthstarServer.ProcessID) of server $($NorthstarServer.NSStrings.ns_server_name)"}
                        $MonitorValues[$refreshrateforeachcount].MONtcpport = $NorthstarServer.NS.ns_player_auth_port
                        #check UDP
                        try{Get-NetUDPEndpoint -OwningProcess $NorthstarServer.ProcessID -LocalPort $NorthstarServer.udpport}
                            catch{throw "Could not get listen UDP port $($NorthstarServer.udpport) for PID $($NorthstarServer.ProcessID) of server $($NorthstarServer.NSStrings.ns_server_name)"}
                        $MonitorValues[$refreshrateforeachcount].MONudpport = $NorthstarServer.udpport
                        #check for window with engineerorclose
                        #TBD
                        #
                    }

                    #check RAM
                    $MonitorValues[$refreshrateforeachcount].MONram = [string]([Math]::Round(((Get-Process -ID $NorthstarServer.ProcessID).WorkingSet64/1024/1024/1024),2)) +"GB"
                    #check VRAM +
                    $MonitorValues[$refreshrateforeachcount].MONvmem = [string]([Math]::Round(((Get-Process -ID $NorthstarServer.ProcessID).PagedMemorySize64/1024/1024/1024),2)) + "GB"




                    #$maxplayers = $windowtitle[6].split("/")[1]
                    $map = $windowtitle.split(" ")[5]
                    switch($map){
                        "mp_black_water_canal"{$MonitorValues[$refreshrateforeachcount].MONmap="Black Water Canal"}
                        "mp_grave"{$MonitorValues[$refreshrateforeachcount].MONmap="Boomtown"}
                        "mp_colony02"{$MonitorValues[$refreshrateforeachcount].MONmap="Colony"}
                        "mp_complex3"{$MonitorValues[$refreshrateforeachcount].MONmap="Complex"}
                        "mp_crashsite3"{$MonitorValues[$refreshrateforeachcount].MONmap="Crashsite"}
                        "mp_drydock"{$MonitorValues[$refreshrateforeachcount].MONmap="DryDock"}
                        "mp_eden"{$MonitorValues[$refreshrateforeachcount].MONmap="Eden"}
                        "mp_thaw"{$MonitorValues[$refreshrateforeachcount].MONmap="Exoplanet"}
                        "mp_forwardbase_kodai"{$MonitorValues[$refreshrateforeachcount].MONmap="Forward Base Kodai"}
                        "mp_glitch"{$MonitorValues[$refreshrateforeachcount].MONmap="Glitch"}
                        "mp_homestead"{$MonitorValues[$refreshrateforeachcount].MONmap="Homestead"}
                        "mp_relic02"{$MonitorValues[$refreshrateforeachcount].MONmap="Relic"}
                        "mp_rise"{$MonitorValues[$refreshrateforeachcount].MONmap="Rise"}
                        "mp_wargames"{$MonitorValues[$refreshrateforeachcount].MONmap="Wargames"}
                        "mp_lobby"{$MonitorValues[$refreshrateforeachcount].MONmap="Lobby"}
                        "mp_lf_deck"{$MonitorValues[$refreshrateforeachcount].MONmap="Deck"}
                        "mp_lf_meadow"{$MonitorValues[$refreshrateforeachcount].MONmap="Meadow"}
                        "mp_lf_stacks"{$MonitorValues[$refreshrateforeachcount].MONmap="Stacks"}
                        "mp_lf_township"{$MonitorValues[$refreshrateforeachcount].MONmap="Township"}
                        "mp_lf_traffic"{$MonitorValues[$refreshrateforeachcount].MONmap="Traffic"}
                        "mp_lf_uma"{$MonitorValues[$refreshrateforeachcount].MONmap="UMA"}
                        "mp_coliseum"{$MonitorValues[$refreshrateforeachcount].MONmap="The Coliseum"}
                        "mp_coliseum_column"{$MonitorValues[$refreshrateforeachcount].MONmap="Pillars"}
                        default{$MonitorValues[$refreshrateforeachcount].MONmap="$map"}
                    }
                }
            }
            $refreshrateforeachcount++
        }catch{
            $MonitorValues[$refreshrateforeachcount].MONserverstatuslabel = "Stopped"
            $MonitorValues[$refreshrateforeachcount].MONpid = 0
            $MonitorValues[$refreshrateforeachcount].MONtcpport = 0
            $MonitorValues[$refreshrateforeachcount].MONudpport = 0
            $MonitorValues[$refreshrateforeachcount].MONuptime = "0:00"
            $MonitorValues[$refreshrateforeachcount].MONram = "0GB"
            $MonitorValues[$refreshrateforeachcount].MONvmem = "0GB"
            if(!($NorthstarServer.Process.HasExited)){
                $NorthstarServer.Kill()
            }
            Write-Host "Server problem detected. Server was terminated. Starting server again."
            Write-Host ($Error | Out-Host)
            $NorthstarServer.WasStarted = $false
            $NorthstarServer.Crashcount++
            $NorthstarServer.Start()
        }
    } #end foreaach northstarserver
    #set UI values

    $MONserverstatuslabel.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONserverstatuslabel
    $MONservernamelabel.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONservernamelabel
    $MONudpport.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONudpport
    $MONtcpport.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONtcpport
    $MONuptime.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONuptime
    $MONmap.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONmap
    $MONplayers.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONplayers
    $MONram.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONram
    $MONvmem.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONvmem
    $MONpid.Content = $MonitorValues[$MONserverdrop.SelectedIndex].MONpid

    if($server.NorthstarServers[$MONserverdrop.SelectedIndex].WasStarted){
        $MONvmembar.value = 100/($monitorvararray[$MONserverdrop.SelectedIndex].MONvmemlimit)*([Math]::Round(((Get-Process -ID $server.NorthstarServers[$MONserverdrop.SelectedIndex].ProcessID).PagedMemorySize64/1024/1024/1024),1))
        $MONrambar.value = 100/($monitorvararray[$MONserverdrop.SelectedIndex].MONramlimit)*([Math]::Round(((Get-Process -ID $server.NorthstarServers[$MONserverdrop.SelectedIndex].ProcessID).WorkingSet64/1024/1024/1024),1))
    }

    $MONtotram.Content = [string]([Math]::Round(((Get-WmiObject -Class WIN32_OperatingSystem).freephysicalmemory/1024/1024),0))+"/"+[string]([Math]::Round(((Get-WmiObject -Class WIN32_OperatingSystem).totalvisiblememorysize/1024/1024),0)) + "GB"
    $MONtotrambar.value = 100/([Math]::Round(((Get-WmiObject -Class WIN32_OperatingSystem).totalvisiblememorysize/1024/1024),0))*([Math]::Round(((Get-WmiObject -Class WIN32_OperatingSystem).freephysicalmemory/1024/1024),0))

    $allpagefilesize = 0
    ForEach($pagefileusage in (Get-WmiObject -Class Win32_PageFileUsage).currentusage){
        $allpagefilesize = $allpagefilesize + $pagefileusage
    }
    $allocatedpagefilesize = 0
    ForEach($pagefile in (Get-WmiObject -Class Win32_PageFileUsage).AllocatedBaseSize){
        $allocatedpagefilesize = $allocatedpagefilesize + $pagefile
    }
    $MONtotvmem.Content = [string]([Math]::round($allpagefilesize/1024,0)) + "/" + [string]([Math]::Round($allocatedpagefilesize/1024,0)) + "GB"
    $MONtotvmembar.Value = 100/([Math]::Round($allocatedpagefilesize/1024,0))*([Math]::round($allpagefilesize/1024,0))



    #get json and render index.html server browser
    #try{
    $serverlist = Invoke-RestMethod "http://northstar.tf/client/servers" -ErrorAction SilentlyContinue
    if(Test-Path "$ScriptPath\index.html"){Remove-Item "$ScriptPath\index.html"}
    Write-FileUtf8 -Append $True -Filepath "$ScriptPath\index.html" -InputVar "<!DOCTYPE html><head><style>table {border-collapse:collapse;}td {border: 1px solid;}th {text-align:left;} html{background:#1a1a1d;color:white};</style></head><table><tr><th>Servername</th><th>Gamemode</th><th>Map</th><th>Players</th><th>Maxplayers</th><th>Description</th></tr>"
    ForEach($filter in $server.NorthstarServers.NSStrings.ns_server_name){
        $filteredserverlist = $serverlist | Where-Object -property name -Contains $filter
        ForEach($serverentry in $filteredserverlist){
            Write-FileUtf8 -Append $True -Filepath "$ScriptPath\index.html" -InputVar "<tr><td>$($serverentry.name)</td><td>$($serverentry.playlist)</td><td>$($serverentry.map)</td><td>$($serverentry.playerCount)</td><td>$($serverentry.maxPlayers)</td><td>$($serverentry.description)</td></tr>"
        }
    }
    Write-FileUtf8 -Append $True -Filepath "$ScriptPath\index.html" -InputVar "</table></html>"
    $browser.Source = "$ScriptPath\index.html"

    #}
    #catch{
        #Write-Host "Error generating HTML file."
    #}
}

#endregion functions

#region classes
class NorthstarServer {
    [int]$ProcessID = 0
    [System.Diagnostics.Process]$Process
    [int64]$VirtualMemory = 0
    [int64]$Memory = 0
    [int]$CrashCount = 0
    [bool]$StopWhenPossible = $false
    [bool]$RestartWhenPossible = $false
    [bool]$Manualstart = $false
    [bool]$WasStarted = $false

    #need special overrides since default / non overriden is actually 1
    [bool]$override_disable_classic_mp = $false
    [bool]$override_disable_run_epilogue = $false

    [int]$UDPPort = 37015
    [string]$Directory = "1"
    [string]$AbsolutePath = ""
    [string]$BinaryFileName = "NorthstarLauncher.exe"
    [string]$StartingArgs = "+setplaylist private_match -dedicated -multiple -softwared3d11"
    [int]$serverstartdelay = 5

    [bool]$PlaylistVarOverrides = $false
    [SetplaylistVarOverrides]$SetplaylistVarOverrides = [SetplaylistVarOverrides]::new() # Ella Setto Playlisto Varro Overrido!
    [NetWork]$NetWork = [NetWork]::new() # La Ticko Ratero Classo
    [NS]$NS = [NS]::new() # El NS class
    [NSStrings]$NSStrings = [NSStrings]::new() # El NSStrings class (name,desc,pass)

    [ValidateSet(0,1)][int]$everything_unlocked = 1

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
        $CVarArrayTickrate = (($this.NetWork | Get-Member) | where-object -Property MemberType -eq Property) | foreach-object{$($_.Definition).split(" ")[1]}
        ForEach($CVar in $CVarArrayTickrate){
            $this.autoexec_ns_server.Add($Cvar +" "+ $this.Tickrate."$Cvar")
        }
        $this.autoexec_ns_server.RemoveAt(0)
        Write-FileUtf8 -FilePath "$($this.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg" -InputVar $this.autoexec_ns_server
    }#>

    [void]Start(){
        if(!($this.Manualstart)){
            if(!$this.WasStarted){
                $this.Process = Start-Process -WindowStyle Minimized -WorkingDirectory $this.AbsolutePath -PassThru -FilePath "$($this.AbsolutePath)\NorthstarLauncher.exe" -ArgumentList $this.StartingArgs
                $this.ProcessID = $this.Process.ID
                $this.WasStarted = $True
                $this.StopWhenPossible = $false
            }else{
                Write-Host "Warning! Tried to start a server that had flag WasStarted = True"
            }
        }else{
            Write-Host "Not starting because server is on manual start mode."
            $this.WasStarted = $false
        }
    }

    [void]StartManual(){
        if(!$this.WasStarted){
            $this.Process = Start-Process -WorkingDirectory $this.AbsolutePath -PassThru -FilePath "$($this.AbsolutePath)\NorthstarLauncher.exe" -ArgumentList $this.StartingArgs
            $this.ProcessID = $this.Process.ID
            $this.WasStarted = $true
            $this.StopWhenPossible = $false
            $this.Manualstart = $false
        }else{
            Write-Warning "Warning! Tried to start a server that had flag WasStarted = True"
        }
    }

    [void]Stop(){
        Write-Host "Stopping process"
        Stop-Process -id $this.Process.Id
        $this.WasStarted = $false
    }

    [void]Kill(){
        Write-Host "Killing process"
        $this.process.Kill()
        $this.WasStarted = $false
    }
}

class NS{
    #[string]$ns_masterserver_hostname = 'https://northstar.tf'
    [int]$ns_player_auth_port = 8081 #default 8081
    [ValidateSet(0,1)][int]$ns_report_server_to_masterserver = 1
    [ValidateSet(0,1)][int]$ns_auth_allow_insecure = 0
    [ValidateSet(
        "mp_angel_city","mp_black_water_canal","mp_grave","mp_colony02","mp_complex3","mp_crashsite3","mp_drydock","mp_eden","mp_thaw","mp_forwardbase_kodai","mp_glitch","mp_homestead","mp_relic02","mp_rise","mp_wargames","mp_lobby","mp_lf_deck","mp_lf_meadow","mp_lf_stacks","mp_lf_township","mp_lf_traffic","mp_lf_uma","mp_coliseum","mp_coliseum_column"
    )][string]$ns_private_match_last_map = "mp_glitch"
    [ValidateSet(
        "tdm", "cp","ctf","lts","ps","ffa","speedball","mfd","ttdm","fra","gg","inf","tt","kr","fastball","arena","ctf_comp","attdm"
    )][string]$ns_private_match_last_mode = "tdm"
    [ValidateSet(0,1)][int]$ns_should_return_to_lobby = 0
    [ValidateSet(0,1,2)][int]$ns_private_match_only_host_can_change_settings = 2
    [ValidateSet(0,1)][int]$ns_erase_auth_info = 1
    [ValidateSet(0,1)][int]$ns_report_sp_server_to_masterserver = 0
    [ValidateSet(0,1)][int]$everything_unlocked = 1

}

class NSStrings{
    [string]$ns_server_name = "Northstar Server generated by PSNorthstarWatcher."
    [string]$ns_server_desc = "This is the default description generated by PSNorthstarWatcher."
    [string]$ns_server_password = '' #cfg
}

class Server{
    [string]$BasePath
    [System.Collections.ArrayList]$NorthstarServers = @()
}

class SetplaylistVarOverrides{
    #[string]$maxplayersplaylist = "-maxplayersplaylist" # should always be "-maxplayersplaylist"
    [int]$max_players
    [int]$custom_air_accel_pilot
    [double]$pilot_health_multiplier
    #[int]$run_epilogue
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
    #[int]$classic_mp
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

class NetWork{
    [double]$base_tickinterval_mp = 0.016666667 # default for 60  tick server / 20 tick client
    [int]$rate = 128000
    [int]$sv_updaterate_mp = 20 # default for 60  tick server / 20 tick client
    [int]$sv_minupdaterate = 20 # default for 60  tick server / 20 tick client
    [int]$sv_max_snapshots_multiplayer = 300 # updaterate * 15
    [int]$sv_querylimit_per_sec = 15
    [int]$net_chan_limit_mode = 2
    [int]$net_chan_limit_msec_per_sec = 100
    [ValidateSet(0,1)][int]$net_data_block_enabled = 0
    [ValidateSet(0,1)][int]$host_skip_client_dll_crc = 1
}

Class UserInputConfig{
    [string]$servername = "new Server"
    [string]$description
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
    [int]$tickrate = 60
    [int]$rate = 384000
    [int]$serverstartdelay = 5
    [int]$net_chan_limit_mode = 2
    [int]$net_chan_limit_msec_per_sec = 100
    [bool]$manualstart = $false
}

class MonitorVars{
    [string]$MONramlimit = "8"
    [string]$MONramlimitkill = "12"
    [string]$MONvmemlimit = "25"
    [string]$MONvmemlimitkill = "50"
    [string]$MONrestarthours = "6"
    [double]$MONrefreshrate = "10"
    #[string]$MONservernamelabel = "servernamelabel"
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

$xmlWPF.SelectNodes("//*[@Name]") | ForEach-Object{
	Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.Name) -Scope Global
}

[xml]$global:xmlWPF2 = Get-Content -Path "$ScriptPath\monitor.xaml"
$global:reader2 = New-Object System.Xml.XmlNodeReader $xmlWPF2
$global:xamGUI2 = [Windows.Markup.XamlReader]::Load( $reader2 )
$xmlWPF2.SelectNodes("//*[@Name]") | ForEach-Object{
	Set-Variable -Name ($_.Name) -Value $xamGUI2.FindName($_.Name) -Scope Global
}
#endregion XAML

#region window logic
$titanfall2path.text = (Get-ItemProperty -Path "hklm:\SOFTWARE\Respawn\Titanfall2" -ErrorAction SilentlyContinue).'Install Dir'
$northstarpath.text = "Northstar"
$serverdirectory.text = "$($env:LOCALAPPDATA)\NorthstarServer"
#[System.Collections.ArrayList]$userinputarray = @()
[System.Collections.ArrayList]$monitorvararray = @()
#[System.Collections.ArrayList]$userinputconfignames = @("servername","gamemode","epilogue","boosts","overridemaxplayers","floorislava","airacceleration","roundscorelimit","scorelimit","timelimit","maxplayers","playerhealthmulti","aegisupgrade","classicmp","playerbleed","tcpport","udpport","reporttomasterserver","softwared3d11","allowinsecure","returntolobby","playercanchangemap","playercanchangemode","tickrate")


$northstarpath.add_LostFocus({
    if($northstarpath.text -ne "Northstar"){
        [System.Windows.Forms.MessageBox]::Show("Northstar source path changed. This is not recommended!","Northstar Source Path",0)
        Set-Need
    }
})


#Click on Add Server
$addserver.add_Click({
    $userinputarray.add([UserInputConfig]::new())
    $serverdropdown.Items.add([System.Windows.Controls.ListBoxItem]::new())
    $serverdropdown.Items[$serverdropdown.Items.Count-1].Content = "new Server"
    [string]$servercount.Content = [int]$servercount.content +1
    Set-Need
})

$removeserver.add_Click({
    if(($servercount.content -gt 0) -and $serverdropdown.SelectedItem){
        $userinputarray.RemoveAt(($serverdropdown.SelectedIndex))
        $serverdropdown.Items.RemoveAt(($serverdropdown.SelectedIndex))
        [string]$servercount.Content = [int]$servercount.content -1
        Set-Need
    }
})


#update window after servername change
$servername.add_LostFocus({
    $serverdropdown.Items[$serverdropdown.SelectedIndex].Content = $servername.text
    #$serverdropdown.UpdateLayout()
    Set-Need
})

#update config after servername change
$servername.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].servername = $servername.Text
    Set-Need
})

$Description.Add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].description = $Description.Text
    Set-Need
})


$Gamemode.add_DropDownClosed({
    $userinputarray[$serverdropdown.SelectedIndex].gamemode = $Gamemode.Text
    Set-Need
})

#server selection was changed using combobox/dropdown. update all values
$serverdropdown.add_DropDownClosed({
    <#$userinputcvars = (($userinputarray[0] | Get-Member) | where-object -Property MemberType -eq Property) | foreach-object{$($_.Definition).split(" ")[1]}
    ForEach($cvar in $userinputcvars){
         (Get-Variable "$cvar").value.text = [string]$userinputarray[$serverdropdown.SelectedIndex]."$cvar"
    }#>
    CvarsToForm -cvararray $userinputarray -dropdown $serverdropdown
    Set-Need
})

$epilogue.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].epilogue = $epilogue.IsChecked #disableepilogue
    Set-Need
})

$boosts.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].boosts = $boosts.IsChecked
    Set-Need
})

<#$overridemaxplayers.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].overridemaxplayers = $overridemaxplayers.IsChecked
    Set-Need
})#>

$floorislava.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].floorislava = $floorislava.IsChecked
    Set-Need
})

$aegisupgrade.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].aegisupgrade = $aegisupgrade.IsChecked
    Set-Need
})

$classicmp.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].classicmp = $classicmp.IsChecked #disableclassicmp
    Set-Need
})

$playerbleed.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].playerbleed = $playerbleed.IsChecked
    Set-Need
})

$reporttomasterserver.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].reporttomasterserver = $reporttomasterserver.IsChecked
    Set-Need
})

$softwared3d11.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].softwared3d11 = $softwared3d11.IsChecked
    Set-Need
})

$allowinsecure.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].allowinsecure = $allowinsecure.IsChecked
    Set-Need
})

$returntolobby.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].returntolobby = $returntolobby.IsChecked
    Set-Need
})

$playercanchangemap.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].playercanchangemap = $playercanchangemap.IsChecked
    Set-Need
})

$playercanchangemap.add_Unchecked({
    if($playercanchangemode.IsChecked -eq $True){
        $playercanchangemode.IsChecked = $False
        $userinputarray[$serverdropdown.SelectedIndex].playercanchangemap = $false
        $userinputarray[$serverdropdown.SelectedIndex].playercanchangemode = $false
        Set-Need
    }
})

$playercanchangemode.add_Checked({
    $playercanchangemap.IsChecked = $True
    $userinputarray[$serverdropdown.SelectedIndex].playercanchangemap = $True
    Set-Need
})

$net_chan_limit_mode.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].net_chan_limit_mode = $net_chan_limit_mode.IsChecked
    Set-Need
})

$playercanchangemode.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].playercanchangemode = $playercanchangemode.IsChecked
    Set-Need
})

$manualstart.add_Click({
    $userinputarray[$serverdropdown.SelectedIndex].manualstart = $manualstart.IsChecked
    Set-Need
})

$airacceleration.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].airacceleration = $airacceleration.Text
    Set-Need
})

$roundscorelimit.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].roundscorelimit = $roundscorelimit.Text
    Set-Need
})

$scorelimit.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].scorelimit = $scorelimit.Text
    Set-Need
})

$timelimit.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].timelimit = $timelimit.Text
    Set-Need
})

$maxplayers.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].maxplayers = $maxplayers.Text
    Set-Need
})

$playerhealthmulti.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].playerhealthmulti = $playerhealthmulti.Text
    Set-Need
})

$tcpport.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].tcpport = $tcpport.Text
    Set-Need
})

$udpport.add_LostFocus({
    $userinputarray[$serverdropdown.SelectedIndex].udpport = $udpport.Text
    Set-Need
})

$tickrate.add_ValueChanged({
    $userinputarray[$serverdropdown.SelectedIndex].tickrate = $tickrate.value
    $userinputarray[$serverdropdown.SelectedIndex].rate = $tickrate.value * 6400
    [string]$servertickratelabel.Content = "Server Tickrate "+[string]$($tickrate.value)
    [string]$rate.Content = "Server Rate "+[string]$($tickrate.value * 6400)
    Set-Need
})

$serverstartdelay.add_ValueChanged({
    $userinputarray[$serverdropdown.SelectedIndex].serverstartdelay = $serverstartdelay.value
    [string]$serverstartdelaylabel.Content = "Server Start Delay (Seconds) "+[string]$($serverstartdelay.value)
    Set-Need
})

$net_chan_limit_msec_per_sec.add_ValueChanged({
    $userinputarray[$serverdropdown.SelectedIndex].net_chan_limit_msec_per_sec = $net_chan_limit_msec_per_sec.value
    [string]$net_chan_limit_mode_label.Content = "Net Chan Kick (MiliSeconds) "+[string]$($net_chan_limit_msec_per_sec.value)
    Set-Need
})

$saveuserinput.add_Click({
    try{
        if(!(Test-Path "$env:LOCALAPPDATA\NorthstarServer\")){
            New-Item "$env:LOCALAPPDATA\NorthstarServer\" -ItemType Directory
        }
        Export-Clixml -InputObject $userinputarray -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"
        Set-Build -Needed $True
    }catch{
        Throw "Could not save correctly!"
        Write-Host ($Error | Out-Host)
    }
})

$start.add_Click({
    try{
        #Check if user did add servers, otherwise do nothing!
        if($serverdropdown.Items.Count -eq 0){
            Throw "Did not add servers! Add servers then try again!"
        }
        if(!(Test-Path "$env:LOCALAPPDATA\NorthstarServer\")){
            New-Item "$env:LOCALAPPDATA\NorthstarServer\" -ItemType Directory
        }
        Export-Clixml -InputObject $userinputarray -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"
        Set-Build -Needed $True
        Class MonitorValues{
            [string]$MONserverstatuslabel # "Running" "Stopped" or "Pending"
            [string]$MONservernamelabel # "this is a server name"
            [string]$MONudpport # "37015"
            [string]$MONtcpport # "8081"
            [string]$MONuptime # HH:MM
            [string]$MONmap # MAPNAME
            [string]$MONplayers #16/20
            [string]$MONram # "14.2GB"
            [string]$MONvmem # "64.3GB"
            [string]$MONtotram #"31.9GB"
            [string]$MONtotvmem # "128.3GB"
            [string]$MONpid # "1234"

            [double]$MONvmembar = 0
            [double]$MONtotrambar = 0
            [double]$MONrambar = 0
            [double]$MONtotvmembar = 0
        }

        #save data before starting
        if(!(Test-Path "$env:LOCALAPPDATA\NorthstarServer\")){
            New-Item "$env:LOCALAPPDATA\NorthstarServer\" -ItemType Directory
        }
        Export-Clixml -InputObject $userinputarray -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"

        $xmlWPF2.SelectNodes("//*[@Name]") | ForEach-Object{
        Remove-Variable -Name ($_.Name) -Scope Global
        }
        Remove-Variable "xmlWPF2" -Scope Global
        Remove-Variable "reader2" -Scope Global
        Remove-Variable "xamGUI2" -Scope Global

        [xml]$global:xmlWPF2 = Get-Content -Path "$ScriptPath\monitor.xaml"
        $global:reader2 = New-Object System.Xml.XmlNodeReader $xmlWPF2
        $global:xamGUI2 = [Windows.Markup.XamlReader]::Load( $reader2 )
        $xmlWPF2.SelectNodes("//*[@Name]") | ForEach-Object{
            Set-Variable -Name ($_.Name) -Value $xamGUI2.FindName($_.Name) -Scope Global
        }

        #Initialize array for user Input vars on UI
        ForEach($item in $serverdropdown.Items){
            $monitorvararray.add([MonitorVars]::new())
            $MONserverdrop.Items.add([System.Windows.Controls.ListBoxItem]::new())
            $MONserverdrop.Items[$MONserverdrop.Items.Count-1].Content = $item.content
            [string]$MONservercount.Content = [int]$MONservercount.content +1
            #$monitorvalues[$MONserverdrop.Items.Count-1].MONservernamelabel = $item.content
        }

        #create server object
        ForEach($item in $MONserverdrop.Items){
            $server.NorthstarServers.Add([NorthstarServer]::new())
            $server.NorthstarServers[$server.NorthstarServers.count-1].Directory = $server.NorthstarServers.count
        }

        #put user input variables from current server to UI
        CvarsToForm -cvararray $monitorvararray -dropdown $MONserverdrop

        #initalize array for values on UI
        [System.Collections.ArrayList]$global:MonitorValues = @()
        ForEach($NorthstarServer in $server.NorthstarServers){
            $MonitorValues.add([MonitorValues]::new())
        }

        $refreshrate = New-Object System.Windows.Forms.Timer
        $refreshrate.Interval = 10000
        $refreshrate.start()

        #on each tick update values on UI
        $refreshrate.add_Tick({
            TickOrServerselect
        })

        $MONserverdrop.add_DropDownClosed({
            CvarsToForm -cvararray $monitorvararray -dropdown $MONserverdrop
            TickOrServerselect
        })

        $MONrefresh.add_Click({
            TickOrServerselect
        })

        $MONrefreshrate.add_ValueChanged({
            [int]$refreshrate.Interval = ($MONrefreshrate.Value)*1000
            ForEach($monitorvar in $monitorvararray){
                $monitorvar.MONrefreshrate = ($MONrefreshrate.Value)
            }
            Write-Host "refreshrate is now "$refreshrate.interval
            $refreshrate.Stop()
            $refreshrate.start()
        })

        $MONstart.add_Click({
            $server.Northstarservers[$MONserverdrop.SelectedIndex].Startmanual()
        })

        $MONstop.add_Click({
            $server.Northstarservers[$MONserverdrop.SelectedIndex].Stop()
            #since server was stopped manually, setting manual start flag
            $server.NorthstarServers[$MONserverdrop.SelectedIndex].Manualstart = $True
        })

        $MONforcestop.add_Click({
            $server.Northstarservers[$MONserverdrop.SelectedIndex].Kill()
            $server.NorthstarServers[$MONserverdrop.SelectedIndex].Manualstart = $True
        })

        $MONstopwhenempty.add_Click({
            $server.NorthstarServers[$MONserverdrop.SelectedIndex].StopWhenPossible = $True
            $server.NorthstarServers[$MONserverdrop.SelectedIndex].Manualstart = $True
        })

        $MONramlimit.add_LostFocus({
            $monitorvararray[$MONserverdrop.SelectedIndex].MONramlimit = $MONramlimit.Text
        })

        $MONvmemlimit.add_LostFocus({
            $monitorvararray[$MONserverdrop.SelectedIndex].MONvmemlimit = $MONvmemlimit.Text
        })

        $MONrestarthours.add_LostFocus({
            $monitorvararray[$MONserverdrop.SelectedIndex].MONrestarthours = $MONrestarthours.Text
        })

        $MONcleanlogdays.add_LostFocus({
            $monitorvararray[$MONserverdrop.SelectedIndex].MONcleanlogdays = $MONcleanlogdays.Text
        })

        $MONramlimitkill.add_LostFocus({
            $monitorvararray[$MONserverdrop.SelectedIndex].MONramlimitkill = $MONramlimitkill.Text
        })

        $MONvmemlimitkill.add_LostFocus({
            $monitorvararray[$MONserverdrop.SelectedIndex].MONvmemlimitkill = $MONvmemlimitkill.Text
        })

        $server.BasePath = $serverdirectory.text.TrimEnd("\")

        #remove before filling otherwise we get duplicates
        #ForEach($server in $server.NorthstarServers){
        #    $server.NorthstarServers.remove($server)
        #}

        #put all info from UI into userinputarray=>[NorthstarServer] Objects
        UItoNS -NorthstarServers $server.northstarservers -userinputarray $userinputarray

        #show monitor window / start servers
        $xamGUI.Close()
        if($NorthstarServer.serverstartdelay -ne 0){
            [System.Windows.Forms.MessageBox]::Show("Start delay is set to $($NorthstarServer.serverstartdelay), Monitor will show up after this period", "Timer", [System.Windows.Forms.MessageBoxButtons]::Ok)
        }
        $ServerCount = 0
        ForEach($NorthstarServer in $server.NorthstarServers){
            if(++$ServerCount % 1 -eq 0)
            {
                Start-Sleep -Seconds $NorthstarServer.serverstartdelay
            }
            $NorthstarServer.Start()
        }

        $xamGUI2.add_Closing({
            param($e)
            $result = [System.Windows.Forms.MessageBox]::Show("This will close ALL Northstar servers. Are you sure?", "Exit PSNorthstarWatcher", [System.Windows.Forms.MessageBoxButtons]::YesNo)
            if ($result -ne [System.Windows.Forms.DialogResult]::Yes)
            {
                $e.Cancel= $true
            }
        })

        $xamGUI2.ShowDialog()
        ForEach($NorthstarServer in $server.NorthstarServers){
            $NorthstarServer.Stop()
        }


        #after window was closed stop refreshrate timer
        $refreshrate.stop()
        $server.NorthstarServers = @()
    }catch{
        Write-Host "Starting servers/monitor failed!"
        Write-host ($Error | Out-Host)
        [System.Windows.Forms.MessageBox]::Show("Could not start servers and monitor, please check debug log.","Starting Servers/Monitor failed",0)
    }finally{
        #do we need to clean up something?
    }
})

function Add-Symlink{ #adds symlink to global var to later create then with New-Symlink
    param(
        [string]$srcpath,
        [string]$dstpath
    )

    $global:symlinklistsrc = $symlinklistsrc + ($srcpath + ";")
	#Write-Host $symlinklistsrc
    $global:symlinklistdst = $symlinklistdst + ($dstpath + ";")
	#Write-Host $symlinklistdst
}
function New-Symlinks{ #creates all symlinks from global variable using admin permissions
    #New-Item -ItemType SymbolicLink -Path "$($NorthstarServer.AbsolutePath)\$($file.name)" -Value $file.fullname
	#Write-Host "listsrc" $symlinklistsrc
	#Write-Host "listdst" $symlinklistdst
    if($symlinklistsrc -and $symlinklistdst){
        Start-process SymlinkHelper.exe -WorkingDirectory $ScriptPath -Argumentlist "-symlinklistsrc $symlinklistsrc -symlinklistdst $symlinklistdst" -Verb RunAs
    }
}
function Add-Servers { #add servers / if they exist script will check if everythings correct.
    try{
        $server.BasePath = $serverdirectory.text.TrimEnd("\")
        #put text from form to var because it can cause weird issues
        $tf2srcpath = $titanfall2path.text.TrimEnd("\")

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

        #Check for duplicate TCP/UDP ports
        [System.Collections.ArrayList]$portlist = @()
        ForEach($nsserver in $server.NorthstarServers){
            $portlist.Add($nsserver.UDPPort)
            $portlist.Add($nsserver.NS.ns_player_auth_port)
        }
        $groupedportlist = $portlist | Group-Object
        ForEach($port in $groupedportlist){
            if($port.Count -gt 1){
                [System.Windows.Forms.MessageBox]::Show("Error! Duplicate ports found, make sure you do not use TCP+UDP Ports twice!","Duplicate Ports Found",0)
                Throw "Error! Duplicate ports found, make sure you do not use TCP+UDP Ports twice!"
            }
        }

        #save data before building
        if(!(Test-Path "$env:LOCALAPPDATA\NorthstarServer\")){
            New-Item "$env:LOCALAPPDATA\NorthstarServer\" -ItemType Directory
        }
        Export-Clixml -InputObject $userinputarray -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"

        #$global:server = [Server]::new() # global var => easier to debug
        if(Test-Path $server.BasePath){
            Write-Host "Given server directory destination does exist."
        }else{
            Write-Host "Creating NorthstarServer base folder in $server.BasePath"
            try{New-Item -ItemType Directory -Path $server.BasePath}
                catch {
                    throw "could not create base NorthstarServer at $server.BasePath"
                    $Error
                }
        }

        #check TF2 source existance

        if(!(Test-Path $tf2srcpath)){
            Throw "Titanfall2 source does not exist! $tf2srcpath"
        }else{Write-Host "Titanfall2 source exists" }
        $tffiles = Get-Childitem $tf2srcpath

        #$atleastoneconfig = $false

        ForEach($NorthstarServer in $server.NorthstarServers){
            if(Test-Path "$($NorthstarServer.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg"){
                Write-Host "$($NorthstarServer.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg exists."
                #$atleastoneconfig = $true
            }
        }
        #$overwriteconfig = "Yes"
        #if($atleastoneconfig){
        #    Write-Host "Server configs ns_autoexec_server.cfg were detected previously for at least one server."
        #    $overwriteconfig = [System.Windows.Forms.MessageBox]::Show("autoexec_ns_server.cfg was detected. Do you want to overwrite config files for ALL servers? You will lose all previous configuration done manually!","Server Configuration File Detected", "YesNo" , "Information" , "Button1")
        #}

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
                    Copy-Item "$ScriptPath\$($northstarpath.text)\$item" -Destination $NorthstarServer.AbsolutePath -Recurse
                }
            }

            #check if it contains NS files and exclude them
            ForEach($item in $northstarrootitems){
                if(Test-Path "$($tf2srcpath)\$item"){ #this NS item exists!
                    Write-Host "Warning! Titanfall2 sources $item (file or folder of NorthStar)! Will try to exclude NS files and folders for symlinks."
                    $tffiles = $tffiles | Where-Object -Property "Name" -ne $item
                }
            }

            #\bin\x64_retail\wsock32.dll
            if(Test-Path "$($tf2srcpath)\bin\x64_retail\wsock32.dll"){
                Write-Host "wsock32.dll already in TF2 original files!"
            }else{
                Write-Host "Copying wsock32.dll to original TF2 folder to make things a bit easier"
                try {Copy-Item ($($northstarpath.text) + "\bin\x64_retail\wsock32.dll") -Destination "$($tf2srcpath)\bin\x64_retail\"}
                    catch {throw "Could not copy wsock32.dll"}
            }

            #cycle through  original TF2 folder and file (non recursive!) and create symbolic links in NS server folder
            ForEach($file in $tffiles){
                if(Test-Path "$($NorthstarServer.AbsolutePath)\$($file.name)"){
                    $target = get-item "$($NorthstarServer.AbsolutePath)\$($file.name)" #put target file/folder in an item object
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
                        <#Write-Host ("Create symbolic link from " + "$($NorthstarServer.AbsolutePath)\$($file.name)" + " to $($file.fullname)")
                        if(!(Test-Adminrights)){
                            [System.Windows.Forms.MessageBox]::Show("The script needs to create symbolic links. Creating symbolic link needs administrator privileges. Please restart again as administrator.","Admin Rights not Detected",0)
                            throw "Can not create symbolic links without admin permission! "
                        }#>
                        #New-Item -ItemType SymbolicLink -Path "$($NorthstarServer.AbsolutePath)\$($file.name)" -Value $file.fullname
                        Add-Symlink -srcpath $file.fullname -dstpath  "$($NorthstarServer.AbsolutePath)\$($file.name)"
                    }catch{
                        throw "Could not create symbolic links!"
                    }
                }
            }
        }
		New-Symlinks

        #if($overwriteconfig -eq "Yes"){
        ForEach($NorthstarServer in $server.NorthstarServers){
            $autoexecserver = "server-" + $server.NorthstarServers.count + "-autoexec.cfg"
            $configfilepath = "$($NorthstarServer.AbsolutePath)\r2\cfg\" + $autoexecserver
            $configfilepathr2n = "$($NorthstarServer.AbsolutePath)\R2Northstar\mods\Northstar.CustomServers\mod\cfg\autoexec_ns_server.cfg"
            Write-FileUtf8 -Append $False -InputVar "//Config file overwritten by PSNorthstarWatcher on $(get-date)" -Filepath $configfilepath
            Write-FileUtf8 -Append $False -InputVar "ns_masterserver_hostname `"https://northstar.tf`"" -Filepath $configfilepathr2n
            Write-Host "Overwriting $configfilepath"
            #Write-FileUtf8 -Append $True -InputVar $NorthstarServer.ns_server_name -Filepath $configfilepath
            $nscvararray = (($server.NorthstarServers[0].NS | Get-Member -MemberType Property)).Name
            $nscvararray = $nscvararray -notmatch "autoexec_ns_server"
            #$nscvararray = $nscvararray.remove("autoexec_ns_server")

            ForEach($nscvar in $nscvararray){
                if($NorthstarServer.NS."$nscvar".gettype().Name -eq "String"){
                    Write-FileUtf8 -InputVar ("$nscvar" + " " + '"' + $NorthstarServer.NS."$nscvar" + '"') -Append $True -Filepath $configfilepath
                }
                if($NorthstarServer.NS."$nscvar".gettype().Name -eq "Int32" -or $NorthstarServer.NS."$nscvar".gettype().Name -eq "Double"){
                    Write-FileUtf8 -InputVar ("$nscvar" + " " + $NorthstarServer.NS."$nscvar") -Append $True -Filepath $configfilepath
                }
            }
            $nstrcvararray = $nstrcvararray + (($server.NorthstarServers[0].NetWork | Get-Member -MemberType Property)).Name
            #$nstrcvararray = $nstrcvararray + (($server.NorthstarServers[0].NetWork | Get-Member -MemberType Property) | Where-Object -Property Name -notmatch "sv_").Name
            ForEach($nscvar in $nstrcvararray){
                if($NorthstarServer.NetWork."$nscvar".gettype().Name -eq "String"){
                    Write-FileUtf8 -InputVar ("$nscvar" + " " + '"' + $NorthstarServer.NetWork."$nscvar" + '"') -Append $True -Filepath $configfilepath
                }
                if(($NorthstarServer.NetWork."$nscvar".gettype().Name -eq "Int32") -or ($NorthstarServer.NetWork."$nscvar".gettype().Name -eq "Double")){
                    Write-FileUtf8 -InputVar ("$nscvar" + " " + $NorthstarServer.NetWork."$nscvar") -Append $True -Filepath $configfilepath
                }
            }

        }
        #}else{
        #    Write-Host "Keeping old autoexec_ns_server.cfg"
        #}
    #Write-Host "Build successful!"
    #[System.Windows.Forms.MessageBox]::Show("Server build was successful!","Build Complete",0)
    Set-Build -Needed $false

    }catch{
        Write-Host "Error bulding servers!"
        Write-Host ($Error | Out-Host)
        [System.Windows.Forms.MessageBox]::Show("There was an error building your servers. Check debug console.","PSNorthstarWatcher Error Building Servers",0)
    }
    #Remove-Variable server -Scope global
    $server.NorthstarServers = @()
}

#endregion window logic

#[System.Windows.Forms.MessageBox]::Show("Thanks for using PSNorthstar Watcher! This is a beta and still being developed. If you find issues, have questions or want to give feedback please create an issue on GitHub. Thank you!.","Message from faky",0)

#get user data from config xml
[System.Collections.ArrayList]$userinputarray = @()
if(Test-Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"){
    #TBD Add import for Titanfall2 Path, Northstar source pathh, Northstar server destination path
    [System.Collections.ArrayList]$userinputarray = Import-Clixml -Path "$env:LOCALAPPDATA\NorthstarServer\psnswUserSettings.xml"
    #$userinputcount = 0
        ForEach($userinput in $userinputarray){
        $serverdropdown.Items.add([System.Windows.Controls.ListBoxItem]::new())
        $serverdropdown.Items[$serverdropdown.Items.Count-1].Content = $userinput.servername
        [string]$servercount.Content = [int]$servercount.content +1
    }
    #Remove-Variable -Name userinputcount
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
Write-Host "Trust me..."