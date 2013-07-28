/*
 *	Copyright 2013, Caleb theMonster
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
#import "Tm_invisiblefacebook.h"

@implementation Tm_invisiblefacebook

//viewDidLoad
-(void)viewDidLoad {
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
	//put code here that adds UI controls to the screen.
    // get user inputs
    self.initialText =  [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"initialText" defaultValue:@""];
    self.images = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"images" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    self.imageURLs = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"imageURLs"defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    self.urls = [[[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"URLs" defaultValue:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    
    // get the view controller that called you, then remove yourself from the view heiarchy
    UIViewController *vc;
    vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [self performInvisibleActionWithVC:vc];
}

- (void) performInvisibleActionWithVC:(UIViewController *)vc
{
    // display facebook if it's available
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        self.composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        // if the Initial Text hasn't been set then we use default: "Let your Friends know about this app!"
        if ([self.initialText isEqualToString:@""])
            self.initialText = @"Let your Friends know about this app!";
        
        [self.composer setInitialText:self.initialText];
        
        // images
        for (NSString *string in self.images) {
            if (![string isEqualToString:@""])
                [self.composer addImage:[UIImage imageNamed:string]];
        }
        // image urls
        for (NSString *string in self.imageURLs) {
            if (![string isEqualToString:@""])
                [self.composer addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]]];
        }
        // urls
        for (NSString *string in self.urls) {
            if (![string isEqualToString:@""])
                [self.composer addURL:[NSURL URLWithString:string]];
        }
        
        [vc presentViewController:self.composer animated:YES completion:nil];
    } else {
        [BT_debugger showIt:self theMessage:@"Unable to Show Facebook Sheet... Either Facebook isn't available or the user doesn't have a FB account setup."];
    }
}

//view will appear
-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[BT_debugger showIt:self theMessage:@"viewWillAppear"];
	
	//flag this as the current screen
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.rootApp.currentScreenData = self.screenData;
	
	//setup navigation bar and background
	[BT_viewUtilities configureBackgroundAndNavBar:self theScreenData:[self screenData]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

//dealloc
-(void)dealloc {
    [super dealloc];
    
}


@end




