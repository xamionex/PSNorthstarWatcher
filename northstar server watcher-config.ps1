## CONFIG START: PLEASE EDIT
$originpath = "C:\Server\Origin Games\" # path to the folder where your titanfall servers reside. Needs ending "\" !!!!!!!!!!!!!!!!!!!
$gamedirs = @("Titanfall2-1","Titanfall2-2","Titanfall2-4","Titanfall2-5","Titanfall2-6","Titanfall2-7") #List your titanfall folders here.
$enginerrorclosepath = "engineerrorclose.exe" # absolute or relative path to your enginerrorclose.exe
$tcpportarray = @(8071,8072,8074,8075,8076,8077) #auth ports you want to use for your titanfall servers
$udpportarray = @(37031,37032,37034,37035,37036,37037) #udp ports you want to use! 
$allowargumentoverride = $false #if set to $true script will take arguments from r2ds.bat to start northstarlauncher.exe instead of using $northstarlauncherargs. CAUTION: EXPERIMENTAL (not tested)
$deletelogsafterdays = 1 #how many days until logs get deleted
$waittimebetweenserverstarts = 5 #time in seconds before server starts, depends on your server speed. recommend values between 5-30 seconds
$waittimebetweenloops = 15 #time in seconds after each loop of this script. also refresh rate for index.html default: 15
$waitwithstartloopscount = 8 # after a server has been started at least wait the defined count of loops to start it again. this prevents accidental server duplicate processes default: 8 (15 second loops * 8 = 120 seconds)
$serverbrowserenable = $true
$serverbrowserfilepath = "C:\Server\xampp\vhosts\romeo91.synology.me\htdocs\northstar\serverbrowser\index.html" #absolute path to where the index.html should be saved. 
$restartserverhours = 6 #time in hours to force restart server (kills process) after certain uptime
#$masterserverlisturl = "https://northstar.tf/client/servers" # url path to master server server list (json format)
$masterserverlisturl = "http://northstar.tf/client/servers"
$myserverfilternamearray = @("faky","Titanfall france5") #put an identifier here to count your slots for serverbrowser .html file
$showmonitorgreeting = $false #if enabled it will display a message on all servers
$showuptimemonitor = $true #starts 2nd powershell process with monitor if true
$showuptimemonitorafterloops = 60 #after how many loops should it show uptime. default: 60 makes it display every 15 minutes
$northstarlauncherargs = "-dedicated -multiple -softwared3d11" #when launching servers use those args. Can be overriden, check $allowargumentoverride
$crashlogscollect = $true #$true to collect them, $false to disable
$crashlogspath = "C:\Server\xampp\vhosts\romeo91.synology.me\htdocs\northstar\servercrash-logs" #where to export crash logs to collect them
$deletelogsminutes = 60 # defines (in minutes) how often this script should search for logfiles and delete them
$enablelogging = $false #if $true puts console output to logfile psnswatcher-<datetime>.log
## CONFIG END