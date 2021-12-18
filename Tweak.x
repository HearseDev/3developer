#include "NSTask.h"
#include <SpringBoard/SBApplication.h>
#include <SpringBoard/SBApplicationController.h>
#include <SpringBoard/SBApplicationInfo.h>

@interface SBSApplicationShortcutIcon : NSObject
@end

@interface SBApplication (private)
@property(retain, nonatomic) SBApplicationInfo *info; // ivar: _appInfo
@end

@interface SBSApplicationShortcutItem : NSObject
@property(nonatomic, retain) NSString *type;
@property(nonatomic, copy) NSString *localizedTitle;
@property(nonatomic, copy) SBSApplicationShortcutIcon *icon;
@end

@interface SBSApplicationShortcutCustomImageIcon : SBSApplicationShortcutIcon
@property(nonatomic, readwrite) BOOL isTemplate;
- (id)initWithImagePNGData:(id)arg1;
- (BOOL)isTemplate;
@end

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)arg1 {
  NSMutableArray *originalItems = [[NSMutableArray alloc] init];
  for (SBSApplicationShortcutItem *item in arg1) {
    [originalItems addObject:item];
  }

  NSData *flexData = UIImagePNGRepresentation(
      [[[UIImage systemImageNamed:@"chevron.left.slash.chevron.right"]
          imageWithTintColor:[UIColor whiteColor]]
          imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);
  SBSApplicationShortcutItem *flexItem =
      [%c(SBSApplicationShortcutItem) alloc];
  flexItem.localizedTitle = @"Flexdecrypt";
  SBSApplicationShortcutCustomImageIcon *icon =
      [[SBSApplicationShortcutCustomImageIcon alloc]
          initWithImagePNGData:flexData];
  [flexItem setIcon:icon];
  flexItem.type = @"com.hearse.flexdecrypt.flex";
  [originalItems addObject:flexItem];
  %orig(originalItems);
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item
    withBundleIdentifier:(NSString *)bundleID
             forIconView:(SBIconView *)iconView {
  if ([[item type] isEqualToString:@"com.hearse.flexdecrypt.flex"]) {
    dispatch_async(
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
          // Background Thread
          FBApplicationInfo *app =
              (FBApplicationInfo *)
                  [[NSClassFromString(@"SBApplicationController")
                       sharedInstance] applicationWithBundleIdentifier:bundleID]
                      .info;
          NSTask *task = [[NSTask alloc] init];
          [task setLaunchPath:@"/usr/bin/flexdecrypt"];
          [task setArguments:@[ app.executableURL.path ]];
          /* NSPipe *pipe = [NSPipe pipe];
          [task setStandardOutput:pipe]; */

          [task launch];
        });
    //TODO:UIAlertController?
    /*
        NSFileHandle *read = [pipe fileHandleForReading];
        NSData *dataRead = [read readDataToEndOfFile];
        NSString *stringRead = [[NSString alloc] initWithData:dataRead
        encoding:NSUTF8StringEncoding];
        NSLog(@"%@",stringRead); */

  } else {
    %orig;
  }
}
%end
