do{
    $processes = get-process -name titanfall2-unpacked| select id,starttime
    $date = get-date
        foreach($process in $processes){
            Write-Host "PID" $process.id
           write-host "hours:" ($date - $process.StartTime).hours "minutes:"($date - $process.StartTime).minutes
        }
    write-host "time: " $date.hour$date.minute
    write-host "------------"
    sleep 60
}
while($true)