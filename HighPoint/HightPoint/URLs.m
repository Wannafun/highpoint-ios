//
//  URLs.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 25.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "URLs.h"

@implementation URLs


+ (NSString *) getServerURL; {
    NSString *serverUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"];
    if (serverUrl.length < 7) {
        serverUrl = @"http://localhost:3002"; //http://146.185.141.21:3002/panel
    } else  {
        serverUrl = [NSString stringWithFormat:@"http://%@:3002", serverUrl];
    }
    NSLog(@"IP --- > %@", serverUrl);
    return serverUrl;
}

+ (void) setServerUrl : (NSString *) serverUrl; {
    //serverUrl = @"146.185.141.21";
    [[NSUserDefaults standardUserDefaults] setObject:serverUrl forKey:@"serverURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"serverURL setted = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"serverURL"]);
}


@end
