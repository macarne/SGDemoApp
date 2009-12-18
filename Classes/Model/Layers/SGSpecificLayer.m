//
//  SGSpecificLayer.m
//  CCLocatorServices
//
//  Created by Derek Smith on 10/1/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGSpecificLayer.h"

#import "SGEntityDescriptions.h"
#import "SGSocialRecord.h"

@implementation SGSpecificLayer

@synthesize title;

- (id) initWithLayerName:(NSString*)name recordClass:(Class)class
{
    if(self = [super initWithLayerName:name]) {
            
        recordClass = class;
        
        NSArray* substrings = [name componentsSeparatedByString:@"."];
        title = [substrings objectAtIndex:[substrings count] - 1];
        
    }
    
    return self;
}

- (id<SGRecordAnnotation>) recordAnnotationFromGeoJSONDictionary:(NSDictionary *)dictionary
{
    SGSocialRecord* record = (SGSocialRecord*)[[recordClass alloc] initWithEntity:[recordClass entityDescription] insertIntoManagedObjectContext:context];
    [record updateRecordWithGeoJSONDictionary:dictionary];
    
    return record;    
}

- (void) dealloc
{
    [title release];
    
    [super dealloc];
}

@end
