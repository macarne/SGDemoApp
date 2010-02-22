// 
//  SGSocialRecord.m
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

#import "SGSocialRecord.h"

#import "UIImageAdditions.h"

@implementation SGSocialRecord 

@synthesize helperView, photo, serviceImage;
@dynamic name, profileImage;

- (id) init
{
    if(self = [super init]) {
        
        serviceImage = nil;
        profileImage = nil;
        photo = nil;
        
        if(!kDefaultProfileImage)
            kDefaultProfileImage = [[UIImage imageWithImage:[UIImage imageNamed:@"SGDefaultProfilePicture.png"]
                                               scaledToSize:CGSizeMake(38.0, 38.0)] retain];

        
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (NSString*) name
{
        
    NSString* name = [self.properties objectForKey:@"name"];
    
    if(!name)
        name = [self.properties objectForKey:@"username"];
    
    return name;
}

- (NSString*) body
{
    return [self.properties objectForKey:@"body"];
}

- (NSString*) title
{
    return [self name];
}

- (NSString*) subtitle
{
    return [self.properties objectForKey:@"body"];
}

- (NSString*) profileURL
{
    return [self.properties objectForKey:@"url"]; 
}

- (UIImage*) coverImage
{
    return [self profileImage];
}

- (void) setProfileImage:(UIImage*)image
{
    profileImage = [image retain];
}

- (UIImage*) profileImage
{
    UIImage* pImage = profileImage;
    if(!pImage)
        pImage = kDefaultProfileImage;
    
    return pImage;
}

- (void) fetchImages
{
    BOOL recievedNewImage = NO;
    
    // Profile image
    NSString* urlString = [properties objectForKey:@"thumbnail"];
    if(!profileImage && urlString) {
     
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if(data) {
         
            self.profileImage = [UIImage imageWithData:data];
            recievedNewImage |= YES;
        }
        
    }
    
    // Photo image
    urlString = [properties objectForKey:@"image"];
    if(!photo && urlString) {
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if(data) {
            
            self.photo = [[UIImage imageWithData:data] retain];            
            recievedNewImage |= YES;
        }
        
    }

    if(recievedNewImage &&  helperView && [helperView isKindOfClass:[UIView class]])
        [helperView performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
    
}

@end
