  //
//  HPBaseNetworkManager.m
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"
#import "HPBaseNetworkManager+Geo.h"
#import "HPBaseNetworkManager+Reference.h"
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"
#import "SocketIOPacket.h"
#import "DataStorage.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "NotificationsConstants.h"
#import "UserTokenUtils.h"
#import "CareerPost.h"
#import "Company.h"
#import "Language.h"
#import "User.h"
#import "Contact.h"
#import "HPAppDelegate.h"


static HPBaseNetworkManager *networkManager;
@interface HPBaseNetworkManager ()
@property (nonatomic,strong) SocketIO* socketIO;
@property (nonatomic, strong) NSMutableArray *taskArray;
@property (nonatomic, strong) NSMutableIndexSet *deletedItemArray;
@property (nonatomic, assign) BOOL isStartAfter;
@end


@implementation HPBaseNetworkManager

+ (HPBaseNetworkManager *) sharedNetworkManager {
    //networkManager = nil;
    @synchronized (self){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            networkManager = [[HPBaseNetworkManager alloc] init];
        });
        return networkManager;
    }
}
# pragma mark -
# pragma mark task monitor
- (void) createDeletedItemArray {
    self.deletedItemArray = [NSMutableIndexSet new];
}
- (void) deleteDeletedItemArray {
    self.deletedItemArray = nil;
}
- (void) addDeletedItemToArray:(NSInteger) index {
    [self.deletedItemArray addIndex:index];
}
- (void) deleteDeletedItemFromArray:(NSInteger) index {
    [self.deletedItemArray removeIndex:index];
}
- (BOOL) isDeletedItemArrayEmpty {
    return self.deletedItemArray.count == 0;
}
- (NSNumber*) getFirstIndexIntoDeletedArray {
    return [NSNumber numberWithInteger:[self.deletedItemArray firstIndex]];
}
- (void) createTaskArray {
    self.taskArray = [NSMutableArray new];
}
- (void) deleteTaskArray {
    self.taskArray = nil;
}
- (BOOL) isTaskArrayEmpty:(AFHTTPRequestOperationManager*) manager {
    if(self.taskArray && self.taskArray.count > 0) {

        NSLog(@"%lu",(unsigned long)self.taskArray.count);
        NSUInteger index = [self.taskArray indexOfObject:manager ];
        if(index != NSNotFound) {
            [self.taskArray removeObjectAtIndex:[self.taskArray indexOfObject:manager ]];
            if(self.taskArray.count == 0) {
                self.taskArray = nil;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedHideSplashView object:nil userInfo:nil];
                return YES;
            } else return NO;
        } else return NO;
    } else return NO;
}
- (void) addTaskToArray:(AFHTTPRequestOperationManager*) manager {
    if(self.taskArray && manager)   {
        [self.taskArray addObject:manager];

    }
}
# pragma mark -
# pragma mark network status
- (void) startNetworkStatusMonitor {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
- (void) setNetworkStatusMonitorCallback {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if([AFStringFromNetworkReachabilityStatus(status) isEqualToString:@"Reachable via WiFi"] ||
           [AFStringFromNetworkReachabilityStatus(status) isEqualToString:@"Reachable via WWAN"]) {
            
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedHideSplashView object:nil userInfo:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        NSLog(@"Warning: Reachability status %@", AFStringFromNetworkReachabilityStatus(status));
    }];
}
//AFHTTPRequestOperationManager
- (AFHTTPRequestOperationManager*) requestOperationManager {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    return manager;
}
- (void) makeTownByIdRequest {
    //NSArray *users = [[[DataStorage sharedDataStorage] allUsersFetchResultsController] fetchedObjects]; allUsersAndContactFetchResultsController
    NSArray *users = [[[DataStorage sharedDataStorage] allUsersAndContactFetchResultsController] fetchedObjects];
    NSString *ids = @"";

    for (int i = 0; i < users.count; i++) {
        if (((User *)[users objectAtIndex:i]).cityId) {
            ids = [ids stringByAppendingString:[NSString stringWithFormat:@"%@%@", ((User *)[users objectAtIndex:i]).cityId, @","]];
        }
    }
    if ([ids length] > 0) {
        ids = [ids substringToIndex:[ids length] - 1];
    }
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:ids, @"cityIds", nil];
    [self getGeoLocation:param];

    if(!_isStartAfter) {
        param = [[NSDictionary alloc] initWithObjectsAndKeys:[[[URLs getServerURL] stringByReplacingOccurrencesOfString:@":3002" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""],@"host", @"3002",@"port", nil];
        [[HPBaseNetworkManager sharedNetworkManager] initSocketIO:param];
        
        //NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil];
        User * usr = [[DataStorage sharedDataStorage] getCurrentUser];
        if(usr) {
            [[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:[[DataStorage sharedDataStorage] prepareParamFromUser:usr]];
        }
        _isStartAfter = YES;
    }
}
- (void) makePingWithBlock:(resultBlock)block {
    NSString *url = @"http://www.apple.com";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 10;
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger httpStatusCode = operation.response.statusCode;
        if(httpStatusCode == HTTPStatusOK) {
            block (@"success");
            } else {
            block(@"Error");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(@"Error");
    }];
}

# pragma mark -
# pragma mark http requests
#pragma mark - geolocation
#pragma mark - application settings
# pragma mark -
# pragma mark socket io methods
//param - dict with keys host, port, user
- (void) initSocketIO:(NSDictionary*) param {
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    [_socketIO connectToHost:[param objectForKey:@"host"]  onPort:[[param objectForKey:@"port"] intValue]];
    [_socketIO sendEvent:@"join" withData:[param objectForKey:@"user"]];
}
- (void) sendMessage:(NSDictionary*) param {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"777",@"id",@"text message",@"body",@"333", @"destinationId", nil];
    [_socketIO sendEvent:kSendMessage withData:dict];
}
- (void) sendUserActivityStart:(NSDictionary*) param {
    if(_socketIO) {
         [_socketIO sendEvent:kActivityStart withData:param];
    }
}
- (void) sendUserActivityEnd:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kActivityEnd withData:param];
    }
}
- (void) sendUserMessagesRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kMessagesRead withData:param];
    }
}
- (void) sendUserTypingStart:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kTypingStart withData:param];
    }
}
- (void) sendUserTypingFinish:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kTypingFinish withData:param];
    }
}
- (void) sendUserNotificationRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kNotificationRead withData:param];
    }
}
- (void) sendUserAllNotificationRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kAllNotificationRead withData:param];
    }
}
# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"Warning: socket.io connected.");
}
//receive event
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    //parsing incoming messages here

    if([packet.name isEqualToString:@"message"])
    {
       // NSArray* args = packet.args;
       // NSDictionary* arg = args[0];
    }

    if ([packet.name isEqualToString:kMeUpdate]) {
        NSDictionary *jsonDict = [packet.args objectAtIndex:0];
        if(jsonDict) {
            //[[DataStorage sharedDataStorage] createAndSaveUserEntity:[[jsonDict objectForKey:@"data"] objectForKey:@"user"] forUserType:CurrentUserType withComplation: nil];
            //[[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:[[DataStorage sharedDataStorage] prepareParamFromUser:[[DataStorage sharedDataStorage] getCurrentUser]]];
        } else {
            NSLog(@"Error: no valid data");
        }

    }

    if ([packet.name isEqualToString:kMessage]) {
        //TODO: write msgs to DB

    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"Error: soket.io error %@", error);
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"Error: socket.io disconnected. did error occur? %@", error);
}

@end
