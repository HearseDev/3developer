#pragma once
#import <SpringBoard/SBApplicationInfo.h>
@interface FBApplicationInfo (devtools)
@property(readonly, nonatomic)
    NSString *teamIdentifier; // ivar: _teamIdentifier
@property(readonly, copy, nonatomic)
    NSString *shortVersionString; // ivar: _shortVersionString
@end
