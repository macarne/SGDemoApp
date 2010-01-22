//
//  SGTwitterLayer.m
//  SGDemoApp
//
//  Created by Derek Smith on 1/20/10.
//  Copyright 2010 SimpleGeo. All rights reserved.
//

#import "SGTwitterLayer.h"
#import "SGTweet.h"

@implementation SGTwitterLayer

- (id<SGRecordAnnotation>) recordAnnotationFromGeoJSONDictionary:(NSDictionary*)dictionary
{
    SGSocialRecord* record = (SGSocialRecord*)[[[SGTweet alloc] init] autorelease];
    [record updateRecordWithGeoJSONDictionary:dictionary];
    
    return record;
}

@end
