
//
//  main.m
//  Varial
//
//  Created by jagan on 23/01/16.
//  Copyright © 2016 Velan. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "AppDelegate.h"
#import "NSBundle+Language.h"
#import <Crashlytics/Crashlytics.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        if([Util getFromDefaults:@"language"] == nil){
            //[NSBundle setLanguage:@"en-US"];
        }else{
            NSLog(@"Language %@",[Util getFromDefaults:@"language"]);
            [NSBundle setLanguage:[Util getFromDefaults:@"language"]];
        }
//        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//        }
//        @catch (NSException *exception) {
//            NSLog(@"Track the error ,,,! %@",exception);
//            [[Crashlytics sharedInstance] crash];
//            NSLog(@"Crash report sent,,,!");
//        }
//        @finally {
//            NSLog(@"Error Occurred...!");
//        }
    }
}
