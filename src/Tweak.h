#pragma once
//@import Foundation;

//@import UIKit;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplicationInfo.h>

#import "DTAppInfoViewController.h"
#import "NSTask.h"
#define FLEX_BUNDLE_ID @"com.hearse.3developer.3d.flex"
#define COPY_BUNDLE_ID @"com.hearse.3developer.3d.copy"
#define INFO_BUNDLE_ID @"com.hearse.3developer.3d.info"
#define OPEN_BUNDLE_IN_FILZA_BUNDLE_ID                                         \
  @"com.hearse.3developer.3d.openBundleInFilza"
#define OPEN_CONTAINER_IN_FILZA_BUNDLE_ID                                      \
  @"com.hearse.3developer.3d.openContainerInFilza"

@interface SBSApplicationShortcutIcon : NSObject
@end

@interface SBApplication (devtools)
@property(retain, nonatomic) SBApplicationInfo *info; // ivar: _appInfo
@end

@interface UIApplication (devtools)
- (void)applicationOpenURL:(id)arg1;
- (bool)launchApplicationWithIdentifier:(id)arg1 suspended:(bool)arg2;
@end

@interface SBSApplicationShortcutItem : NSObject
@property(nonatomic, retain) NSString *type;
@property(nonatomic, copy) NSString *localizedTitle;
@property(copy, nonatomic)
    NSString *localizedSubtitle; // ivar: _localizedSubtitle
@property(copy, nonatomic)
    NSString *bundleIdentifierToLaunch; // ivar: _bundleIdentifierToLaunch
@property(nonatomic, copy) SBSApplicationShortcutIcon *icon;
@property(copy, nonatomic) NSDictionary *userInfo;
@end

@interface SBIcon : NSObject
@end

@interface SBIconView : UIView
@property(readonly, copy, nonatomic)
    NSString *applicationBundleIdentifierForShortcuts;
@property(nonatomic, strong, readwrite) SBIcon *icon;
- (BOOL)isFolderIcon;
@end

@interface SBSApplicationShortcutSystemPrivateIcon : SBSApplicationShortcutIcon
- (id)initWithSystemImageName:(id)arg1;
@end
