//
//  HPBaseNetworkManager+Contacts.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"

@interface HPBaseNetworkManager (Contacts)
- (void) getContactsRequest;
- (void) deleteContactRequest : (NSNumber *)contactId;
@end
