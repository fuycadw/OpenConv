//
//  GlassWindow.m
//  GlassWindow
//
//  Created by Lee Brimelow on 7/28/13.
//
//  Modified by Cai, Zhi-Wei on 11/18/13.
//

#import "GlassWindow.h"

extern CGError CGSNewCIFilterByName(CGSConnection cid, CFStringRef filterName, CGSWindowFilterRef *outFilter);
extern CGError CGSSetCIFilterValuesFromDictionary(CGSConnection cid, CGSWindowFilterRef filter, CFDictionaryRef filterValues);
extern CGError CGSAddWindowFilter(CGSConnection cid, CGSWindowID wid, CGSWindowFilterRef filter, int flags);

@implementation GlassWindow

- initWithContentRect:(NSRect)contentRect
            styleMask:(NSUInteger)aStyle
              backing:(NSBackingStoreType)bufferingType
                defer:(BOOL)flag;
{
    if ((self = [super initWithContentRect:contentRect
                                 styleMask:aStyle
                                   backing:NSBackingStoreBuffered
                                     defer:flag]) != nil) {
        
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:.7]];
        [self enableBlurForWindow:self];
        [self makeKeyAndOrderFront:nil];
    }
    
    return self;
}

-(id)init {
    self = [super init];
    return self;
}

-(void)enableBlurForWindow:(NSWindow *)window
{
    // Private API
    
    CGSConnection thisConnection;
    uint32_t compositingFilter;
    int compositingType = 1;
    
    /* Make a new connection to CoreGraphics */
    CGSNewConnection(NULL, &thisConnection);
    
    /* Create a CoreImage filter and set it up */
    CGSNewCIFilterByName(thisConnection, (CFStringRef)@"CIGaussianBlur", &compositingFilter);
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:3.0] forKey:@"inputRadius"];
    CGSSetCIFilterValuesFromDictionary(thisConnection, compositingFilter, (__bridge CFDictionaryRef)options);
    
    /* Now apply the filter to the window */
    CGSAddWindowFilter(thisConnection, [window windowNumber], compositingFilter, compositingType);
}

@end
