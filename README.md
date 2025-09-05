# Steam SDK Mac Catalyst Bridge

Finally, a working solution for integrating Steamworks SDK with Mac Catalyst apps. This took way too long to figure out, so here it is for everyone else.

## The Problem
- Steam SDK doesn't officially support Mac Catalyst
- Library signing conflicts between Valve and your team
- Sandbox restrictions block Steam IPC
- Dynamic library loading issues with Catalyst

## Prerequisites
- Steamworks SDK (download from partner.steamgames.com)
- Steam client installed and running
- Xcode 14+
- A Steam App ID (use 480 for testing with Spacewar)

## Installation

### Step 1: Prepare the Steam Library
```bash
# Fix the library's install name
install_name_tool -id @rpath/libsteam_api.dylib libsteam_api.dylib
