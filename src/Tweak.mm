#import "Tweak.h"
#import <objc/runtime.h>
#import <rootless.h>

SBSApplicationShortcutItem *createShortcutItem(NSString *localizedTitle,
                                               NSString *localizedSubtitle,
                                               NSString *iconName,
                                               NSString *type) {
  SBSApplicationShortcutItem *item =
      [objc_getClass("SBSApplicationShortcutItem") alloc];
  item.localizedTitle = localizedTitle;
  item.localizedSubtitle = localizedSubtitle;
  SBSApplicationShortcutSystemPrivateIcon *icon =
      [[objc_getClass("SBSApplicationShortcutSystemPrivateIcon") alloc]
          initWithSystemImageName:iconName];
  [item setIcon:icon];
  item.type = type;
  return item;
}

void showErrorAlert(NSString *title, NSString *message,
                    UIViewController *presentingVC) {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:title
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *dismissAction =
      [UIAlertAction actionWithTitle:@"Dismiss"
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action){
                             }];
  [alert addAction:dismissAction];

  [presentingVC presentViewController:alert animated:YES completion:nil];
}

// %hook SBIconView
void (*orig_setApplicationShortcutItems)(SBIconView *, SEL, NSArray *);
void setApplicationShortcutItems(SBIconView *self, SEL _cmd, NSArray *arg1) {
  if ([self.icon isMemberOfClass:objc_getClass("SBWidgetIcon")] ||
      [self isFolderIcon]) {
    orig_setApplicationShortcutItems(self, _cmd, arg1);
    return;
  }
  NSMutableArray *modifiedItems =
      (arg1) ? [arg1 mutableCopy] : [NSMutableArray new];
  SBSApplicationShortcutItem *flexItem = createShortcutItem(
      @"flexdecrypt", nil, @"chevron.left.slash.chevron.right", FLEX_BUNDLE_ID);
  SBSApplicationShortcutItem *copyBundleItem = createShortcutItem(
      @"Copy Bundle ID", self.applicationBundleIdentifierForShortcuts,
      @"app.badge", COPY_BUNDLE_ID);
  SBSApplicationShortcutItem *openBundleItem =
      createShortcutItem(@"Open Bundle In Filza", nil, @"doc.zipper",
                         OPEN_BUNDLE_IN_FILZA_BUNDLE_ID);
  SBSApplicationShortcutItem *openContainerItem =
      createShortcutItem(@"Open Container In Filza", nil, @"doc.fill",
                         OPEN_CONTAINER_IN_FILZA_BUNDLE_ID);
  SBSApplicationShortcutItem *infoItem =
      createShortcutItem(@"Info", nil, @"info", INFO_BUNDLE_ID);
  SBSApplicationShortcutItem *choicyItem =
      createShortcutItem(@"Open Choicy", nil, @"info", CHOICY_BUNDLE_ID);

  [modifiedItems addObject:flexItem];
  [modifiedItems addObject:copyBundleItem];
  [modifiedItems addObject:infoItem];
  [modifiedItems addObject:openContainerItem];
  [modifiedItems addObject:openBundleItem];
  [modifiedItems addObject:choicyItem];

  orig_setApplicationShortcutItems(self, _cmd, modifiedItems);
}

void (*orig_activateShortcut)(SBIconView *, SEL, SBSApplicationShortcutItem *,
                              NSString *, SBIconView *);
void activateShortcut(SBIconView *self, SEL _cmd,
                      SBSApplicationShortcutItem *item, NSString *bundleID,
                      SBIconView *iconView) {
  if ([[item type] isEqualToString:FLEX_BUNDLE_ID] && bundleID &&
      [bundleID length] != 0) {

    FBApplicationInfo *app =
        (FBApplicationInfo *)[[objc_getClass("SBApplicationController")
                                  sharedInstance]
            applicationWithBundleIdentifier:bundleID]
            .info;
    if (access(ROOT_PATH("/usr/bin/flexdecrypt"), F_OK) != 0) {
      UIAlertController *alert = [UIAlertController
          alertControllerWithTitle:@"flexdecrypt"
                           message:[NSString
                                       stringWithFormat:
                                           @"%s not found",
                                           ROOT_PATH("/usr/bin/flexdecrypt")]
                    preferredStyle:UIAlertControllerStyleAlert];

      UIAlertAction *dismissAction =
          [UIAlertAction actionWithTitle:@"Dismiss"
                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action){
                                 }];
      [alert addAction:dismissAction];

      [iconView.window.rootViewController presentViewController:alert
                                                       animated:YES
                                                     completion:nil];
      return;
    }

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:ROOT_PATH_NS(@"/usr/bin/flexdecrypt")];
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
            alertControllerWithTitle:@"flexdecrypt"
                             message:stringRead
                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *dismissAction =
            [UIAlertAction actionWithTitle:@"Dismiss"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action){
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
                      NSString *trimmedUrlString = [pathInFilza
                          stringByTrimmingCharactersInSet:
                              [NSCharacterSet
                                  whitespaceAndNewlineCharacterSet]];
                      NSURL *url = [NSURL
                          URLWithString:
                              [trimmedUrlString
                                  stringByAddingPercentEncodingWithAllowedCharacters:
                                      [NSCharacterSet
                                          URLQueryAllowedCharacterSet]]];

                      NSLog(@"NSLogify |%@|", url);
                      [[objc_getClass("SpringBoard") sharedApplication]
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

  } else if ([[item type] isEqualToString:COPY_BUNDLE_ID] && bundleID &&
             [bundleID length] != 0) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = bundleID;

  } else if ([[item type] isEqualToString:OPEN_BUNDLE_IN_FILZA_BUNDLE_ID] &&
             bundleID && [bundleID length] != 0) {

    @try {
      FBApplicationInfo *app =
          (FBApplicationInfo *)[[objc_getClass("SBApplicationController")
                                    sharedInstance]
              applicationWithBundleIdentifier:bundleID]
              .info;
      NSString *pathInFilza =
          [@"filza://view" stringByAppendingString:app.bundleURL.path];
      NSURL *url = [NSURL
          URLWithString:[pathInFilza
                            stringByAddingPercentEncodingWithAllowedCharacters:
                                [NSCharacterSet URLQueryAllowedCharacterSet]]];
      if (app && url) {
        if ([[objc_getClass("SpringBoard") sharedApplication] canOpenURL:url] ==
            NO) {
          showErrorAlert(@"Filza Not Installed",
                         @"Filza File Manager is not installed on this device.",
                         iconView.window.rootViewController);

          return;
        }

        [[objc_getClass("SpringBoard") sharedApplication]
            applicationOpenURL:url];
      }
    } @catch (NSException *exception) {
    }

  } else if ([[item type] isEqualToString:OPEN_CONTAINER_IN_FILZA_BUNDLE_ID] &&
             bundleID && [bundleID length] != 0) {
    @try {
      FBApplicationInfo *app =
          (FBApplicationInfo *)[[objc_getClass("SBApplicationController")
                                    sharedInstance]
              applicationWithBundleIdentifier:bundleID]
              .info;
      NSString *pathInFilza =
          [@"filza://view" stringByAppendingString:app.dataContainerURL.path];
      NSURL *url = [NSURL
          URLWithString:[pathInFilza
                            stringByAddingPercentEncodingWithAllowedCharacters:
                                [NSCharacterSet URLQueryAllowedCharacterSet]]];
      if (app && url) {
        if ([[objc_getClass("SpringBoard") sharedApplication] canOpenURL:url] ==
            NO) {
          showErrorAlert(@"Filza Not Installed",
                         @"Filza File Manager is not installed on this device.",
                         iconView.window.rootViewController);

          return;
        }
        [[objc_getClass("SpringBoard") sharedApplication]
            applicationOpenURL:url];
      }
    } @catch (NSException *exception) {
    }
  } else if ([[item type] isEqualToString:INFO_BUNDLE_ID] && bundleID &&
             [bundleID length] != 0) {

    UIWindow *keyWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
      if (window.isKeyWindow) {
        keyWindow = window;
        break;
      }
    }

    @try {
      if (keyWindow) {
        FBApplicationInfo *app =
            (FBApplicationInfo *)[[objc_getClass("SBApplicationController")
                                      sharedInstance]
                applicationWithBundleIdentifier:bundleID]
                .info;
        if (app) {
          DTAppInfoViewController *infoVC =
              [[DTAppInfoViewController alloc] initWithApp:app];
          [keyWindow.rootViewController presentViewController:infoVC
                                                     animated:YES
                                                   completion:NULL];
        }
      }
    } @catch (NSException *exception) {
    }
  } else if ([[item type] isEqualToString:CHOICY_BUNDLE_ID] && bundleID &&
             [bundleID length] != 0) {

    if ([[NSFileManager defaultManager]
            fileExistsAtPath:ROOT_PATH_NS(
                                 @"/Library/MobileSubstrate/DynamicLibraries/"
                                 @"ChoicySB.dylib")] == NO) {
      showErrorAlert(@"Choicy Not Installed",
                     @"Choicy is not installed on this device.",
                     iconView.window.rootViewController);
      return;
    }

    [[objc_getClass("SpringBoard") sharedApplication]
        applicationOpenURL:
            [NSURL
                URLWithString:[NSString
                                  stringWithFormat:
                                      @"prefs:root=Choicy&path=APPLICATIONS/%@",
                                      bundleID]]];
  } else {
    orig_activateShortcut(self, _cmd, item, bundleID, iconView);
  }
}

void replaceMethod(Class cls, SEL sel, void *replacement, void *orig) {
  Method orig_met = class_getInstanceMethod(cls, sel);
  IMP orig_imp = method_getImplementation(orig_met);
  *(IMP *)orig = orig_imp;
  class_replaceMethod(cls, sel, (IMP)replacement,
                      method_getTypeEncoding(orig_met));
}

void __attribute((constructor)) load() {
  replaceMethod(objc_getClass("SBIconView"),
                @selector(setApplicationShortcutItems:),
                (void *)setApplicationShortcutItems,
                (void *)&orig_setApplicationShortcutItems);

  replaceMethod(objc_getMetaClass("SBIconView"),
                @selector(activateShortcut:withBundleIdentifier:forIconView:),
                (void *)activateShortcut, (void *)&orig_activateShortcut);
}
