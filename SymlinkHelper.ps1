#helper for creating symbolic links in a different process that can be started with admin privileges
param(
    [string]$srcpath,
    [string]$dstpath
)
#New-Item -ItemType SymbolicLink -Path "$($NorthstarServer.AbsolutePath)\$($file.name)" -Value $file.fullname
New-Item -ItemType SymbolicLink -Path $dstpath -Value $srcpath
Write-Host "srcpath" $srcpath
Write-Host "dstpath" $dstpath
Write-Host ($Error | Out-string)