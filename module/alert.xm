#import "alert.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <spawn.h>
#include <rootless.h>

// get the IP address of current-device
 NSString * getIPAddress() {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}
void runCommand(NSString *command, const char *args[]) {
    pid_t pid;
    posix_spawn(&pid, 
    JBROOT_PATH_CSTRING([command UTF8String])
, NULL, NULL, (char * const *)args, NULL);
    
}

%subclass ModuleAlertItem : SBAlertItem


- (void)configure:(BOOL)arg1 requirePasscodeForActions:(BOOL)arg2 {
    UIAlertController *alertController = [self alertController];
    alertController.title = [NSString stringWithFormat: @"IP: %@", getIPAddress()];

    UIAlertAction *sbreloadAction = [UIAlertAction actionWithTitle:@"sbreload"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {


        const char *args[] = {NULL};
        runCommand(@"/usr/bin/sbreload", args);
        [self dismiss];
    }];

    UIAlertAction *urAction = [UIAlertAction actionWithTitle:@"Userspace Reboot" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        const char *args[] = {"launchctl","reboot", "userspace", NULL};
        runCommand(@"/usr/bin/launchctl", args);
        [self dismiss];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self dismiss];
    }];

    [alertController addAction: sbreloadAction];
    [alertController addAction: urAction];
    [alertController addAction: cancelAction];

}

%end
