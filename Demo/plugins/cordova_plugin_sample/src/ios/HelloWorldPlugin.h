#import <Cordova/CDVPlugin.h>

@interface HelloWorldPlugin : CDVPlugin

- (void) say:(CDVInvokedUrlCommand*)command;

@end