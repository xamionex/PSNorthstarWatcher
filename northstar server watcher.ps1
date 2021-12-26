    $originpath = "D:\Games\Origin\"
    $gamedir = "Titanfall2-"
    $enginerrorclosepath = "D:\Games\Origin\engineerrorclose.exe"
    $portarray = @(8081,8082,8083,8084,8085,8086,8087)
    $killemptypath = "D:\Games\Origin\restart0players.exe"
do{

    function Check-Listenport([int] $port){
        if ($port -gt 0 -and $port -lt 65535){
        
        }
        else{
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
            Write-Host "starting $servernumber"
            cd "$originpath$gamedir$servernumber"
            Start-Process NorthstarLauncher.exe -ArgumentList "-dedicated -multiple -softwared3d11"
            sleep 7
        }
    }
    
    start-process $enginerrorclosepath #send enter to window "Engine Error" to close it properly if crashed with msgbox
    sleep 15
    #start-process $killemptypath #workaround restart not needed anymore
    sleep 3
    $processes = get-process -name titanfall2-unpacked| select id,starttime
    $date = get-date
    foreach($process in $processes){
        if(($date - $process.StartTime).hours -gt 2){
            Stop-Process $process.id
            Write-Host stopped $process.id
        }
    }
    
}
while($true)