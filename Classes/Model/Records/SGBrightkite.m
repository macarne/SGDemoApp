//
//  SGBrightkite.m
//  SGiPhoneSDK
//
//  Created by Derek Smith on 11/13/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGBrightkite.h"

#import "SGEntityDescriptions.h"

static UIImage* brightkiteServiceImage = nil;

@interface SGBrightkite (NSManagedObjectMethods)

- (void) setPrimitiveBrightkiteImageData:(NSData*)data;
- (NSData*) primitiveBrightkiteImageData;

@end

@implementation SGBrightkite

@dynamic brightkiteImage, brightkiteImageURL, body;

+ (NSEntityDescription*) entityDescription
{
    return brightkiteDescription;
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    
    if(!brightkiteServiceImage)
        brightkiteServiceImage = [[UIImage imageNamed:@"BrightKite.png"] retain];
}

- (void) awakeFromFetch
{
    [super awakeFromFetch];
    
    if(!brightkiteServiceImage)
        brightkiteServiceImage = [[UIImage imageNamed:@"BrightKite.png"] retain];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) setBrightkiteImage:(UIImage*)image
{
    if(image) {
        
        NSData* data = UIImagePNGRepresentation(image);
        
        if(data) {
            
            [self willChangeValueForKey:@"brightkiteData"];
            [self setPrimitiveBrightkiteImageData:data];
            [self didChangeValueForKey:@"brightkiteData"];
            
        }
        
        
    }
}

- (UIImage*) brightkiteImage
{
    UIImage* image = nil;
    
    [self willAccessValueForKey:@"brightkiteData"];
    NSData* data = [self primitiveBrightkiteImageData];
    [self didAccessValueForKey:@"brightkiteData"];
    
    if(data)
        image = [UIImage imageWithData:data];
    
    return image;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGRecord overrides 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (UIImage*) serviceImage
{
    return brightkiteServiceImage;
}

- (NSString*) profileURL
{
    return [NSString stringWithFormat:@"http://brightkite.com/objects/%@", self.recordId];
}

- (void) fetchImages
{
    
    NSString* urlString = self.profileImageURL;
    
    if(urlString) {
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if(data) {
            
            UIImage* image = [UIImage imageWithData:data];
            [self setProfileImage:image];
            
        }
        
    }
    
    if(helperView && [helperView isKindOfClass:[UIView class]])
        [helperView performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
    
}

@end
