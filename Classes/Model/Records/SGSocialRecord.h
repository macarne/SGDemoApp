//
//  SGSocialRecord.h
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGRecord.h"

@interface SGSocialRecord :  SGRecord  
{
    /* 
     * The profile image for the social record. 
     */
    UIImage* profileImage;
    
    /*
     * If the social record comes with an extra photo (Brightkite or Flickr).
     * then it will will be assigned to this value.
     */
    UIImage* serviceImage;    
    
    /*
     * The helper view is a view that displays
     * any images held by this record. When we are retreiving 
     * images from URLs, we will call setNeedsLayout when we have
     * finished downloading the image data.
     */
    UIView* helperView;
    
}

@property (nonatomic, retain) UIImage* profileImage;
@property (nonatomic, retain) UIImage* photo;
@property (nonatomic, readonly) UIImage* serviceImage;

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* body;

@property (nonatomic, retain) UIView* helperView;

/*
 * The URL that points to the profile of this
 * social record.
 */
- (NSString*) profileURL;

/*
 * Fetches data for values at photoURL and profileImageURL. Once this
 * process is completed, it will call setNeedsLayout on the helperView
 * to update the pictures.
 */
- (void) fetchImages;

@end



