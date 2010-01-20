// 
//  SGSocialRecord.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGSocialRecord.h"

@implementation SGSocialRecord 

@synthesize helperView, profileImage, photo, serviceImage;
@dynamic name;

- (id) init
{
    if(self = [super init]) {
        
        serviceImage = nil;
        
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (NSString*) name
{
        
    NSString* name = [self.userDefinedProperties objectForKey:@"name"];
    
    if(!name)
        name = [self.userDefinedProperties objectForKey:@"username"];
    
    return name;
}

- (NSString*) body
{
    return [self.userDefinedProperties objectForKey:@"body"];
}

- (NSString*) title
{
    return [self name];
}

- (NSString*) subtitle
{
    return [self.userDefinedProperties objectForKey:@"body"];
}

- (NSString*) profileURL
{
    return [self.userDefinedProperties objectForKey:@"url"]; 
}

- (UIImage*) coverImage
{
    return [self profileImage];
}

- (void) fetchImages
{
    BOOL recievedNewImage = NO;
    
    // Profile image
    NSString* urlString = [self.userDefinedProperties objectForKey:@"thumbnail"];
    if(urlString) {
     
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if(data) {
         
            self.profileImage = [[UIImage imageWithData:data] retain];
            recievedNewImage = YES;
        }
        
    }
    
    // Photo image
    urlString = [self.userDefinedProperties objectForKey:@"image"];
    if(urlString) {
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if(data) {
            
            self.photo = [[UIImage imageWithData:data] retain];            
            recievedNewImage = YES;
        }
        
    }

    if(recievedNewImage &&  helperView && [helperView isKindOfClass:[UIView class]])
        [helperView performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
    
}

@end
