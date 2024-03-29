/*
 *	Copyright 2012, Susan Metoxen
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

@interface WB_screen_menuImage : BT_viewController <BT_downloadFileDelegate,
UITableViewDelegate,
UITableViewDataSource>{
	NSMutableArray *menuItems;
	UITableView *myTableView;
	BT_downloader *downloader;
	NSString *saveAsFileName;	
	BOOL isLoading;	
	int didInit;
    
    UIImageView *headerImage;
    int imageHeight;
    int imageWidth;
    
    int tableHeight;
    
    NSString *imageFileName;
    NSString *imageURL;
    
}

@property (nonatomic, retain) NSMutableArray *menuItems;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSString *saveAsFileName;
@property (nonatomic, retain) BT_downloader *downloader;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) int didInit;

@property (nonatomic, retain) UIImageView *headerImage;
@property (nonatomic) int imageHeight;
@property (nonatomic) int imageWidth;
@property (nonatomic) int tableHeight;
@property (nonatomic, retain) NSString *imageFileName;
@property (nonatomic, retain) NSString *imageURL;

-(void)loadData;
-(void)downloadData;
-(void)layoutScreen;
-(void)parseScreenData:(NSString *)theData;
-(void)checkIsLoading;

@end










