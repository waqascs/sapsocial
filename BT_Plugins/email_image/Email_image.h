/*
 *	Copyright 2012, Mark S Fleming
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
#import "BT_viewController.h"
#import "BT_downloader.h"
#import "BT_item.h"

@interface Email_image : BT_viewController <UIActionSheetDelegate,
													UIPopoverControllerDelegate,
													UIImagePickerControllerDelegate, 
													UINavigationControllerDelegate>{
	UIImageView *bgImage;
	UIImageView *imageToEmailView;
	UIImage *imageToEmail;
	int imageWidth;
	int imageHeight;
	int imageSize;
	NSString *imageFileName;
	UIImagePickerController *imgPicker;
	UIPopoverController *popover;
	BOOL didEmail;

}

@property (nonatomic, retain) UIImageView *bgImage;
@property (nonatomic, retain) UIImageView *imageToEmailView;
@property (nonatomic, retain) UIImage *imageToEmail;
@property (nonatomic) int imageWidth;
@property (nonatomic) int imageHeight;
@property (nonatomic) int imageSize;
@property (nonatomic) BOOL didEmail;

@property (nonatomic, retain) NSString *imageFileName;
@property (nonatomic, retain) UIImagePickerController *imgPicker;
@property (nonatomic, retain) UIPopoverController *popover;


-(void)showOptions;
-(void)setImage:(UIImage *)selectedImage;
-(void)emailImage;



/*
	This navigation controller serves as the delegate for image picker methods
*/
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;


@end




















