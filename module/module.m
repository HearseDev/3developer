#import "module.h"
#include "alert.h"
#include <UIKit/UIKit.h>
#include <objc/runtime.h>

@implementation DeveloperModule
- (UIImage *)iconGlyph {
  return [UIImage systemImageNamed:@"gear"];
}
- (UIImage *)selectedIconGlyph {
  return [UIImage systemImageNamed:@"gear"];
}
- (UIColor *)selectedColor {
  return [UIColor blueColor];
}
- (BOOL)isSelected {
  return NO;
}

- (void)setSelected:(BOOL)selected {
  ModuleAlertItem *item = [[objc_getClass("ModuleAlertItem") alloc] init];
  [[item class] activateAlertItem:item];
}

@end
