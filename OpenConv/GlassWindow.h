//
//  GlassWindow.h
//  GlassWindow
//
//  Created by Lee Brimelow on 7/28/13.
//
//  Modified by Cai, Zhi-Wei on 11/18/13.
//

#import <Cocoa/Cocoa.h>

typedef     uint32_t    CGSWindowFilterRef;
typedef     long        CGSWindowID;
typedef     void        *CGSConnection;
extern      OSStatus    CGSNewConnection(const void **attributes, CGSConnection * id);

@interface GlassWindow : NSWindow

-(void)enableBlurForWindow:(NSWindow *)window;

@end
