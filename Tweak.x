#include "Tweak.h"

HBPreferences *preferences;
BOOL kEnabled;
BOOL kFlex;
BOOL kBundleID;
BOOL kOpenBundleInFilza;

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)arg1 {
  NSMutableArray *originalItems = [[NSMutableArray alloc] init];
  for (SBSApplicationShortcutItem *item in arg1) {
    [originalItems addObject:item];
  }

  if (kFlex) {
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
    flexItem.type = @"com.hearse.3developer.flex";
    [originalItems addObject:flexItem];
  }

  if (kBundleID) {
    NSData *bundleData = UIImagePNGRepresentation([[[UIImage
        systemImageNamed:@"app.badge"] imageWithTintColor:[UIColor whiteColor]]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);
    SBSApplicationShortcutItem *bundleItem =
        [%c(SBSApplicationShortcutItem) alloc];
    bundleItem.localizedTitle = @"Copy Bundle ID";
    bundleItem.localizedSubtitle = self.applicationBundleIdentifierForShortcuts;
    SBSApplicationShortcutCustomImageIcon *icon =
        [[SBSApplicationShortcutCustomImageIcon alloc]
            initWithImagePNGData:bundleData];
    [bundleItem setIcon:icon];
    bundleItem.type = @"com.hearse.3developer.bundle";
    [originalItems addObject:bundleItem];
  }
  if (kOpenBundleInFilza) {
    NSData *bundleData = UIImagePNGRepresentation([[[UIImage
        systemImageNamed:@"doc.fill"] imageWithTintColor:[UIColor whiteColor]]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]);
    SBSApplicationShortcutItem *bundleItem =
        [%c(SBSApplicationShortcutItem) alloc];
    bundleItem.localizedTitle = @"Open Bundle In Filza";
    SBSApplicationShortcutCustomImageIcon *icon =
        [[SBSApplicationShortcutCustomImageIcon alloc]
            initWithImagePNGData:bundleData];
    [bundleItem setIcon:icon];
    bundleItem.type = @"com.hearse.3developer.openBundleInFilza";
    [originalItems addObject:bundleItem];
  }

  %orig(originalItems);
}

/* NSString *pathInFilza = [@"filza://view"
   stringByAppendingString:applicationProxy.bundleURL.path];
                [[%c(SpringBoard) sharedApplication]
   applicationOpenURL:[NSURL URLWithString:[pathInFilza
   stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
   URLQueryAllowedCharacterSet]]]]; return NO; */

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item
    withBundleIdentifier:(NSString *)bundleID
             forIconView:(SBIconView *)iconView {
  if ([[item type] isEqualToString:@"com.hearse.3developer.flex"]) {

    FBApplicationInfo *app =
        (FBApplicationInfo *)[[NSClassFromString(@"SBApplicationController")
                                  sharedInstance]
            applicationWithBundleIdentifier:bundleID]
            .info;

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/flexdecrypt"];
    [task setArguments:@[ app.executableURL.path ]];
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];

    [task setTerminationHandler:^(NSTask *task) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NSFileHandle *read = [out fileHandleForReading];
        NSData *dataRead = [read readDataToEndOfFile];
        NSString *stringRead =
            [[NSString alloc] initWithData:dataRead
                                  encoding:NSUTF8StringEncoding];
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Flexdecrypt"
                             message:stringRead
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *dismissAction = [UIAlertAction
            actionWithTitle:@"Dismiss"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action) {
                    }];
        UIAlertAction *filzaAction = [UIAlertAction
            actionWithTitle:@"Open in Filza"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *action) {
                      NSString *decryptedPath = [[NSString alloc]
                          initWithFormat:
                              @"%@",
                              [stringRead
                                  stringByReplacingOccurrencesOfString:
                                      @"Wrote decrypted image to "
                                                            withString:@""]];

                      NSString *pathInFilza = [@"filza://view"
                               stringByAppendingString:decryptedPath];
NSString* trimmedUrlString = [pathInFilza stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                      NSURL *url = [NSURL
                          URLWithString:
                              [trimmedUrlString
                                  stringByAddingPercentEncodingWithAllowedCharacters:
                                      [NSCharacterSet
                                          URLQueryAllowedCharacterSet]]];

                      NSLog(@"NSLogify |%@|", url);
                      [[%c(SpringBoard) sharedApplication]
                          applicationOpenURL:url];
                    }];
        [alert addAction:dismissAction];
        [alert addAction:filzaAction];

        [iconView.window.rootViewController presentViewController:alert
                                                         animated:YES
                                                       completion:nil];
      });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
      [task launch];
    });

  } else if ([[item type] isEqualToString:@"com.hearse.3developer.bundle"]) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = bundleID;

  } else if ([[item type]
                 isEqualToString:@"com.hearse.3developer.openBundleInFilza"]) {

    FBApplicationInfo *app =
        (FBApplicationInfo *)[[NSClassFromString(@"SBApplicationController")
                                  sharedInstance]
            applicationWithBundleIdentifier:bundleID]
            .info;
    NSString *pathInFilza =
        [@"filza://view" stringByAppendingString:app.bundleURL.path];
    NSURL *url = [NSURL
        URLWithString:[pathInFilza
                          stringByAddingPercentEncodingWithAllowedCharacters:
                              [NSCharacterSet URLQueryAllowedCharacterSet]]];
    [[%c(SpringBoard) sharedApplication] applicationOpenURL:url];

  } else {
    %orig;
  }
}
%end

%hook SBHomeScreenViewController

%end

%ctor {
  preferences =
      [[HBPreferences alloc] initWithIdentifier:@"com.hearse.3developerprefs"];
  [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
  [preferences registerBool:&kFlex default:NO forKey:@"kFlexDecrypt"];
  [preferences registerBool:&kBundleID default:NO forKey:@"kCopyBundleID"];
  [preferences registerBool:&kOpenBundleInFilza
                    default:NO
                     forKey:@"kOpenBundleInFilza"];
}
