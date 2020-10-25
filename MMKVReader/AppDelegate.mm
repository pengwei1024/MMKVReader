//
//  AppDelegate.m
//  MMKVReader
//
//  Created by Peng,Wei(BAMRD) on 2020/10/24.
//  Copyright © 2020 apkfuns.com. All rights reserved.
//

#import "AppDelegate.h"
#import "MMKV.h"

using namespace mmkv;

@interface AppDelegate ()

@end

@implementation AppDelegate {
    NSString *rootPath;
    NSFileManager *fileManager;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSString *homePath = NSHomeDirectory();
    rootPath = [homePath stringByAppendingPathComponent:@"files"];
    NSLog(@"initializeMMKV:%@", homePath);
    fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:rootPath]) {
        [fileManager createDirectoryAtPath:rootPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    MMKV::initializeMMKV([rootPath UTF8String], MMKVLogDebug);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [fileManager removeItemAtPath:rootPath error:nil];
}


@end