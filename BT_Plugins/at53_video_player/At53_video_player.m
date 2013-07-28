//
//  ATRAIN53 BuzzTouch Video Player plug-in
//  skompdev@skomp.net
//
//  Created by ATRAIN53 8/1/12
//  Copyright (c) 2012 skompdev. All rights reserved.
//
/*
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
#import "BT_color.h"
#import "BT_strings.h"
#import "BT_viewUtilities.h"
#import "BT_fileManager.h"
#import "socialnetworkingsupercharged_appDelegate.h"
#import "BT_item.h"
#import "BT_debugger.h"
#import "BT_viewControllerManager.h"
#import "At53_video_player.h"


@implementation At53_video_player
@synthesize imageVideo, buttonPlay, textDescription;

//viewDidLoad
-(void)viewDidLoad{
	[BT_debugger showIt:self theMessage:@"viewDidLoad"];
	[super viewDidLoad];
 
    //set text for description...
    [textDescription setText:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"videoDescription" defaultValue:@""]];
    
    //set descirption color as needed...
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"videoDescriptionColor" defaultValue:@""] length] > 3){
        [textDescription setTextColor:[BT_color getColorFromHexString:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"videoDescriptionColor" defaultValue:@""]]];
    }
    
    //set video image if provided...
    if([[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"videoImageFileName" defaultValue:@""] length] > 3){
        UIImage* img = [UIImage imageNamed:[BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"videoImageFileName" defaultValue:@""]];
        [imageVideo setImage:img];
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
	
}

//Video Player button actions
-(IBAction)playMovie:(id)sender{
	[BT_debugger showIt:self theMessage:@"playMovie"];
    
    NSString *videoFileName = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"videoFileName" defaultValue:@""];
    NSString *videoURL = [BT_strings getJsonPropertyValue:self.screenData.jsonVars nameOfProperty:@"videoURL" defaultValue:@""];
    NSURL *escapedURL = nil;
    BOOL bolFoundVideo  = false;
    
    /*
     video file
     --------------------------------
     a)	No dataURL is provided in the screen data - use the localFileName configured in the screen data
     b)	A dataURL is provided, check for local copy, download if not available
     
     */
    
    if([videoURL length] < 3){
        if([videoFileName length] > 3){
            if([BT_fileManager doesFileExistInBundle:videoFileName]){
                NSString *rootPath = [[NSBundle mainBundle] resourcePath];
                NSString *filePath = [rootPath stringByAppendingPathComponent:videoFileName];
                escapedURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
                bolFoundVideo = true;
            }
        }
    }else{
        //merge possible varialbes in url...
        videoURL = [BT_strings mergeBTVariablesInString:videoURL];
        escapedURL = [NSURL URLWithString:[videoURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        bolFoundVideo = true;
    }
    
    //play video if found...
    if(bolFoundVideo){
        [BT_debugger showIt:self theMessage:[NSString stringWithFormat:@"playMovie: found file or URL, trigger play method using: %@", [escapedURL absoluteString]]];
        [self playVideoFromFileOrURL:escapedURL];
    }
    
    
}


//play video method, triggered from line 127 above...
-(void)playVideoFromFileOrURL:(NSURL*)theFilePathOrURL{
    [BT_debugger showIt:self theMessage:@"playVideoFromFileOrURL"];

    // Initialize the movie player view controller with a video URL string
    MPMoviePlayerViewController *playerVC = [[[MPMoviePlayerViewController alloc] initWithContentURL:theFilePathOrURL] autorelease];
    
    //make sure to remove a possible "playback did finish" notification from last time (if we are playing movie again)...
    [[NSNotificationCenter defaultCenter] removeObserver:playerVC name:MPMoviePlayerPlaybackDidFinishNotification object:playerVC.moviePlayer];
    
    //register an observer so we know when the player is done playing...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieEndedMethod:) name:MPMoviePlayerPlaybackDidFinishNotification object:playerVC.moviePlayer];
    
    //trasnition the movie player onto screen using built in "cross dissolve" effect...
    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    //show the movie player view controller...
    [self presentViewController:playerVC animated:YES completion:nil];
    
    //start playing...
    [playerVC.moviePlayer prepareToPlay];
    [playerVC.moviePlayer play];
}

//movie is done playing...
- (void)movieEndedMethod:(NSNotification*)aNotification{
	[BT_debugger showIt:self theMessage:@"movieEndedMethod"];
    
    //reference the moviePlayer...
    MPMoviePlayerController *moviePlayer = [aNotification object];
    
    //get rid of the "listener" ...
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification  object:moviePlayer];
    
    //get the reason why the movie playback finished...
    int finishReason = [[[aNotification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    //perform different action depending on the finished reason?
    if (finishReason == MPMovieFinishReasonPlaybackEnded) {
        
        //movie finished playing on it's own...
        [BT_debugger showIt:self theMessage:@"movieEndedMethod: finished naturally"];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        
        //transition to another screen if configured...
        
        //appDelegate
        socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];
        
        //get possible itemId of the screen to load
        NSString *loadScreenItemId = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"videoEndedLoadScreenItemId" defaultValue:@""];
        
        //get possible nickname of the screen to load
        NSString *loadScreenNickname = [BT_strings getJsonPropertyValue:screenData.jsonVars nameOfProperty:@"videoEndedLoadScreenNickname" defaultValue:@""];
        
        BT_item *screenObjectToLoad = nil;
        if([loadScreenItemId length] > 1){
            screenObjectToLoad = [appDelegate.rootApp getScreenDataByItemId:loadScreenItemId];
        }else{
            if([loadScreenNickname length] > 1){
                screenObjectToLoad = [appDelegate.rootApp getScreenDataByNickname:loadScreenNickname];
            }else{
                if([screenData.jsonVars objectForKey:@"videoEndedLoadScreenObject"]){
                    screenObjectToLoad = [[BT_item alloc] init];
                    [screenObjectToLoad setItemId:[[screenData.jsonVars objectForKey:@"videoEndedLoadScreenObject"] objectForKey:@"itemId"]];
                    [screenObjectToLoad setItemNickname:[[screenData.jsonVars objectForKey:@"videoEndedLoadScreenObject"] objectForKey:@"itemNickname"]];
                    [screenObjectToLoad setItemType:[[screenData.jsonVars objectForKey:@"videoEndedLoadScreenObject"] objectForKey:@"itemType"]];
                    [screenObjectToLoad setJsonVars:[screenData.jsonVars objectForKey:@"videoEndedLoadScreenObject"]];
                }
            }
        }
        
        //load next screen if it's not nil
        if(screenObjectToLoad != nil){
            [BT_viewControllerManager handleTapToLoadScreen:[self screenData] theMenuItemData:screenData theScreenData:screenObjectToLoad];
            [screenObjectToLoad release];
        }

                
    
    }else if (finishReason == MPMovieFinishReasonUserExited) {
        
        //user used the built in "done" button on the player...
        [BT_debugger showIt:self theMessage:@"movieEndedMethod: user tapped the done button"];
        [self dismissViewControllerAnimated:YES completion:nil];
    
    }else if (finishReason == MPMovieFinishReasonPlaybackError) {
        
        //an error occured while the movie was playing...
        [BT_debugger showIt:self theMessage:@"movieEndedMethod: ended due to an error"];
        [self dismissViewControllerAnimated:YES completion:nil];
    
    }
    
 
    
}


//dealloc
-(void)dealloc {
    [super dealloc];
    [buttonPlay release];
    [textDescription release];
    [imageVideo release];
}

@end







