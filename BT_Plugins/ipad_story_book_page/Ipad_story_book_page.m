/*
 *	Copyright 2012, Chris Robbins
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
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "Ipad_story_book_page.h"


@implementation Ipad_story_book_page
@synthesize nextButton, menuButton, interactButton, lastButton, BGimage;
@synthesize iButtonx, iButtony, iButtonw, iButtonh, mButtonx, mButtony, mButtonw, mButtonh;
@synthesize nButtonx, nButtony, nButtonw, nButtonh, pButtonx, pButtony, pButtonw, pButtonh;


-(void)screenWasSwipedLeft{
    [BT_debugger showIt:self theMessage:@"screenWasSwipedLeft"];
	//appDelegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
	//get possible itemId of the screen to load
	NSString *loadScreenItemId = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"nextScreenId" defaultValue:@""];
	
	//get possible nickname of the screen to load
	NSString *loadScreenNickname = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"nextScreenNickname" defaultValue:@""];
    
	//bail if load screen = "none"
	if([loadScreenItemId isEqualToString:@"none"]){
		return;
	}
	
	//check for loadScreenWithItemId THEN loadScreenWithNickname THEN loadScreenObject
	BT_item *screenObjectToLoad = nil;
	if([loadScreenItemId length] > 1){
		screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenItemId];
	}else{
		if([loadScreenNickname length] > 1){
			screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenNickname];
		}
    }
    //load next screen if it's not nil
	if(screenObjectToLoad != nil){
        
		//build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
		BT_item *tmpMenuItem = [[BT_item alloc] init];
        
		//Get transition type for next page from screen's JSON or from Global Theme...
        NSString *nextTrans = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"nextScreenTransitionType" defaultValue:@""] ;
        
		//build an NSDictionary of values for the jsonVars property
		NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"unused", @"itemId", 
                                       nextTrans, @"transitionType",
                                       nil];	
		[tmpMenuItem setJsonVars:tmpDictionary];
		[tmpMenuItem setItemId:@"0"];
        
		//load the next screen	
		[BT_viewControllerManager handleTapToLoadScreen:[self screenData] theMenuItemData:tmpMenuItem theScreenData:screenObjectToLoad];
		[tmpMenuItem release];
		
	}else{
		//show debug
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
	}	
    
    

}

-(void)screenWasSwipedRight{
    
    [BT_debugger showIt:self theMessage:@"screenWasSwipedRight"];

    [BT_viewControllerManager handleLeftButton:screenData];
    
}

//viewDidLoad
-(void)viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];

	//put code here that adds UI controls to the screen. 
    
    if([[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"sbSwipe" defaultValue:@"0"] isEqualToString:@"1" ]){
        
        //Recognize Left Swipe
        UISwipeGestureRecognizer *swipeLEFT = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwipedLeft)];
        swipeLEFT.numberOfTouchesRequired = 1;
        swipeLEFT.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLEFT];
        
        //Recognize Right Swipe
        UISwipeGestureRecognizer *swipeRIGHT = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwipedRight)];
        swipeRIGHT.numberOfTouchesRequired = 1;
        swipeRIGHT.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeRIGHT];
        
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

    //Gather the Storybok Page Image name from JSON and assign it to the UIImage
    NSString *BGImageToLoad = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"sbBGImage" defaultValue:@""];
    
    UIImage *image = [UIImage imageNamed: BGImageToLoad];
	
	[BGimage setImage:image];
    
    
    //Load Button Images...
    
    //Next Button...
    UIImage *tmpBtnImg = [UIImage imageNamed:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"sbNextButtonImage" defaultValue:@"noIcon.png"]];
    [nextButton setImage:tmpBtnImg forState:UIControlStateNormal];
   
    //Previous Button...
    UIImage *tmpBtnImg2 = [UIImage imageNamed:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"sbPrevButtonImage" defaultValue:@"noIcon.png"]];
    [lastButton setImage:tmpBtnImg2 forState:UIControlStateNormal];

    //Menu Button...
    UIImage *tmpBtnImg3 = [UIImage imageNamed:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"sbMenuButtonImage" defaultValue:@"noIcon.png"]];
    [menuButton setImage:tmpBtnImg3 forState:UIControlStateNormal];
    
    //interact button...
    UIImage *tmpBtnImg4 = [UIImage imageNamed:[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"iButtonImage" defaultValue:@"noIcon.png"]];
    [interactButton setImage:tmpBtnImg4 forState:UIControlStateNormal];
    
    
    //Gather JSON variables for Previous Button from Screen or Global Theme
    pButtonx = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"pButtonx" defaultValue:@"100"] intValue] ;
    pButtony = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"pButtony" defaultValue:@"50"] intValue] ;
    pButtonw = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"pButtonw" defaultValue:@"50"] intValue] ;
    pButtonh = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"pButtonh" defaultValue:@"50"] intValue] ;
    
    //Set location of Previous Button
    CGRect pframe = CGRectMake(pButtonx, pButtony, pButtonw, pButtonh);
    lastButton.frame = pframe;
    
    
    //Gather JSON variables for Next Button from Screen or Global Theme
    nButtonx = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"nButtonx" defaultValue:@"400"] intValue] ;
    nButtony = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"nButtony" defaultValue:@"50"] intValue] ;
    nButtonw = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"nButtonw" defaultValue:@"50"] intValue] ;
    nButtonh = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"nButtonh" defaultValue:@"50"] intValue] ;
    
    //Set location of Next Button
    CGRect nframe = CGRectMake(nButtonx, nButtony, nButtonw, nButtonh);
    nextButton.frame = nframe;

    //Gather JSON variables for Menu Button from Screen or Global Theme
    mButtonx = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"mButtonx" defaultValue:@"700"] intValue] ;
    mButtony = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"mButtony" defaultValue:@"50"] intValue] ;
    mButtonw = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"mButtonw" defaultValue:@"50"] intValue] ;
    mButtonh = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"mButtonh" defaultValue:@"50"] intValue] ;
    
    //Set location of Menu Button
    CGRect mframe = CGRectMake(mButtonx, mButtony, mButtonw, mButtonh);
    menuButton.frame = mframe;


    //Gather JSON variables for Interaction Button from Screen or Global Theme
    iButtonx = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"iButtonx" defaultValue:@"100"] intValue] ;
    iButtony = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"iButtony" defaultValue:@"150"] intValue] ;
    iButtonw = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"iButtonw" defaultValue:@"50"] intValue] ;
    iButtonh = [[BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"iButtonh" defaultValue:@"50"] intValue] ;

    //Set location of Interaction Button
    CGRect iframe = CGRectMake(iButtonx, iButtony, iButtonw, iButtonh);
    interactButton.frame = iframe;

}

//Next Button Touched....
-(IBAction)nextPage:(id)sender{
    [BT_debugger showIt:self theMessage:@"nextPage"];

	//appDelegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
	//get possible itemId of the screen to load
	NSString *loadScreenItemId = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"nextScreenId" defaultValue:@""];
	
	//get possible nickname of the screen to load
	NSString *loadScreenNickname = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"nextScreenNickname" defaultValue:@""];
    
	//bail if load screen = "none"
	if([loadScreenItemId isEqualToString:@"none"]){
		return;
	}
	
	//check for loadScreenWithItemId THEN loadScreenWithNickname THEN loadScreenObject
	BT_item *screenObjectToLoad = nil;
	if([loadScreenItemId length] > 1){
		screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenItemId];
	}else{
		if([loadScreenNickname length] > 1){
			screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenNickname];
    
        }
    }
    //load next screen if it's not nil
	if(screenObjectToLoad != nil){
        
		//build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
		BT_item *tmpMenuItem = [[BT_item alloc] init];
        
        //Get transition type for next page from screen's JSON or from Global Theme...
        NSString *nextTrans = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"nextScreenTransitionType" defaultValue:@""] ;
        
		//build an NSDictionary of values for the jsonVars property
		NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"unused", @"itemId", 
                                       nextTrans, @"transitionType",
                                       nil];	
		[tmpMenuItem setJsonVars:tmpDictionary];
		[tmpMenuItem setItemId:@"0"];
        
		//load the next screen	
		[BT_viewControllerManager handleTapToLoadScreen:[self screenData] theMenuItemData:tmpMenuItem theScreenData:screenObjectToLoad];
		[tmpMenuItem release];
		
	}else{
		//show debug
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
	}	
    


}



//Previous Button Touched....


-(IBAction)prevPage:(id)sender{
    
    [BT_debugger showIt:self theMessage:@"prevPage"];

    [BT_viewControllerManager handleLeftButton:screenData];
}

//Menu Button Touched....
-(IBAction)openMenu:(id)sender{
    [BT_debugger showIt:self theMessage:@"openMenu"];
        
	//appDelegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
    
	//get possible itemId of the screen to load
    NSString *loadScreenItemId = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"sbMenuScreenId" defaultValue:@""];
	
	//get possible nickname of the screen to load
    NSString *loadScreenNickname = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"sbMenuScreenNickname" defaultValue:@""];
    
	//bail if load screen = "none"
	if([loadScreenItemId isEqualToString:@"none"]){
		return;
	}
	
	//check for loadScreenWithItemId THEN loadScreenWithNickname THEN loadScreenObject
	BT_item *screenObjectToLoad = nil;
	if([loadScreenItemId length] > 1){
		screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenItemId];
	}else{
		if([loadScreenNickname length] > 1){
			screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenNickname];
		}
    }
    //load next screen if it's not nil
	if(screenObjectToLoad != nil){
        
		//build a temp menu-item to pass to screen load method. We need this because the transition type is in the menu-item
		BT_item *tmpMenuItem = [[BT_item alloc] init];
        
        //Get transition type for next page from screen's JSON or from Global Theme...
        NSString *menuTrans = [BT_strings getStyleValueForScreen:self.screenData nameOfProperty:@"menuScreenTransitionType" defaultValue:@""] ;

        //build an NSDictionary of values for the jsonVars property
		NSDictionary *tmpDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"unused", @"itemId", 
                                       menuTrans, @"transitionType",
                                       nil];	
		[tmpMenuItem setJsonVars:tmpDictionary];
		[tmpMenuItem setItemId:@"0"];
        
		//load the next screen	
		[BT_viewControllerManager handleTapToLoadScreen:[self screenData] theMenuItemData:tmpMenuItem theScreenData:screenObjectToLoad];
		[tmpMenuItem release];
		
	}else{
		//show debug
		[BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"%@",NSLocalizedString(@"menuTapError",@"The application doesn't know how to handle this action?")]];
	}	
    
    
    
}


//Interaction Button Touched
-(IBAction)pageInteraction:(id)sender{
    
    [BT_debugger showIt:self theMessage:@"pageInteraction"];

    socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];
    
    //Plays MP3 sound effect - The MP3 file must be added to the sound array in the appDelegate (around line 900)
    [appDelegate playSoundEffect:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"sbInteractionSound" defaultValue:@""]];;
    
}



//dealloc
-(void)dealloc {
    [super dealloc];

}


@end







