#pragma once
@interface DTAppInfoViewController : UIViewController
@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) FBApplicationInfo *app;
- (instancetype)initWithApp:(FBApplicationInfo *)app;
@end
