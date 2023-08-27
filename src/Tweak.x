#import "Tweak.h"
#include <rootless.h>



%group 3D

%hook SBIconView
- (void)setApplicationShortcutItems:(NSArray *)arg1 {
  if ([self.icon isMemberOfClass:objc_getClass("SBWidgetIcon")] || [self isFolderIcon]){
    %orig(arg1);
    return;
  }
  
  // Reduces the use of objc_getClass and also if class names ever change in the future.
  Class ShortcutItemRuntimeClass = objc_getClass("SBSApplicationShortcutItem");
  Class ShortcutIconRuntimeClass = objc_getClass("SBSApplicationShortcutSystemPrivateIcon");
  // Realistically this check is not needed.
  if (!ShortcutItemRuntimeClass || !ShortcutIconRuntimeClass){
    %orig(arg1);
    return;
  }
  
  NSMutableArray *modifiedItems = (arg1) ? [arg1 mutableCopy] : [NSMutableArray new];

  //decrypt
  SBSApplicationShortcutItem *flexItem =
      [ShortcutItemRuntimeClass alloc];
  flexItem.localizedTitle = @"flexdecrypt";
  SBSApplicationShortcutSystemPrivateIcon *flexIcon =
      [[ShortcutIconRuntimeClass alloc]
          initWithSystemImageName:@"chevron.left.slash.chevron.right"];
  [flexItem setIcon:flexIcon];
  flexItem.type = FLEX_BUNDLE_ID;

  //copy bundle id
  SBSApplicationShortcutItem *copyBundleItem =
      [ShortcutItemRuntimeClass alloc];
  copyBundleItem.localizedTitle = @"Copy Bundle ID";
  copyBundleItem.localizedSubtitle = self.applicationBundleIdentifierForShortcuts;
  SBSApplicationShortcutSystemPrivateIcon *copyBundleIcon =
      [[ShortcutIconRuntimeClass alloc]
          initWithSystemImageName:@"app.badge"];
  [copyBundleItem setIcon:copyBundleIcon];
  copyBundleItem.type = COPY_BUNDLE_ID;
  //open bundle
  SBSApplicationShortcutItem *openBundleItem =
      [ShortcutItemRuntimeClass alloc];
  openBundleItem.localizedTitle = @"Open Bundle In Filza";
  SBSApplicationShortcutSystemPrivateIcon *openBundleIcon =
      [[ShortcutIconRuntimeClass alloc]
          initWithSystemImageName:@"doc.zipper"];
  [openBundleItem setIcon:openBundleIcon];
  openBundleItem.type = OPEN_BUNDLE_IN_FILZA_BUNDLE_ID;
  //open container
  SBSApplicationShortcutItem *openContainerItem =
      [ShortcutItemRuntimeClass alloc];
  openContainerItem.localizedTitle = @"Open Container In Filza";
  SBSApplicationShortcutSystemPrivateIcon *openContainerIcon =
      [[ShortcutIconRuntimeClass alloc]
          initWithSystemImageName:@"doc.fill"];
  [openContainerItem setIcon:openContainerIcon];
  openContainerItem.type = OPEN_CONTAINER_IN_FILZA_BUNDLE_ID;
  //info
  SBSApplicationShortcutItem *infoItem =
      [ShortcutItemRuntimeClass alloc];
  infoItem.localizedTitle = @"Info";
  SBSApplicationShortcutSystemPrivateIcon *infoIcon =
      [[ShortcutIconRuntimeClass alloc]
          initWithSystemImageName:@"info"];
  [infoItem setIcon:infoIcon];
  infoItem.type = INFO_BUNDLE_ID;

  [modifiedItems addObject:flexItem];
  [modifiedItems addObject:copyBundleItem];
  [modifiedItems addObject: infoItem];
  [modifiedItems addObject:openContainerItem];
  [modifiedItems addObject:openBundleItem];

  %orig(modifiedItems);
}

+ (void)activateShortcut:(SBSApplicationShortcutItem *)item
    withBundleIdentifier:(NSString *)bundleID
             forIconView:(SBIconView *)iconView {
  if ([[item type] isEqualToString:FLEX_BUNDLE_ID] && bundleID && [bundleID length] != 0) {

    FBApplicationInfo *app =
        (FBApplicationInfo *)[[objc_getClass("SBApplicationController")
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

  } else if ([[item type] isEqualToString: COPY_BUNDLE_ID] && bundleID && [bundleID length] != 0) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = bundleID;

  } else if ([[item type]
                 isEqualToString:OPEN_BUNDLE_IN_FILZA_BUNDLE_ID] && bundleID && [bundleID length] != 0) {

    @try{
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
      if (app && url){
        [[objc_getClass("SpringBoard") sharedApplication] applicationOpenURL:url];
      }
    }@catch(NSException *exception){}

  } else if ([[item type]
                 isEqualToString:OPEN_CONTAINER_IN_FILZA_BUNDLE_ID] && bundleID && [bundleID length] != 0) {
    @try{
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
      if (app && url){
        [[objc_getClass("SpringBoard") sharedApplication] applicationOpenURL:url];
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
          (FBApplicationInfo *)[[objc_getClass("SBApplicationController")
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
  %init(3D)
}
