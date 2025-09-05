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
Fix the library's install name:
install_name_tool -id @rpath/libsteam_api.dylib libsteam_api.dylib

### Step 2: Add to Xcode Project
1. Drag libsteam_api.dylib into your project
2. In General → Frameworks, Libraries, and Embedded Content:
   - Set to "Embed Without Signing"

### Step 3: Configure Build Settings
1. Disable Library Validation: YES
2. Allow Unsigned Executable Memory: YES  
3. Runpath Search Paths: Add
   - @executable_path/../Frameworks
   - @loader_path/../Frameworks

### Step 4: Remove App Sandbox
⚠️ Important: This makes your app incompatible with Mac App Store
- In Signing & Capabilities, remove "App Sandbox"
- This is required for Steam IPC to work

### Step 5: Add Bridge Files
Copy the SteamBridge files to your project and add to bridging header:
#import "SteamBridge.h"

### Step 6: Initialize in Your App
#if targetEnvironment(macCatalyst)
if SteamBridge.initSteam() {
    print("Steam initialized!")
    Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
        SteamBridge.runCallbacks()
    }
}
#endif

### Step 7: Create steam_appid.txt
Add your App ID (or 480 for testing) to steam_appid.txt in project root

## Usage
Right now, the current uses are very limited. Steam Overlay currently does not work.

## Limitations
- No App Sandbox = No Mac App Store
- Some Steam features may not work (achievements need additional setup)
- Performance overhead from Catalyst (~10% vs native)

## Deployment
Maintain two build configurations:
- Steam Build: No sandbox, Steam enabled
- App Store Build: Sandbox enabled, no Steam

## Why This Exists
I spent hours fighting with Mac Catalyst + Steam SDK. The documentation is non-existent, and the errors are cryptic. This solution works but requires compromises (no sandboxing).

If you need full Steam features with better performance, consider a native Mac target instead of Catalyst.

## Credits
Created by Adrian Martinez while building Infinilearn (https://store.steampowered.com/app/3513130)

## License
MIT - Use this however you want. Save yourself the pain I went through.

## Contributing
If you find a way to make this work WITH sandboxing, please PR immediately!
