//
//  PHDataManager.h
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString* const kPHLines;

@interface PHNetworkingManager : NSObject

- (void)requestTransportInfoWithCompletionHandler:(void(^)(NSDictionary* transportInfo))completionHandler;

@end
