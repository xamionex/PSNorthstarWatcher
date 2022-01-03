#changelog
<#
    use external config file to make updates easier.
    check all config variables
    added regions to script
#>

#region configtest
try{
if(Test-Path "example-northstar server watcher-config.ps1" -ErrorAction Stop){
    Write-Host "Please rename example config file!"
    throw "Example config not renamed. Please rename config file, edit config variables and start again."
}

if(Test-Path "northstar server watcher-config.ps1" -ErrorAction Stop){
    . ("$PSScriptRoot\northstar server watcher-config.ps1")
}
else{
    throw "Config file not found!"
}

if($originpath){
    if($originpath[$originpath.length-1] -ne '\'){
        throw "Last character of origin path has to be a backslash!"
    }
}
else{
    throw "Origin path not set!"
}

if($portarray){
    if($portarray.Count -gt 9){
        throw "Added more than 9 Auth. ports. Only 9 are supported."
    }
}
else{
    throw "port array not set!"
}

if($udpstartport){
 
}
else{
    throw "UDP start port not set!"
}

if($deletelogsafterdays){
    
}
else{
    throw "deletelogsafterdays not set!"
}

if($waittimebetweenserverstarts){
    
}
else{
    throw "waittimebetweenserverstarts not set!"
} 

if($waittimebetweenloops){
    
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
        
    }
    else{
        throw "serverbrowserenable is true but you did not set a path!"
    }
}
else{
    throw "serverbrowserenable not set!"
}

if($restartserverhours){

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
    
}
else{
    throw "northstarlauncherargs not set!"
} 
if($crashlogscollect){
    if($crashlogspath){

    }
    else{
        throw "crashlogscollect is true but did not set crashlogspath!"
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
#endregion functions

#region vars and stuff
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
Northstar is awesome!! https://northstar.tf
"
Write-Host "Thanks for using this Powershell script. If you need help just @faky me on Northstar Discord."
write-host (get-date -Format HH:mm:ss) "Starting Northstar Server Watcher"
$serverwaitforrestartcounterarray = @()
$servercount = $portarray.count
foreach($server in $portarray){ #initialize array for counter
    $serverwaitforrestartcounterarray = $serverwaitforrestartcounterarray + 0
}
$logfilesdeletelastdate = (get-date).AddYears(-5) #make sure logs get cleared on first loop
cd $originpath
$logfilespathstring = "" + $originpath + $gamedir + "`*\R2Northstar\logs\`*"  #generate string for searching logfiles later, escaping * with backticks
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
    foreach($port in $portarray){
        $portstring = $port.tostring()
        $servernumber = $portstring.substring(3) #only get latest number of 4 digit port
        $isrunning = Check-Listenport $port

        if($isrunning -eq $true){
			if ($serverwaitforrestartcounterarray[($servernumber-1)] -gt 0){
				Write-Host (get-date -Format HH:mm:ss) "Server $servernumber is running again."
			}
			else{
				if($firstloop){
					Write-Host (get-date -Format HH:mm:ss) "Server $servernumber is running."
				}
			}
            $serverwaitforrestartcounterarray[($servernumber-1)] = 0
        }

        
        if ($isrunning -ne $true){
            $serverstartdelay = $serverstartdelay + $waittimebetweenserverstarts 
            if($serverwaitforrestartcounterarray[($servernumber-1)] -eq 0){ ##
                
                if($timeout -eq $false){ # gather logfiles
					if($crashlogscollect){
						$getchilditemstring = "$originpath$gamedir$servernumber"+ "\R2Northstar\logs"
						$logfiles = Get-Childitem $getchilditemstring -File | sort -Descending LastWriteTime
						Copy-Item $logfiles[1].fullname $crashlogspath
						write-host (get-date -Format HH:mm:ss) "Server $servernumber crashed. Logfile copied to " $crashlogspath
					}
					else{
						write-host (get-date -Format HH:mm:ss) "Server $servernumber crashed."
					}
                }

                $startprocessstring = "$originpath$gamedir$servernumber" + "\NorthstarLauncher.exe"
                $argumentliststring = $northstarlauncherargs + " -port " + $udpstartport + $servernumber
                $nspowershellcommand = "-command &{ 
                    write-host (get-date -Format HH:mm:ss) Executing startup delay for server $servernumber of $serverstartdelay seconds;
                    sleep $serverstartdelay; 
                    start-process -WindowStyle hidden -WorkingDirectory $singlequote`"$originpath$gamedir$servernumber`"$singlequote $singlequote`"$originpath$gamedir$servernumber\NorthstarLauncher.exe`"$singlequote `" -argumentlist $singlequote `"$argumentliststring `" $singlequote;
                }" # Dont ask! ;-) only took me 2 hours to figure out
                write-host (get-date -Format HH:mm:ss) "Starting server $servernumber using additional (non visible) Powershell process with delay $serverstartdelay seconds."
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

    start-process $enginerrorclosepath #send enter to window "Engine Error" to close it properly if crashed with msgbox
    sleep $waittimebetweenloops
    
    #region Monitor uptime and close after certain uptime
    $date = get-date
    $timeout = $false 
	$processes = get-process -name titanfall2-unpacked
    foreach($process in $processes){
		if($showuptimemonitor){
			if($showuptimeloopcounter -ge $showuptimemonitorafterloops){
				write-host (get-date -Format HH:mm:ss) Process $process.path "PID" $process.id  " is running for" ($date - $process.StartTime).hours "hours and" ($date - $process.StartTime).minutes "minutes"
                Write-Host "---------"
			}
		}
		
        if(($date - $process.StartTime).hours -ge $restartserverhours){
            Stop-Process $process.id
            write-host (get-date -Format HH:mm:ss) $process.path "Stopping server because it is runnig for at least $restartserverhours hours. PID: " $process.id
            $timeout = $true #set timeout $true so we know we did kill that server and it did not crash, so it doesnt copy logfile
        }
    }
	if($showuptimeloopcounter -ge $showuptimemonitorafterloops){
		$showuptimeloopcounter = 0
	}
	$showuptimeloopcounter = $showuptimeloopcounter + 1
	#endregion Monitor uptime and close after certain uptime

    #region Serverbrowser
    $myserverlist = @()
    $serverlist = Invoke-RestMethod $masterserverlisturl #get serverlist from master server
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

	    $file | Out-File -Filepath $htmlpath
        ForEach($server in $myserverlist){
            "<tr><td>" + $server.name + "</td><td>"+ $server.playlist +"</td><td>" + $server.map + "</td><td>" +$server.playerCount + "</td><td>" + $server.maxPlayers +"</td><td>" +$server.hasPassword + "</td><td>" +$server.description + "</td></tr>" | Out-File -Append -FilePath $htmlpath
        }

        '</tbody>
</table>
<br>
<table>
<tbody id="myTable">
<tr><th>Servername</th><th>Gamemode</th><th>Map</th><th>Players</th><th>Maxplayers</th><th>Password</th><th>Description</th></tr>' | Out-File -Append -FilePath $htmlpath

	    ForEach($server in $serverlist){
		    "<tr><td>" + $server.name + "</td><td>"+ $server.playlist +"</td><td>" + $server.map + "</td><td>" +$server.playerCount + "</td><td>" + $server.maxPlayers +"</td><td>" +$server.hasPassword + "</td><td>" +$server.description + "</td></tr>" | Out-File -Append -FilePath $htmlpath
	    }

	    $file = @"
</tbody>
</table>
</body>
</html>
"@
	    $file | Out-File -Append -Filepath $htmlpath

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
        write-host (get-date -Format HH:mm:ss) "Checking/clearing logfiles because they haven't been cleared for $deletelogsminutes minutes or script was just started."
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
    pause
}