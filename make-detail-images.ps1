param(
  [string]$Source = "D:\1义乌\流苏款\image_task_01KRWTRKFXJ0QPTJ41J2AYGNJS_0.png",
  [string]$OutDir = "C:\Users\Administrator\Documents\Codex\2026-05-28\new-chat\detail-page-draft"
)

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

[System.IO.Directory]::CreateDirectory($OutDir) | Out-Null

$W = 750
$H = 1000
$dark = [System.Drawing.Color]::FromArgb(19, 92, 48)
$deep = [System.Drawing.Color]::FromArgb(8, 68, 36)
$gold = [System.Drawing.Color]::FromArgb(194, 143, 57)
$cream = [System.Drawing.Color]::FromArgb(248, 246, 234)
$mint = [System.Drawing.Color]::FromArgb(226, 239, 215)
$text = [System.Drawing.Color]::FromArgb(45, 56, 44)
$red = [System.Drawing.Color]::FromArgb(184, 49, 43)

function Font-Cn([float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
  $names = @("Microsoft YaHei UI", "Microsoft YaHei", "SimHei", "SimSun")
  foreach ($n in $names) {
    try { return New-Object System.Drawing.Font($n, $size, $style, [System.Drawing.GraphicsUnit]::Pixel) } catch {}
  }
  return New-Object System.Drawing.Font("Arial", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-Canvas([System.Drawing.Color]$top, [System.Drawing.Color]$bottom) {
  $bmp = New-Object System.Drawing.Bitmap($W, $H)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, $W, $H)),
    $top,
    $bottom,
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
  )
  $g.FillRectangle($brush, 0, 0, $W, $H)
  $brush.Dispose()
  return @($bmp, $g)
}

function Rounded-Path([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

function Fill-Rounded($g, [int]$x, [int]$y, [int]$w, [int]$h, [int]$r, [System.Drawing.Color]$color) {
  $path = Rounded-Path $x $y $w $h $r
  $brush = New-Object System.Drawing.SolidBrush($color)
  $g.FillPath($brush, $path)
  $brush.Dispose()
  $path.Dispose()
}

function Stroke-Rounded($g, [int]$x, [int]$y, [int]$w, [int]$h, [int]$r, [System.Drawing.Color]$color, [float]$width = 2) {
  $path = Rounded-Path $x $y $w $h $r
  $pen = New-Object System.Drawing.Pen($color, $width)
  $g.DrawPath($pen, $path)
  $pen.Dispose()
  $path.Dispose()
}

function Draw-Txt($g, [string]$s, [int]$x, [int]$y, [int]$w, [int]$h, [float]$size, [System.Drawing.Color]$color, [string]$align = "Near", [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
  $font = Font-Cn $size $style
  $brush = New-Object System.Drawing.SolidBrush($color)
  $fmt = New-Object System.Drawing.StringFormat
  if ($align -eq "Center") { $fmt.Alignment = [System.Drawing.StringAlignment]::Center }
  elseif ($align -eq "Far") { $fmt.Alignment = [System.Drawing.StringAlignment]::Far }
  else { $fmt.Alignment = [System.Drawing.StringAlignment]::Near }
  $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
  $rect = New-Object System.Drawing.RectangleF($x, $y, $w, $h)
  $g.DrawString($s, $font, $brush, $rect, $fmt)
  $fmt.Dispose()
  $brush.Dispose()
  $font.Dispose()
}

function Draw-Image-Cover($g, $img, [int]$dx, [int]$dy, [int]$dw, [int]$dh, [int]$sx, [int]$sy, [int]$sw, [int]$sh) {
  $destRatio = $dw / $dh
  $srcRatio = $sw / $sh
  if ($srcRatio -gt $destRatio) {
    $newW = [int]($sh * $destRatio)
    $sx = $sx + [int](($sw - $newW) / 2)
    $sw = $newW
  } else {
    $newH = [int]($sw / $destRatio)
    $sy = $sy + [int](($sh - $newH) / 2)
    $sh = $newH
  }
  $dest = New-Object System.Drawing.Rectangle($dx, $dy, $dw, $dh)
  $srcRect = New-Object System.Drawing.Rectangle($sx, $sy, $sw, $sh)
  $g.DrawImage($img, $dest, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-Chip($g, [string]$s, [int]$x, [int]$y, [int]$w) {
  Fill-Rounded $g $x $y $w 54 27 ([System.Drawing.Color]::FromArgb(246, 250, 239))
  Stroke-Rounded $g $x $y $w 54 27 ([System.Drawing.Color]::FromArgb(208, 178, 93)) 2
  Draw-Txt $g $s $x $y $w 54 25 $dark "Center" ([System.Drawing.FontStyle]::Bold)
}

function Save-Page($bmp, $g, [string]$name) {
  $path = Join-Path $OutDir $name
  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  return $path
}

$img = [System.Drawing.Image]::FromFile($Source)
$created = New-Object System.Collections.Generic.List[string]

# 01 hero
$cv = New-Canvas $mint ([System.Drawing.Color]::FromArgb(244, 248, 236)); $bmp=$cv[0]; $g=$cv[1]
Draw-Image-Cover $g $img 0 0 750 750 0 0 1024 1024
Fill-Rounded $g 38 730 674 230 26 ([System.Drawing.Color]::FromArgb(248, 250, 240))
Draw-Txt $g "端午定制重绳" 72 752 606 62 48 $dark "Center" ([System.Drawing.FontStyle]::Bold)
Draw-Txt $g "贵一点 诚一点 | 扔得越重 轻得越快" 72 815 606 42 26 $text "Center" ([System.Drawing.FontStyle]::Regular)
Draw-Chip $g "手工编织" 82 884 160
Draw-Chip $g "流苏款" 296 884 150
Draw-Chip $g "可定制" 500 884 150
$created.Add((Save-Page $bmp $g "01-首屏主图.png"))

# 02 selling points
$cv = New-Canvas ([System.Drawing.Color]::FromArgb(249, 247, 236)) ([System.Drawing.Color]::FromArgb(221, 238, 214)); $bmp=$cv[0]; $g=$cv[1]
Draw-Txt $g "为什么选重绳款" 58 44 634 72 46 $dark "Center" ([System.Drawing.FontStyle]::Bold)
Draw-Txt $g "不是普通五彩绳，是更有分量的端午仪式感" 70 112 610 40 24 $text "Center"
Draw-Image-Cover $g $img 80 176 590 380 120 345 820 530
$items = @(
  @("01", "分量感更足", "上手更有质感，佩戴不显单薄"),
  @("02", "颜色更醒目", "红蓝金多色交织，节日氛围强"),
  @("03", "流苏更灵动", "手腕轻动有线条感，拍照更出片")
)
$y = 610
foreach ($it in $items) {
  Fill-Rounded $g 58 $y 634 98 20 ([System.Drawing.Color]::FromArgb(255, 255, 250))
  Draw-Txt $g $it[0] 82 ($y+20) 58 48 34 $gold "Center" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $it[1] 156 ($y+16) 230 34 28 $dark "Near" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $it[2] 156 ($y+52) 470 28 22 $text "Near"
  $y += 118
}
$created.Add((Save-Page $bmp $g "02-核心卖点.png"))

# 03 detail
$cv = New-Canvas ([System.Drawing.Color]::FromArgb(235, 243, 224)) ([System.Drawing.Color]::FromArgb(250, 246, 230)); $bmp=$cv[0]; $g=$cv[1]
Draw-Txt $g "细节看得见" 56 48 638 68 46 $dark "Center" ([System.Drawing.FontStyle]::Bold)
Draw-Txt $g "绳结、线色、流苏，每一处都服务于端午氛围" 62 116 626 36 23 $text "Center"
Draw-Image-Cover $g $img 52 184 646 460 90 450 850 420
$detailItems = @(
  @("紧实绳结", "多股编织，视觉更饱满"),
  @("撞色线材", "红蓝金交织，节日识别度高"),
  @("长流苏尾", "佩戴有垂坠感，轻盈不沉闷")
)
$x = 46
foreach ($it in $detailItems) {
  Fill-Rounded $g $x 702 204 178 18 ([System.Drawing.Color]::FromArgb(255, 255, 248))
  Draw-Txt $g $it[0] ($x+16) 724 172 38 27 $dark "Center" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $it[1] ($x+20) 768 164 58 21 $text "Center"
  $x += 250
}
Draw-Txt $g "适合端午佩戴、亲友小礼、节日搭配" 70 910 610 38 24 $red "Center" ([System.Drawing.FontStyle]::Bold)
$created.Add((Save-Page $bmp $g "03-细节展示.png"))

# 04 scene and meaning
$cv = New-Canvas ([System.Drawing.Color]::FromArgb(20, 99, 54)) ([System.Drawing.Color]::FromArgb(231, 240, 220)); $bmp=$cv[0]; $g=$cv[1]
Draw-Txt $g "戴在手上的是端午心意" 52 50 646 70 43 ([System.Drawing.Color]::White) "Center" ([System.Drawing.FontStyle]::Bold)
Draw-Txt $g "五彩绳寓意美好，重绳款更有仪式感" 58 122 634 40 24 ([System.Drawing.Color]::FromArgb(232, 241, 222)) "Center"
Fill-Rounded $g 55 198 640 470 28 ([System.Drawing.Color]::FromArgb(245, 250, 235))
Draw-Image-Cover $g $img 85 225 580 410 100 340 850 560
$scene = @(
  @("给孩子", "节日佩戴，颜色亮眼"),
  @("给朋友", "小礼不贵，心意到位"),
  @("给自己", "日常搭配，也有节日感")
)
$x = 56
foreach ($it in $scene) {
  Fill-Rounded $g $x 720 196 142 20 ([System.Drawing.Color]::FromArgb(255, 255, 250))
  Draw-Txt $g $it[0] ($x+16) 742 164 32 27 $dark "Center" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $it[1] ($x+18) 786 160 42 20 $text "Center"
  $x += 249
}
Draw-Txt $g "端午节前建议提前下单，定制款需预留沟通时间" 58 900 634 42 23 $deep "Center" ([System.Drawing.FontStyle]::Bold)
$created.Add((Save-Page $bmp $g "04-场景寓意.png"))

# 05 custom process
$cv = New-Canvas ([System.Drawing.Color]::FromArgb(250, 248, 238)) ([System.Drawing.Color]::FromArgb(227, 239, 219)); $bmp=$cv[0]; $g=$cv[1]
Draw-Txt $g "定制流程很简单" 55 58 640 66 44 $dark "Center" ([System.Drawing.FontStyle]::Bold)
Draw-Txt $g "下单前确认需求，减少反复沟通" 68 126 614 38 24 $text "Center"
$steps = @(
  @("1", "选款式", "确认重绳/流苏/颜色偏好"),
  @("2", "发需求", "备注尺寸、数量或特殊要求"),
  @("3", "看确认", "客服核对细节后再安排"),
  @("4", "等发货", "按约定时间制作与发出")
)
$y = 210
foreach ($s in $steps) {
  Fill-Rounded $g 70 $y 610 112 22 ([System.Drawing.Color]::FromArgb(255, 255, 250))
  Fill-Rounded $g 94 ($y+24) 64 64 32 $dark
  Draw-Txt $g $s[0] 94 ($y+24) 64 64 34 ([System.Drawing.Color]::White) "Center" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $s[1] 184 ($y+20) 200 38 28 $dark "Near" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $s[2] 184 ($y+62) 430 30 22 $text "Near"
  $y += 134
}
Draw-Image-Cover $g $img 142 780 466 150 100 520 850 260
Draw-Txt $g "批量、礼品、颜色搭配可先沟通" 80 934 590 36 24 $red "Center" ([System.Drawing.FontStyle]::Bold)
$created.Add((Save-Page $bmp $g "05-定制流程.png"))

# 06 service
$cv = New-Canvas ([System.Drawing.Color]::FromArgb(238, 244, 226)) ([System.Drawing.Color]::FromArgb(250, 247, 236)); $bmp=$cv[0]; $g=$cv[1]
Draw-Txt $g "购买更放心" 60 58 630 68 46 $dark "Center" ([System.Drawing.FontStyle]::Bold)
Draw-Txt $g "把细节说清楚，把服务做踏实" 70 126 610 38 24 $text "Center"
$cards = @(
  @("实拍参考", "颜色以实物和沟通确认为准"),
  @("细节沟通", "定制需求提前确认"),
  @("节前备货", "建议尽早下单"),
  @("售后响应", "收到后有问题及时沟通")
)
$positions = @(@(62,220), @(392,220), @(62,472), @(392,472))
for ($i=0; $i -lt $cards.Count; $i++) {
  $px = $positions[$i][0]; $py = $positions[$i][1]
  Fill-Rounded $g $px $py 296 202 22 ([System.Drawing.Color]::FromArgb(255, 255, 250))
  Stroke-Rounded $g $px $py 296 202 22 ([System.Drawing.Color]::FromArgb(217, 190, 109)) 2
  Fill-Rounded $g ($px+104) ($py+26) 88 88 44 $dark
  Draw-Txt $g ([string]($i+1)) ($px+104) ($py+26) 88 88 40 ([System.Drawing.Color]::White) "Center" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $cards[$i][0] ($px+20) ($py+124) 256 34 28 $dark "Center" ([System.Drawing.FontStyle]::Bold)
  Draw-Txt $g $cards[$i][1] ($px+28) ($py+162) 240 30 20 $text "Center"
}
Draw-Image-Cover $g $img 100 726 550 160 80 565 900 250
Fill-Rounded $g 86 914 578 52 26 $dark
Draw-Txt $g "简梵诗饰品旗舰店 · 端午定制重绳" 86 914 578 52 24 ([System.Drawing.Color]::White) "Center" ([System.Drawing.FontStyle]::Bold)
$created.Add((Save-Page $bmp $g "06-售后保障.png"))

$img.Dispose()
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$created | ForEach-Object { $_ }
