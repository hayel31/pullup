param(
  [string]$Source = 'assets\branding\pullup-midnight-logo.jpg'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $projectRoot $Source

function Export-Logo {
  param(
    [string]$TargetPath,
    [int]$Width,
    [int]$Height,
    [double]$Padding
  )

  $sourceImage = [System.Drawing.Image]::FromFile($sourcePath)
  $bitmap = [System.Drawing.Bitmap]::new(
    $Width,
    $Height,
    [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
  )
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $imageAttributes = [System.Drawing.Imaging.ImageAttributes]::new()

  try {
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#08080B'))
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

    $availableWidth = $Width * (1 - 2 * $Padding)
    $availableHeight = $Height * (1 - 2 * $Padding)
    $scale = [Math]::Min(
      $availableWidth / $sourceImage.Width,
      $availableHeight / $sourceImage.Height
    )
    $drawWidth = $sourceImage.Width * $scale
    $drawHeight = $sourceImage.Height * $scale
    $x = ($Width - $drawWidth) / 2
    $y = ($Height - $drawHeight) / 2
    $destination = [System.Drawing.Rectangle]::new(
      [int][Math]::Round($x),
      [int][Math]::Round($y),
      [int][Math]::Round($drawWidth),
      [int][Math]::Round($drawHeight)
    )
    $imageAttributes.SetColorKey(
      [System.Drawing.Color]::FromArgb(0, 0, 0),
      [System.Drawing.Color]::FromArgb(24, 24, 24)
    )
    $graphics.DrawImage(
      $sourceImage,
      $destination,
      0,
      0,
      $sourceImage.Width,
      $sourceImage.Height,
      [System.Drawing.GraphicsUnit]::Pixel,
      $imageAttributes
    )

    $directory = Split-Path -Parent $TargetPath
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $bitmap.Save($TargetPath, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  finally {
    $imageAttributes.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
    $sourceImage.Dispose()
  }
}

function Export-LikeExisting {
  param(
    [string]$RelativePath,
    [double]$Padding
  )

  $targetPath = Join-Path $projectRoot $RelativePath
  $existing = [System.Drawing.Image]::FromFile($targetPath)
  try {
    $width = $existing.Width
    $height = $existing.Height
  }
  finally {
    $existing.Dispose()
  }
  Export-Logo $targetPath $width $height $Padding
}

$regularIcons = @(
  'web\pullup-mark.png',
  'web\favicon.png',
  'web\icons\Icon-192.png',
  'web\icons\Icon-512.png'
)
$regularIcons += Get-ChildItem (Join-Path $projectRoot 'android\app\src\main\res\mipmap-*\ic_launcher.png') |
  ForEach-Object { $_.FullName.Substring($projectRoot.Length + 1) }
$regularIcons += Get-ChildItem (Join-Path $projectRoot 'ios\Runner\Assets.xcassets\AppIcon.appiconset\*.png') |
  ForEach-Object { $_.FullName.Substring($projectRoot.Length + 1) }

$maskableIcons = @(
  'web\icons\Icon-maskable-192.png',
  'web\icons\Icon-maskable-512.png'
)

$launchImages = Get-ChildItem (Join-Path $projectRoot 'android\app\src\main\res\mipmap-*\launch_image.png') |
  ForEach-Object { $_.FullName.Substring($projectRoot.Length + 1) }
$launchImages += Get-ChildItem (Join-Path $projectRoot 'ios\Runner\Assets.xcassets\LaunchImage.imageset\*.png') |
  ForEach-Object { $_.FullName.Substring($projectRoot.Length + 1) }

foreach ($path in $regularIcons) {
  Export-LikeExisting $path 0.08
}
foreach ($path in $maskableIcons) {
  Export-LikeExisting $path 0.18
}
foreach ($path in $launchImages) {
  Export-LikeExisting $path 0.04
}

Export-Logo (Join-Path $projectRoot 'web\pullup-midnight-mark.png') 256 256 0.04
Export-Logo (Join-Path $projectRoot 'assets\branding\pullup-midnight-logo.png') 908 896 0
Write-Host 'PULLUP brand assets generated from' $Source
