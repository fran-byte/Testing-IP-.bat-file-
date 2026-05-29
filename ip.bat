@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1

REM ============================================================
REM  Network Tester by Fran-Byte  -  CMD/BAT version
REM ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Run this script as Administrator.
    pause
    exit /b
)

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

REM -- Selected values -----------------------------------------
set SEL_HOST=%IP_HOST_1%
set SEL_GW=%IP_GW_1%
set SEL_ADAPTER=
set PING_COUNT=100
set PING_MODE=Normal Check
set MAX_ERR=2

REM -- Detect ALL adapters at startup (including disabled) -----
set TOTAL_ADAPTERS=0
for /f "skip=1 tokens=* delims=" %%A in ('wmic nic where "NetConnectionID like '%%'" get NetConnectionID 2^>nul') do (
    set LINE=%%A
    for /f "tokens=* delims= " %%S in ("!LINE!") do set LINE=%%S
    if not "!LINE!"=="" (
        set /a TOTAL_ADAPTERS+=1
        set ALL_ADAPTER_!TOTAL_ADAPTERS!=!LINE!
    )
)

:MAIN_MENU
cls
color 0A
echo ============================================================
echo         NETWORK TESTER  by Fran-Byte
echo ============================================================
echo.
echo  HOST     : !SEL_HOST!
echo  GATEWAY  : !SEL_GW!
echo  ETHERNET : !SEL_ADAPTER!
echo  CHECK    : !PING_MODE!
echo.
echo ------------------------------------------------------------
echo  [1] Select HOST IP
echo  [2] Select GATEWAY IP
echo  [3] Select ETHERNET Adapter
echo  [4] Select CHECK mode
echo ------------------------------------------------------------
echo  [5] SAVE SETTINGS (Static IP)
echo  [6] DYNAMIC IP (DHCP)
echo  [7] START TEST (Ping)
echo ------------------------------------------------------------
echo  [8] RESTORE ETHERNET Adapters
echo  [H] HELP
echo  [9] EXIT
echo ------------------------------------------------------------
echo.
set /p CHOICE="Option: "

if "!CHOICE!"=="1" goto SELECT_HOST
if "!CHOICE!"=="2" goto SELECT_GW
if "!CHOICE!"=="3" goto SELECT_ADAPTER
if "!CHOICE!"=="4" goto SELECT_CHECK
if "!CHOICE!"=="5" goto SAVE_SETTINGS
if "!CHOICE!"=="6" goto SET_DHCP
if "!CHOICE!"=="7" goto START_TEST
if "!CHOICE!"=="8" goto RESTORE_ETHERNETS
if /i "!CHOICE!"=="H" goto HELP
if "!CHOICE!"=="9" goto DO_EXIT
goto MAIN_MENU

:SELECT_HOST
cls
echo ================= SELECT HOST IP =================
echo.
echo [1] %IP_HOST_1%
echo [2] %IP_HOST_2%
echo [3] %IP_HOST_3%
echo [4] %IP_HOST_4%
echo [5] %IP_HOST_5%
echo [6] %IP_HOST_6%
echo [7] %IP_HOST_7%
echo [8] %IP_HOST_8%
echo [M] Manual
echo.
set /p H="Option: "
if "!H!"=="1" set SEL_HOST=%IP_HOST_1%
if "!H!"=="2" set SEL_HOST=%IP_HOST_2%
if "!H!"=="3" set SEL_HOST=%IP_HOST_3%
if "!H!"=="4" set SEL_HOST=%IP_HOST_4%
if "!H!"=="5" set SEL_HOST=%IP_HOST_5%
if "!H!"=="6" set SEL_HOST=%IP_HOST_6%
if "!H!"=="7" set SEL_HOST=%IP_HOST_7%
if "!H!"=="8" set SEL_HOST=%IP_HOST_8%
if /i "!H!"=="M" set /p SEL_HOST="Enter IP: "
goto MAIN_MENU

:SELECT_GW
cls
echo ================= SELECT GATEWAY =================
echo.
echo [1]  %IP_GW_1%
echo [2]  %IP_GW_2%
echo [3]  %IP_GW_3%
echo [4]  %IP_GW_4%
echo [5]  %IP_GW_5%
echo [6]  %IP_GW_6%
echo [7]  %IP_GW_7%
echo [8]  %IP_GW_8%
echo [9]  %IP_GW_9%
echo [10] %IP_GW_10%
echo [M]  Manual
echo.
set /p G="Option: "
if "!G!"=="1"  set SEL_GW=%IP_GW_1%
if "!G!"=="2"  set SEL_GW=%IP_GW_2%
if "!G!"=="3"  set SEL_GW=%IP_GW_3%
if "!G!"=="4"  set SEL_GW=%IP_GW_4%
if "!G!"=="5"  set SEL_GW=%IP_GW_5%
if "!G!"=="6"  set SEL_GW=%IP_GW_6%
if "!G!"=="7"  set SEL_GW=%IP_GW_7%
if "!G!"=="8"  set SEL_GW=%IP_GW_8%
if "!G!"=="9"  set SEL_GW=%IP_GW_9%
if "!G!"=="10" set SEL_GW=%IP_GW_10%
if /i "!G!"=="M" set /p SEL_GW="Enter IP: "
goto MAIN_MENU

:SELECT_ADAPTER
cls
echo ================ SELECT ADAPTER ==================
echo.
set IDX=0
for /f "tokens=1,* delims=:" %%A in ('ipconfig /all ^| findstr /i /c:"Ethernet adapter " /c:"Adaptador de Ethernet "') do (
    set /a IDX+=1
    set RAW=%%A
    set RAW=!RAW:Ethernet adapter =!
    set RAW=!RAW:Adaptador de Ethernet =!
    for /f "tokens=* delims= " %%S in ("!RAW!") do set RAW=%%S
    set ADAPTER_!IDX!=!RAW!
    echo [!IDX!] !RAW!
)
echo [M] Manual
echo.
set /p AD="Option: "
for /l %%i in (1,1,%IDX%) do if "!AD!"=="%%i" set SEL_ADAPTER=!ADAPTER_%%i!
if /i "!AD!"=="M" set /p SEL_ADAPTER="Enter name: "
goto MAIN_MENU

:SELECT_CHECK
cls
echo ================ SELECT CHECK =====================
echo.
echo [1] Normal   (100 pings,   2 errors)
echo [2] Extended (1000 pings,  6 errors)
echo [3] Plus     (10000 pings, 20 errors)
echo [4] EXTREM   (50000 pings, 100 errors)
echo.
set /p CK="Option: "
if "!CK!"=="1" set PING_COUNT=100&set MAX_ERR=2&set PING_MODE=Normal
if "!CK!"=="2" set PING_COUNT=1000&set MAX_ERR=6&set PING_MODE=Extended
if "!CK!"=="3" set PING_COUNT=10000&set MAX_ERR=20&set PING_MODE=Plus
if "!CK!"=="4" set PING_COUNT=50000&set MAX_ERR=100&set PING_MODE=EXTREM
goto MAIN_MENU

:SAVE_SETTINGS
cls
echo ============= SAVE SETTINGS (Static IP) =============
echo.
echo  Adapter  : !SEL_ADAPTER!
echo  Host IP  : !SEL_HOST!
echo  Gateway  : !SEL_GW!
echo.
if "!SEL_ADAPTER!"=="" (
    echo  [ERROR] No adapter selected. Go to option [3] first.
    pause
    goto MAIN_MENU
)

REM -- 0) Disable Wi-Fi first ----------------------------------
echo  Disabling Wi-Fi...
netsh interface set interface "Wi-Fi" admin=disable >nul 2>&1
netsh interface set interface "WiFi" admin=disable >nul 2>&1
netsh interface set interface "WLAN" admin=disable >nul 2>&1

REM -- 1) Enable the selected adapter --------------------------
echo  Enabling adapter: !SEL_ADAPTER!
netsh interface set interface "!SEL_ADAPTER!" admin=enable >nul 2>&1
timeout /t 1 /nobreak >nul

REM -- 2) Flush existing IP to avoid "object already exists" ---
echo  Flushing existing IP config...
netsh interface ip set address "!SEL_ADAPTER!" dhcp >nul 2>&1
timeout /t 1 /nobreak >nul

REM -- 3) Assign static IP -------------------------------------
echo  Setting static IP...
netsh interface ip set address "!SEL_ADAPTER!" static !SEL_HOST! 255.255.255.0 !SEL_GW! >nul 2>&1
echo  Setting DNS to gateway...
netsh interface ip set dns "!SEL_ADAPTER!" static !SEL_GW! >nul 2>&1

REM -- 4) Disable all OTHER adapters ---------------------------
for /l %%i in (1,1,%TOTAL_ADAPTERS%) do (
    set OTHER=!ALL_ADAPTER_%%i!
    if /i "!OTHER!" neq "!SEL_ADAPTER!" (
        echo  Disabling: !OTHER!
        netsh interface set interface "!OTHER!" admin=disable >nul 2>&1
    )
)

echo.
echo  [OK] Static IP applied. Wi-Fi and other adapters disabled.
pause
goto MAIN_MENU

:SET_DHCP
cls
echo ============= DYNAMIC IP (DHCP) ======================
echo.
if "!SEL_ADAPTER!"=="" (
    echo  [ERROR] No adapter selected. Go to option [3] first.
    pause
    goto MAIN_MENU
)
netsh interface ip set address "!SEL_ADAPTER!" dhcp >nul 2>&1
netsh interface ip set dns    "!SEL_ADAPTER!" dhcp >nul 2>&1
echo.
echo  [OK] DHCP enabled on !SEL_ADAPTER!.
pause
goto MAIN_MENU

:START_TEST
cls
echo ================= PING TEST ======================
echo  Gateway : !SEL_GW!
echo  Mode    : !PING_MODE!
echo  Pings   : !PING_COUNT!
echo  Max Err : !MAX_ERR!
echo --------------------------------------------------
set ERRORS=0
set PING_I=1

:PING_LOOP
if !PING_I! GTR !PING_COUNT! goto PING_SUCCESS

ping -n 1 !SEL_GW! >nul
if errorlevel 1 (
    set /a ERRORS+=1
    echo [!PING_I!] ERROR (!ERRORS!)
    if !ERRORS! GEQ !MAX_ERR! goto FAIL
) else (
    echo [!PING_I!] OK
)
set /a PING_I+=1
goto PING_LOOP

:PING_SUCCESS
echo.
echo ================== SUCCESS =======================
pause
goto MAIN_MENU

:FAIL
echo.
echo ================== FAIL ==========================
echo  Errors: !ERRORS! / !MAX_ERR!
pause
goto MAIN_MENU

:RESTORE_ETHERNETS
cls
echo ============= RESTORE ALL ETHERNET ADAPTERS ==========
echo.
call :DO_RESTORE
echo  All adapters restored to DHCP.
pause
goto MAIN_MENU

:DO_EXIT
cls
echo ============================================================
echo   EXIT - Restoring all adapters before closing...
echo ============================================================
echo.
call :DO_RESTORE
echo  All adapters restored. Closing...
timeout /t 2 /nobreak >nul
exit

REM ============================================================
REM  SUBRUTINA COMPARTIDA - usada por opcion 8 y opcion 9
REM ============================================================
:DO_RESTORE
echo  Enabling Wi-Fi...
netsh interface set interface "Wi-Fi" admin=enable >nul 2>&1
netsh interface set interface "WiFi"  admin=enable >nul 2>&1
netsh interface set interface "WLAN"  admin=enable >nul 2>&1
set EXIT_TOTAL=0
for /f "skip=1 tokens=* delims=" %%A in ('wmic nic where "NetConnectionID like '%%'" get NetConnectionID 2^>nul') do (
    set LINE=%%A
    for /f "tokens=* delims= " %%S in ("!LINE!") do set LINE=%%S
    if not "!LINE!"=="" (
        set /a EXIT_TOTAL+=1
        set EXIT_ADAPTER_!EXIT_TOTAL!=!LINE!
    )
)
for /l %%i in (1,1,%EXIT_TOTAL%) do (
    set ADNAME=!EXIT_ADAPTER_%%i!
    echo  Enabling : !ADNAME!
    netsh interface set interface "!ADNAME!" admin=enable >nul 2>&1
    echo  DHCP     : !ADNAME!
    netsh interface ip set address "!ADNAME!" dhcp >nul 2>&1
    netsh interface ip set dns    "!ADNAME!" dhcp >nul 2>&1
    echo  [OK] !ADNAME!
    echo.
)
goto :eof

:HELP
cls
color 0B
echo ============================================================
echo         NETWORK TESTER  by Fran-Byte  -  HELP
echo ============================================================
echo.
echo  OBJETIVO DEL PROGRAMA
echo  ----------------------
echo  Herramienta para configurar rapidamente la IP estatica
echo  de un adaptador Ethernet y verificar la conexion mediante
echo  pings continuos al gateway. Disenada para entornos
echo  industriales donde se requiere una red estable y aislada.
echo.
echo  FLUJO DE USO RECOMENDADO
echo  ------------------------
echo  1. Selecciona la IP del HOST (tu maquina)        -> Op. 1
echo  2. Selecciona la IP del GATEWAY (equipo destino) -> Op. 2
echo  3. Selecciona el adaptador Ethernet a usar       -> Op. 3
echo  4. Selecciona el modo de prueba (pings)          -> Op. 4
echo  5. Guarda la configuracion con IP estatica       -> Op. 5
echo  6. Lanza el test de ping al gateway              -> Op. 7
echo.
echo  OPCIONES DETALLADAS
echo  -------------------
echo  [1] HOST IP    : IP que se asignara a tu maquina.
echo  [2] GATEWAY IP : IP del equipo al que haras ping.
echo  [3] ETHERNET   : Adaptador que recibira la IP estatica.
echo  [4] CHECK MODE : Numero de pings y tolerancia de errores:
echo                   Normal   =   100 pings,   2 errores max
echo                   Extended =  1000 pings,   6 errores max
echo                   Plus     = 10000 pings,  20 errores max
echo                   EXTREM   = 50000 pings, 100 errores max
echo.
echo  [5] SAVE       : Desactiva el Wi-Fi, asigna IP estatica
echo                   al adaptador seleccionado y desactiva
echo                   el resto de adaptadores.
echo  [6] DYNAMIC IP : Vuelve el adaptador seleccionado a DHCP.
echo  [7] START TEST : Lanza pings continuos al gateway.
echo                   Muestra OK o ERROR en cada ping.
echo                   Para si se supera el maximo de errores.
echo  [8] RESTORE    : Reactiva todos los adaptadores incluido
echo                   el Wi-Fi y los configura en DHCP.
echo  [9] EXIT       : Ejecuta RESTORE automaticamente y cierra.
echo.
echo  NOTAS IMPORTANTES
echo  -----------------
echo  - Ejecutar siempre como Administrador.
echo  - SAVE desactiva el Wi-Fi para evitar conflictos de ruta.
echo  - Usar RESTORE u EXIT al terminar para dejar la red
echo    en estado normal antes de salir del programa.
echo.
echo ============================================================
pause
goto MAIN_MENU
