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
#import "JSON.h"
#import "BT_item.h"
#import "socialnetworkingsupercharged_appDelegate.h"
#import "BT_color.h"
#import "BT_viewUtilities.h"
#import "BT_imageTools.h"
#import "BT_device.h"
#import "BT_strings.h"
#import "BT_settingData.h"
#import "BT_cell_settings.h"


@implementation BT_cell_settings
@synthesize titleLabel, descriptionLabel, cellImageView, glossyMaskView, theParentMenuScreenData, theMenuItemData;
@synthesize imageLoadingView, imageBox, theSettingsItemData;


//size and color come from screen, not menu item 	
- (id)initWithStyle:(UITableViewCellStyle)stylereuseIdentifier reuseIdentifier:(NSString *)reuseIdentifier {
    if((self = [super initWithStyle:stylereuseIdentifier reuseIdentifier:reuseIdentifier])){		

		//set background to clear to start
		[self.contentView setBackgroundColor:[UIColor clearColor]];
		
		//the image box gets resized to exactly the same size as the icon (if we use one) so we can
		//apply a drop-shadow to it's view 
		imageBox = [[UIView alloc] init];
		[imageBox setContentMode:UIViewContentModeCenter];
		[imageBox setBackgroundColor:[UIColor clearColor]];
		
		//image view for icon
		cellImageView = [[UIImageView alloc] init];
		[cellImageView setClipsToBounds:YES];
		[cellImageView setContentMode:UIViewContentModeCenter];
		[cellImageView setBackgroundColor:[UIColor clearColor]];
		[imageBox addSubview:cellImageView];

		//glossy view, goes on top of cell image after download complete, inits at default cell / image size
		glossyMaskView = [[UIImageView alloc] init];
		glossyMaskView.clipsToBounds = YES;
		glossyMaskView.image = [UIImage imageNamed:@"imageOverlay.png"];
		glossyMaskView.backgroundColor = [UIColor clearColor];
		glossyMaskView.contentMode = UIViewContentModeScaleAspectFill;
		[imageBox addSubview:glossyMaskView];

		//spinner, not animated unless we are setting an icon
		imageLoadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
		imageLoadingView.backgroundColor = [UIColor clearColor];
		imageLoadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		[imageLoadingView setHidesWhenStopped:TRUE];
        imageLoadingView.contentMode = UIViewContentModeCenter;
		[imageLoadingView startAnimating];
		[imageBox addSubview:imageLoadingView];
		
		//add the image box
		[self.contentView addSubview:imageBox];

		//label for text
		titleLabel = [[UILabel alloc] init];
		[titleLabel setClipsToBounds:YES];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;	
		titleLabel.numberOfLines = 1;
		[self.contentView addSubview:titleLabel];
		
		//textView for description. no padding!
		descriptionLabel = [[UITextView alloc] init];
		[descriptionLabel setClipsToBounds:YES];
		[descriptionLabel setBackgroundColor:[UIColor clearColor]];
		[descriptionLabel setEditable:FALSE];
		[descriptionLabel setUserInteractionEnabled:FALSE];
		[descriptionLabel setShowsVerticalScrollIndicator:FALSE];
		[descriptionLabel setShowsHorizontalScrollIndicator:FALSE];
		[descriptionLabel setContentInset:UIEdgeInsetsMake(-8,-8,0,0)];
		[descriptionLabel setTextAlignment:NSTextAlignmentLeft];
		descriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;	
		[self.contentView addSubview:descriptionLabel];	
		
    }
    return self;
}

//sets text, image, size, etc.
-(void)configureCell{
	
	//appDelegate
	socialnetworkingsupercharged_appDelegate *appDelegate = (socialnetworkingsupercharged_appDelegate *)[[UIApplication sharedApplication] delegate];	
	
	/*
		cell design comes from rootApp.rootTheme OR from parentScreen's JSON data if over-ridden
		Scenarios:
			a) 	Title NO Description.
				In this case, the row-height is used for the label the text is centered. 
			b) 	Title + Description.
				In this case, the "listTitleHeight" is used and the the difference between this and
				the row-height becomes the height of the description label
				
		IMPORTANT: The image with be center in the image box. This means if the image is larger than
		the row height it will not look right. Scaling images in lists is memory intensive so we do
		not do it. This means you should only use icons / images that are "smaller than the row height"			
				
				
	*/

	//default values
	int rowHeight = 50;
	int titleHeight = 50;
	int descriptionHeight = 0;
	int iconSize = 50;
	int iconLeft = 0;
	int iconPadding = 0;
	int iconRadius = 0;
	int titleFontSize = 20;
	int descriptionFontSize = 20;
	UIColor *titleFontColor = [UIColor blackColor];
	UIColor *descriptionFontColor = [UIColor blackColor];
	NSString *iconName = @"";
	NSString *iconURL = @"";
	NSString *iconScale = @"center";
	NSString *applyShinyEffect = @"0";
	NSString *rowSelectionStyle = @"arrow";
	NSString *useWhiteIcons = @"0";
	NSString *rowAccessoryType = @"";
	NSString *titleText = @"";
	NSString *descriptionText = @"";
	
	
	////////////////////////////////////////////////////////////////////////
	//properties not related to the device's size

	//variables from the BT_settingsData. Settings are simple text
	//labels and a checkmark if selected, blank if not selected.
	titleText = [self.theSettingsItemData settingLabel];
	
	titleFontColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleFontColor" defaultValue:@"#000000"]];
	descriptionFontColor = [BT_color getColorFromHexString:[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listDescriptionFontColor" defaultValue:@"#000000"]];	
	rowSelectionStyle = [BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listRowSelectionStyle" defaultValue:@"none"];
	iconScale = [BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listIconScale" defaultValue:@"center"];
	applyShinyEffect = [BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listIconApplyShinyEffect" defaultValue:@"0"];

	//icon name, radius, use rounded corners?
	iconName = [BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"iconName" defaultValue:@""];
	iconURL = [BT_strings getJsonPropertyValue:theMenuItemData.jsonVars nameOfProperty:@"iconURL" defaultValue:@""];
	iconRadius = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listIconCornerRadius" defaultValue:@"0"] intValue];
	useWhiteIcons = [BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listUseWhiteIcons" defaultValue:@"0"];

	//if the global theme or the parent screen use a "round" list type, button left changes so it's not against the edge
	NSString *parentListStyle = [BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listStyle" defaultValue:@"plain"];
	if([parentListStyle isEqualToString:@"round"]){	
		iconLeft = -5;
		iconPadding = 7;
	}	
	
	//center image or scale image? When using icons that are smaller than the row height it's best to center
	//when using images (usually from a URL) that are larger than the row height, use scale
	if([iconScale isEqualToString:@"scale"]){
		cellImageView.contentMode = UIViewContentModeScaleAspectFill;
	}
	
	////////////////////////////////////////////////////////////////////////
	//properties related to the device's size

	//height and size depends on device type
	if([appDelegate.rootApp.rootDevice isIPad]){
	
		//user large device settings
		rowHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listRowHeightLargeDevice" defaultValue:@"50"] intValue];
		titleHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleHeightLargeDevice" defaultValue:@"30"] intValue];
		titleFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleFontSizeLargeDevice" defaultValue:@"20"] intValue];
		descriptionFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listDescriptionFontSizeLargeDevice" defaultValue:@"15"] intValue];
		iconSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listIconSizeLargeDevice" defaultValue:@"50"] intValue];

	}else{
	
		//user small device settings
		rowHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listRowHeightSmallDevice" defaultValue:@"50"] intValue];
		titleHeight = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleHeightSmallDevice" defaultValue:@"30"] intValue];
		titleFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listTitleFontSizeSmallDevice" defaultValue:@"20"] intValue];
		descriptionFontSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listDescriptionFontSizeSmallDevice" defaultValue:@"15"] intValue];
		iconSize = [[BT_strings getStyleValueForScreen:theParentMenuScreenData nameOfProperty:@"listIconSizeSmallDevice" defaultValue:@"50"] intValue];
		
	}
			
	//figure out heights
	if(titleHeight > rowHeight){
		titleHeight = rowHeight;
	}
	if([descriptionText length] > 0){
		descriptionHeight = (rowHeight - titleHeight);
	}else{
		titleHeight = rowHeight;
	}
							
											
	//this is bound to happen! Users will enter a rowHeight that is the same as the titleHeight and
	//provide a description. In this case, it won't work because the title will cover the description.
	//ignore their settings in the case so they can see what they did and force them to adjust.
	if(titleHeight == rowHeight && [descriptionText length] > 0){
		titleHeight = (rowHeight / 2);
		descriptionHeight	 = (rowHeight / 2);
	}




	//label size / position depend on whether or not we have an icon.
	if([iconName length] > 1){
	
		//are we using the white versions of icons?
		if([useWhiteIcons isEqualToString:@"1"]){
			iconName = [BT_imageTools getWhiteIconName:iconName];
		}

		//set the imageName and imageURL in the BT_item so it can find the icon, image, whatever
		[self.theMenuItemData setImageName:iconName];
		[self.theMenuItemData setImageURL:iconURL];	
	
		//frame for image / shine, etc
		CGRect boxFrame = CGRectMake((iconLeft + iconPadding), 0, rowHeight, rowHeight);
		CGRect imageFrame = CGRectMake((iconLeft + iconPadding) + 3, rowHeight / 2 - (iconSize / 2), iconSize, iconSize);
		
		//set image frames
		[imageBox setFrame:boxFrame];
		[cellImageView setFrame:imageFrame];
		[glossyMaskView setFrame:imageFrame];
		[imageLoadingView setFrame:imageFrame];

		//remove glossy mask if we don't want it
		if([applyShinyEffect isEqualToString:@"0"]){
			[glossyMaskView removeFromSuperview];
		}
		
		//round corners? Apply shadow?
		if(iconRadius > 0){
			cellImageView = [BT_viewUtilities applyRoundedCornersToImageView:cellImageView radius:iconRadius];
		}
		
		//text
		int labelLeft = (iconSize + iconPadding + 8);
		int labelWidth = self.contentView.frame.size.width - iconSize - iconPadding;
		
		[titleLabel setFrame:CGRectMake(labelLeft, 0, labelWidth, titleHeight)];
		[descriptionLabel setFrame:CGRectMake(labelLeft, titleHeight - 5, labelWidth, descriptionHeight)];
		
		//show the image
		[self showImage];
		
	}else{

		//remove image frames
		[cellImageView removeFromSuperview];
		[glossyMaskView removeFromSuperview];
		[imageLoadingView removeFromSuperview];
		
		//text		
		int labelLeft = 10 + iconPadding;
		int labelWidth = self.contentView.frame.size.width - 25;
		
		[titleLabel setFrame:CGRectMake(labelLeft, 0, labelWidth, titleHeight)];
		[descriptionLabel setFrame:CGRectMake(labelLeft, titleHeight - 5, labelWidth, descriptionHeight)];

	}
	
	//set title
	[titleLabel setTextColor:titleFontColor];
	[titleLabel setFont:[UIFont boldSystemFontOfSize:titleFontSize]];
	[titleLabel setText:titleText];
	[titleLabel setOpaque:FALSE];
	
	//set description
	[descriptionLabel setTextColor:descriptionFontColor];
	[descriptionLabel setFont:[UIFont systemFontOfSize:descriptionFontSize]];
	[descriptionLabel setText:descriptionText];
	[descriptionLabel setOpaque:FALSE];
		
	//cell selection style: Blue, Gray, None
	if([rowSelectionStyle rangeOfString:@"blue" options:NSCaseInsensitiveSearch].location != NSNotFound){
		[self setSelectionStyle:UITableViewCellSelectionStyleBlue];
	}
	if([rowSelectionStyle rangeOfString:@"gray" options:NSCaseInsensitiveSearch].location != NSNotFound){
		[self setSelectionStyle:UITableViewCellSelectionStyleGray];
	}	
	if([rowSelectionStyle rangeOfString:@"none" options:NSCaseInsensitiveSearch].location != NSNotFound){
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
	}	
	
	//chevron indicator: DisclosureButton, DetailDisclosureButton, Checkmark, None
	if([rowAccessoryType rangeOfString:@"arrow" options:NSCaseInsensitiveSearch].location != NSNotFound){
		[self setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	}
	if([rowAccessoryType rangeOfString:@"details" options:NSCaseInsensitiveSearch].location != NSNotFound){
		[self setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
	}	
	if([rowAccessoryType rangeOfString:@"checkmark" options:NSCaseInsensitiveSearch].location != NSNotFound){
		[self setAccessoryType: UITableViewCellAccessoryCheckmark];
	}		
	if([rowAccessoryType rangeOfString:@"none" options:NSCaseInsensitiveSearch].location != NSNotFound){
		[self setAccessoryType: UITableViewCellAccessoryNone];
	}	
	
}


//shows image
- (void)showImage {

	@synchronized(self) {      
		if ([[NSThread currentThread] isCancelled]) return;
		
		[thread cancel]; // Cell! Stop what you were doing!
		[thread release];
		thread = nil;
        
		if ([theMenuItemData image]) { // If the image has already been downloaded.
			
			//set the image
			cellImageView.image = [theMenuItemData image];
			
			//hide loading spinner...
			[imageLoadingView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
			
		}else{
			
			// We need to download the image, get it in a seperate thread!      
			thread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadImage) object:nil];
			[thread start];
		
		}  		    
	}    
}

//downloads icon
- (void)downloadImage {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([[NSThread currentThread] isCancelled]) {
		[imageLoadingView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
	}
	
	if (![[NSThread currentThread] isCancelled]) {

		//if image already set
		if([theMenuItemData image] != nil){
			
			[imageLoadingView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
		
		}else{
			
			//download (BT_item will return local version of icon if available)
			[theMenuItemData downloadImage];
		
			@synchronized(self) {
				if (![[NSThread currentThread] isCancelled]) {
					if(theMenuItemData.image != nil){
						[self performSelectorOnMainThread:@selector(setImageFromThread:) withObject:theMenuItemData.image waitUntilDone:NO];                
						[imageLoadingView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
					}else{
						[imageLoadingView performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
					}
				}
			}
			
		}//icon != nil
	
	}
	[pool release];
}

//load image from other thread
-(void)setImageFromThread:(UIImage *)theImage{
	[cellImageView setImage:theImage];
}


- (void)dealloc {
	[theParentMenuScreenData release];
		theParentMenuScreenData = nil;
	[titleLabel release];
		titleLabel = nil;
	[imageBox release];
		imageBox = nil;
	[descriptionLabel release];
		descriptionLabel = nil;
	[cellImageView release];
		cellImageView = nil;
	[glossyMaskView release];
		glossyMaskView = nil;
	[theMenuItemData release];
		theMenuItemData = nil;
	[theSettingsItemData release];
		theSettingsItemData = nil;
	[super dealloc];
}

@end



