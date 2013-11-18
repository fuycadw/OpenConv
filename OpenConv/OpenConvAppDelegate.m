//
//  OpenConvAppDelegate.m
//  OpenConv
//
//  Copyright (c) 2013 Cai, Zhi-Wei. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "OpenConvAppDelegate.h"

@implementation OpenConvAppDelegate

@synthesize win_mainWindow=_win_mainWindow;

//@synthesize dict_UserDefaults;

#pragma mark - Basic

+ (void) initialize
{
    // Hello world! :D
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Debug Output.
    [self openConvErrorLog:@"DEBUG MODE."];
    
    // Push things via Notification Center.
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    
    // Define objects.
    BOOL            bool_olderUserDefaultsVersionExisted;
    NSDecimalNumber *string_UserDefaultsVersionCurrent, *string_UserDefaultsVersionExisted;
    
    // Gathering information.
    defaults_UserDefaults = [NSUserDefaults standardUserDefaults];
    string_UserDefaultsVersionCurrent = [NSDecimalNumber decimalNumberWithString:define_UserDefaultsVersion];
    string_UserDefaultsVersionExisted = [NSDecimalNumber decimalNumberWithString:
                                         [defaults_UserDefaults objectForKey:@"UserDefaultsVersion"]];
    bool_olderUserDefaultsVersionExisted = [[string_UserDefaultsVersionCurrent decimalNumberBySubtracting:string_UserDefaultsVersionExisted] boolValue];
    
    // Reset UserDefaults for older versions if needed.
    if ( define_UserDefaultsResetIsNeeded && bool_olderUserDefaultsVersionExisted ) {
        [defaults_UserDefaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        defaults_UserDefaults = [NSUserDefaults standardUserDefaults];
        // Debug Output.
        [self openConvErrorLog:@"UserDefaults Reset"];
    }
    
    // Create default UserDefaults values
    NSDictionary *dict_userDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:NO],    @"DisableNotificationCenter",
                                       [NSNumber numberWithBool:NO],    @"DisableUTF8Output",
                                       [NSNumber numberWithBool:NO],    @"ForceChineseSimplifiedOutput",
                                       [NSNumber numberWithBool:NO],    @"ForceChineseTraditionalInput",
                                       [NSNumber numberWithBool:YES],   @"PasteboardConversionEnabled",
                                       [NSNumber numberWithBool:NO],    @"RightClickPasteboardChineseTraditional",
                                       define_UserDefaultsVersion,      @"UserDefaultsVersion",
                                       nil];
    // Debug Output.
    [self openConvErrorLog:[NSString stringWithFormat:@"UserDefaults Dictionary: %@", dict_userDefaults]];
    
    // Updating the UserDefaults for newly add keys.
    id id_key;
    NSEnumerator *enum_keys = [dict_userDefaults keyEnumerator];
    
    while ( (id_key = [enum_keys nextObject]) ) {
        if ( ![defaults_UserDefaults objectForKey:id_key] ) {
            // Debug Output.
            [self openConvErrorLog:[NSString stringWithFormat:@"Adding UserDefaults: %@",
                                    [dict_userDefaults objectForKey:id_key]]];
            [defaults_UserDefaults setObject:[dict_userDefaults objectForKey:id_key]
                                      forKey:id_key];
        }
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // TBA.
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    // Push things via Notification Center.
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    // Shut down the application when the main window closed.
	return YES;
}

- (void)awakeFromNib
{
    // Store current window position.
    [_win_mainWindow setFrameUsingName: @"WindowFrame"];
    [_win_mainWindow setFrameAutosaveName: @"WindowFrame"];
    [_win_mainWindow setLevel:NSFloatingWindowLevel];
    
    // Define objects.
    BOOL            bool_olderUserDefaultsVersionExisted;
    NSDecimalNumber *string_UserDefaultsVersionCurrent, *string_UserDefaultsVersionExisted;
    
    // Gathering information.
    defaults_UserDefaults = [NSUserDefaults standardUserDefaults];
    string_UserDefaultsVersionCurrent = [NSDecimalNumber decimalNumberWithString:define_UserDefaultsVersion];
    string_UserDefaultsVersionExisted = [NSDecimalNumber decimalNumberWithString:
                                         [defaults_UserDefaults objectForKey:@"UserDefaultsVersion"]];
    bool_olderUserDefaultsVersionExisted = [string_UserDefaultsVersionCurrent intValue] - [string_UserDefaultsVersionExisted intValue];
    
    // Reset UserDefaults for older versions if needed.
    if ( define_UserDefaultsResetIsNeeded && bool_olderUserDefaultsVersionExisted ) {
        [defaults_UserDefaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        defaults_UserDefaults = [NSUserDefaults standardUserDefaults];
        // Debug Output.
        [self openConvErrorLog:@"UserDefaults Reset"];
    }
    
    // Create default UserDefaults values
    NSDictionary *dict_userDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:NO],    @"DisableNotificationCenter",
                                       [NSNumber numberWithBool:NO],    @"DisableUTF8Output",
                                       [NSNumber numberWithBool:NO],    @"ForceChineseSimplifiedOutput",
                                       [NSNumber numberWithBool:NO],    @"ForceChineseTraditionalInput",
                                       [NSNumber numberWithBool:YES],   @"PasteboardConversionEnabled",
                                       [NSNumber numberWithBool:NO],    @"RightClickPasteboardChineseTraditional",
                                       define_UserDefaultsVersion,      @"UserDefaultsVersion",
                                       nil];
    // Debug Output.
    [self openConvErrorLog:[NSString stringWithFormat:@"UserDefaults Dictionary: %@", dict_userDefaults]];
    
    // Updating the UserDefaults for newly add keys.
    id id_key;
    NSEnumerator *enum_keys = [dict_userDefaults keyEnumerator];
    
    while ( (id_key = [enum_keys nextObject]) ) {
        if ( ![defaults_UserDefaults objectForKey:id_key] ) {
            // Debug Output.
            [self openConvErrorLog:[NSString stringWithFormat:@"Adding UserDefaults: %@",
                                    [dict_userDefaults objectForKey:id_key]]];
            [defaults_UserDefaults setObject:[dict_userDefaults objectForKey:id_key]
                                      forKey:id_key];
        }
    }
}


#pragma mark - Misc

- (IBAction)goToGithub:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:define_githubURL]];
}

- (void)openConvErrorLog:(NSString *)anError
{
    // Display debug information if in debug mode.
#ifdef DEBUG
    NSLog(@"[OpenConv Debug] %@", anError);
#endif
}

@end
