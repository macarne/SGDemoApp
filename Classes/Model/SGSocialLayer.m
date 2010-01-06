//
//  SGSocialLayer.m
//  SGDemoApp
//
//  Created by Derek Smith on 12/21/09.
//  Copyright 2009 CrashCorp. All rights reserved.
//

#import "SGSocialLayer.h"

#import "SGSocialRecord.h"


@implementation SGSocialLayer

@synthesize socialRecordClass;

- (id<SGRecordAnnotation>) recordAnnotationFromGeoJSONDictionary:(NSDictionary*)dictionary
{
    SGSocialRecord* record = (SGSocialRecord*)[[[socialRecordClass alloc] init] autorelease];
    [record updateRecordWithGeoJSONDictionary:dictionary];
    
    return record;
}

@end
