# Copy the local IP address.
# @zunder.name  Copy Local IP
# @zunder.mode  command
# @zunder.glyph \uf0e8
# @zunder.color #2f93b8
# @zunder.description Copy your local IPv4 address to the clipboard
# @zunder.platforms   windows
# The address Windows would send from to reach the internet, like `ip route get 1.1.1.1`:
# connecting a UDP socket picks the route without sending anything.
$ip = $null
$sock = New-Object System.Net.Sockets.Socket ([System.Net.Sockets.AddressFamily]::InterNetwork), ([System.Net.Sockets.SocketType]::Dgram), ([System.Net.Sockets.ProtocolType]::Udp)
try {
    $sock.Connect("1.1.1.1", 53)
    $ip = $sock.LocalEndPoint.Address.ToString()
} catch {
} finally {
    $sock.Close()
}
if (-not $ip -or $ip -eq "0.0.0.0") {
    [Console]::Error.WriteLine("No IP: not connected")
    exit 1
}
Set-Clipboard -Value $ip
# zunder ignores a command plugin's output; printed for scripts and tests
Write-Output $ip
exit 0
