#import <Foundation/Foundation.h>
#import "TDPRootListController.h"

@implementation TDPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (instancetype)init {
	self = [super init];

	if(self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = [UIColor colorWithRed: 0.84 green: 0.66 blue: 0.87 alpha: 1.00];;
		appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
		self.hb_appearanceSettings = appearanceSettings;

		self.applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply"
															style:UIBarButtonItemStylePlain
														   target:self
														   action:@selector(apply:)];
		self.applyButton.tintColor = [UIColor colorWithRed: 0.84 green: 0.66 blue: 0.87 alpha: 1.00];
		self.navigationItem.rightBarButtonItem = self.applyButton;
	}

	return self;
}

-(void)apply:(id)sender {
    [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=3developerprefs"]];
}

-(void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/HearseDev/3developer"] options:@{} completionHandler:nil];
}

-(void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/HearseDev"] options:@{} completionHandler:nil];
}

@end
