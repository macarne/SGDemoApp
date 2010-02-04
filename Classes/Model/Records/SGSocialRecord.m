// 
//  SGSocialRecord.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
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
