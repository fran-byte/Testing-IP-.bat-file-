# Network Tester (CMD/BAT)

A small Windows CMD/BAT tool to quickly set a static IP on an Ethernet adapter and verify connectivity to a gateway using repeated pings. Designed for industrial or isolated network environments where a stable local IP and simple connectivity checks are required.

## Features
- Select from predefined host and gateway IPs or enter them manually
- Choose an Ethernet adapter from the system list
- Apply a static IP or switch back to DHCP
- Run a configurable ping test with error thresholds
- Disable Wi‑Fi and other adapters while a static IP is active
- Restore all adapters to DHCP when finished

## Requirements
- Windows (tested in Command Prompt)
- Run the script as Administrator (the script checks for elevation)
- The script uses `netsh`, `wmic`, and `ping` commands

## Quick usage
1. Open an elevated Command Prompt (Run as Administrator).
2. Run `ip.bat`.
3. Use the menu options:
   - 1: Select host IP (or manual)
   - 2: Select gateway IP (or manual)
   - 3: Select Ethernet adapter
   - 4: Choose ping test mode (Normal / Extended / Plus / EXTREM)
   - 5: SAVE SETTINGS — apply static IP and disable other adapters
   - 6: DYNAMIC IP — switch selected adapter back to DHCP
   - 7: START TEST — run pings against the selected gateway
   - 8: RESTORE — re-enable all adapters and set them to DHCP
   - 9: EXIT — restores adapters and exits

## Customization
Edit the variables at the top of `ip.bat` to change defaults:
- IP_HOST_1..8 — predefined host IPs
- IP_GW_1..10 — predefined gateway IPs
- PING_COUNT, PING_MODE, MAX_ERR — test behavior

## Important notes & warnings
- The script will disable Wi‑Fi interfaces and other adapters when applying a static IP; use with caution.
- Always run as Administrator. Changes affect the system network configuration.
- Intended for controlled environments; use at your own risk.

## Troubleshooting
- If the script reports "[ERROR] Run this script as Administrator", re-launch the Command Prompt with elevation.
- If an adapter name is not listed, use the Manual option in the adapter menu and type the exact adapter name shown by `ipconfig /all`.
