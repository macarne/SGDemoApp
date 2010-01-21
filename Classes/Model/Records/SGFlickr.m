// 
//  SGFlickr.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGFlickr.h"

@implementation SGFlickr 

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (UIImage*) photo
{
    return profileImage;
}

- (UIImage*) serviceImage
{
    return [UIImage imageNamed:@"Flickr.png"];
}


@end

