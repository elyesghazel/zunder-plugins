# Screenshot a region or window with the Snipping Tool, or every screen into a folder.
# @zunder.name        Screenshot
# @zunder.prefix      shot
# @zunder.glyph       \uf030
# @zunder.color       #c79a2a
# @zunder.description Screenshot a region, window or screen with the Snipping Tool, saved and copied
# @zunder.platforms   windows
# @zunder.setting     dir "Folder for screenshots (default Pictures\Screenshots)"
try { [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch {}

$dir = if ($env:ZUNDER_DIR) { $env:ZUNDER_DIR } else { Join-Path ([Environment]::GetFolderPath("MyPictures")) "Screenshots" }
if ($dir.StartsWith("~")) { $dir = $env:USERPROFILE + $dir.Substring(1) }

if ($args.Count -ge 2 -and $args[0] -eq "--take") {
    # every monitor in one image, saved and copied, like the Print Screen key
    if ($args.Count -ge 3) { $dir = $args[2] }
    Add-Type -AssemblyName System.Windows.Forms, System.Drawing
    # without this a scaled display is captured at the wrong size
    Add-Type -Name Dpi -Namespace Zunder -MemberDefinition '[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();'
    [void][Zunder.Dpi]::SetProcessDPIAware()
    Start-Sleep -Milliseconds 300  # let zunder close before the capture
    $b = [System.Windows.Forms.SystemInformation]::VirtualScreen
    $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($b.Left, $b.Top, 0, 0, $bmp.Size)
    $g.Dispose()
    [void](New-Item -ItemType Directory -Force -Path $dir)
    $file = Join-Path $dir ((Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".png")
    $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
    [System.Windows.Forms.Clipboard]::SetImage($bmp)
    $bmp.Dispose()
    exit 0
}

$q = if ($args.Count -gt 0) { "$($args[0])".ToLower() } else { "" }
function Row($mode, $title, $subtitle, $action) {
    if (-not "$mode $title".ToLower().Contains($q)) { return }
    [ordered]@{ title = $title; subtitle = $subtitle; action = $action } | ConvertTo-Json -Compress -Depth 5
}
# cmd /C runs `run`: paths stay in double quotes, which Windows paths can't contain; a trailing
# backslash would escape the closing quote
$take = "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" --take all `"$($dir.TrimEnd('\'))`""
Row "region" "Region" "drag a rectangle, copied" @{ open = "ms-screenclip:" }
Row "window" "Window" "pick the window mode in the Snipping Tool bar" @{ open = "ms-screenclip:" }
Row "all" "All screens" "every monitor in one image, saved and copied" @{ run = $take }
Row "folder" "Open folder" $dir @{ open = $dir }
