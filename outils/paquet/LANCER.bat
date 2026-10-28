@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title Ateliers Godot

rem ------------------------------------------------------------
rem  1. Verifier que le zip a bien ete extrait
rem ------------------------------------------------------------
echo "%~dp0" | findstr /i /c:"\Temp\" >nul
if not errorlevel 1 goto pas_extrait
if not exist "projets\" goto pas_extrait

rem ------------------------------------------------------------
rem  2. Trouver l'executable Godot (peu importe la version)
rem ------------------------------------------------------------
set "GODOT="
for %%f in (Godot*_win64.exe) do (
    echo %%f | findstr /i "console" >nul || set "GODOT=%%f"
)
if not defined GODOT (
    echo.
    echo   Godot est introuvable dans ce dossier.
    echo   Avertis ton enseignant.
    echo.
    pause
    exit /b 1
)

rem ------------------------------------------------------------
rem  3. Mode autonome : les reglages restent dans editor_data\
rem ------------------------------------------------------------
if not exist "_sc_" type nul > "_sc_"

rem ------------------------------------------------------------
rem  4. Lister les projets (chaque dossier avec un project.godot)
rem ------------------------------------------------------------
set n=0
for /d %%d in ("projets\*") do (
    if exist "%%d\project.godot" (
        set /a n+=1
        set "proj!n!=%%~nxd"
    )
)
if %n%==0 (
    echo.
    echo   Aucun projet trouve dans le dossier projets.
    echo.
    pause
    exit /b 1
)
if %n%==1 (
    set "choix=1"
    goto lancer
)

:menu
cls
echo.
echo   =====================================
echo            ATELIERS GODOT
echo   =====================================
echo.
for /l %%i in (1,1,%n%) do echo     %%i - !proj%%i!
echo.
set "choix="
set /p "choix=  Ecris le numero de ton atelier et appuie sur Entree : "

:lancer
set "projet="
if defined choix set "projet=!proj%choix%!"
if not defined projet goto menu

echo.
echo   Ouverture de !projet!... (ca peut prendre quelques secondes)
start "" "%GODOT%" -e --path "projets\!projet!"
timeout /t 3 >nul
exit /b 0

rem ------------------------------------------------------------
:pas_extrait
cls
echo.
echo   =====================================
echo     ATTENTION : le zip n'est pas extrait!
echo   =====================================
echo.
echo   1. Ferme cette fenetre.
echo   2. Fais un clic droit sur le fichier .zip
echo   3. Choisis "Extraire tout..." puis "Extraire".
echo   4. Dans le nouveau dossier, double-clique sur LANCER.bat
echo.
pause
exit /b 1
