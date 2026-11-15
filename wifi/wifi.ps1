# List Wi-Fi networks; Enter connects to a saved one, new ones open the Windows Wi-Fi list.
# @zunder.name        Wi-Fi
# @zunder.prefix      wifi
# @zunder.glyph       \uf1eb
# @zunder.color       #2a9d8f
# @zunder.description Connect to Wi-Fi networks with netsh
# @zunder.platforms   windows
# Pure ASCII on purpose: Windows PowerShell 5.1 reads a .ps1 without BOM as ANSI.
# netsh output is localised, so only labels that are the same in every language are matched
# (SSID, BSSID, the % after the signal).
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}

$query = if ($args.Count -gt 0) { "$($args[0])".Trim().ToLower() } else { "" }

function Row($r) { $r | ConvertTo-Json -Compress -Depth 5 }
function Bars($signal) { "$([char]0x2582)$([char]0x2584)$([char]0x2586)$([char]0x2588)".Substring(0, [Math]::Max(1, [Math]::Min(4, [int][Math]::Floor(($signal + 24) / 25)))) }
# cmd /C runs the actions: keep the SSID inside double quotes, which it can't contain itself
function Name($ssid) { 'name="' + $ssid + '"' }

$connected = $null
foreach ($line in (netsh wlan show interfaces 2>$null)) {
    if ($line -match '^\s+SSID\s+:\s(.*)$') { $connected = $Matches[1].Trim() }
}

# "User profiles" section: "    All User Profile     : Home" (the label is translated)
$saved = @{}
foreach ($line in (netsh wlan show profiles 2>$null)) {
    if ($line -match '^\s{4}\S.*?\s+:\s(.+)$') { $saved[$Matches[1].Trim()] = $true }
}

$nets = [ordered]@{}
$cur = $null
$output = netsh wlan show networks mode=bssid 2>$null
foreach ($line in $output) {
    if ($line -match '^SSID \d+\s*:\s?(.*)$') {
        $ssid = $Matches[1].Trim()
        if (-not $ssid) { $cur = $null; continue }  # hidden network
        if (-not $nets.Contains($ssid)) { $nets[$ssid] = @{ signal = 0; security = "" } }
        $cur = $nets[$ssid]
    } elseif ($cur -and $line -match '^\s+[^:]*?(Auth|Authentifi)[^:]*:\s(.+)$') {
        # Authentication / Authentifizierung / Authentification
        $cur.security = $Matches[2].Trim()
    } elseif ($cur -and $line -match ':\s(\d+)%\s*$') {
        $cur.signal = [Math]::Max($cur.signal, [int]$Matches[1])
    }
}

$open = '^(Open|Offen|Ouvert|Aperto|Abierta)'
$rows = @()
foreach ($ssid in $nets.Keys) {
    if ($ssid.Contains('"')) { continue }
    if ($query -and -not $ssid.ToLower().Contains($query)) { continue }
    $n = $nets[$ssid]
    $inuse = $ssid -eq $connected
    $secure = $n.security -and $n.security -notmatch $open
    $actions = @(@{ title = "Copy SSID"; copy = $ssid })
    if ($inuse) {
        $action = @{ run = "netsh wlan disconnect" }
        $subtitle = "connected $([char]0xB7) Enter disconnects"
    } elseif ($saved.ContainsKey($ssid)) {
        $action = @{ run = "netsh wlan connect $(Name $ssid)" }
        $subtitle = "saved"
    } else {
        # netsh can only connect with a profile; Windows' own list asks for the password
        $action = @{ open = "ms-availablenetworks:" }
        $subtitle = if ($secure) { "password in the Wi-Fi list" } else { "open network" }
    }
    if ($saved.ContainsKey($ssid)) {
        $actions += @{ title = "Forget network"; run = "netsh wlan delete profile $(Name $ssid)" }
    }
    $glyph = if ($inuse) { [char]0xf00c } elseif ($secure) { [char]0xf023 } else { [char]0xf1eb }
    $rows += [pscustomobject]@{
        inuse = $inuse; signal = $n.signal
        row = [ordered]@{
            title = $ssid
            subtitle = if ($secure) { "$subtitle $([char]0xB7) $($n.security)" } else { $subtitle }
            hint = "$(Bars $n.signal) $($n.signal)%"
            glyph = "$glyph"
            action = $action
            actions = $actions
        }
    }
}
foreach ($r in ($rows | Sort-Object -Property @{ Expression = "inuse"; Descending = $true }, @{ Expression = "signal"; Descending = $true })) {
    Row $r.row
}
if (-not $query -or "settings".StartsWith($query)) {
    Row ([ordered]@{ title = "Wi-Fi settings"; subtitle = "Windows Settings $([char]0xB7) Wi-Fi"; glyph = "$([char]0xf013)"; action = @{ open = "ms-settings:network-wifi" } })
}
if ($nets.Count -eq 0) {
    $why = ($output | Where-Object { "$_".Trim() } | Select-Object -First 1)
    Row ([ordered]@{ title = "No networks"; subtitle = if ($why) { "$why".Trim() } else { "is Wi-Fi on? Enter opens the Wi-Fi list" }; action = @{ open = "ms-availablenetworks:" } })
}
