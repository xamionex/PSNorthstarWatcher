#helper for creating symbolic links in a different process that can be started with admin privileges
#New-Item -ItemType SymbolicLink -Path "$($NorthstarServer.AbsolutePath)\$($file.name)" -Value $file.fullname
param(
    [string]$symlinklistsrc,
    [String]$symlinklistdst
)
function New-Symlink{
    param(
        [string]$srcpath,
        [string]$dstpath
    )
    New-Item -ItemType SymbolicLink -Path $dstpath -Value $srcpath
}
Write-Host "SRC String" $symlinklistsrc
Write-Host "DST String" $symlinklistdst
[System.Collections.ArrayList]$src = $symlinklistsrc.split(";")
Write-Host "SRC array" $src
[System.Collections.ArrayList]$dst = $symlinklistdst.split(";")
Write-Host "DST array" $dst
$src.Removeat($src.count-1)
Write-Host "SRC array" $src
$dst.Removeat($dst.count-1)
Write-Host "DST array" $dst

For($i=0;$i -lt $src.count;$i++){
	Write-Host "loop count $i"
	Write-Host "array count" $src.count
	if($src[0] -ne "True" -and $dst[0]-ne "True"){
		Write-Host "Creating Symlink" $src[$i] "to" $dst[$i]
		New-Symlink -srcpath $src[$i] -dstpath $dst[$i]
	}
}

Write-Host ($Error | Out-string)