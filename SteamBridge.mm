//
//  SteamBridge.mm
//  Steam Bridge
//
//  Created by Adrian Martinez on 9/4/25.
//

#import "SteamBridge.h"

#if TARGET_OS_MACCATALYST
#include <dlfcn.h>

typedef bool (*SteamAPI_InitSafe_t)(void);
typedef void (*SteamAPI_RunCallbacks_t)(void);
typedef void (*SteamAPI_Shutdown_t)(void);

static void* steamLib = NULL;
static SteamAPI_InitSafe_t SteamAPI_InitSafe_ptr = NULL;
static SteamAPI_RunCallbacks_t SteamAPI_RunCallbacks_ptr = NULL;
static SteamAPI_Shutdown_t SteamAPI_Shutdown_ptr = NULL;
#endif

@implementation SteamBridge
+ (BOOL)initSteam {
#if TARGET_OS_MACCATALYST
    NSString *frameworksPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Frameworks/libsteam_api.dylib"];
    
    NSLog(@"Looking for Steam library at: %@", frameworksPath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:frameworksPath]) {
        NSLog(@"Steam library not found at expected path");
        return NO;
    }
    
    NSLog(@"Found Steam library!");
    
    // Load the library with RTLD_LAZY instead of RTLD_NOW
    steamLib = dlopen([frameworksPath UTF8String], RTLD_LAZY | RTLD_GLOBAL);
    if (!steamLib) {
        NSLog(@"Failed to load Steam library: %s", dlerror());
        return NO;
    }
    
    NSLog(@"Library loaded successfully");
    
    // Clear any previous errors
    dlerror();
    
    // Get function pointers - use InitSafe instead of Init
        SteamAPI_InitSafe_ptr = (SteamAPI_InitSafe_t)dlsym(steamLib, "SteamAPI_InitSafe");
        if (!SteamAPI_InitSafe_ptr) {
            NSLog(@"Failed to get SteamAPI_InitSafe: %s", dlerror());
        }
        
        SteamAPI_RunCallbacks_ptr = (SteamAPI_RunCallbacks_t)dlsym(steamLib, "SteamAPI_RunCallbacks");
        if (!SteamAPI_RunCallbacks_ptr) {
            NSLog(@"Failed to get SteamAPI_RunCallbacks: %s", dlerror());
        }
        
        SteamAPI_Shutdown_ptr = (SteamAPI_Shutdown_t)dlsym(steamLib, "SteamAPI_Shutdown");
        if (!SteamAPI_Shutdown_ptr) {
            NSLog(@"Failed to get SteamAPI_Shutdown: %s", dlerror());
        }
        
        if (!SteamAPI_InitSafe_ptr || !SteamAPI_RunCallbacks_ptr || !SteamAPI_Shutdown_ptr) {
            NSLog(@"Failed to get all Steam functions");
            return NO;
        }
        
        NSLog(@"All function pointers obtained successfully");
        
    // Set Steam environment variables to help it find Steam
    setenv("SteamAppId", "3513130", 1);
    setenv("SteamGameId", "3513130", 1);

    // Try to help it find Steam's location
    NSString *homeDir = NSHomeDirectory();
    NSString *steamPath = [homeDir stringByAppendingPathComponent:@"Library/Application Support/Steam"];
    setenv("STEAM_PATH", [steamPath UTF8String], 1);

    // Also try the typical Steam install location
    setenv("DYLD_LIBRARY_PATH", "/Applications/Steam.app/Contents/MacOS", 1);
    setenv("DYLD_FRAMEWORK_PATH", "/Applications/Steam.app/Contents/Frameworks", 1);

    // Create the app ID file
    NSString *appIDPath = @"steam_appid.txt";
    NSString *appID = @"3513130";
    [appID writeToFile:appIDPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    // Now try to initialize
    bool result = SteamAPI_InitSafe_ptr();
        if (result) {
            NSLog(@"✅ Steam initialized successfully!");
        } else {
            NSLog(@"❌ Steam init failed - is Steam running?");
        }
    return result;
#else
    return NO;
#endif
}

+ (void)runCallbacks {
#if TARGET_OS_MACCATALYST
    if (SteamAPI_RunCallbacks_ptr) {
        SteamAPI_RunCallbacks_ptr();
    }
#endif
}

+ (void)shutdown {
#if TARGET_OS_MACCATALYST
    if (SteamAPI_Shutdown_ptr) {
        SteamAPI_Shutdown_ptr();
    }
    if (steamLib) {
        dlclose(steamLib);
        steamLib = NULL;
    }
#endif
}

@end
