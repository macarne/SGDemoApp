// 
//  SGSocialRecord.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGSocialRecord.h"

#import "SGModelController.h"
#import "SGEntityDescriptions.h"

@interface SGSocialRecord (NSManagedObjectMethods)

- (void) setPrimitiveProfileImageData:(NSData*)data;
- (NSData*) primitiveProfileImageData;

- (void) setPrimitiveProfilePhotoData:(NSData*)data;
- (NSData*) primitiveProfilePhotoData;


@end


@implementation SGSocialRecord 

@synthesize helperView;
@dynamic profileImage, serviceImage, body, username, photo, photoURL, profileImageURL;

- (void) awakeFromInsert
{
    [super awakeFromInsert];

    helperView = nil;
}

- (void) awakeFromFetch
{
    [super awakeFromFetch];
    
    helperView = nil;
}

- (void) updateRecordWithGeoJSONDictionary:(NSDictionary*)dictionary
{
    [super updateRecordWithGeoJSONDictionary:dictionary];
    
    NSDictionary* properties = [dictionary objectForKey:@"properties"];
    
    if(properties) {
        
        NSString* string = [properties objectForKey:@"name"];
        if([self isValid:string])
            [self setName:string];
        
        string = [properties objectForKey:@"username"];
        if([self isValid:string])
            [self setUsername:string];
        
        string = [properties objectForKey:@"thumbnail"];
        if([self isValid:string])
            [self setProfileImageURL:string];
        
        string = [properties objectForKey:@"thumbnail"];
        if([self isValid:string])
            [self setProfileImageURL:string];
            
        string = [properties objectForKey:@"body"];
        if([self isValid:string])
            [self setBody:string];
        
        string = [properties objectForKey:@"image"];
        if([self isValid:string])
            [self setPhotoURL:string];
                
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) setProfileImage:(UIImage*)image
{
    if(image) {
        
        NSData* data = UIImagePNGRepresentation(image);
        
        if(data) {
         
            [self willChangeValueForKey:@"profileImageData"];
            [self setPrimitiveProfileImageData:data];
            [self didChangeValueForKey:@"profileImageData"];
            
        }
    }
}

- (UIImage*) profileImage
{
    
    UIImage* image = nil;
     
    [self willAccessValueForKey:@"profileImageData"];
    NSData* data = [self primitiveProfileImageData];
    [self didAccessValueForKey:@"profileImageData"];
        
    if(data)
        image = [UIImage imageWithData:data];
    
    return image;
}

- (void) photo:(UIImage*)image
{
    if(image) {
     
        NSData* data = UIImagePNGRepresentation(image);
            
        if(data) {
            
            [self willChangeValueForKey:@"photoData"];
            [self setPrimitivePhotoData:data];
            [self didChangeValueForKey:@"photoData"];
                
        }
                
            
    }
}

- (UIImage*) photo
{
    UIImage* image = nil;
        
    [self willAccessValueForKey:@"photoData"];
    NSData* data = [self primitivePhotoData];
    [self didAccessValueForKey:@"photoData"];
        
    if(data)
        image = [UIImage imageWithData:data];
            
    return image;
}


- (NSString*) name
{
        
    [self willAccessValueForKey:@"name"];
    NSString* name = [self primitiveName];
    [self didAccessValueForKey:@"name"];
    
    if(!name)
        name = [self username];
    
    return name;
}

- (NSString*) title
{
    return self.name;
}

- (NSString*) subtitle
{
    return self.body;
}

- (NSString*) profileURL
{
    return @"";
}

- (UIImage*) coverImage
{
    return [self profileImage];
}

- (void) fetchImages
{
    BOOL recievedNewImage = NO;
    
    NSString* urlString = self.profileImageURL;
    if(urlString) {
     
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if(data) {
         
            UIImage* image = [UIImage imageWithData:data];
            [self setProfileImage:image];
            
            recievedNewImage = YES;
        }
        
    }
    
    urlString = self.photoURL;
    if(urlString) {
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        
        if(data) {
            
            UIImage* image = [UIImage imageWithData:data];
            [self setPhoto:image];
            
            recievedNewImage = YES;
        }
        
    }

    if(recievedNewImage &&  helperView && [helperView isKindOfClass:[UIView class]])
        [helperView performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
    
}

@end
