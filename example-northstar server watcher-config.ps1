## CONFIG START: PLEASE EDIT
$originpath = "C:\Server\Origin Games\" # path to the folder where your titanfall servers reside. Needs ending "\" !!!!!!!!!!!!!!!!!!!
$gamedir = "Titanfall2-" #name/prefix of your titanfall folders inside $originpath without number, example: Titantall2-n (n is the server number). If your server folders are just named "1", "2" (without prefix) just leave this empty
$enginerrorclosepath = "engineerrorclose.exe" # absolute or relative path to your enginerrorclose.exe
$tcpportarray = @(8081,8082) #auth ports you want to use for your titanfall servers.
$udpportarray = @(37015,37016) #specify startport without latest number (37031=> 3703). Dont forget to adjust your portforwarding!!! 
$deletelogsafterdays = 1 #how many days until logs get deleted
$waittimebetweenserverstarts = 15 #time in seconds before server starts, depends on your server speed. recommend values between 5-30 seconds
$waittimebetweenloops = 15 #time in seconds after each loop of this script. also refresh rate for index.html default: 15
$waitwithstartloopscount = 8 # after a server has been started at least wait the defined count of loops to start it again. this prevents accidental server duplicate processes default: 8 (15 second loops * 8 = 120 seconds)
$serverbrowserenable = $true
$serverbrowserfilepath = "index.html" #absolute path to where the index.html should be saved. 
$restartserverhours = 4 #time in hours to force restart server (kills process) after certain uptime
$masterserverlisturl = "https://northstar.tf/client/servers" # url path to master server server list (json format)
$myserverfilternamearray = @("Kraber","Gun") #put an identifier here to count your slots for serverbrowser .html file
$showuptimemonitor = $true #starts 2nd powershell process with monitor if true
$showuptimemonitorafterloops = 60 #after how many loops should it show uptime. default: 60 makes it display every 15 minutes
$northstarlauncherargs = "-dedicated -multiple -softwared3d11" #when launching servers use those args
$crashlogscollect = $false #$true to collect them, $false to disable
$crashlogspath = "C:\apache\htdocs\northstar\servercrash-logs" #where to export crash logs to collect them
$deletelogsminutes = 60 # defines (in minutes) how often this script should search for logfiles and delete them
## CONFIG END