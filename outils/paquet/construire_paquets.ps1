<#
  Construit des zips "prets a lancer" dans dist\ :
    Godot (exe) + _sc_ (mode autonome) + LANCER.bat + LISEZMOI.txt + projets\...
  Si outils\paquet\data\editor_data\ existe, il est copie aussi (reglages de l'editeur).

  Par defaut : un zip par atelier (Atelier-<nom>.zip).
  Avec -Tous  : un seul zip avec tous les ateliers (Ateliers-Godot.zip), LANCER.bat affiche un menu.

  Exemples :
    powershell -ExecutionPolicy Bypass -File outils\paquet\construire_paquets.ps1
    powershell -ExecutionPolicy Bypass -File outils\paquet\construire_paquets.ps1 -Ateliers PolygonDash
    powershell -ExecutionPolicy Bypass -File outils\paquet\construire_paquets.ps1 -Tous
    powershell -ExecutionPolicy Bypass -File outils\paquet\construire_paquets.ps1 -Tous -Ateliers PolygonDash,Clonario -Nom Ateliers-Hiver
    powershell -ExecutionPolicy Bypass -File outils\paquet\construire_paquets.ps1 -GodotVersion 4.7.3-stable
#>
param(
    [string]$GodotVersion = "4.7.2-stable",
    [string[]]$Ateliers = @(
        "top_down_polygon_shooter",
        "Void-Hunters",
        "PolygonDash",
        "Clonario",
        "flappy_thing",
        "Plateforme-Secondaire"
    ),
    [switch]$Tous,
    [string]$Nom = "Ateliers-Godot"
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$racine = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$src    = Join-Path $racine "godot"
$dist   = Join-Path $racine "dist"
$cache  = Join-Path $dist "_cache"
$tmpDir = Join-Path $dist "_tmp"
$exeNom = "Godot_v$($GodotVersion)_win64.exe"
$exe    = Join-Path $cache $exeNom
$ed     = Join-Path $PSScriptRoot "data\editor_data"

New-Item -ItemType Directory -Force $cache | Out-Null

# 1. Telecharger Godot une seule fois (garde en cache dans dist\_cache)
if (-not (Test-Path $exe)) {
    $url = "https://github.com/godotengine/godot/releases/download/$GodotVersion/$exeNom.zip"
    $zip = Join-Path $cache "godot-$GodotVersion.zip"
    Write-Host "Telechargement de Godot $GodotVersion..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest $url -OutFile $zip -UseBasicParsing
    Expand-Archive $zip $cache -Force
    Remove-Item $zip
}

# 2. Garder seulement les ateliers qui existent
$valides = @()
foreach ($a in $Ateliers) {
    if (Test-Path (Join-Path (Join-Path $src $a) "project.godot")) { $valides += $a }
    else { Write-Warning "Projet introuvable : godot\$a (ignore)" }
}
if ($valides.Count -eq 0) { throw "Aucun atelier valide." }

# 3. Construit un zip qui contient la liste d'ateliers recue
function New-Paquet([string]$nomZip, [string[]]$liste) {
    $tmp = Join-Path $tmpDir $nomZip
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    New-Item -ItemType Directory -Force (Join-Path $tmp "projets") | Out-Null

    Copy-Item $exe $tmp
    Copy-Item (Join-Path $PSScriptRoot "LANCER.bat")   $tmp
    Copy-Item (Join-Path $PSScriptRoot "LISEZMOI.txt") $tmp
    New-Item -ItemType File (Join-Path $tmp "_sc_") | Out-Null
    if (Test-Path $ed) { Copy-Item $ed $tmp -Recurse }

    # Copie complete de chaque projet, y compris .godot\ (cache d'import = demarrage plus rapide)
    foreach ($a in $liste) {
        Copy-Item (Join-Path $src $a) (Join-Path $tmp "projets") -Recurse -Force
    }

    $zipOut = Join-Path $dist "$nomZip.zip"
    if (Test-Path $zipOut) { Remove-Item $zipOut }
    [IO.Compression.ZipFile]::CreateFromDirectory($tmp, $zipOut, [IO.Compression.CompressionLevel]::Optimal, $false)
    $mo = [math]::Round((Get-Item $zipOut).Length / 1MB, 1)
    Write-Host ("OK  {0}.zip  ({1} Mo) : {2}" -f $nomZip, $mo, ($liste -join ", "))
}

if (Test-Path $ed) { Write-Host "editor_data trouve : inclus dans les paquets" }

if ($Tous) {
    New-Paquet $Nom $valides
} else {
    foreach ($a in $valides) { New-Paquet "Atelier-$a" @($a) }
}

if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
Write-Host "Termine. Les zips sont dans $dist"
