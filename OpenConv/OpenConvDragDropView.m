//
//  OpenConvDragDropView.m
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

#import "OpenConvDragDropView.h"

@implementation OpenConvDragDropView

@synthesize textField_zoneLabel=_textField_zoneLabel;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        // Gathering information.
        mutDict_convertTable = [[NSMutableDictionary alloc] initWithContentsOfFile:
                                [[NSBundle mainBundle] pathForResource:@"ConvertTable"
                                                                ofType:@"plist"]];
        defaults_UserDefaults = [NSUserDefaults standardUserDefaults];
        
        // Debug Output.
        [self openConvErrorLog:[NSString stringWithFormat:@"Convert Table = %@", mutDict_convertTable]];
        
        // Show hints.
        [_textField_zoneLabel setStringValue:NSLocalizedString(@"LABEL_DROP_FILES_TO_STRAT_CONVERTING", nil)];
        
        // Initialization deag and drop functions.
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
        
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	[super drawRect:dirtyRect];
}


#pragma mark - Dragging Operations

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    
    // Define objects.
	NSPasteboard    *pboard;
	NSDragOperation sourceDragMask;
    
    // Show hints.
    [_textField_zoneLabel setStringValue:NSLocalizedString(@"LABEL_CONVERTING_PLEASE_WAIT", nil)];
    
    // Disable the drag'n drop zone until current conversion is done.
    [self setEnabled:NO];
    
    // Gathering information.
	sourceDragMask  = [sender draggingSourceOperationMask];
	pboard          = [sender draggingPasteboard];
    
	if ([sender draggingSource] != self) {
        
		if ([[pboard types] containsObject:NSFilenamesPboardType]) {
            
            // Define objects.
            BOOL    isNameMode;
            long    i, c, count;
            NSDate  *stopWatchBeigns;
			NSArray *files;
            
            // Gathering information.
            isNameMode      = [defaults_UserDefaults boolForKey:@"NameMode"];
            stopWatchBeigns = [NSDate date];
			files           = [pboard propertyListForType:NSFilenamesPboardType];
            c               = 1;
            count           = [files count];
            
            // Debug Output.
            [self openConvErrorLog:[NSString stringWithFormat:@"Name Mode: %li", (long)isNameMode]];
            
            for ( i = 0; i < count; i++, c++) {
                
                // Show hints.
                [_textField_zoneLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"LABEL_CONVERTING_PLEASE_WAIT", nil), i, count]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @autoreleasepool {
                        
                        // Define objects.
                        BOOL                bool_isCht;
                        NSError             *error;
                        NSString            *filePath, *inputType, *outputType, *textData;
                        NSStringEncoding    enc;
                        NSDictionary        *zhTable;
                        
                        // Gathering information.
                        bool_isCht  = YES;
                        error       = nil;
                        filePath    = [files objectAtIndex:i];
                        inputType   = NSLocalizedString(@"FILE_ENCODING_TYPE_UNKNOWN", nil);
                        outputType  = @"";
                        
                        if (isNameMode) {
                            bool_isCht  = ![defaults_UserDefaults boolForKey:@"ForceChineseSimplifiedOutput"];
                            textData    = [NSString stringWithString:[[filePath lastPathComponent] stringByDeletingPathExtension]];
                            
                            // Debug Output.
                            [self openConvErrorLog:[NSString stringWithFormat:@"Name Mode textData: %@", textData]];
                            
                        } else {
                            
                            // Debug Output.
                            [self openConvErrorLog:@"Trying GB-18030"];
                            
                            enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                            textData = [[NSString alloc] initWithContentsOfFile:filePath
                                                                       encoding:enc
                                                                          error:&error];
                            
                            // Debug Output.
                            [self openConvErrorLog:[NSString stringWithFormat:@"Error: %@", error]];
                            
                            if ( error ||
                                [defaults_UserDefaults boolForKey:@"ForceChineseTraditionalInput"]) {
                                
                                // Debug Output.
                                [self openConvErrorLog:@"Trying Big-5"];
                                
                                inputType = NSLocalizedString(@"FILE_ENCODING_TYPE_BIG5", nil);
                                error = nil;
                                enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
                                textData = [[NSString alloc] initWithContentsOfFile:filePath
                                                                           encoding:enc
                                                                              error:&error];
                                if( error ) {
                                    
                                    // Debug Output.
                                    [self openConvErrorLog:@"Trying UTF-8"];
                                    
                                    inputType = NSLocalizedString(@"FILE_ENCODING_TYPE_UTF8", nil);
                                    error = nil;
                                    enc = NSUTF8StringEncoding;
                                    textData = [[NSString alloc] initWithContentsOfFile:filePath
                                                                               encoding:enc
                                                                                  error:&error];
                                } else {
                                    bool_isCht = NO;
                                }
                                
                                if( error ) {
                                    
                                    // Debug Output.
                                    [self openConvErrorLog:@"Trying UTF-16"];
                                    
                                    inputType = NSLocalizedString(@"FILE_ENCODING_TYPE_UTF16", nil);
                                    error = nil;
                                    enc = NSUTF16StringEncoding;
                                    textData = [[NSString alloc] initWithContentsOfFile:filePath
                                                                               encoding:enc
                                                                                  error:&error];
                                }
                                
                                if ( [defaults_UserDefaults boolForKey:@"ForceChineseSimplifiedOutput"] ) {
                                    
                                    // Debug Output.
                                    [self openConvErrorLog:@"Force CHT -> CHS Mode."];
                                    bool_isCht = NO;
                                }
                                
                            } else {
                                
                                inputType = NSLocalizedString(@"FILE_ENCODING_TYPE_GB18030", nil);
                                
                            }
                        }
                        
                        zhTable = [self zhTableWithReverse:!bool_isCht];
                        outputType = (bool_isCht) ? @"cht" : @"chs";
                        
                        if( error ) {
                            
                            // Debug Output.
                            [self openConvErrorLog:[NSString stringWithFormat:@"Error: %@", error]];
                            
                            [self showNotification:NSLocalizedString(@"LABEL_NOTIFICATION_ERROR_TITLE", nil)
                                          subtitle:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_PROGRESS_INFO_TEXT", nil), c, count, inputType]
                                   informativeText:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_ERROR_INFO_TEXT", nil), [[filePath lastPathComponent] stringByDeletingPathExtension]]
                                         soundName:NSUserNotificationDefaultSoundName];
                        } else {
                            
                            // Define objects.
                            long        j, textLen;
                            NSString    *saveName;
                            
                            // Gathering information.
                            textLen = [textData length];
                            
                            for (j = 0; j < textLen; j++) {
                                
                                NSString *c = [zhTable objectForKey:[textData substringWithRange:NSMakeRange(j, 1)]];
                                if (c != nil) {
                                    textData = [textData stringByReplacingCharactersInRange:NSMakeRange(j, 1) withString:c];
                                }
                            }
                            
                            if (isNameMode) {
                                
                                NSString *newPath;
                                
                                newPath = [NSString stringWithFormat:@"%@/%@.%@",
                                           [filePath stringByDeletingLastPathComponent],
                                           textData,
                                           [filePath pathExtension]];;
                                [[NSFileManager defaultManager] moveItemAtPath:filePath
                                                                        toPath:newPath
                                                                         error:nil];
                                
                                // Debug Output.
                                [self openConvErrorLog:[NSString stringWithFormat:@"Name Mode New Path: %@", newPath]];
                                
                            } else {
                                
                                NSStringEncoding enc;
                                
                                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DisableUTF8Output"]) {
                                    
                                    // Debug Output.
                                    [self openConvErrorLog:[NSString stringWithFormat:@"Big-5/GB-18030 Output Mode: %@", outputType]];
                                    
                                    enc = (bool_isCht) ? CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5) : CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                                    outputType = [NSString stringWithFormat:@"%@.%@",
                                                  outputType,
                                                  (bool_isCht) ? @"big5" : @"gb"];
                                    
                                } else {
                                    
                                    enc = NSUTF8StringEncoding;
                                    outputType = [NSString stringWithFormat:@"%@.utf8",
                                                  outputType];
                                    
                                }
                                
                                saveName = [NSString stringWithFormat:@"%@.%@.%@",
                                            [filePath stringByDeletingPathExtension],
                                            outputType,
                                            [filePath pathExtension]];
                                
                                [[[NSData alloc] initWithData:[textData dataUsingEncoding:enc
                                                                     allowLossyConversion:YES]]
                                 writeToFile:saveName
                                 atomically:YES];
                                
                            }
                            
                            [self showNotification:NSLocalizedString(@"LABEL_NOTIFICATION_TITLE", nil)
                                          subtitle:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_PROGRESS_INFO_TEXT", nil),
                                                    c,
                                                    count,
                                                    inputType]
                                   informativeText:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_INFO_TEXT", nil),
                                                    [[filePath lastPathComponent] stringByDeletingPathExtension]]
                                         soundName:NSUserNotificationDefaultSoundName];
                            
                        }
                    }
                });
                
            }
            
            [self showNotification:NSLocalizedString(@"LABEL_NOTIFICATION_COMPLIETE_TITLE", nil)
                          subtitle:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_COMPLIETE_PROGRESS_INFO_TEXT", nil),
                                    [[NSDate date] timeIntervalSinceDate:stopWatchBeigns]]
                   informativeText:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_COMPLIETE_INFO_TEXT", nil),
                                    count]
                         soundName:NSUserNotificationDefaultSoundName];
            
            // Show hints.
            [_textField_zoneLabel setTextColor:[NSColor alternateSelectedControlColor]];
            [_textField_zoneLabel setStringValue:NSLocalizedString(@"LABEL_DRAG_FILES_HERE_TO_START", nil)];
            
            // Re-enable the view.
            [self setEnabled:YES];
        }
	}
    
	return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    // Show hints.
    [_textField_zoneLabel setStringValue:NSLocalizedString(@"LABEL_DROP_FILES_TO_STRAT_CONVERTING", nil)];
    
	NSPasteboard *pboard;
	NSDragOperation sourceDragMask;
    
	sourceDragMask = [sender draggingSourceOperationMask];
	pboard = [sender draggingPasteboard];
    
	if ([[pboard types] containsObject:NSFilenamesPboardType]) {
		if (sourceDragMask & NSDragOperationLink) {
			return NSDragOperationLink;
		}
	}
	return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    // Show hints.
    [_textField_zoneLabel setStringValue:NSLocalizedString(@"LABEL_DRAG_FILES_HERE_TO_START", nil)];
}


#pragma mark - Mouse Operations

- (void)mouseUp:(NSEvent *)theEvent
{
    if (!self.isEnabled) return;
    if([theEvent clickCount] == 2) {
        
        // Debug Output.
        [self openConvErrorLog:@"Double Click!"];
        [self pastebardConversion:NO];
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    if (!self.isEnabled) return;
    if([theEvent clickCount] == 2) {
        
        // Debug Output.
        [self openConvErrorLog:@"Double Right-Click!"];
        [self pastebardConversion:YES];
    }
}


#pragma mark - Pastebard Operations

- (void)pastebardConversion:(BOOL)isRightClick
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PasteboardConversionEnabled"]) {

        // Debug Output.
        [self openConvErrorLog:@"Pastebard Conversion!"];
        
        // Define objects.
        BOOL            bool_toCht;
        NSPasteboard    *pasteboard;
        NSDictionary    *zhTable;
        NSString        *textData;
        
        bool_toCht = [defaults_UserDefaults boolForKey:@"RightClickPasteboardChineseTraditional"];
        
        if (!isRightClick) bool_toCht = !bool_toCht;
        
        pasteboard  = [NSPasteboard generalPasteboard];
        zhTable     = [self zhTableWithReverse:bool_toCht];
        textData    = [pasteboard stringForType:NSPasteboardTypeString];

        // Debug Output.
        [self openConvErrorLog:[NSString stringWithFormat:@"Pastebard to CHT: %i", bool_toCht]];
        
        if (textData != nil) {
            
            // Define objects.
            long    i, textLen;
            NSDate  *stopWatchBeigns;
            
            textLen         = [textData length];
            stopWatchBeigns = [NSDate date];
            
            [self setEnabled:NO];
            
            for (i = 0; i < textLen; i++) {
                
                NSString *c = [zhTable objectForKey:[textData substringWithRange:NSMakeRange(i, 1)]];
                if (c != nil) {
                    textData = [textData stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:c];
                }
            }
            
            [self showNotification:NSLocalizedString(@"LABEL_NOTIFICATION_PASTEBOARD_TITLE", nil)
                          subtitle:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_PASTEBOARD_INFO_TEXT", nil), [[NSDate date] timeIntervalSinceDate:stopWatchBeigns]]
                   informativeText:[NSString stringWithFormat:NSLocalizedString(@"LABEL_NOTIFICATION_PASTEBOARD_PROGRESS_INFO_TEXT", nil),
                                    (bool_toCht) ? NSLocalizedString(@"LABEL_CHINESE_TRADITIONAL", nil) : NSLocalizedString(@"LABEL_CHINESE_SIMPLIFIED", nil),
                                    (!bool_toCht) ? NSLocalizedString(@"LABEL_CHINESE_TRADITIONAL", nil) : NSLocalizedString(@"LABEL_CHINESE_SIMPLIFIED", nil)]
                         soundName:NSUserNotificationDefaultSoundName];
            
            [self setEnabled:YES];
        }
        
        [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [pasteboard setString:textData forType:NSStringPboardType];
    }
}


#pragma mark - Table Handling

- (NSDictionary *)zhTableWithReverse:(BOOL)isRevered
{
    
    NSDictionary *dict_zhTable;
    
    dict_zhTable = [NSDictionary dictionaryWithDictionary:mutDict_convertTable];
    
    // Return the table accordingly.
    if (isRevered) {
        return [NSDictionary dictionaryWithObjects:[dict_zhTable allKeys] forKeys:[dict_zhTable allValues]];
    }
    return dict_zhTable;
}


#pragma mark - Notification Center

- (void)showNotification:(NSString *)title subtitle:(NSString *)subtitle informativeText:(NSString *)informativeText soundName:(NSString *)soundName
{
    NSUserNotification *notification;
    
    notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.subtitle = subtitle;
    notification.informativeText = informativeText;
    notification.soundName = soundName;
    
    // Debug Output.
    [self openConvErrorLog:@"Notification Received!"];
    
    // Show notifications accordingly.
    if ( ![defaults_UserDefaults boolForKey:@"DisableNotificationCenter"] ) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}


#pragma mark - Misc

- (void)openConvErrorLog:(NSString *)anError
{
    // Display debug information if in debug mode.
#ifdef DEBUG
    NSLog(@"[OpenConv Debug] %@", anError);
#endif
}

@end
