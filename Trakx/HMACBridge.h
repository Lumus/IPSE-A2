//
//  HMACBridge.h
//  Trakx
//
//  Created by Matt Croxson on 28/06/2015.
//  Copyright © 2016 Matt Croxson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMACBridge : NSObject

+ (NSURL * _Nullable)signedURLWithPath: (NSString * _Nonnull)path;

@end
