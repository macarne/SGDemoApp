//
//  SGBrightkiteLayer.m
//  SGDemoApp
//
//  Created by Derek Smith on 1/20/10.
//  Copyright 2010 SimpleGeo. All rights reserved.
//

#import "SGBrightkiteLayer.h"
#import "SGBrightkite.h"

@implementation SGBrightkiteLayer

- (id<SGRecordAnnotation>) recordAnnotationFromGeoJSONObject:(NSDictionary*)dictionary
{
    SGSocialRecord* record = [[[SGBrightkite alloc] init] autorelease];
    [record updateRecordWithGeoJSONObject:dictionary];
    
    return record;
}


@end
