# Search running processes in your session; Enter stops the selected one.
# @zunder.name   Kill Process
# @zunder.prefix kill
# @zunder.glyph  \uf05e
# @zunder.color  #c94f4f
# @zunder.description Search your processes by name, sorted by CPU, Enter stops one
# @zunder.platforms   windows
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}

$query = if ($args.Count -gt 0) { "$($args[0])".ToLower() } else { "" }
$dot = [char]0xB7
# your session only, like `ps -u $UID`: services in session 0 aren't yours to stop
$session = [System.Diagnostics.Process]::GetCurrentProcess().SessionId
$now = Get-Date
$cores = [Environment]::ProcessorCount

$rows = @()
foreach ($p in (Get-Process | Where-Object { $_.SessionId -eq $session -and $_.Id -ne $PID })) {
    $name = $p.ProcessName
    if ($query -and -not $name.ToLower().Contains($query)) { continue }
    # lifetime average like ps's %cpu: cpu seconds over seconds alive, per core
    $cpu = 0.0
    try {
        $alive = ($now - $p.StartTime).TotalSeconds
        if ($alive -gt 0 -and $p.CPU) { $cpu = 100.0 * $p.CPU / $alive / $cores }
    } catch {}
    $rows += [pscustomobject]@{ cpu = $cpu; id = $p.Id; mb = [int]($p.WorkingSet64 / 1MB); name = $name }
}

# apps like a browser run as many processes: offer one row that stops them all
if ($query -and $rows.Count -gt 1) {
    $names = (($rows | ForEach-Object name | Sort-Object -Unique) -join ", ")
    if ($names.Length -gt 80) { $names = $names.Substring(0, 80) }
    $pids = ($rows | ForEach-Object { "/PID $($_.id)" }) -join " "
    $mb = ($rows | Measure-Object -Property mb -Sum).Sum
    [ordered]@{ title = "kill all $query"; subtitle = "$($rows.Count) processes $dot $names"; hint = "$mb MB"
                action = @{ run = "taskkill /F $pids" } } | ConvertTo-Json -Compress -Depth 5
}
foreach ($r in ($rows | Sort-Object -Property cpu, id -Descending | Select-Object -First 40)) {
    [ordered]@{ title = $r.name; subtitle = "pid $($r.id)"; hint = "{0:N0}% $dot {1} MB" -f $r.cpu, $r.mb
                action = @{ run = "taskkill /F /PID $($r.id)" } } | ConvertTo-Json -Compress -Depth 5
}
