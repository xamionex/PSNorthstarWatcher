## CONFIG START: PLEASE EDIT
$originpath = "C:\Server\Origin Games\" # path to the folder where your titanfall servers reside
$gamedir = "Titanfall2-" #name of your titanfall folders without number, example: Titantall2-n (n is the server number)
$enginerrorclosepath = "engineerrorclose.exe" # absolute or relative path to your enginerrorclose.exe
$portarray = @(8081) #auth ports you want to use for your titanfall servers, also: last number is used to detect server number Titanfall2-n (eg 8081 => Titanfall 2-1), at the moment restricted to 9 servers!
$udpstartport = 3701 #specify startport without latest number (37031=> 3703). Dont forget to adjust your portforwarding!!! works the same as authport (above)
# $killemptypath = "D:\Games\Origin\restart0players.exe" #obsolete
$deletelogsafterdays = 1 #how many days until logs get deleted
$waittimebetweenserverstarts = 60 #time in seconds before server starts, depends on your server speed. recommend values between 30-120
$waittimebetweenloops = 15 #time in seconds after each loop of this script. also refresh rate for index.html default: 15
$serverbrowserenable = $true #$true to enable, $false to disable
$serverbrowserfilepath = "index.html" #absolute or relative path to where the index.html should be saved. 
$restartserverhours = 3 #time in hours to force restart server (kills process) after certain uptime
$masterserverlisturl = "https://northstar.tf/client/servers" # url path to master server server list (json format)
$myserverfilternamearray = @("Kraber ","Dedicated") #put an identifier here to count your slots for serverbrowser .html file
$showuptimemonitor = $true #starts 2nd powershell process with monitor if true
$northstarlauncherargs = "-dedicated -multiple -softwared3d11" #when launching server use those args
$crashlogscollect = $false #$true to collect them, $false to disable
$crashlogspath = "C:\server\apache\htdocs\northstar\server-crashlogs" #where to export crash logs to collect them
## CONFIG END

$logfilespathstring = "" + $originpath + $gamedir + "`*\R2Northstar\logs\`*"  # dont change this
if($showuptimemonitor){
    Start-Process powershell -argumentlist "-File monitor_runtime.ps1"
}
$myfilterstring = ""
foreach($filter in $myserverfilternamearray){$myfilterstring = $myfilterstring + $filter +", "}

do{

    function Check-Listenport([int] $port){
        if ($port -gt 0 -and $port -lt 65535){
        
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
    ##
    foreach($port in $portarray){
        $isrunning = Check-Listenport $port
        if ($isrunning -ne $true){
            $portstring = $port.tostring()
            $servernumber = $portstring.substring(3)
            Write-Host "starting server $servernumber time:" (get-date).hour (get-date).minute
            #cd "$originpath$gamedir$servernumber"
            $startprocessstring = "$originpath$gamedir$servernumber" + "\NorthstarLauncher.exe"
            $argumentliststring = $northstarlauncherargs + " -port " + $udpstartport + $servernumber
            sleep $waittimebetweenserverstarts
            Start-Process $startprocessstring -ArgumentList $argumentliststring -WorkingDirectory "$originpath$gamedir$servernumber"
            if($timeout -eq $false){
                $logfiles = Get-Childitem "$originpath$gamedir$servernumber"+ "\R2Northstar\logs" -File | sort -Descending LastWriteTime
                Copy-Item $logfiles[1].fullname $crashlogspath
                Write-Host "logfile copied to " $crashlogspath
            }
        }
    }
    
    start-process $enginerrorclosepath #send enter to window "Engine Error" to close it properly if crashed with msgbox
    sleep $waittimebetweenloops
    #start-process $killemptypath #workaround restart not needed anymore
    $processes = get-process -name titanfall2-unpacked| select id,starttime
    $date = get-date
    $timeout = $false 
    foreach($process in $processes){
        if(($date - $process.StartTime).hours -ge $restartserverhours){
            Stop-Process $process.id
            Write-Host "stopping server because it hit restartserverhours " $process.id
            $timeout = $true #set timeout $true so we know we did kill that server and it did not crash, so it doesnt copy logfile
        }
    }


    $serverlist = Invoke-RestMethod $masterserverlisturl #get serverlist from master server
    $serverlist = $serverlist | sort playercount -Descending # sort by player count

    $fakyplayercount = 0
    $fakyslots = 0

    ForEach($server in $serverlist){
        $servercount = $servercount +1
        $totalplayercount = $totalplayercount + $server.playerCount
        foreach($myserverfiltername in $myserverfilternamearray){
            if($server.name -match $myserverfiltername){
                $fakyplayercount = $fakyplayercount + $server.playerCount
                $fakyslots = $fakyslots + $server.maxPlayers
		        #Write-Host $server.name $server.playerCount "/" $server.maxPlayers $server.map
            }
        }
        if($server.hasPassword -eq $false){
            $playercountpublic = $playercountpublic + $server.playerCount
            $totalslots = $totalslots + $server.maxPlayers
    
        }
	    if($server.name -match "EU" -or $server.name -match  "UK" -or $server.name -match "LONDON" -or $server.name -match "Softballpit"){
            $euplayercount = $euplayercount + $server.playerCount
            $euslots = $euslots + $server.maxPlayers
        }
        if($server.name -match "US-" -or $server.name -match "US " -or $server.name -match "NA " -or $server.name -match "NA-"){
            $usplayercount = $usplayercount + $server.playerCount
            $usslots = $usslots + $server.maxPlayers
        }
        if(!($server.name -match "EU" -or $server.name -match  "UK" -or $server.name -match "LONDON" -or $server.name -match "Softballpit" -or $server.name -match "US-" -or $server.name -match "US " -or $server.name -match "NA " -or $server.name -match "NA-" -or $server.name -match "EU" -or $server.name -match  "UK" -or $server.name -match "LONDON" -or $server.name -match "Softballpit")){
            $ucount = $ucount + $server.playerCount
            $uslots = $uslots + $server.maxPlayers
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
US slots: $usplayercount / $usslots <br>
Other regions: $ucount / $uslots <br><br>
<button type="button" onclick="reloadPage();">Refresh</button>   
<input id="myInput" type="text" placeholder="Search..">
</p>
<table>
<tbody id="myTable">
<tr><th>Servername</th><th>Gamemode</th><th>Map</th><th>Players</th><th>Maxplayers</th><th>Password</th><th>Description</th></tr>
"@

    $file | Out-File -Filepath $htmlpath
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
    Remove-Variable file
    


    #$serverlist = Invoke-RestMethod https://northstar.tf/client/servers

#write-host "fakys slots" $fakyplayercount "/" $fakyslots
#write-host "public slots" $playercountpublic "/" $totalslots
#write-host "EU+UK slots" $euplayercount "/" $euslots
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
}

#log cleanup
$logfiles = get-childitem -recurse -include ('*.txt','*.dmp') -Path "$logfilespathstring"
$logfilesdelete = $logfiles | Where-Object { $_.LastWriteTime -lt ((Get-Date).AddDays(-($deletelogsafterdays)))}
$logfilesdelete | Remove-Item -Verbose

}
while($true)