//
//  SGFlickrLayer.m
//  SGDemoApp
//
//  Created by Derek Smith on 1/20/10.
//  Copyright 2010 SimpleGeo. All rights reserved.
//

#import "SGFlickrLayer.h"
#import "SGFlickr.h"

@implementation SGFlickrLayer

- (id<SGRecordAnnotation>) recordAnnotationFromGeoJSONObject:(NSDictionary*)dictionary
{
    SGSocialRecord* record = (SGSocialRecord*)[[[SGFlickr alloc] init] autorelease];
    [record updateRecordWithGeoJSONObject:dictionary];
    
    return record;
}

@end
