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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <UIKit/UIKit.h>
#import "BT_viewController.h"

@interface Ipad_story_book_page : BT_viewController <UIGestureRecognizerDelegate> {
	
    
    IBOutlet UIButton *nextButton;
    IBOutlet UIButton *lastButton;
    IBOutlet UIButton *menuButton;
    IBOutlet UIButton *interactButton;
    IBOutlet UIImageView *BGimage;
    
   }

@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *lastButton;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet UIButton *interactButton;
@property (nonatomic, retain) IBOutlet UIImageView *BGimage;

@property (nonatomic) int iButtonx;
@property (nonatomic) int iButtony;
@property (nonatomic) int iButtonw;
@property (nonatomic) int iButtonh;
@property (nonatomic) int mButtonx;
@property (nonatomic) int mButtony;
@property (nonatomic) int mButtonw;
@property (nonatomic) int mButtonh;
@property (nonatomic) int nButtonx;
@property (nonatomic) int nButtony;
@property (nonatomic) int nButtonw;
@property (nonatomic) int nButtonh;
@property (nonatomic) int pButtonx;
@property (nonatomic) int pButtony;
@property (nonatomic) int pButtonw;
@property (nonatomic) int pButtonh;




-(IBAction)nextPage:(id)sender;
-(IBAction)prevPage:(id)sender;
-(IBAction)openMenu:(id)sender;
-(IBAction)pageInteraction:(id)sender;





@end










