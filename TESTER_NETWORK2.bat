@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Network Tester

REM ============================================================
REM  Network Tester by Fran-Byte  -  CMD/BAT version  (v2.0)
REM ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Run this script as Administrator.
    pause
    exit /b
)

REM -- Control characters: CR (carriage return) and ESC --------
for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
for /F "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "ESC=%%E"

REM -- Palette (ANSI 256 colours) ------------------------------
set "RST=!ESC![0m"
set "BOLD=!ESC![1m"
set "DIM=!ESC![38;5;244m"
set "ACC=!ESC![38;5;45m"
set "OKC=!ESC![38;5;78m"
set "ERC=!ESC![38;5;203m"
set "WRN=!ESC![38;5;221m"
set "WHT=!ESC![38;5;255m"
set "HDR=!ESC![48;5;24m!ESC![38;5;255m!ESC![1m"
set "PASSB=!ESC![48;5;28m!ESC![38;5;255m!ESC![1m"
set "FAILB=!ESC![48;5;160m!ESC![38;5;255m!ESC![1m"
set "HR=──────────────────────────────────────────────────────────────────────────"

REM -- Default IPs ---------------------------------------------
set IP_HOST_1=192.168.0.24
set IP_HOST_2=192.168.1.2
set IP_HOST_3=192.168.0.2
set IP_HOST_4=10.117.3.84
set IP_HOST_5=192.168.0.205
set IP_HOST_6=192.168.1.1
set IP_HOST_7=192.168.1.34
set IP_HOST_8=192.168.199.175

set IP_GW_1=192.168.0.25
set IP_GW_2=192.168.0.30
set IP_GW_3=192.168.0.1
set IP_GW_4=192.168.0.5
set IP_GW_5=192.168.1.1
set IP_GW_6=10.117.3.85
set IP_GW_7=192.168.0.201
set IP_GW_8=192.168.1.2
set IP_GW_9=192.168.1.35
set IP_GW_10=192.168.199.176

REM -- Test profiles -------------------------------------------
set PF_N_1=Normal
set PF_C_1=100
set PF_E_1=1
set PF_N_2=Extended
set PF_C_2=1000
set PF_E_2=4
set PF_N_3=Plus
set PF_C_3=10000
set PF_E_3=16
set PF_N_4=EXTREM
set PF_C_4=50000
set PF_E_4=64

REM -- Selected values -----------------------------------------
set SEL_HOST=%IP_HOST_1%
set SEL_GW=%IP_GW_1%
set SEL_ADAPTER=
set PING_COUNT=100
set PING_MODE=Normal
set MAX_ERR=2

REM -- Saved-profile flag (1 = static IP already applied) ------
set CONFIG_SAVED=0


REM ============================================================
REM  STARTUP
REM ============================================================
color 07
call :HEADER "STARTING"
echo.
echo   !DIM!Detecting network adapters...!RST!
call :LOAD_ADAPTERS


REM ============================================================
REM  MAIN MENU
REM ============================================================
:MAIN_MENU
call :HEADER "HOME"
echo.
echo   !ACC!CURRENT CONFIGURATION!RST!
echo   !DIM!!HR!!RST!

set "AD_SHOW=!SEL_ADAPTER!"
set "ST_SHOW=!OKC!●!RST! !WHT!Ready!RST!"
if "!SEL_ADAPTER!"=="" (
    set "AD_SHOW=!WRN!not selected!RST!"
    set "ST_SHOW=!WRN!○ Select an adapter with [3] before applying!RST!"
)
set "T_PROFILE=!PING_MODE!  ·  !PING_COUNT! pings  ·  max !MAX_ERR! errors"

call :CFG "Host IP       " SEL_HOST
call :CFG "Gateway IP    " SEL_GW
call :CFG "Adapter       " AD_SHOW
call :CFG "Test profile  " T_PROFILE
call :CFG "Status        " ST_SHOW
echo   !DIM!!HR!!RST!
echo.
echo   !ACC!CONFIGURE!RST!                               !ACC!ACTIONS!RST!
echo     !DIM![!RST!!ACC!1!RST!!DIM!]!RST!  Host IP                          !DIM![!RST!!ACC!5!RST!!DIM!]!RST!  Set DHCP on adapter
echo     !DIM![!RST!!ACC!2!RST!!DIM!]!RST!  Gateway IP                       !DIM!!PASSB![6]!RST!  !BOLD!!PASSB!Run ping test!RST!
echo     !DIM![!RST!!ACC!3!RST!!DIM!]!RST!  Ethernet adapter                 !DIM![!RST!!ACC!7!RST!!DIM!]!RST!  Restore all adapters
echo     !DIM![!RST!!ACC!4!RST!!DIM!]!RST!  Test profile
echo.
echo   !ACC!SYSTEM!RST!
echo     !DIM![!RST!!ACC!A!RST!!DIM!]!RST!  Automatic test                   !DIM![!RST!!ACC!8!RST!!DIM!]!RST!  Exit and restore adapters
echo     !DIM![!RST!!ACC!H!RST!!DIM!]!RST!  Help                             
echo.
echo   !DIM!!HR!!RST!
set "CHOICE="
set /p "CHOICE=  !ACC!>!RST! Option: "

if "!CHOICE!"=="1" goto SELECT_HOST
if "!CHOICE!"=="2" goto SELECT_GW
if "!CHOICE!"=="3" goto SELECT_ADAPTER
if "!CHOICE!"=="4" goto SELECT_CHECK
if "!CHOICE!"=="5" goto SET_DHCP
if "!CHOICE!"=="6" goto START_TEST
if "!CHOICE!"=="7" goto RESTORE_ETHERNETS
if "!CHOICE!"=="8" goto DO_EXIT
if /i "!CHOICE!"=="A" goto AUTO_TEST
if /i "!CHOICE!"=="H" goto HELP
goto MAIN_MENU


REM ============================================================
REM  CONFIGURATION SCREENS
REM ============================================================
:SELECT_HOST
call :HEADER "CONFIGURE  ›  HOST IP"
echo.
echo   IP address assigned to this machine.
echo.
for /l %%i in (1,1,8) do (
    set "N= %%i"
    set "V=!IP_HOST_%%i!"
    if "!V!"=="!SEL_HOST!" (
        echo     !OKC!●!RST! !BOLD![!N!]!RST!  !WHT!!V!!RST!   !DIM!◄ in use!RST!
    ) else (
        echo     !DIM!○ [!N!]!RST!  !V!
    )
)
echo.
echo     !BOLD![M]!RST!  Enter manually        !BOLD![Enter]!RST!  Back
echo.
echo   !DIM!!HR!!RST!
set "H="
set /p "H=  !ACC!>!RST! Option: "
for /l %%i in (1,1,8) do if "!H!"=="%%i" set "SEL_HOST=!IP_HOST_%%i!"
if /i "!H!"=="M" call :ASK_IP SEL_HOST
set "CONFIG_SAVED=0"
goto MAIN_MENU

:SELECT_GW
call :HEADER "CONFIGURE  ›  GATEWAY IP"
echo.
echo   IP address of the target device that will receive the pings.
echo.
for /l %%i in (1,1,10) do (
    set "N= %%i"
    if %%i GEQ 10 set "N=%%i"
    set "V=!IP_GW_%%i!"
    if "!V!"=="!SEL_GW!" (
        echo     !OKC!●!RST! !BOLD![!N!]!RST!  !WHT!!V!!RST!   !DIM!◄ in use!RST!
    ) else (
        echo     !DIM!○ [!N!]!RST!  !V!
    )
)
echo.
echo     !BOLD![M]!RST!  Enter manually        !BOLD![Enter]!RST!  Back
echo.
echo   !DIM!!HR!!RST!
set "G="
set /p "G=  !ACC!>!RST! Option: "
for /l %%i in (1,1,10) do if "!G!"=="%%i" set "SEL_GW=!IP_GW_%%i!"
if /i "!G!"=="M" call :ASK_IP SEL_GW
set "CONFIG_SAVED=0"
goto MAIN_MENU

:SELECT_ADAPTER
call :HEADER "CONFIGURE  ›  ETHERNET ADAPTER"
echo.
echo   !DIM!Detecting adapters...!RST!
call :LOAD_ADAPTERS
call :HEADER "CONFIGURE  ›  ETHERNET ADAPTER"
echo.
echo   Adapter that will receive the static IP. All others are disabled on apply.
echo.
for /l %%i in (1,1,!TOTAL_ADAPTERS!) do (
    set "N= %%i"
    if %%i GEQ 10 set "N=%%i"
    set "V=!ALL_ADAPTER_%%i!"
    set "S=!ALL_STATUS_%%i!"
    set "VP=!V!                                "
    set "VP=!VP:~0,30!"
    set "SC=!DIM!"
    if /i "!S!"=="Up" set "SC=!OKC!"
    if /i "!S!"=="Disconnected" set "SC=!WRN!"
    if "!V!"=="!SEL_ADAPTER!" (
        echo     !OKC!●!RST! !BOLD![!N!]!RST!  !WHT!!VP!!RST! !SC!!S!!RST!   !DIM!◄ selected!RST!
    ) else (
        echo     !DIM!○ [!N!]!RST!  !VP! !SC!!S!!RST!
    )
)
echo.
echo     !BOLD![M]!RST!  Enter name manually   !BOLD![Enter]!RST!  Back
echo.
echo   !DIM!!HR!!RST!
set "AD="
set /p "AD=  !ACC!>!RST! Option: "
for /l %%i in (1,1,!TOTAL_ADAPTERS!) do if "!AD!"=="%%i" set "SEL_ADAPTER=!ALL_ADAPTER_%%i!"
if /i "!AD!"=="M" (
    set "TMP_AD="
    set /p "TMP_AD=  !ACC!>!RST! Adapter name: "
    if defined TMP_AD set "SEL_ADAPTER=!TMP_AD!"
)
set "CONFIG_SAVED=0"
goto MAIN_MENU

:SELECT_CHECK
call :HEADER "CONFIGURE  ›  TEST PROFILE"
echo.
echo   Number of pings to the gateway and tolerated errors before aborting.
echo.
for /l %%i in (1,1,4) do (
    set "NP=!PF_N_%%i!          "
    set "NP=!NP:~0,10!"
    set "CP=        !PF_C_%%i!"
    set "CP=!CP:~-7!"
    set "EP=   !PF_E_%%i!"
    set "EP=!EP:~-4!"
    if "!PF_N_%%i!"=="!PING_MODE!" (
        echo     !OKC!●!RST! !BOLD![%%i]!RST!  !WHT!!NP!!RST! !CP! pings    max !EP! errors   !DIM!◄ active!RST!
    ) else (
        echo     !DIM!○ [%%i]!RST!  !NP! !CP! pings    max !EP! errors
    )
)
echo.
echo     !BOLD![Enter]!RST!  Back
echo.
echo   !DIM!!HR!!RST!
set "CK="
set /p "CK=  !ACC!>!RST! Option: "
for /l %%i in (1,1,4) do if "!CK!"=="%%i" (
    set "PING_MODE=!PF_N_%%i!"
    set "PING_COUNT=!PF_C_%%i!"
    set "MAX_ERR=!PF_E_%%i!"
)
set "CONFIG_SAVED=0"
goto MAIN_MENU

REM -- :ASK_IP <varname>  - asks for an IPv4 and validates format
:ASK_IP
set "TMP_IP="
set /p "TMP_IP=  !ACC!>!RST! IPv4 address: "
if "!TMP_IP!"=="" goto :eof
echo !TMP_IP!| findstr /r /x "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >nul
if errorlevel 1 (
    echo.
    echo   !ERC!✖ Invalid IPv4 format. Value not changed.!RST!
    timeout /t 2 /nobreak >nul
) else (
    set "%~1=!TMP_IP!"
)
goto :eof


REM ============================================================
REM  ACTIONS
REM ============================================================
:SET_DHCP
call :HEADER "APPLY  ›  DYNAMIC IP (DHCP)"
echo.
if "!SEL_ADAPTER!"=="" (
    echo   !ERC!✖ No adapter selected. Use option [3] first.!RST!
    call :PAUSE_KEY
    goto MAIN_MENU
)
call :CFG "Adapter       " SEL_ADAPTER
echo.
call :DHCP_ONE "!SEL_ADAPTER!"
set "CONFIG_SAVED=0"
call :PAUSE_KEY
goto MAIN_MENU

:START_TEST
if "!CONFIG_SAVED!"=="1" goto RUN_TEST_NOW
call :HEADER "RUN  ›  PING TEST"
echo.
echo   !WRN!Saving configuration profile first...!RST!
echo.
if "!SEL_ADAPTER!"=="" (
    echo   !ERC!✖ No adapter selected. Use option [3] first.!RST!
    call :PAUSE_KEY
    goto MAIN_MENU
)
call :CFG "Adapter       " SEL_ADAPTER
call :CFG "Host IP       " SEL_HOST
call :CFG "Gateway IP    " SEL_GW
echo.
echo   !DIM!!HR!!RST!
echo.
call :APPLY_STATIC
set "CONFIG_SAVED=1"
echo.
echo   !OKC!✔ Static IP applied. Wi-Fi and other adapters disabled.!RST!
timeout /t 1 /nobreak >nul

:RUN_TEST_NOW
call :HEADER "RUN  ›  PING TEST"
echo.
call :CFG "Host IP       " SEL_HOST
call :CFG "Target        " SEL_GW
call :CFG "Adapter       " SEL_ADAPTER
call :CFG "Profile       " PING_MODE
call :CFG "Pings         " PING_COUNT
call :CFG "Max errors    " MAX_ERR
echo   !DIM!!HR!!RST!
call :RUN_TEST
call :SHOW_RESULT
call :PAUSE_KEY
goto MAIN_MENU

:RESTORE_ETHERNETS
call :HEADER "SYSTEM  ›  RESTORE ADAPTERS"
echo.
call :DO_RESTORE
echo.
echo   !OKC!✔ Restore finished.!RST!
call :PAUSE_KEY
goto MAIN_MENU

:DO_EXIT
call :HEADER "EXIT"
echo.
echo   !DIM!Restoring all adapters before closing...!RST!
echo.
call :DO_RESTORE
echo.
echo   Closing...
<nul set /p "=!ESC![?25h"
timeout /t 2 /nobreak >nul
exit

:AUTO_TEST
call :HEADER "AUTOMATIC TEST"
echo.

set SEL_HOST=192.168.0.24
set SEL_GW=192.168.0.25

REM -- First physical Ethernet adapter (enabled or not) --------
set "SEL_ADAPTER="
for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "(Get-NetAdapter -Physical | Where-Object { $_.PhysicalMediaType -eq '802.3' } | Select-Object -First 1).Name"`) do set "SEL_ADAPTER=%%A"

if "!SEL_ADAPTER!"=="" (
    echo   !ERC!✖ No Ethernet adapter found.!RST!
    call :PAUSE_KEY
    goto MAIN_MENU
)

set PING_COUNT=1000
set MAX_ERR=6
set PING_MODE=Extended

call :CFG "Host IP       " SEL_HOST
call :CFG "Gateway IP    " SEL_GW
call :CFG "Adapter       " SEL_ADAPTER
call :CFG "Profile       " PING_MODE
echo   !DIM!!HR!!RST!
echo.

call :APPLY_STATIC
set "CONFIG_SAVED=1"

echo.
echo   !DIM!Waiting 3 seconds for network stabilization...!RST!
timeout /t 3 /nobreak >nul

echo.
echo   !ACC!Starting test!RST!
echo   !DIM!!HR!!RST!
call :RUN_TEST
call :SHOW_RESULT

REM ----- If test failed, return to main menu -----
if /i "!TEST_RESULT!"=="FAIL" (
    echo.
    echo   !ERC!Test FAILED. Press any key to return to the main menu.!RST!
    pause >nul
    goto MAIN_MENU
)

REM ----- Success path -----
echo.
echo   !OKC!Test finished. Restoring default configuration in 3 seconds...!RST!
timeout /t 3 /nobreak >nul

call :DO_RESTORE

echo.
echo   Closing...
timeout /t 2 /nobreak >nul
exit


REM ============================================================
REM  SUBROUTINES
REM ============================================================

REM -- :HEADER "breadcrumb"  - banner + breadcrumb ---------------
:HEADER
cls
echo !HDR!                                                                              !RST!
echo !HDR!   NETWORK TESTER  ·  Ethernet Link Validator           by Fran-Byte   v3.0   !RST!
echo !HDR!                                                                              !RST!
echo   !DIM!%~1!RST!
goto :eof

REM -- :CFG "label" VARNAME  - one row of the info panel ---------
:CFG
set "V=!%~2!"
echo     !DIM!%~1!RST! !WHT!!V!!RST!
goto :eof

REM -- :PAUSE_KEY  - styled "press any key" ----------------------
:PAUSE_KEY
echo.
<nul set /p "=  !DIM!Press any key to continue...!RST!"
pause >nul
goto :eof

REM -- Load every adapter (enabled or disabled) with its status --
:LOAD_ADAPTERS
set TOTAL_ADAPTERS=0
for /f "usebackq tokens=1,2 delims=|" %%A in (`powershell -NoProfile -Command "Get-NetAdapter | ForEach-Object { $_.Name + '|' + $_.Status }"`) do (
    set /a TOTAL_ADAPTERS+=1
    set "ALL_ADAPTER_!TOTAL_ADAPTERS!=%%A"
    set "ALL_STATUS_!TOTAL_ADAPTERS!=%%B"
)
goto :eof

REM -- Static IP on SEL_ADAPTER, everything else disabled ------
:APPLY_STATIC
echo   !ACC!Applying configuration!RST!
echo     !DIM!›!RST! Disabling Wi-Fi
netsh interface set interface "Wi-Fi" admin=disable >nul 2>&1
netsh interface set interface "WiFi" admin=disable >nul 2>&1
netsh interface set interface "WLAN" admin=disable >nul 2>&1

echo     !DIM!›!RST! Enabling adapter: !SEL_ADAPTER!
netsh interface set interface "!SEL_ADAPTER!" admin=enable >nul 2>&1
timeout /t 2 /nobreak >nul

echo     !DIM!›!RST! Flushing existing IP config
netsh interface ip set address "!SEL_ADAPTER!" dhcp >nul 2>&1
timeout /t 1 /nobreak >nul

echo     !DIM!›!RST! Setting static IP and DNS
netsh interface ip set address "!SEL_ADAPTER!" static !SEL_HOST! 255.255.255.0 !SEL_GW! >nul 2>&1
if errorlevel 1 (
    echo     !WRN![WARN]!RST! netsh returned an error setting the static IP.
) else (
    echo     !OKC![ OK ]!RST! !SEL_HOST!/24  gateway !SEL_GW!
)
netsh interface ip set dns "!SEL_ADAPTER!" static !SEL_GW! >nul 2>&1

call :LOAD_ADAPTERS
for /l %%i in (1,1,!TOTAL_ADAPTERS!) do (
    set "OTHER=!ALL_ADAPTER_%%i!"
    if /i "!OTHER!" neq "!SEL_ADAPTER!" (
        echo     !DIM!›!RST! Disabling: !OTHER!
        netsh interface set interface "!OTHER!" admin=disable >nul 2>&1
    )
)
goto :eof

REM -- Ping test with progress bar -----------------------------
REM  Result in TEST_RESULT (OK / FAIL)
:RUN_TEST
set ERRORS=0
set PING_I=0
set BARW=40
set "FULL=████████████████████████████████████████"
set "EMPTY=░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░"
set "TEST_RESULT=OK"
echo.
<nul set /p "=!ESC![?25l"
<nul set /p "=  Starting...!CR!"

:RUN_LOOP
if !PING_I! GEQ !PING_COUNT! goto RUN_END
set /a PING_I+=1

ping -n 1 -w 1000 !SEL_GW! | find "TTL=" >nul
if errorlevel 1 set /a ERRORS+=1

set /a PCT=PING_I*100/PING_COUNT
set /a FILLED=PING_I*BARW/PING_COUNT
set /a REST=BARW-FILLED
for /f "tokens=1,2" %%F in ("!FILLED! !REST!") do (
    set "BF=!FULL:~0,%%F!"
    set "BE=!EMPTY:~0,%%G!"
)
set "PP=  !PCT!"
set "PP=!PP:~-3!"
set "EC=!OKC!"
if !ERRORS! GTR 0 set "EC=!WRN!"

<nul set /p "=!ESC![1A"
echo   !ACC!!BF!!DIM!!BE!!RST!  !WHT!!PP!%%!RST!
<nul set /p "=!ESC![2K    !DIM!Ping!RST! !PING_I! / !PING_COUNT!     !DIM!Lost!RST! !EC!!ERRORS!!RST! / !MAX_ERR!!CR!"

if !ERRORS! GEQ !MAX_ERR! (
    set "TEST_RESULT=FAIL"
    goto RUN_END
)
goto RUN_LOOP

:RUN_END
echo.
<nul set /p "=!ESC![?25h"
goto :eof

:SHOW_RESULT
set /a DEN=PING_I
if !DEN! EQU 0 set "DEN=1"
set /a LOSS=ERRORS*100/DEN
set /a REPLIES=PING_I-ERRORS
set "T_SENT=!PING_I! of !PING_COUNT!"
set "T_LOST=!ERRORS!  ·  limit !MAX_ERR!"
set "T_LOSS=!LOSS!%%"
echo   !DIM!!HR!!RST!
echo.
if "!TEST_RESULT!"=="OK" (
    echo   !PASSB!  PASS  !RST!  !OKC!Link stable. Error threshold not exceeded.!RST!
) else (
    echo   !FAILB!  FAIL  !RST!  !ERC!Error threshold exceeded. Test aborted.!RST!
)
echo.
call :CFG "Pings sent    " T_SENT
call :CFG "Replies       " REPLIES
call :CFG "Lost          " T_LOST
call :CFG "Packet loss   " T_LOSS
goto :eof

REM -- Restore: enable ALL adapters, then DHCP on ALL ----------
:DO_RESTORE
call :LOAD_ADAPTERS
echo   !ACC!Enabling adapters!RST!
for /l %%i in (1,1,!TOTAL_ADAPTERS!) do (
    echo     !DIM!›!RST! !ALL_ADAPTER_%%i!
    netsh interface set interface "!ALL_ADAPTER_%%i!" admin=enable >nul 2>&1
)
echo.
echo   !DIM!Waiting for adapters to come up...!RST!
timeout /t 3 /nobreak >nul
echo.
echo   !ACC!Setting DHCP!RST!
for /l %%i in (1,1,!TOTAL_ADAPTERS!) do call :DHCP_ONE "!ALL_ADAPTER_%%i!"
set "CONFIG_SAVED=0"
goto :eof

REM -- DHCP on one adapter, verified, up to 3 tries ------------
:DHCP_ONE
set "AD_NAME=%~1"
set "OK_DHCP=0"
for /l %%t in (1,1,3) do if "!OK_DHCP!"=="0" (
    netsh interface set interface "!AD_NAME!" admin=enable >nul 2>&1
    netsh interface ip set address "!AD_NAME!" dhcp >nul 2>&1
    netsh interface ip set dns "!AD_NAME!" dhcp >nul 2>&1
    set "DH="
    for /f %%D in ('powershell -NoProfile -Command "(Get-NetIPInterface -InterfaceAlias '!AD_NAME!' -AddressFamily IPv4 -ErrorAction SilentlyContinue).Dhcp"') do set "DH=%%D"
    if /i "!DH!"=="Enabled" (set "OK_DHCP=1") else timeout /t 2 /nobreak >nul
)
if "!OK_DHCP!"=="1" (
    echo     !OKC![ OK ]!RST!  DHCP  !AD_NAME!
) else (
    echo     !ERC![FAIL]!RST!  DHCP  !AD_NAME!
)
goto :eof


REM ============================================================
REM  HELP
REM ============================================================
:HELP
call :HEADER "HELP"
echo.
echo   !ACC!OBJETIVO!RST!
echo   !DIM!!HR!!RST!
echo     Configura rápidamente la IP estática de un adaptador Ethernet
echo     y verifica la conexión mediante pings continuos al gateway.
echo     Diseñado para entornos industriales que requieren una red
echo     estable y aislada.
echo.
echo   !ACC!FLUJO RECOMENDADO!RST!
echo   !DIM!!HR!!RST!
echo     !BOLD![1]!RST!  Selecciona la IP del HOST ^(tu máquina^)
echo     !BOLD![2]!RST!  Selecciona la IP del GATEWAY ^(equipo destino^)
echo     !BOLD![3]!RST!  Selecciona el adaptador Ethernet
echo     !BOLD![4]!RST!  Selecciona el perfil de prueba
echo     !BOLD![6]!RST!  Lanza el test de ping al gateway
echo.                 ^(guarda el perfil antes si es necesario^)
echo   !ACC!OPCIONES!RST!
echo   !DIM!!HR!!RST!
echo     !BOLD![1]!RST! HOST IP     IP que se asignará a tu máquina.
echo     !BOLD![2]!RST! GATEWAY IP  IP del equipo al que se hará ping.
echo     !BOLD![3]!RST! ADAPTER     Adaptador que recibirá la IP estática.
echo     !BOLD![4]!RST! PROFILE     Pings y tolerancia de errores:
echo                       Normal     100 pings     2 errores máx.
echo                       Extended  1000 pings     6 errores máx.
echo                       Plus     10000 pings    20 errores máx.
echo                       EXTREM   50000 pings   100 errores máx.
echo     !BOLD![5]!RST! DHCP        Devuelve el adaptador seleccionado a DHCP.
echo                       También marca el perfil como NO guardado.
echo     !BOLD![6]!RST! RUN TEST    Si el perfil no está guardado, lo guarda
echo                       primero ^(desactiva Wi-Fi, asigna IP estática y
echo                       desactiva el resto^) y después lanza pings
echo                       continuos al gateway con barra de progreso.
echo                       Para si se supera el máximo de errores.
echo     !BOLD![7]!RST! RESTORE     Reactiva todos los adaptadores ^(incluido
echo                       Wi-Fi^) y los configura en DHCP.
echo     !BOLD![8]!RST! EXIT        Ejecuta RESTORE automáticamente y cierra.
echo     !BOLD![A]!RST! AUTO TEST   Modo automático: HOST 192.168.0.24,
echo                       GATEWAY 192.168.0.25, perfil Extended, primer
echo                       adaptador Ethernet físico. Si el test es
echo                       satisfactorio restaura y cierra; si falla,
echo                       vuelve al menú para otro intento.
echo.
echo   !ACC!NOTAS!RST!
echo   !DIM!!HR!!RST!
echo     - Ejecutar siempre como Administrador.
echo     - Requiere Windows 10 o superior ^(PowerShell + ANSI^).
echo     - RUN TEST desactiva el Wi-Fi para evitar conflictos de ruta.
echo     - Cambiar cualquier ajuste ^(1-4^), DHCP ^(5^) o RESTORE ^(7^)
echo       obliga a reaplicar la configuración en el siguiente [6].
echo     - Usa RESTORE o EXIT al terminar para dejar la red normal.
call :PAUSE_KEY
goto MAIN_MENU