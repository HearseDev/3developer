#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Additions.h"
#import "DTAppInfoViewController.h"

@implementation DTAppInfoViewController
- (instancetype)initWithApp:(FBApplicationInfo *)app {
  self = [super init];
  if (self) {
    self.app = app;
  }
  return self;
}
- (void)addField:(NSString *)text {
  if (!self.textView.text) {
    self.textView.text = @"";
  }
  if (text) {
    self.textView.text =
        [self.textView.text stringByAppendingFormat:@"%@\n", text];
    [self.textView sizeToFit];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupTextView];
  [self setupConstraints];
}
- (void)setupTextView {
  self.textView = [UITextView new];
  self.textView.translatesAutoresizingMaskIntoConstraints = false;
  self.textView.editable = NO;
  self.textView.scrollEnabled = true;
  @try {
    [self addField:[NSString stringWithFormat:@"isBeta: %d", self.app.beta]];
    [self addField:[NSString stringWithFormat:@"signerIdentity: %@",
                                              self.app.signerIdentity]];
    [self addField:[NSString stringWithFormat:@"sdkVersion: %@",
                                              self.app.sdkVersion]];

    [self addField:[NSString stringWithFormat:@"bundleVersion: %@",
                                              self.app.bundleVersion]];
    [self addField:[NSString stringWithFormat:@"shortVersion: %@",
                                              self.app.shortVersionString]];
    [self addField:[NSString stringWithFormat:@"teamIdentifier: %@",
                                              self.app.teamIdentifier]];

    [self addField:[NSString stringWithFormat:@"bundleURL: %@",
                                              self.app.bundleURL.path]];
    [self
        addField:[NSString stringWithFormat:@"containerURL: %@",
                                            self.app.bundleContainerURL.path]];
    [self
        addField:[NSString
                     stringWithFormat:@"lastModifiedDate: %@",
                                      [NSDate dateWithTimeIntervalSinceNow:
                                                  self.app.lastModifiedDate]]];
    [self addField:[NSString stringWithFormat:@"requiredCapabilities: %@",
                                              self.app.requiredCapabilities]];
    [self addField:[NSString stringWithFormat:@"environmentVariables: %@",
                                              self.app.environmentVariables]];
    [self addField:[NSString stringWithFormat:@"entitlements: %@",
                                              self.app.entitlements]];
  } @catch (NSException *exception) {
    [self addField:[NSString stringWithFormat:@"error occured: %@", exception]];
  }
  [self.textView sizeToFit];
  [self.view addSubview:self.textView];
  self.textView.scrollEnabled = NO;
  self.textView.scrollEnabled = YES;
}
- (void)setupConstraints {
  [self.textView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active =
      YES;
  [self.textView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
      .active = YES;
  [self.textView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]
      .active = YES;
  [self.textView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]
      .active = YES;
}

@end
