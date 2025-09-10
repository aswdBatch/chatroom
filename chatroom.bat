@echo off
rem Simple P2P text chat using PowerShell TCP sockets
rem Usage:
rem   p2pchat.bat server <port>
rem   p2pchat.bat client <host> <port>

if "%~1"=="" (
  echo Usage:
  echo   %~nx0 server ^<port^>
  echo   %~nx0 client ^<host^> ^<port^>
  goto :eof
)

set MODE=%~1

if /I "%MODE%"=="server" (
  if "%~2"=="" (
    echo Missing port.
    goto :eof
  )
  set PORT=%~2
  echo Starting chat server on port %PORT%...
  powershell -NoProfile -Command ^
    "$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, %PORT%); `
     $listener.Start(); Write-Host 'Waiting for connection...'; `
     $client = $listener.AcceptTcpClient(); Write-Host 'Client connected!'; `
     $stream = $client.GetStream(); `
     $reader = New-Object IO.StreamReader($stream); `
     $writer = New-Object IO.StreamWriter($stream); $writer.AutoFlush = $true; `
     Start-Job { while ($true) { $line = Read-Host 'You'; if ($line -eq 'exit') { break }; $writer.WriteLine($line) } }; `
     while ($true) { $msg = $reader.ReadLine(); if ($msg -eq $null) { break }; Write-Host ('Peer: ' + $msg) } `
     $client.Close(); $listener.Stop();"
  goto :eof
)

if /I "%MODE%"=="client" (
  if "%~2"=="" (
    echo Missing host.
    goto :eof
  )
  if "%~3"=="" (
    echo Missing port.
    goto :eof
  )
  set HOST=%~2
  set PORT=%~3
  echo Connecting to %HOST%:%PORT% ...
  powershell -NoProfile -Command ^
    "$client = New-Object System.Net.Sockets.TcpClient; `
     $client.Connect('%HOST%', %PORT%); `
     $stream = $client.GetStream(); `
     $reader = New-Object IO.StreamReader($stream); `
     $writer = New-Object IO.StreamWriter($stream); $writer.AutoFlush = $true; `
     Start-Job { while ($true) { $line = Read-Host 'You'; if ($line -eq 'exit') { break }; $writer.WriteLine($line) } }; `
     while ($true) { $msg = $reader.ReadLine(); if ($msg -eq $null) { break }; Write-Host ('Peer: ' + $msg) } `
     $client.Close();"
  goto :eof
)

echo Unknown mode "%MODE%".
