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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSON.h"
#import "BT_application.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "socialnetworkingsupercharged_appDelegate.h"
#import "BT_imageTools.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "Email_image.h"


@implementation Email_image
@synthesize bgImage, didEmail, imageToEmail, imageToEmailView, imageWidth, imageHeight, imageSize;
@synthesize imageFileName, imgPicker, popover;

//viewDidLoad
-(void)viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];

	//init screen properties
	[self setImageWidth:0];
	[self setImageHeight:0];
	[self setImageSize:0];
	[self setImageToEmail:nil];
	[self setDidEmail:FALSE];

	//appDelegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	//left is horizontal center..
	int left = [appDelegate.rootApp.rootDevice deviceWidth] / 2 - 47;

	//background image
	bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(left, 0, 87, 225)];
	bgImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[bgImage setContentMode:UIViewContentModeCenter];
	[bgImage setImage:[UIImage imageNamed:@"bgRefresh.png"]];
	[self.view addSubview:bgImage];
	
	//image to email (filled when image is selected)
	CGRect fullSizeFrame = CGRectMake(0, 0, appDelegate.window.bounds.size.width, appDelegate.window.bounds.size.height);
	imageToEmailView = [[UIImageView alloc] initWithFrame:fullSizeFrame];
	imageToEmailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[imageToEmailView setContentMode:UIViewContentModeScaleAspectFill];
	[self.view addSubview:imageToEmailView];

}

//view will appear
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
	
	//flag this as the current screen
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
	appDelegate.rootApp.currentScreenData = self.screenData;
	
	//setup navigation bar and background
	[BT_viewUtilities configureBackgroundAndNavBar:self theScreenData:[self screenData]];
	
	//show upload / send options..
	if(self.didEmail && ![appDelegate.rootApp.rootDevice isIPad]){
		[self showAlert:nil theMessage:NSLocalizedString(@"emailImageDone", "Re-load this screen to re-start the process or to send another message") alertTag:0];
	}else{
		[self performSelector:@selector(showOptions) withObject:nil afterDelay:0.5];
	}
	
	
}


//showOptions
-(void)showOptions{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"showUploadOptions%@", @""]];

	//action sheet choices depend on device
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	

	//must be able to send emails
	if(![appDelegate.rootApp.rootDevice canSendEmails]){

		[self showAlert:NSLocalizedString(@"emailsNotSupportedTitle", "Email Not Supported") theMessage:NSLocalizedString(@"emailsNotSupportedMessage", "Sending emails is not supported on this device") alertTag:0];
		
	}else{
	
		//buttons for choices
		NSMutableArray *buttons = [[NSMutableArray alloc] init];
		
		//only show this after choosing an image and NOT if it already uploaded
		if(self.imageToEmail != nil && !self.didEmail){
			[buttons addObject:NSLocalizedString(@"emailImage", "Email Image")];
		}

		//always allow choosing from library	
		[buttons addObject:NSLocalizedString(@"chooseImage", "Choose Image")];
		
		//allow new if device has camera
		if([appDelegate.rootApp.rootDevice canTakePictures]){	
			[buttons addObject:NSLocalizedString(@"takeNewImage", "Take New Image")];
		}

		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
					delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
		[actionSheet setTag:1];
		for (int i = 0; i < [buttons count]; i++) {
			[actionSheet addButtonWithTitle:[buttons objectAtIndex:i]];
		}
		[actionSheet addButtonWithTitle:NSLocalizedString(@"cancel", "Cancel")];
		
		//figure out what view to show it in...
        BT_navigationController *theNavController = [appDelegate getNavigationController];

        //is this a tabbed app?
        if([appDelegate.rootApp.tabs count] > 0){
            [actionSheet showFromTabBar:[appDelegate.rootApp.rootTabBarController tabBar]];
        }else{
            [actionSheet showInView:[theNavController view]];
        }			

		[actionSheet release];
	
	}//can send emails
	
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//action sheet delegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"actionSheetClick for button index: %i", buttonIndex]];
	
	//action sheet choices depend on device
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	//if we have a button index (ipad may dismiss action sheet without a button press)
	if(buttonIndex > -1){
	
		//choose image
		if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"chooseImage", "Choose Image")]){
		
			//choose existing image
			imgPicker = [[UIImagePickerController alloc] init];
			[imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
			[imgPicker setAllowsEditing:FALSE];
			[imgPicker setDelegate:self];
			[imgPicker.navigationBar setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];

			//picker changes if iPad
			if([appDelegate.rootApp.rootDevice isIPad]){
				
				//dismiss the action sheet
				[actionSheet dismissWithClickedButtonIndex:0 animated:YES];

				//hide status images (they look crappy with popover view showing)
				[self.bgImage setHidden:YES];
				
				//center the popover
				CGRect rect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 1, 1);
				popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
				[popover setDelegate:self];
				[popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];				


			}else{
		
				//present modal view controller
				[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                [self presentViewController:imgPicker animated:YES completion:nil];
			}
		}
		
		//take new image
		if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"takeNewImage", "Take New Image")]){
		
			//choose existing image
			imgPicker = [[UIImagePickerController alloc] init];
			[imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
			[imgPicker setAllowsEditing:FALSE];
			[imgPicker setDelegate:self];
			[imgPicker.navigationBar setTintColor:[BT_viewUtilities getNavBarBackgroundColorForScreen:self.screenData]];

			//picker changes if iPad
			if([appDelegate.rootApp.rootDevice isIPad]){
				
				//dismiss the action sheet
				[actionSheet dismissWithClickedButtonIndex:0 animated:YES];

				//hide status images (they look crappy with popover view showing)
				[self.bgImage setHidden:YES];
				
				//center the popover
				CGRect rect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 1, 1);
				popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
				[popover setDelegate:self];
				[popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];				


			}else{
		
				//present modal view controller
				[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
                [self presentViewController:imgPicker animated:YES completion:nil];
			}
		}
		
		
		//upload image
		if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"emailImage", "Email Image")]){
			[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
			[self emailImage];
		}

		//cancel
		if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"cancel", "Cancel")]){
			[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
			[self.navigationController popViewControllerAnimated:YES];
		}
		
	}else{
	
		//this is iPad when "no" button was clicked to dismiss (clicked outside of action sheet)
		[actionSheet dismissWithClickedButtonIndex:0 animated:TRUE];
		[self showOptions];
		
	}//buttonIndex > -1
}


//emailImage
-(void)emailImage {
	[BT_debugger showIt:self theMessage:@"emailImage"];
    
	//if we don't have an imageFileName, bail
	if([[self imageFileName] length] < 3){
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"Error getting file name of image to email%@", @""]];
		return;
	}

	//lower case image name
	NSString *imageName = [[self imageFileName] lowercaseString];
	[self setImageFileName:imageName];
	
	//BT_viewControllerManager sends message
	[BT_viewControllerManager sendEmailWithScreenData:[self screenData] imageAttachment:self.imageToEmail imageAttachmentName:imageName];
		
	//flag as 'true'
	self.didEmail = TRUE;
		
}


//did pick image
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"didFinishPickingMediaWithInfo%@", @""]];
	
	//flag to choices show upload option
	[self setDidEmail:FALSE];

	//set the image view, hide the picker
	[self setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	//get the image name from the selected image
	NSString *imageId = @"";
	NSString *imageExt = @"";
	NSString *imageName = @"";
	NSURL *localImageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
	if(localImageURL){
		NSArray *parameters = [[localImageURL query] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
		NSMutableDictionary *keyValueParm = [NSMutableDictionary dictionary];
		for (int i = 0; i < [parameters count]; i=i+2) {
			[keyValueParm setObject:[parameters objectAtIndex:i+1] forKey:[parameters objectAtIndex:i]];
		}
		imageId = [keyValueParm objectForKey:@"id"];
		imageExt = [keyValueParm objectForKey:@"ext"];
		imageName = [NSString stringWithFormat:@"%@.%@", imageId, imageExt];	
	}
	//if we snapped a new image it won't have name. Create a random name for it...
	if([imageName length] < 3){
		NSString *timestamp = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
 		imageName = [NSString stringWithFormat:@"%@.jpg", timestamp];
	}
	
	//remember the image name so we can use it when we upload
	[self setImageFileName:imageName];
	
	//delegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	//different if iPad
	if([appDelegate.rootApp.rootDevice isIPad]){
		[popover dismissPopoverAnimated:YES];
		[self showOptions];
	}else{
		[self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
	}
	
}

//did cancel picking image
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"imagePickerControllerDidCancel%@", @""]];
	
	//delegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	//different if iPad
	if([appDelegate.rootApp.rootDevice isIPad]){
		[popover dismissPopoverAnimated:YES];
	}else{
		[self.navigationController dismissViewControllerAnimated:TRUE completion:nil];
	}
}

//closed popover (iPad)
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"popoverControllerDidDismissPopover%@", @""]];
	
	//show options..
	if(self.didEmail){
		[self showAlert:nil theMessage:NSLocalizedString(@"emailImageDone", "Re-load this screen to re-start the process or to send another message")alertTag:99];
	}else{
		[self performSelector:@selector(showOptions) withObject:nil afterDelay:0.5];
	}	
}

//show close popover (iPad)
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"popoverControllerDidDismissPopover%@", @""]];
	NSLog(@"popoverControllerShouldDismissPopover");
	return TRUE;
}



//setImage
-(void)setImage:(UIImage *)selectedImage{
	[BT_debugger showIt:self theMessage:@"submitImage"];
	
	//scale image to size of screen
	if(selectedImage){

		//delegate
		socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
		int newWidth = 320;
		int newHeight = 480;
		if([appDelegate.rootApp.rootDevice isIPad]){
			newWidth = 768;
			newHeight = 1024;
		}
		UIImage *scaledImage = [BT_imageTools scaleProportionalToSize:selectedImage theSize:CGSizeMake(newWidth, newHeight)];

		//set image
		[self setImageToEmail:scaledImage];
		[self.imageToEmailView setImage:scaledImage];
	
		//hide underlying graphics
		[self.bgImage setHidden:TRUE];
	
	}
	
}


//view will dissappear
-(void)viewWillDisappear:(BOOL)animated{
	[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"viewWillDisappear%@", @""]];
	
	self.popover = nil;
	self.imgPicker = nil;
	
}

//dealloc
-(void)dealloc {
    [super dealloc];
	[screenData release];
	[progressView release];
	[bgImage release];
	[imageToEmail release];
	[imageToEmailView release];
	[imageFileName release];
	[imgPicker release];
	[popover release];
}


@end







