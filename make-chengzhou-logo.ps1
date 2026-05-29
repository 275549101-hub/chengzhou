param(
  [string]$OutDir = "C:\Users\Administrator\Documents\Codex\2026-05-28\new-chat\logo"
)

Add-Type -AssemblyName System.Drawing

[System.IO.Directory]::CreateDirectory($OutDir) | Out-Null

function New-Canvas([int]$size) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  return @($bmp, $g)
}

function Save-Png($bmp, $g, [string]$path) {
  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

function Draw-Logo([int]$size, [string]$path) {
  $cv = New-Canvas $size
  $bmp = $cv[0]
  $g = $cv[1]

  $bgTop = [System.Drawing.Color]::FromArgb(37, 98, 70)
  $bgBottom = [System.Drawing.Color]::FromArgb(20, 66, 51)
  $ring = [System.Drawing.Color]::FromArgb(210, 183, 104)
  $line = [System.Drawing.Color]::FromArgb(236, 240, 226)
  $dot = [System.Drawing.Color]::FromArgb(230, 191, 87)

  $rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $bgTop, $bgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
  $g.FillRectangle($bg, $rect)
  $bg.Dispose()

  $outer = [int]($size * 0.07)
  $inner = [int]($size * 0.09)
  $penRing = New-Object System.Drawing.Pen($ring, [float]$outer)
  $g.DrawEllipse($penRing, $outer, $outer, $size - 2 * $outer, $size - 2 * $outer)
  $penRing.Dispose()

  $hullY = [int]($size * 0.63)
  $hullW = [int]($size * 0.50)
  $hullH = [int]($size * 0.08)
  $hullX = [int](($size - $hullW) / 2)

  $pathHull = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pathHull.AddArc($hullX, $hullY, $hullH, $hullH, 180, 90)
  $pathHull.AddArc($hullX + $hullW - $hullH, $hullY, $hullH, $hullH, 270, 90)
  $pathHull.AddArc($hullX + $hullW - $hullH, $hullY + $hullH - 2, $hullH, $hullH, 0, 90)
  $pathHull.AddArc($hullX, $hullY + $hullH - 2, $hullH, $hullH, 90, 90)
  $pathHull.CloseFigure()
  $brushLine = New-Object System.Drawing.SolidBrush($line)
  $g.FillPath($brushLine, $pathHull)
  $pathHull.Dispose()

  $penWave = New-Object System.Drawing.Pen($line, [float][int]($size * 0.028))
  $g.DrawArc($penWave, [int]($size * 0.22), [int]($size * 0.70), [int]($size * 0.56), [int]($size * 0.16), 200, 140)
  $penWave.Dispose()

  $pathSail = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p1 = New-Object System.Drawing.Point([int]($size * 0.47), [int]($size * 0.30))
  $p2 = New-Object System.Drawing.Point([int]($size * 0.47), [int]($size * 0.61))
  $p3 = New-Object System.Drawing.Point([int]($size * 0.70), [int]($size * 0.49))
  $pathSail.AddPolygon(@($p1, $p2, $p3))
  $g.FillPath($brushLine, $pathSail)
  $pathSail.Dispose()

  $mastPen = New-Object System.Drawing.Pen($line, [float][int]($size * 0.024))
  $g.DrawLine($mastPen, [int]($size * 0.43), [int]($size * 0.30), [int]($size * 0.43), [int]($size * 0.63))
  $mastPen.Dispose()

  $dotBrush = New-Object System.Drawing.SolidBrush($dot)
  $dotR = [int]($size * 0.028)
  $g.FillEllipse($dotBrush, [int]($size * 0.72), [int]($size * 0.22), $dotR * 2, $dotR * 2)
  $dotBrush.Dispose()

  $brushLine.Dispose()
  Save-Png $bmp $g $path
}

$out512 = Join-Path $OutDir "chengzhou-logo-512.png"
$out128 = Join-Path $OutDir "chengzhou-logo-128.png"
$out64 = Join-Path $OutDir "chengzhou-logo-64.png"

Draw-Logo 512 $out512
Draw-Logo 128 $out128
Draw-Logo 64 $out64

[Console]::OutputEncoding = [Text.Encoding]::UTF8
Write-Output $out512
Write-Output $out128
Write-Output $out64
