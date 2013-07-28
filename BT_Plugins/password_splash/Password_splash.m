/*
 *	Copyright 2012, David Book
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
#import "BT_item.h"
#import "BT_fileManager.h"
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "BT_color.h"
#import "Password_splash.h"


@implementation Password_splash
@synthesize backgroundImageView, frmView, lblPassword, txtPassword, btnSubmit, spinner;



//viewDidLoad
-(void)viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];

    
	//appDelegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	/////////////////////////////////////////////////////////////////////////
	// 1) Add a full-size sub-view to hold a possible solid background color
	
	//solid background properties..
	UIColor *solidBgColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundColor" defaultValue:@"clear"]];
	NSString *solidBgOpacity = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundColorOpacity" defaultValue:@"100"];
	if([solidBgOpacity isEqualToString:@"100"]) solidBgOpacity = @"99";
	solidBgOpacity = [NSString stringWithFormat:@".%@", solidBgOpacity];
    
	//sub-view for background color
	UIView *bgColorView;
	if([appDelegate.rootApp.rootDevice isIPad]){
		bgColorView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	}else{
		bgColorView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	}
	[bgColorView setAlpha:[solidBgOpacity doubleValue]];
	[bgColorView setBackgroundColor:solidBgColor];
    
    //auto resizing of bgColorView...
    bgColorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
	//add view
	[self.view addSubview:bgColorView];
	[bgColorView release];
    
    
	////////////////////////////////////////////////////////////////////////
	// 3) Add a full-size image-view to hold a possible background image
    
	NSString *imageName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameSmallDevice" defaultValue:@""];
	NSString *imageURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageURLSmallDevice" defaultValue:@""];
	if([appDelegate.rootApp.rootDevice isIPad]){
		imageName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameLargeDevice" defaultValue:@""];
		imageURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageURLLargeDevice" defaultValue:@""];
	}
	
	//init the image view
	self.backgroundImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.backgroundImageView setContentMode:UIViewContentModeCenter];
	self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.backgroundImageView];
	
    //bring UIView that's holding text and button to the front (setup in interface builder)...
    [self.view bringSubviewToFront:[self frmView]];
    
    //set background image after a short delay so UI doesn't lock up....
    [self performSelector:@selector(setBgImage) withObject:nil afterDelay:.5];
    
    //the form is 175px wide. To center it horizontally use (deviceWidth / 2) - (175 / 2)
    
    //defaultX is used if there are no JSON propeties provided (center horizontally).
    NSString *defaultX = [NSString stringWithFormat:@"%i", ( ([appDelegate.rootApp.rootDevice deviceWidth] / 2) - (175 / 2))];
    
    //move form "down" from top of screen....
    int frmX = [[BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"formXSmallDevice" defaultValue:defaultX] intValue];
    int frmY = [[BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"formYSmallDevice" defaultValue:@"75"] intValue];
    if([appDelegate.rootApp.rootDevice isIPad]){
        frmX = [[BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"formXLargeDevice" defaultValue:defaultX] intValue];
        frmY = [[BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"formYLargeDevice" defaultValue:@"75"] intValue];
    }
    
    //keep form in location on rotate......
	self.frmView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    //set frame for form view...
    CGRect frmFrame = CGRectMake(frmX, frmY, 175, 250);
    [self.frmView setFrame:frmFrame];

    //set background image for button, default to "ps_submit.png" if one is not provided in the JSON...
    NSString *tmpButtonImageName = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"buttonImageFileName" defaultValue:@"ps_submit.png"];
    [self.btnSubmit setBackgroundImage:[UIImage imageNamed:tmpButtonImageName] forState:UIControlStateNormal];
    
    //set text on button, default to "submit"....
    NSString *tmpButtonText = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"buttonText" defaultValue:@"Submit"];
    [self.btnSubmit setTitle:tmpButtonText forState:UIControlStateNormal];

    //set color for the button's text...
    NSString *tmpButtonTextColor = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"buttonTextColor" defaultValue:@"#000000"];
    [self.btnSubmit setTitleColor:[BT_color getColorFromHexString:tmpButtonTextColor] forState:UIControlStateNormal];
    
    //set text for the label above the password box...
    NSString *tmpPasswordText = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"passwordLabel" defaultValue:@"Password"];
    [self.lblPassword setText:tmpPasswordText];
    
    //set color for the lable above the password box....
    NSString *passwordLabelColor = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"passwordLabelColor" defaultValue:@"#000000"];
    [self.lblPassword setTextColor:[BT_color getColorFromHexString:passwordLabelColor]];
    
    //setup the keyboard type...
    NSString *keyboardType = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"keyboardType" defaultValue:@""];
    if([keyboardType length] > 0){
        if([keyboardType isEqualToString:@"default"]) [self.txtPassword setKeyboardType:UIKeyboardTypeAlphabet];
        if([keyboardType isEqualToString:@"emailPad"]) [self.txtPassword setKeyboardType:UIKeyboardTypeEmailAddress];
        if([keyboardType isEqualToString:@"namePad"]) [self.txtPassword setKeyboardType:UIKeyboardTypeNamePhonePad];
        if([keyboardType isEqualToString:@"numberPad"]) [self.txtPassword setKeyboardType:UIKeyboardTypeNumberPad];
        if([keyboardType isEqualToString:@"phonePad"]) [self.txtPassword setKeyboardType:UIKeyboardTypePhonePad];
        if([keyboardType isEqualToString:@"decimalPad"]) [self.txtPassword setKeyboardType:UIKeyboardTypeDecimalPad];
     }
    
    
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
    
    //if view is about to appear, but the password exists in the user prefs....hide controls and animate spalsh...
    NSString *secretPassword = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"secretPassword" defaultValue:@""];
    NSString *saveSecretName = [NSString stringWithFormat:@"secret_%@", secretPassword];
    if([[BT_strings getPrefString:saveSecretName] isEqualToString:secretPassword]){
        
        //get rid of the form view...
        [self.frmView removeFromSuperview];
        
        //animate splash screen after a short delay so possible background image has a chance to render....
        [self performSelector:@selector(animateSplashScreen) withObject:nil afterDelay:1];
        
    }
	
}

//submit click
-(IBAction)submitClick:(id)sender{
	[BT_debugger showIt:self theMessage:@"submitClick"];
    
     //what is the secret password...
    NSString *secretPassword = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"secretPassword" defaultValue:@""];
    NSString *secretPasswordWarning = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"secretPasswordWarning" defaultValue:@"The password you entered is incorrect, please try again."];
    
    //password must match...
    if([[txtPassword text] length] > 0 && [[txtPassword text] isEqualToString:secretPassword]){
        
        //dismiss keyboard...
        [self.txtPassword resignFirstResponder];
        
        //save password for next time so user doesn't have to enter it again OPTIONAL, default to NO....
        if([[BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"rememberSecretOnDevice" defaultValue:@"0"] isEqualToString:@"1"]){
            NSString *saveSecretName = [NSString stringWithFormat:@"secret_%@", secretPassword];
            [BT_strings setPrefString:saveSecretName valueOfPref:[txtPassword text]];
        }
        
        //animate splash  away....
        [self animateSplashScreen];
        
    
    }else{
        
        [self showAlert:nil theMessage:secretPasswordWarning alertTag:0];
    
    }
    
    
    
}

//downloadImage
-(void)setBgImage{
    
	//appDelegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];
    
	/*
     Where is the background image?
     a) File exists in bundle. Use this image, ignore possible download URL
     b) File DOES NOT exist in bundle, but does exist in writeable data directory: Use it. (it was already downloaded and saved)
     c) File DOES NOT exist in bundle, and DOES NOT exist in writeable data directory and an imageURL is set: Download it, save it for next time, use it.
     */
    
	NSString *imageName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameSmallDevice" defaultValue:@""];
	NSString *imageURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageURLSmallDevice" defaultValue:@""];
	if([appDelegate.rootApp.rootDevice isIPad]){
		imageName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageNameLargeDevice" defaultValue:@""];
		imageURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"backgroundImageURLLargeDevice" defaultValue:@""];
	}
    
    
    
	//if we have an imageURL, and no imageName, figure out a name to use...
	if(imageName.length < 3 && imageURL.length > 3){
		imageName = [BT_strings getFileNameFromURL:imageURL];
	}
	
	//get the image
	if([imageName length] > 1){
		
		if([BT_fileManager doesFileExistInBundle:imageName]){
			
			[BT_debugger showIt:self theMessage:@"Image for splash-screen exists in bundle - not downloading."];
			[self.backgroundImageView setImage:[UIImage imageNamed:imageName]];
			
		}else{
            
			if([BT_fileManager doesLocalFileExist:imageName]){
                
				[BT_debugger showIt:self theMessage:@"Image for splash-screen exists in cache - not downloading."];
                [self.backgroundImageView setImage:[BT_fileManager getImageFromFile:imageName]];
                
			}else{
                
				//only do this if we have an image URL
				if([imageURL length] > 3){
                    
					[BT_debugger showIt:self theMessage:@"Image for splash-screen does not exist in cache - downloading."];
                    [self.backgroundImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]]];
                    
                    
				}
			}
            
		}
        
	}//imageName
    
    
	//set the image's opacity
	NSString *imageBgOpacity = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundImageOpacity" defaultValue:@"100"];
	if([imageBgOpacity isEqualToString:@"100"]) imageBgOpacity = @"99";
	imageBgOpacity = [NSString stringWithFormat:@".%@", imageBgOpacity];
	[self.backgroundImageView setAlpha:[imageBgOpacity doubleValue]];
    
    //set the background's scale property...
    NSString *backgroundImageScale = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"backgroundImageScale" defaultValue:@"fullScreen"];
    
    //set the content mode for the image...
    if([backgroundImageScale isEqualToString:@"center"]) [self.backgroundImageView setContentMode:UIViewContentModeCenter];
    if([backgroundImageScale isEqualToString:@"fullScreen"]) [self.backgroundImageView setContentMode:UIViewContentModeScaleToFill];
    if([backgroundImageScale isEqualToString:@"fullScreenPreserve"]) [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
    if([backgroundImageScale isEqualToString:@"top"]) [self.backgroundImageView setContentMode:UIViewContentModeTop];
    if([backgroundImageScale isEqualToString:@"bottom"]) [self.backgroundImageView setContentMode:UIViewContentModeBottom];
    if([backgroundImageScale isEqualToString:@"topLeft"]) [self.backgroundImageView setContentMode:UIViewContentModeTopLeft];
    if([backgroundImageScale isEqualToString:@"topRight"]) [self.backgroundImageView setContentMode:UIViewContentModeTopRight];
    if([backgroundImageScale isEqualToString:@"bottomLeft"]) [self.backgroundImageView setContentMode:UIViewContentModeBottomLeft];
    if([backgroundImageScale isEqualToString:@"bottomRight"]) [self.backgroundImageView setContentMode:UIViewContentModeBottomRight];
    self.backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    
 
}


//animateSplashScreen
-(void)animateSplashScreen{
	[BT_debugger showIt:self theMessage:@"animating splash screen"];
	
	//setup animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(removeSplashScreen)];
    
    //transition type...
    NSString *transitionType = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"transitionType" defaultValue:@"fade"];
    double transitionDurationSeconds = [[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"transitionDurationSeconds" defaultValue:@"1"] doubleValue];
    
    
	//shrink
	if([transitionType rangeOfString:@"shrink" options: NSCaseInsensitiveSearch].location != NSNotFound){
		self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
		[UIView setAnimationDuration:transitionDurationSeconds];
		self.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
	}
	//fade
	if([transitionType rangeOfString:@"fade" options: NSCaseInsensitiveSearch].location != NSNotFound){
		[self.view setAlpha:1];
		[UIView setAnimationDuration:transitionDurationSeconds];
		[self.view setAlpha:0];
	}
	//curl
	if([transitionType rangeOfString:@"curl" options: NSCaseInsensitiveSearch].location != NSNotFound){
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:[self view] cache:YES];
		[self.view setAlpha:0];
		[UIView setAnimationDuration:transitionDurationSeconds];
	}
	
	//start animation
	[UIView commitAnimations];
	
}

//unloads view from stack
-(void)removeSplashScreen{
	[self.view removeFromSuperview];
	self = nil;
}




//dealloc
-(void)dealloc {
    [super dealloc];
    [backgroundImageView release];
    [frmView release];
    [lblPassword release];
    [txtPassword release];
    [btnSubmit release];
    [spinner release];

}


@end







