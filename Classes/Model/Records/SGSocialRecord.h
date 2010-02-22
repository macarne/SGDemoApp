//
//  SGSocialRecord.h
//  SGDemoApp
//
//  Copyright (c) 2009-2010, SimpleGeo
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, 
//  this list of conditions and the following disclaimer. Redistributions 
//  in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution.
//  
//  Neither the name of the SimpleGeo nor the names of its contributors may
//  be used to endorse or promote products derived from this software 
//  without specific prior written permission.
//   
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  Created by Derek Smith.
//

#import "SGRecord.h"

static UIImage* kDefaultProfileImage = nil;

@interface SGSocialRecord :  SGRecord  
{
    /* 
     * The profile image for the social record. 
     */
    UIImage* profileImage;
    
    UIImage* photo;
    
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



