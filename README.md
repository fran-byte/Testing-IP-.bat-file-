@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul
mode con: cols=80 lines=30

:: Network Tester by Fran Byte -
:: Este programa permite configurar IP estática/dinámica y probar conectividad

:main
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║      NETWORK TESTER v2.0 by Fran-Byte        ║
echo                  ║         (Admin privileges required)          ║
echo                  ╚══════════════════════════════════════════════╝
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║                   MAIN MENU                  ║
echo                  ╠══════════════════════════════════════════════╣
echo                  ║   1.  Set static IP                          ║
echo                  ║   2.  Set DHCP                               ║
echo                  ║   3.  Test connectivity (Ping Test)          ║
echo                  ║   4.  Reset Ethernet adapters                ║
echo                  ║   5.  Diagnose network issues                ║
echo                  ║   6.  Exit                                   ║
echo                  ╚══════════════════════════════════════════════╝
echo.
set /p choice="                   Select an option [1-6]: "

if "!choice!"=="1" goto static_ip
if "!choice!"=="2" goto dhcp
if "!choice!"=="3" goto ping_test
if "!choice!"=="4" goto restore_adapters
if "!choice!"=="5" goto network_diagnosis
if "!choice!"=="6" goto exit

goto main

:static_ip
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║            CONFIGURE STATIC IP               ║
echo                  ╚══════════════════════════════════════════════╝
echo.

:: Intentar hasta 3 veces con delay
set retry_count=0

:retry_detect
set adapters_count=0

:: Esperar antes de detectar (solo en reintentos)
if !retry_count! gtr 0 (
    echo                  Retrying detection... (!retry_count!/3)
    timeout /t 1 /nobreak >nul
)

echo                  Network interfaces list:
echo                  ══════════════════════════════════════════════
echo.
set adapters_count=0

for /f "tokens=4* delims= " %%a in ('netsh interface show interface ^| findstr "Conectado Connected"') do (
    set /a adapters_count+=1
    set adapter!adapters_count!=%%a %%b
    echo                  !adapters_count!.  %%a %%b
)

if !adapters_count! equ 0 (
    set /a retry_count+=1
    if !retry_count! lss 3 (
        goto retry_detect
    )
   
    echo.
    echo                  ╔══════════════════════════════════════════════╗
    echo                  ║                  ERROR                       ║
    echo                  ╠══════════════════════════════════════════════╣
    echo                  ║ No connected network adapters found          ║
    echo                  ╚══════════════════════════════════════════════╝
    echo.
    
    echo                  Available but disconnected adapters:
    for /f "tokens=4* delims= " %%a in ('netsh interface show interface ^| findstr "Desconectado Disconnected"') do (
        echo                  - ✗ %%a %%b [Disconnected]
    )
   
    echo.
    echo                  Possible solutions:
    echo                  1. Check cable connection
    echo                  2. Enable network card
    echo                  3. Restart network adapter
    echo.
    choice /c 123R /n /m "Select: [1] Retry, [2] Menu, [3] Diagnose, [R] Restart adapters"
   
    if errorlevel 4 goto reset_adapters
    if errorlevel 3 goto network_diagnosis
    if errorlevel 2 goto main
    if errorlevel 1 goto static_ip
    goto main
)

echo.
set /p adapter_num="                  Select the adapter [1-!adapters_count!]: "

:: Convertir a número para validación
set /a adapter_num=!adapter_num! 2>nul
if !adapter_num! lss 1 goto static_ip
if !adapter_num! gtr !adapters_count! goto static_ip

set selected_adapter=!adapter%adapter_num%!

:: Lista de IPs predefinidas
set ip_host[1]=192.168.0.24
set ip_host[2]=192.168.1.2
set ip_host[3]=192.168.0.2
set ip_host[4]=10.117.3.84
set ip_host[5]=192.168.0.205
set ip_host[6]=192.168.1.1
set ip_host[7]=192.168.1.34
set ip_host[8]=192.168.199.175

set ip_gateway[1]=192.168.0.25
set ip_gateway[2]=192.168.0.30
set ip_gateway[3]=192.168.0.1
set ip_gateway[4]=192.168.0.5
set ip_gateway[5]=192.168.1.1
set ip_gateway[6]=10.117.3.85
set ip_gateway[7]=192.168.0.201
set ip_gateway[8]=192.168.1.2
set ip_gateway[9]=192.168.1.35
set ip_gateway[10]=192.168.199.176

:: Seleccionar Host IP
:select_host_ip
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║            CONFIGURE STATIC IP               ║
echo                  ╚══════════════════════════════════════════════╝
echo.
echo                  Selected adapter: !selected_adapter!
echo.
echo                  Available Host IPs:
for /l %%i in (1,1,8) do echo                  %%i. !ip_host[%%i]!
echo.
echo                  M. Enter IP manually
echo.
set /p host_input="                  Select Host IP [1-8] or 'M' for manual: "

if /i "!host_input!"=="M" (
    set /p host_ip="                  Enter IP address manually: "
    goto gateway_selection
)

set /a host_ip_num=!host_input!
if !host_ip_num! lss 1 goto select_host_ip
if !host_ip_num! gtr 8 goto select_host_ip
set host_ip=!ip_host[%host_ip_num%]!

:gateway_selection
:: Seleccionar Gateway
:select_gateway
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║            CONFIGURE STATIC IP               ║
echo                  ╚══════════════════════════════════════════════╝
echo.
echo                  Selected adapter: !selected_adapter!
echo                  Host IP: !host_ip!
echo.
echo                  Available Gateway IPs:
for /l %%i in (1,1,10) do echo                  %%i. !ip_gateway[%%i]!
echo.
echo                  M. Enter Gateway manually
echo.
set /p gateway_input="                  Select Gateway IP [1-10] or 'M' for manual: "

if /i "!gateway_input!"=="M" (
    set /p gateway_ip="                  Enter Gateway address manually: "
    goto configure_ip
)

set /a gateway_ip_num=!gateway_input!
if !gateway_ip_num! lss 1 goto select_gateway
if !gateway_ip_num! gtr 10 goto select_gateway
set gateway_ip=!ip_gateway[%gateway_ip_num%]!

:configure_ip
:: Deshabilitar WiFi
netsh interface set interface "Wi-Fi" admin=disable >nul 2>&1

:: Configurar IP estática
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║            CONFIGURE STATIC IP               ║
echo                  ╚══════════════════════════════════════════════╝
echo.
echo                  Setting static IP on !selected_adapter!...
echo                  IP: !host_ip!
echo                  Gateway: !gateway_ip!
echo.

echo                  Executing: netsh interface ip set address "!selected_adapter!" static !host_ip! 255.255.255.0 !gateway_ip! 1
netsh interface ip set address "!selected_adapter!" static !host_ip! 255.255.255.0 !gateway_ip! 1

if !errorlevel! neq 0 (
    echo.
    echo                  ╔══════════════════════════════════════════════╗
    echo                  ║                  ERROR                       ║
    echo                  ╠══════════════════════════════════════════════╣
    echo                  ║ Failed to set static IP                      ║
    echo                  ╚══════════════════════════════════════════════╝
    echo.
    echo                  Possible solutions:
    echo                  1. Run as Administrator
    echo                  2. Check adapter name
    echo                  3. Verify adapter is connected
    pause
    goto main
)

echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║                  SUCCESS                     ║
echo                  ╠══════════════════════════════════════════════╣
echo                  ║ IP configuration successful                  ║
echo                  ╚══════════════════════════════════════════════╝
echo.

:: Test de ping inmediato
echo                  Testing connectivity to gateway !gateway_ip!...
ping -n 4 !gateway_ip!

echo.
echo                  Press any key to return to main menu...
pause >nul
goto main

:dhcp
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║               CONFIGURE DHCP                 ║
echo                  ╚══════════════════════════════════════════════╝
echo.

:: Detección de adaptadores
set adapters_count=0
for /f "tokens=4* delims= " %%a in ('netsh interface show interface ^| findstr "Conectado Connected"') do (
    set /a adapters_count+=1
    set adapter!adapters_count!=%%a %%b
    echo                  !adapters_count!.  %%a %%b
)

if !adapters_count! equ 0 (
    echo                  No connected network adapters found
    pause
    goto main
)

echo.
set /p adapter_num="                  Select the adapter [1-!adapters_count!]: "
set /a adapter_num=!adapter_num!
if !adapter_num! lss 1 goto dhcp
if !adapter_num! gtr !adapters_count! goto dhcp

set selected_adapter=!adapter%adapter_num%!

:: Configure DHCP
cls
echo.
echo                  Setting DHCP on !selected_adapter!...
echo.
netsh interface ip set address "!selected_adapter!" dhcp >nul
if !errorlevel! neq 0 (
    echo                  Error setting DHCP
    pause
    goto dhcp
)

:: Enable WiFi
netsh interface set interface "Wi-Fi" admin=enable >nul 2>&1

echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║                  SUCCESS                     ║
echo                  ╠══════════════════════════════════════════════╣
echo                  ║ DHCP configuration applied on !selected_adapter!║
echo                  ╚══════════════════════════════════════════════╝
echo.

echo                  Press any key to return to main menu...
pause >nul
goto main

:ping_test
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║            CONNECTIVITY TEST                 ║
echo                  ╚══════════════════════════════════════════════╝
echo.

:: Obtener gateway actual - MÉTODO MEJORADO Y CORREGIDO
set gateway=
set found_gateway=0

:: Método 1: Usar ipconfig con un enfoque más robusto
for /f "tokens=13 delims= " %%a in ('ipconfig ^| findstr /i "Default Gateway"') do (
    set gateway=%%a
    if not "!gateway!"=="" if not "!gateway!"=="." if not "!gateway!"==":" set found_gateway=1
)

:: Método 2: Si el primer método falla, usar route print
if !found_gateway! equ 0 (
    for /f "tokens=3 delims= " %%a in ('route print ^| findstr /i "0.0.0.0.*0.0.0.0"') do (
        set gateway=%%a
        if not "!gateway!"=="" if not "!gateway!"=="0.0.0.0" set found_gateway=1
    )
)

:: Método 3: Buscar en la tabla de rutas
if !found_gateway! equ 0 (
    for /f "tokens=3 delims= " %%a in ('route print ^| findstr /i "0.0.0.0"') do (
        set gateway=%%a
        if not "!gateway!"=="" if not "!gateway!"=="0.0.0.0" set found_gateway=1
    )
)

:: Si todavía no se encuentra, mostrar mensaje de error
if !found_gateway! equ 0 (
    echo                  Unable to detect gateway automatically
    echo.
    :manual_gateway_input
    set /p gateway="                  Please enter the gateway IP address manually: "
   
    :: Validar la entrada
    echo !gateway! | findstr /R "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
    if errorlevel 1 (
        echo                  Invalid IP address format. Please use format: XXX.XXX.XXX.XXX
        goto manual_gateway_input
    )
) else (
    echo                  Detected gateway: !gateway!
)

echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║               TEST OPTIONS                   ║
echo                  ╠══════════════════════════════════════════════╣
echo                  ║   1.  Quick test (10 pings)                  ║
echo                  ║   2.  Normal test (100 pings)                ║
echo                  ║   3.  Extended test (1000 pings)             ║
echo                  ║   4.  Return to menu                         ║
echo                  ╚══════════════════════════════════════════════╝
echo.
choice /c 1234 /n /m "                  Select test type [1-4]: "

if errorlevel 4 goto main
if errorlevel 3 set pings=1000
if errorlevel 2 set pings=100
if errorlevel 1 set pings=10

cls
echo.
echo                  Performing !pings! pings to !gateway!
echo.
ping -n !pings! !gateway!
echo.
echo                  Test completed. Press any key to continue...
pause >nul
goto main

:restore_adapters
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║           RESET ETHERNET ADAPTERS            ║
echo                  ╚══════════════════════════════════════════════╝
echo.

:: Habilitar todos los adaptadores de red
set count=0

:: Habilitar WiFi
netsh interface set interface "Wi-Fi" admin=enable >nul 2>&1
echo                   Enabled adapter: Wi-Fi
set /a count+=1

:: Habilitar todos los adaptadores Ethernet
for /f "tokens=4* delims= " %%a in ('netsh interface show interface ^| findstr /i "Ethernet"') do (
    set adapter_name=%%a %%b
    netsh interface set interface "!adapter_name!" admin=enable >nul
    set /a count+=1
    echo                   Enabled adapter: !adapter_name!
)

:: Configurar todos los adaptadores Ethernet en DHCP
for /f "tokens=4* delims= " %%a in ('netsh interface show interface ^| findstr /i "Ethernet"') do (
    set adapter_name=%%a %%b
    netsh interface ip set address "!adapter_name!" dhcp >nul
    echo                   Configured DHCP on: !adapter_name!
)

echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║                  SUCCESS                     ║
echo                  ╠══════════════════════════════════════════════╣
echo                  ║ Total adapters enabled: !count!              ║
echo                  ║ All network adapters reset to DHCP           ║
echo                  ╚══════════════════════════════════════════════╝
echo.

echo                  Press any key to return to main menu...
pause >nul
goto main

:network_diagnosis
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║            NETWORK DIAGNOSIS                 ║
echo                  ╚══════════════════════════════════════════════╝
echo.
echo                  Running network diagnostics...
echo.

:: 1. Check adapters
echo                  ══════════════════════════════════════════════
echo                  NETWORK ADAPTERS:
echo                  ══════════════════════════════════════════════
netsh interface show interface
echo.

:: 2. Check IP configuration
echo                  ══════════════════════════════════════════════
echo                  IP CONFIGURATION:
echo                  ══════════════════════════════════════════════
ipconfig
echo.

:: 3. Check gateway connectivity
echo                  ══════════════════════════════════════════════
echo                  GATEWAY TEST:
echo                  ══════════════════════════════════════════════
set gateway=
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "Default Gateway"') do (
    set gateway=%%a
    set gateway=!gateway: =!
)

if "!gateway!"=="" (
    echo                   Default gateway not detected
) else (
    echo                   Detected gateway: !gateway!
    ping -n 4 !gateway!
)

echo.
echo                  Diagnostics completed. Review the information above.
echo.
echo                  Press any key to return to main menu...
pause >nul
goto main

:exit
cls
echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║                 EXITING PROGRAM              ║
echo                  ╚══════════════════════════════════════════════╝
echo.

:: Restaurar configuración de red a DHCP en todos los adaptadores
echo                  Restoring network configuration to DHCP...
for /f "tokens=4* delims= " %%a in ('netsh interface show interface ^| findstr /i "Ethernet"') do (
    set adapter_name=%%a %%b
    netsh interface ip set address "!adapter_name!" dhcp >nul
    echo                   Restored DHCP on: !adapter_name!
)

:: Habilitar todos los adaptadores
for /f "tokens=4* delims= " %%a in ('netsh interface show interface') do (
    set adapter_name=%%a %%b
    netsh interface set interface "!adapter_name!" admin=enable >nul
)

:: Habilitar WiFi específicamente
netsh interface set interface "Wi-Fi" admin=enable >nul 2>&1

echo.
echo                  ╔══════════════════════════════════════════════╗
echo                  ║                  COMPLETED                   ║
echo                  ╠══════════════════════════════════════════════╣
echo                  ║ All network adapters restored to DHCP        ║
echo                  ║ All adapters have been enabled               ║
echo                  ║ Program finished                             ║
echo                  ╚══════════════════════════════════════════════╝
timeout /t 3 >nul
exit /b
