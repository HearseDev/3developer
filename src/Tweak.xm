#import "Tweak.h"
#include <rootless.h>

%group 3D

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)arg1 {
  if ([self.icon isMemberOfClass:objc_getClass("SBWidgetIcon")] || [self isFolderIcon]){
    %orig(arg1);
    return;
  }

  NSMutableArray *originalItems = [[NSMutableArray alloc] init];

  for (SBSApplicationShortcutItem *item in arg1) {
    [originalItems addObject:item];
  }
    //decrypt
    SBSApplicationShortcutItem *flexItem =
        [%c(SBSApplicationShortcutItem) alloc];
    flexItem.localizedTitle = @"flexdecrypt";
    SBSApplicationShortcutSystemPrivateIcon *flexIcon =
        [[%c(SBSApplicationShortcutSystemPrivateIcon) alloc]
            initWithSystemImageName:@"chevron.left.slash.chevron.right"];
    [flexItem setIcon:flexIcon];
    flexItem.type = FLEX_BUNDLE_ID;
    //copy bundle id
    SBSApplicationShortcutItem *copyBundleItem =
        [%c(SBSApplicationShortcutItem) alloc];
    copyBundleItem.localizedTitle = @"Copy Bundle ID";
    copyBundleItem.localizedSubtitle = self.applicationBundleIdentifierForShortcuts;
    SBSApplicationShortcutSystemPrivateIcon *copyBundleIcon =
        [[%c(SBSApplicationShortcutSystemPrivateIcon) alloc]
            initWithSystemImageName:@"app.badge"];
    [copyBundleItem setIcon:copyBundleIcon];
    copyBundleItem.type = COPY_BUNDLE_ID;
    //open bundle
    SBSApplicationShortcutItem *openBundleItem =
        [%c(SBSApplicationShortcutItem) alloc];
    openBundleItem.localizedTitle = @"Open Bundle In Filza";
    SBSApplicationShortcutSystemPrivateIcon *openBundleIcon =
        [[%c(SBSApplicationShortcutSystemPrivateIcon) alloc]
            initWithSystemImageName:@"doc.zipper"];
    [openBundleItem setIcon:openBundleIcon];
    openBundleItem.type = OPEN_BUNDLE_IN_FILZA_BUNDLE_ID;
    //open container
    SBSApplicationShortcutItem *openContainerItem =
        [%c(SBSApplicationShortcutItem) alloc];
    openContainerItem.localizedTitle = @"Open Container In Filza";
    SBSApplicationShortcutSystemPrivateIcon *openContainerIcon =
        [[%c(SBSApplicationShortcutSystemPrivateIcon) alloc]
            initWithSystemImageName:@"doc.fill"];
    [openContainerItem setIcon:openContainerIcon];
    openContainerItem.type = OPEN_CONTAINER_IN_FILZA_BUNDLE_ID;
    //info
    SBSApplicationShortcutItem *infoItem =
        [%c(SBSApplicationShortcutItem) alloc];
    infoItem.localizedTitle = @"Info";
    SBSApplicationShortcutSystemPrivateIcon *infoIcon =
        [[%c(SBSApplicationShortcutSystemPrivateIcon) alloc]
            initWithSystemImageName:@"info"];
    [infoItem setIcon:infoIcon];
    infoItem.type = INFO_BUNDLE_ID;

    [originalItems addObject:flexItem];
    [originalItems addObject:copyBundleItem];
    [originalItems addObject: infoItem];
    [originalItems addObject:openContainerItem];
    [originalItems addObject:openBundleItem];


    %orig(originalItems);
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item
    withBundleIdentifier:(NSString *)bundleID
             forIconView:(SBIconView *)iconView {
  if ([[item type] isEqualToString:FLEX_BUNDLE_ID] && bundleID && [bundleID length] != 0) {

    FBApplicationInfo *app =
        (FBApplicationInfo *)[[NSClassFromString(@"SBApplicationController")
                                  sharedInstance]
            applicationWithBundleIdentifier:bundleID]
            .info;

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:ROOT_PATH_NS_VAR(@"/usr/bin/flexdecrypt")];
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

  } else if ([[item type] isEqualToString: COPY_BUNDLE_ID] && bundleID && [bundleID length] != 0) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = bundleID;

  } else if ([[item type]
                 isEqualToString:OPEN_BUNDLE_IN_FILZA_BUNDLE_ID] && bundleID && [bundleID length] != 0) {

    @try{
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
      if (app && url){
        [[%c(SpringBoard) sharedApplication] applicationOpenURL:url];
      }
    }@catch(NSException *exception){}

  } else if ([[item type]
                 isEqualToString:OPEN_CONTAINER_IN_FILZA_BUNDLE_ID] && bundleID && [bundleID length] != 0) {
    @try{
      FBApplicationInfo *app =
          (FBApplicationInfo *)[[NSClassFromString(@"SBApplicationController")
                                    sharedInstance]
              applicationWithBundleIdentifier:bundleID]
              .info;
      NSString *pathInFilza =
          [@"filza://view" stringByAppendingString:app.dataContainerURL.path];
      NSURL *url = [NSURL
          URLWithString:[pathInFilza
                            stringByAddingPercentEncodingWithAllowedCharacters:
                                [NSCharacterSet URLQueryAllowedCharacterSet]]];
      if (app && url){
        [[%c(SpringBoard) sharedApplication] applicationOpenURL:url];
      }
  }@catch(NSException *exception){}
  }else if ([[item type]
                 isEqualToString:INFO_BUNDLE_ID] && bundleID && [bundleID length] != 0) {

    UIWindow *keyWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            keyWindow = window;
            break;
        }
    }

    @try{
      if (keyWindow){
        FBApplicationInfo *app =
          (FBApplicationInfo *)[[NSClassFromString(@"SBApplicationController")
                                    sharedInstance]
              applicationWithBundleIdentifier:bundleID]
              .info;
        if (app){
          DTAppInfoViewController *infoVC = [[DTAppInfoViewController alloc]initWithApp:app];
          [keyWindow.rootViewController presentViewController:infoVC animated:YES completion:NULL];
        }
      }
    }@catch(NSException *exception){}

  }else {
    %orig;
  }
}
%end
%end

%ctor{
  if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]){
    %init(3D)
  }
}
