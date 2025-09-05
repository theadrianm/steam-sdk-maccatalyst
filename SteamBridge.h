//
//  SteamBridge.h
//  infinilearn
//
//  Created by Adrian Martinez on 9/4/25.
//

#import <Foundation/Foundation.h>

@interface SteamBridge : NSObject
+ (BOOL)initSteam;
+ (void)runCallbacks;
+ (void)shutdown;
@end

