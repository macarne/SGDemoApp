// 
//  SGFlickr.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGFlickr.h"

#import "SGEntityDescriptions.h"

static UIImage* flickrServiceImage = nil;

@implementation SGFlickr 

+ (NSEntityDescription*) entityDescription
{
    return flickrDescription;
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    
    if(!flickrServiceImage)
        flickrServiceImage = [[UIImage imageNamed:@"Flickr.png"] retain];
}

- (void) awakeFromFetch
{
    [super awakeFromFetch];
    
    if(!flickrServiceImage)
        flickrServiceImage = [[UIImage imageNamed:@"Flickr.png"] retain];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGRecord overrides 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (UIImage*) serviceImage
{
    return flickrServiceImage;
}

- (NSString*) profileURL
{
    return [NSString stringWithFormat:@"http://flickr.com/photos/%@/%@", self.username, self.recordId];
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

