# Windows services; status in the preview, Ctrl+K starts, stops or restarts (asks for admin).
# @zunder.name        Services
# @zunder.prefix      sd
# @zunder.glyph       \uf085
# @zunder.color       #46a35e
# @zunder.description Search Windows services, start, stop or restart them
# @zunder.platforms   windows
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}

$words = if ($args.Count -gt 0) { "$($args[0])".ToLower().Split(" ", [StringSplitOptions]::RemoveEmptyEntries) } else { @() }
$dot = [char]0xB7
$glyphs = @{ Running = "$([char]0xf058)"; StartPending = "$([char]0xf110)"; StopPending = "$([char]0xf110)" }

# Actions run through cmd /C. An encoded command needs no quoting, and Start-Process -Verb RunAs
# shows the UAC prompt, since starting or stopping a service needs admin.
function Encoded($script) {
    "powershell -NoProfile -WindowStyle Hidden -EncodedCommand " + [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))
}
function Elevated($cmdlet, $name) {
    $inner = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes("$cmdlet -Name '$($name.Replace("'", "''"))'"))
    Encoded "Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList '-NoProfile -EncodedCommand $inner'"
}

$found = @(Get-Service -ErrorAction SilentlyContinue | Where-Object {
    $hay = "$($_.Name) $($_.DisplayName) $($_.Status)".ToLower()
    -not ($words | Where-Object { -not $hay.Contains($_) })
} | Sort-Object -Property @{ Expression = { $_.Status -ne "Running" } }, DisplayName | Select-Object -First 60)

foreach ($s in $found) {
    $deps = @($s.DependentServices | ForEach-Object Name)
    $needs = @($s.ServicesDependedOn | ForEach-Object Name)
    $preview = @("$($s.DisplayName) ($($s.Name))", "",
                 "state    $($s.Status)",
                 "start    $($s.StartType)")
    if ($needs.Count) { $preview += "needs    $($needs -join ', ')" }
    if ($deps.Count) { $preview += "used by  $($deps -join ', ')" }
    [ordered]@{
        title = $s.DisplayName
        subtitle = $s.Name
        hint = "$($s.StartType.ToString().ToLower()) $dot $($s.Status.ToString().ToLower())"
        glyph = if ($glyphs.ContainsKey("$($s.Status)")) { $glyphs["$($s.Status)"] } else { "" }
        action = @{ open = "services.msc" }
        actions = @(
            [ordered]@{ title = "Start"; glyph = "$([char]0xf04b)"; run = (Elevated "Start-Service" $s.Name) },
            [ordered]@{ title = "Stop"; glyph = "$([char]0xf04d)"; run = (Elevated "Stop-Service -Force" $s.Name) },
            [ordered]@{ title = "Restart"; glyph = "$([char]0xf01e)"; run = (Elevated "Restart-Service -Force" $s.Name) },
            [ordered]@{ title = "Copy name"; copy = $s.Name })
        preview = $preview -join "`n"
    } | ConvertTo-Json -Compress -Depth 5
}
