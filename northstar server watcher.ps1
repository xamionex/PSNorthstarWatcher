if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
 { $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition }
 else
 { $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) 
     if (!$ScriptPath){ $ScriptPath = "." } }
#region script greeting
Write-Host "
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNNXXXXXXKKKKKKKKKXNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXKKKKKK0xolclox0KKKKKKXNNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNXK000KK0xl:,',,,,,:oxO000000KNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNK00O000Oko:,',,'',,'''',:okO0OOOO0KXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMWWXK0OkOOOkxoc,''''',''''''''''',codkkOkkkOKXNWMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMWNK0Okkkkkxdl;,''''''''''''''''''''''',;coxkkxxkk0KNWMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMWX0kxxxxxxoc;,''''''''''''''''''''''''''''',;codxxxdxkOKNMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMWNX0kxdddddoc;,''''''''''''''''''''''''''''''''''',;coddddddk0XNWMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMWNKOxddoddoc:;,'''':xdllc,'''''''''''''''''',:lcodc,''''';:coodoodxO0NWMMMMMMMMMMMMMMM
MMMMMMMMMMMMNKOxdoooooc:,'.'''''c0WWNWXk:,'''''''''',;''':xXNNNWXo'''''''',;cloooodxOXNMMMMMMMMMMMMM
MMMMMMMMMWXOxdoooooc:,'....''''',l0WWWWWXd;'',:cllc:::'':OWWWWWXd;'''''.....',:cooooodx0XWMMMMMMMMMM
MMMMMMMMMNOdooolc;,'........''''''ckKNWWWNOkO0XWWWNXKOkk0WWWNK0o,'''''.........',;:looodONMMMMMMMMMM
MMMMMMMMMNOdlc;,............''''''',;cld0WMMMMMMMMMMMMMMWKxlc;,''''''''............';cloONMMMMMMMMMM
MMMMMMMMWKo:,.............'''''''''''',ckNMMMMMMMMMMMMMMWOl;'''''''''''''.............,:oONMMMMMMMMM
MMMMMNKOo;'.............''''''''''',;,lXWMMMMMMMMMMMMMMMMWNx,,;,'''''''''''..............,cx0NWMMMMM
MMN0d:,................'''''''''';lO0kONMMMMMMMMMMMMMMMMMMW0ox0k:,''''''''''................';oOXWMM
Kxc'.................''''''''''';xXWWWWMMMMMMMMMMMMMMMMMMMWWWWWW0l,'''''''''''..................;d0N
x:'................'''''''''',,,c0WWWWWWMMMMMMMMMMMMMMMMMMWWWNNWNk:,,,'''''''''..................;dX
WN0xc'............''''''''',,;;:kNWXXWWNXWMMMMMMMMMMMMMMWXNWWKxKWKo;:;''''''''''''...........':dOXWM
MMMMNKxc,.......''''''''',,,,:oONW0llddc:kWMWMMMMMMMMMMWKocddc;lKWXxoc,,,''''''''''.......':d0NMMMMM
MMMMMMMWKx:'...'''''''',,,,,,dXWNXd;,....cxk0KWMMMMWX0Oxo;....';kNWNXx;,,,,''''''''''..';oONWMMMMMMM
MMMMMMMMMMNOc''''''''',,,,,,:ONWXOc,,,loc,..,dXWWWMNk;'.':ol;..,o0NNN0c,,,,,,''''''''':kXWMMMMMMMMMM
MMMMMMMMMMMWx,'''''',,,,,,,,c0WN0o;;l0NWNx,.;OWWWWWWK:..:0WNKd'':xXNWKl,,,,,,,''''''''lXMMMMMMMMMMMM
MMMMMMMMMMMWd,''''',,,,,,,,;dXWKl;;:kWWWWNOodKWWWWWWXxld0WWWWXl',:xXNXd;,,,,,,,,''''''lXMMMMMMMMMMMM
MMMMMMMMMMMWx,''',,,,,,,,;,c0NXx:;,:0WWWWWXKKNWWWWWWNX0KNWWWWNx'';cONNOc,,,,,,,,,'''''oXMMMMMMMMMMMM
MMMMMMMMMMMWx,'',,,,,,,,;;;xXXxc;;':0WWWWNk::xXXXXKXOc;l0NWNNXd,.,;lONKl;;;,,,,,,,,'',oXMMMMMMMMMMMM
MMMMMMMMMMMWx,',,,,,,,;;;;oKNOc;:,.;ONNNW0:..:occccoc...lXNNNKd,.';;lOXOc;;;,,,,,,,,',oXMMMMMMMMMMMM
MMMMMMMMMMMWx,'',,,,,;;;;cONXkc:;'.:0NNNXd'..';;;;;;'...;ONNNNk,..,::xXXx:;;;;,,,,,'',oXMMMMMMMMMMMM
MMMMMMMMMMMWd'......';;;:o0NX0kxc'.;ONNNNx'.............:ONNNNx'.':dkOXXOl;;;;,'......lXMMMMMMMMMMMM
MMMMMMMMMMMWd.......';;;:d0XXxlol;.,xNNNNx'.............;ONNNKc..:loodKKOo:;;;,.......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......';;;:cokKx:'...'dXNNNx,.............:ONNNk,.....,d0koc:;;;,.......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......';;;:::ckk:.....;o0NNKc............'oXNKx:'.....,xkc:::;;;,.......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,;;:::::od;.......oKNXk:'........';o0NXd'.......ckd:::::;;,.......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,;::::::::'.......cKNXX0o,......'lOKXXKo'.......,::::::::;,.......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,;:::::::,.......'dXXXXXOc'.....;kXXXXXx,.........,::::::;,.......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,;::::::,.........;kXXXXd,'''..',oKXXXO:..........';::::::,.......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,;:::::;'.........,dKXX0l;c:'..;coOXXXk;...........,::::::,'......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,::::::,..........;d0X0xllo:'..;lox0KKx;...........';:::::;'......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,:::::;'..........;xKK0xoll:'.';lodOKKk:............,:::::;'......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,:::::,........''.;kXK0dlll:'.';lldOKKOl,'..........';::::;'......lXMMMMMMMMMMMM
MMMMMMMMMMMWd'......,::::;'......'.'';lOKKOdll:,''.';coOKK0dc:,'.''......';:::;'.....'lXMMMMMMMMMMMM
MMMMMMMMMMMWXko:,'.',:::;'...'''''',:coOKK0o;,'''''''':kKK0dlcc;,''''''..',:::;'..';lxKWMMMMMMMMMMMM
MMMMMMMMMMMMMMWN0dc,,::;,'''''''';:cdxk0KK0d,'''''''',o0KK0Okdlcc;,'''''''';::;,:okKWMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMWNKkdl;''''''',:cccoxxdoool;'''''''',coolodxocccc:;,'''''',:ok0XWMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMWXkoc;,',:cccccc:;,''''''''''''''''''',;:cccccc:;,',:lx0NMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMWNKOxoc:ccc:;,'''''''''''''''''''''''',:ccc:clok0NWMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMWN0kdl:,''''''''''''''''''''''''''',;:ldOKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWNKkl:,''''''''''''''''''''''',,:dOXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWX0xl:,,','''''''''''',,:ok0XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN0o;,''',,,,,,,,,,:dKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
Northstar is awesome!! https://northstar.tf"
Write-Host "Thanks for using this Northstar Server Watcher v0.1.4 script. If you need help just @faky me on Northstar Discord."
Write-Host "To gracefully close this script press CTRL+C"
write-host (get-date -Format HH:mm:ss) "Starting Northstar Server Watcher"
#endregion script greeting

#region configtest
try{

if($enablelogging){
    $logfilename = "psnswatcher"+(get-date -Format "yyyy-MM-dd-HH-mm") + ".log"
    Start-Transcript $logfilename
    Write-Host "Logging enabled. Logging to $logfilename"
}else{
    Write-Host "Log file disabled."
}

#region includes
if(Test-Path "$ScriptPath\northstar server watcher-config.ps1" -ErrorAction Stop){
    . ("$ScriptPath\northstar server watcher-config.ps1")
}
else{
    #if(Test-Path "$ScriptPath\scripts\example-northstar server watcher-config.ps1" -ErrorAction Stop){
       # Write-Host "Please rename example config file!"
       # throw "Example config not renamed. Please rename config file, edit config variables and start again."
   # }
    else{
        throw "Config file not found! Make sure northstar server watcher-config.ps1 is in the same directory."
    }
}
#endregion includes
if($allowargumentoverride){
    Write-Host "allowargumentoverride set to true, r2ds.bat will override starting arguments, if it exists."
}
else{
    
}
if(Test-Path $originpath){
    Write-Host "`$originpath path exists. Value: $originpath"
}else{
    throw "`$originpath folder does not exist. Value: $originpath"
}

if ($portarray -or $gamedir){
    throw "You are using a config file format not supported anymore since v0.1.3. Please migrate your configuration."
}
if($originpath){
    if($originpath[$originpath.length-1] -ne '\'){
        throw "Last character of origin path has to be a backslash!"
    }
}
else{
    throw "`$originpath path not set!"
}

if($tcpportarray){

}
else{
    throw "UDP ports not set! Please edit your config at `$tcpportarray"
}

if($udpportarray){
    if($tcpportarray.count -ne $udpportarray.count){
        throw "UDP and TCP port count is not the same. Please edit your config. UDP Count: $udpportarray.count / TCP Count: $tcpportarray.count"
    }
}else{
    throw "UDP ports not set! Please edit your config at `$udpportarray"
}

if($gamedirs){
    if($gamedirs.count -ne $tcpportarray.count -or $gamedirs.count -ne $udpportarray.count){
        throw "You need to set the same amount of TCP ports, UDP ports and game directories."
    }
    ForEach($gamedir in $gamedirs){
        if(Test-Path "$($originpath)$($gamedir)"){
            Write-Host "Found server directory $($gamedir) in $originpath"
            if(Test-Path "$($originpath)$($gamedir)\NorthstarLauncher.exe"){
                Write-Host "Found NorthstarLauncher.exe in $gamedir"
            }else{
                throw "Could not find NorthstarLauncher.exe in $($gamedir). Please check path or config."
            }
        }else{
            throw "Directory specified in `$gamedirs was not found. Directory: $gamedir"
        }
    }
}

if($deletelogsafterdays){
    Write-Host "Will delete Northstar logs after $deletelogsafterdays days."
}
else{
    throw "`$deletelogsafterdays not set!"
}

if($waittimebetweenserverstarts){
    
}
else{
    throw "waittimebetweenserverstarts not set!"
} 

if($waittimebetweenloops){
    if($waittimebetweenloops -lt 5 -or $waittimebetweenloops -gt 30){
        Write-Host "Warning. You set `$waittimebetweenloops to a value which is not recommended. Value: $waittimebetweenloops"
    }
}
else{
    throw "waittimebetweenloops not set!"
}

if($waitwithstartloopscount){

}
else{
    throw "waitwithstartloopscount not set!"
}

if($serverbrowserenable){
    if($serverbrowserfilepath){
        Write-Host "Server browser enabled. Path: $($serverbrowserfilepath). You can open it using your browser."
    }
    else{
        throw "`$serverbrowserenable is true but you did not set a path!"
    }
}
else{
    throw "serverbrowserenable not set!"
}

if($restartserverhours){
    Write-Host "Server restart after $($restartserverhours) hours."
}
else{
    throw "restartserverhours not set!"
}

if($showuptimemonitor = $true){
    if($showuptimemonitorafterloops){

    }
    else{
        throw "showuptimemonitor is true but did not set showuptimemonitorafterloops!"
    }
}

if($northstarlauncherargs){
    Write-Host "`$northstarlauncherargs value: $northstarlauncherargs"
}
else{
    throw "northstarlauncherargs not set!"
} 
if($crashlogscollect){
    if($crashlogspath){

    }
    else{
        throw "`$crashlogscollect is true but did not set `$crashlogspath! Please edit your config."
    }
} 

if($deletelogsminutes){
    
}
else{
    throw "$deletelogsminutes not set! "
}
#endregion configtest

#region functions
function Check-Listenport([int] $port){
        if ($port -gt 0 -and $port -lt 65535){
            #port input was in correct range
        }
        else{ #when port is not within 0 or 65535
            throw "Something wrong with the port number"
        }

        $netstat = netstat -an
        foreach($line in $netstat){
            if($line.contains("0.0.0.0:$port")){
                $portfound = $true
                return $true
            }
        }
        if ($portfound -ne $true){
            return $false
        }
    }
function Get-PIDByPorts([int]$tcpport, [int]$udpport){
    $localporttcp = Get-NetTCPConnection -State "Listen" | Where-Object -Property "LocalPort" -eq $tcpport
    $localportudp = Get-NetUDPEndpoint | Where-Object -Property localport -eq $udpport
    if($localporttcp){
        if($localporttcp.OwningProcess -eq $localportudp.OwningProcess){
            #ports belong to same process!
            return $localporttcp.OwningProcess
        }else{
            #Write-Host "Warning: UDP port $udpport (used by PID: $($localportudp.OwningProcess)) and TCP port $tcpport (used byPID: $($localporttcp.OwningProcess)) are not being used by the same process. There might be something wrong with your port configuration in your Norhtstar server or another application is using your UDP port."
            return $localporttcp.OwningProcess
        }
    }else{
        return 0
    }
}
#endregion functions

#region vars and stuff
$timeout = $false
$serverwaitforrestartcounterarray = @()
foreach($server in $tcpportarray){ #initialize array for counter
    $serverwaitforrestartcounterarray = $serverwaitforrestartcounterarray + 0
}
$logfilesdeletelastdate = (get-date).AddYears(-5) #make sure logs get cleared on first loop
cd $originpath
$logfilespathstring = "" + $originpath + "`*`\" + "R2Northstar\logs\`*"  #generate string for searching logfiles later, escaping * with backticks
$myfilterstring = ""
foreach($filter in $myserverfilternamearray){$myfilterstring = $myfilterstring + $filter +", "} #generate name for myfilter to display later
$singlequote = "'"
$showuptimeloopcounter = 0
#endregion vars and stuff

#region Main loop
$firstloop = $true
write-host (get-date -Format HH:mm:ss) "Starting main loop."
do{ 
    $serverstartdelay = 0
    #region Serverrestart
    #foreach($port in $tcpportarray){
    for($i=0;$i -lt $tcpportarray.count;$i++){
        $portstring = $tcpportarray[$i].tostring()
        $servernumber = $i+1 
        $isrunning = Check-Listenport $tcpportarray[$i]

        if($isrunning -eq $true){
            $pidbyports = Get-PIDByPorts $tcpportarray[$i] $udpportarray[$i]
            if($pidbyports -eq 0){
               # Write-Host "Warning. Could not get the PID by udp + tcp ports. This usually happens when UDP or TCP ports were not closed fast enough. Increase `$waittimebetweenserverstarts or `$waitwithstartloopscount"
            }
			if ($serverwaitforrestartcounterarray[($servernumber-1)] -gt 0){
				Write-Host (get-date -Format HH:mm:ss) "Server $servernumber (PID: $($pidbyports)) is running again. Gamedir: $($gamedirs[$i])"
			}
			else{
				if($firstloop){
					Write-Host (get-date -Format HH:mm:ss) "Server $servernumber (PID: $($pidbyports)) is running.  Gamedir: $($gamedirs[$i])"
				}
			}
            $serverwaitforrestartcounterarray[($servernumber-1)] = 0
        }

        
        if ($isrunning -ne $true){
            $serverstartdelay = $serverstartdelay + $waittimebetweenserverstarts 
            if($serverwaitforrestartcounterarray[($servernumber-1)] -eq 0){ ##
                #region gather logfiles
                if($timeout){ # gather logfiles
                    Write-Host "timeout "$timeout
					if($crashlogscollect){
						$getchilditemstring = "$originpath$($gamedirs[$i])"+ "\R2Northstar\logs"
						$logfiles = Get-Childitem $getchilditemstring -File | sort -Descending LastWriteTime
						Copy-Item $logfiles[1].fullname $crashlogspath
						write-host (get-date -Format HH:mm:ss) "Server $servernumber crashed. Gamedir $($gamedirs[$i]). Logfile copied to " $crashlogspath
					}
					else{
						write-host (get-date -Format HH:mm:ss) "Server $servernumber crashed. Gamedir $($gamedirs[$i])."
					}
                }
                #endregion gather logfiles
                $startprocessstring = "$originpath$($gamedirs[$i])" + "\NorthstarLauncher.exe"
                if($allowargumentoverride){
                    Write-Host (get-date -Format HH:mm:ss) "Using starting arguments for server $servernumber / gamedir $($gamedirs[$i]) from r2ds.bat because override flag was set."
                    $r2dsbat = Get-Content "$($gamedirs[$i])\r2ds.bat"
                    if($r2dsbat -match " -port"){
                        $argumentliststring = $r2dsbat
                    }
                    else{
                        $argumentliststring = $r2dsbat +  " -port " + $udpportarray[$i]
                    }
                }
                else{
                    $argumentliststring = $northstarlauncherargs + " -port " + $udpportarray[$i]
                }
                
                $nspowershellcommand = "-command &{ 
                    write-host (get-date -Format HH:mm:ss) Executing startup delay for server $servernumber of $serverstartdelay seconds;
                    sleep $serverstartdelay; 
                    start-process -WindowStyle Minimized -WorkingDirectory $singlequote`"$originpath$($gamedirs[$i])`"$singlequote $singlequote`"$originpath$($gamedirs[$i])\NorthstarLauncher.exe`"$singlequote `" -argumentlist $singlequote `"$argumentliststring `" $singlequote;
                }" # Dont ask! ;-) only took me 2 hours to figure out
                write-host (get-date -Format HH:mm:ss) "Starting server $servernumber (gamedir $($gamedirs[$i])) using additional (non visible) Powershell process with delay $serverstartdelay seconds."
                Start-Process -WindowStyle hidden powershell -argumentlist $nspowershellcommand
                $serverwaitforrestartcounterarray[($servernumber-1)] = $waitwithstartloopscount
            }
            else{
                write-host (get-date -Format HH:mm:ss) "Waiting to start server $servernumber again for loops:" $serverwaitforrestartcounterarray[($servernumber-1)]
            }

        $serverwaitforrestartcounterarray[($servernumber-1)] = $serverwaitforrestartcounterarray[($servernumber-1)] -1 
        }
    }
    $serverstartdelay = 0 #reset delay for next loop
    #endregion Serverrestart
    try{start-process "$ScriptPath\$enginerrorclosepath" -ErrorAction SilentlyContinue}catch{}finally{} #send enter to window "Engine Error" to close it properly if crashed with msgbox
    sleep $waittimebetweenloops
    
    #region Monitor uptime and close after certain uptime
    $date = get-date
    $timeout = $false 
	$processes = get-process -name NorthstarLauncher -ErrorAction SilentlyContinue
    foreach($process in $processes){
        $windowtitle = $process.MainWindowTitle
        $maxplayers = 0
        $players = 0
        if($windowtitle -match "Titanfall 2 dedicated server - "){
            $windowtitle1 = ($windowtitle.split("/"))[0]
            $windowtitle2 = ($windowtitle.split("/"))[1]
            $maxplayers = ($windowtitle2.substring((0),2))
            $players = ($windowtitle1.substring(($windowtitle1.length-2),2))
        }

		if($showuptimemonitor){
			if($showuptimeloopcounter -ge $showuptimemonitorafterloops){
                $virtualmemory = [math]::round(([int64]$process.VirtualMemorySize64 / 1024 / 1024 / 1024),1)
				write-host (get-date -Format HH:mm:ss) Process $process.path "PID" $process.id  "is running for" ($date - $process.StartTime).hours "hours and" ($date - $process.StartTime).minutes "minutes and has $players players playing on it. Virtual Memory: $($virtualmemory)GB"
                <#if($showmonitorgreeting){
                    Write-Host "Sending greeting message to server."
                    Start-Process "$ScriptPath\sendcommandtopid.exe" -Wait -argumentlist "$($process.ID) `"sv_cheats 1`""
                    Start-Process "$ScriptPath\sendcommandtopid.exe" -Wait -argumentlist "$($process.ID) `"script foreach `(entity player in GetPlayerArray`(`)`) SendHudMessage`( player, `"`"Server Message Thanks for playing on faky`"'`"s servers`"`", -1, 0.4, 0, 255, 0, 3000, 0.5, 2.0, 1 )`""
                    Start-Process "$ScriptPath\sendcommandtopid.exe" -Wait -argumentlist "$($process.ID) `"sv_cheats 0`""
                }#>
			}
		}
		if($process.Starttime){
            if(($date - $process.StartTime).hours -ge $restartserverhours){
                if($players -lt 2){
                    #Stop-Process $process.id
                    Start-Process "$ScriptPath\sendcommandtopid.exe" -Argumentlist "$($process.ID) quit"
                    write-host (get-date -Format HH:mm:ss) $process.path "Stopping server because it is runnig for at least $restartserverhours hours. PID: " $process.id
                    $timeout = $true #set timeout $true so we know we did kill that server and it did not crash, so it doesnt copy logfile
                    #$srvalreadynotifiedplayers = $false
                }else{
                    Write-Host (get-date -Format HH:mm:ss) "$($process.path) is running for at least $restartserverhours hours. Will not terminate server because there are $players players on it."
                    #$srvalreadynotifiedplayers = $true
                }
            }
        }
    }
	if($showuptimeloopcounter -ge $showuptimemonitorafterloops){
		$showuptimeloopcounter = 0
	}
	$showuptimeloopcounter = $showuptimeloopcounter + 1
	#endregion Monitor uptime and close after certain uptime

    #region Serverbrowser
    $myserverlist = @()
    $masterservernotreachable = $false
    try{$serverlist = Invoke-RestMethod $masterserverlisturl -ErrorAction SilentlyContinue}
    catch{
        Write-Host "Could not query master server. Can not get server list for server browser from $masterserverlisturl"
        $masterservernotreachable = $true
    }
    finally{} #get serverlist from master server
    $serverlist = $serverlist | sort playercount -Descending # sort by player count
    ForEach($filter in $myserverfilternamearray){
        $filteredserverlist = $serverlist | where -property name -match $filter
        $myserverlist = $myserverlist + $filteredserverlist
        $serverlist = $serverlist | where -property name -notmatch $filter
    }

	$fakyplayercount = 0
	$playercountpublic = 0
	$totalslots = 0
	$fakyslots = 0
	$euslots = 0
	$euplayercount = 0
	$usslots = 0
	$usplayercount = 0
	$euslots = 0
	$euplayercount = 0
	$ucount = 0
	$uslots = 0
	$totalplayercount = 0
	$servercount = 0
    $asiaplayercount = 0
    $asiaslots = 0
    $rusplayercount = 0
    $russlots = 0
    $ausplayercount = 0
    $ausslots = 0
    $saplayercount = 0
    $saslots = 0

    ForEach($server in $myserverlist){
        $servercount = $servercount +1
        $totalplayercount = $totalplayercount + $server.playerCount
        $fakyplayercount = $fakyplayercount + $server.playerCount
        $fakyslots = $fakyslots + $server.maxPlayers
    }

    ForEach($server in $serverlist){
        $servercount = $servercount +1
        $totalplayercount = $totalplayercount + $server.playerCount
        if($server.hasPassword -eq $false){
            $playercountpublic = $playercountpublic + $server.playerCount
            $totalslots = $totalslots + $server.maxPlayers
        }

	    if($server.name -match "EU" -or $server.name -match  "UK" -or $server.name -match "LONDON" -or $server.name -match "Softballpit" -or $server.name -match '\[GER'){ #EU
            $euplayercount = $euplayercount + $server.playerCount
            $euslots = $euslots + $server.maxPlayers
        }
        else{
            if($server.name -match "US-" -or $server.name -match '\[US' -or $server.name -match "NA " -or $server.name -match "NA-"){ #US / North America
                $usplayercount = $usplayercount + $server.playerCount
                $usslots = $usslots + $server.maxPlayers
            }
            else{
                if($server.name -match '\[AUS\]' -or $server.name -match '\[AU\]'){ #AUS
                    $ausplayercount = $ausplayercount + $server.playerCount
                    $ausslots = $ausslots + $server.maxPlayers
                }
                else{
                    if($server.name -match '\[ASIA\]' -or $server.name -match '\[JPN\]' ){ #ASIA
                        $asiaplayercount = $asiaplayercount + $server.playerCount
                        $asiaslots = $asiaslots + $server.maxPlayers
                    }
                    else{
                        if($server.name -match '\[RU' ){ #RUS
                            $rusplayercount = $rusplayercount + $server.playerCount
                            $russlots = $russlots + $server.maxPlayers
                        }
                        else{
                            if($server.name -match '\[South-America'-or $server.name -match '\[South america' -or $server.name -match '\[ZA' -or $server.name -match '\[Brazil') # SA
                            {
                                $saplayercount = $saplayercount + $server.playerCount
                                $saslots = $saslots + $server.maxPlayers 
                            }
                            else{
                                $ucount = $ucount + $server.playerCount
                                $uslots = $uslots + $server.maxPlayers
                            }
                        }
                    }
                }
            }
        }
    }
    if($serverbrowserenable -eq $true){
		$htmlpath = $serverbrowserfilepath
		if(Test-Path $serverbrowserfilepath){
			remove-item $htmlpath #remove index.html
		}
		$file = @"
<!DOCTYPE html>
<head>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>
   function reloadPage(){
        location.reload(true);
    }

`$(document).ready(function(){
  `$("#myInput").on("keyup", function() {
    var value = `$(this).val().toLowerCase();
    `$("#myTable tr").filter(function() {
      `$(this).toggle(`$(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
});
</script>

<style>
table {border-collapse:collapse;}
td {border: 1px solid;}
th {text-align:left;}
</style>
</head>
<body>
<p>Delay: approx 30 seconds<p/>
<p>
Servers: $servercount <br>
Total players: $totalplayercount<br>
Public slots: $playercountpublic / $totalslots <br>
$myfilterstring slots: $fakyplayercount / $fakyslots <br>
EU slots: $euplayercount / $euslots <br>
NA slots: $usplayercount / $usslots <br>
Asia slots: $asiaplayercount / $asiaslots <br>
RUS slots: $rusplayercount / $russlots <br>
AUS slots: $ausplayercount / $ausslots <br>
SA slots: $saplayercount / $saslots <br>
Other / unknown regions: $ucount / $uslots <br><br>
<button type="button" onclick="reloadPage();">Refresh</button>   
<input id="myInput" type="text" placeholder="Search..">
</p>
<p>Your servers based on config myserverfilternamearray</p>
<table>
<tbody id="myTable">
<tr><th>Servername</th><th>Gamemode</th><th>Map</th><th>Players</th><th>Maxplayers</th><th>Password</th><th>Description</th></tr>
"@
        if($masterservernotreachable){
            "Could not query master server $masterserverlisturl" | Out-File -Encoding utf8 -Filepath $htmlpath
        }

	    $file | Out-File -Encoding utf8 -Append -Filepath $htmlpath
        ForEach($server in $myserverlist){
            "<tr><td>" + $server.name + "</td><td>"+ $server.playlist +"</td><td>" + $server.map + "</td><td>" +$server.playerCount + "</td><td>" + $server.maxPlayers +"</td><td>" +$server.hasPassword + "</td><td>" +$server.description + "</td></tr>" | Out-File -Encoding utf8 -Append -FilePath $htmlpath
        }

        '</tbody>
</table>
<br>
<table>
<tbody id="myTable">
<tr><th>Servername</th><th>Gamemode</th><th>Map</th><th>Players</th><th>Maxplayers</th><th>Password</th><th>Description</th></tr>' | Out-File -encoding utf8 -Append -FilePath $htmlpath

	    ForEach($server in $serverlist){
		    "<tr><td>" + $server.name + "</td><td>"+ $server.playlist +"</td><td>" + $server.map + "</td><td>" +$server.playerCount + "</td><td>" + $server.maxPlayers +"</td><td>" +$server.hasPassword + "</td><td>" +$server.description + "</td></tr>" | Out-File -Encoding utf8 -Append -FilePath $htmlpath
	    }

	    $file = @"
</tbody>
</table>
</body>
</html>
"@
	    $file | Out-File -Encoding utf8 -Append -Filepath $htmlpath

	    clear-variable file
	    clear-variable fakyplayercount 
	    clear-variable playercountpublic
	    clear-variable totalslots
	    clear-variable fakyslots
	    clear-variable euslots
	    clear-variable euplayercount
	    clear-variable usslots
	    clear-variable usplayercount
	    clear-variable euslots
	    clear-variable euplayercount
	    clear-variable ucount
	    clear-variable uslots
	    clear-variable totalplayercount
	    clear-variable servercount
        clear-variable asiaplayercount
        clear-variable asiaslots
        clear-variable rusplayercount
        clear-variable russlots
        clear-variable ausplayercount
        clear-variable ausslots
        clear-variable saplayercount
        clear-variable saslots
    }
    #endregion Serverbrowser

    #region log cleanup
    if((get-date) -ge $logfilesdeletelastdate.AddMinutes($deletelogsminutes)){
        write-host (get-date -Format HH:mm:ss) "Checking/clearing Northstar logfiles because they haven't been cleared for $deletelogsminutes minutes or script was just started."
        $logfiles = get-childitem -recurse -include ('*.txt','*.dmp') -Path "$logfilespathstring"
        $logfilesdelete = $logfiles | Where-Object { $_.LastWriteTime -lt ((Get-Date).AddDays(-($deletelogsafterdays)))}
        $logfilesdelete | Remove-Item -Verbose
        $logfilesdeletelastdate = get-date
    }
    #endregion log cleanup
    $firstloop = $false #setting to false so we know that first loop is over
}
while($true) #execute forever
}
#endregion mainloop

catch{
    Write-Host "Error occured!"
    $Error
    $Error.clear()
}

finally{
    if($enablelogging){
        Stop-Transcript
    }
    if($htmlpath){
        if(Test-Path $htmlpath){
            remove-item $htmlpath
        }
    }
    Write-Host "Northstar Watcher terminated. Please close your severs manually."
    pause
}