/*  File Version: 3.0
 *	Copyright David Book, buzztouch.com
 *
 *	All rights reserved.
 *
 *	Redistribution and use in source and binary forms, with or without modification, are 
 *	permitted provided that the following conditions are met:
 *
 *	Redistributions of source code must retain the above copyright notice which includes the
 *	name(s) of the copyright holders. It must also retain this list of conditions and the 
 *	following disclaimer. 
 *
 *	Redistributions in binary form must reproduce the above copyright notice, this list 
 *	of conditions and the following disclaimer in the documentation and/or other materials 
 *	provided with the distribution. 
 *
 *	Neither the name of David Book, or buzztouch.com nor the names of its contributors 
 *	may be used to endorse or promote products derived from this software without specific 
 *	prior written permission.
 *
 *	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 *	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
 *	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 *	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
 *	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
 *	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 *	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 *	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
 *	OF SUCH DAMAGE. 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "socialnetworkingsupercharged_appDelegate.h"
#import "BT_item.h"

@interface BT_viewControllerManager : NSObject {
}

//main navigation methods...
+(id)initViewControllerForScreen:(BT_item *)theScreen;
+(BT_item *)getErrorViewController;
+(void)handleTapToLoadScreen:(BT_item *)parentScreenData theMenuItemData:(BT_item *)theMenuItemData theScreenData:(BT_item *)theScreenData;
+(void)handleLeftButton:(BT_item *)parentScreenData;
+(void)handleRightButton:(BT_item *)parentScreenData;
+(void)closeChildApp;
+(void)showParentApp;


//special action methods that don't launch another view controller...
+(void)placeCallWithScreenData:(BT_item *)theScreenData;
+(void)sendEmailWithScreenData:(BT_item *)theScreenData imageAttachment:(UIImage *)imageAttachment imageAttachmentName:(NSString *)imageAttachmentName;
+(void)sendEmailWithAttachmentFromScreenData:(BT_item *)theScreenData theAttachmentData:(NSData *)theAttachmentData attachmentName:(NSString *)attachmentName;
+(void)sendEmailFromWebLink:(BT_item *)theScreenData toAddress:(NSString *)toAddress;
+(void)sendTextMessageWithScreenData:(BT_item *)theScreenData;



@end










