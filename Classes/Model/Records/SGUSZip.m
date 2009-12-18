//
//  SGUSZip.m
//  SGiPhoneSDK
//
//  Created by Derek Smith on 11/13/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGUSZip.h"

#import "SGEntityDescriptions.h"

@interface SGUSZip (NSManagedObjectMethods)

- (void) setPrimitiveElevation:(NSNumber*)value;
- (NSData*) primitiveElevation;

@end

@implementation SGUSZip

@dynamic country, name, elevation;

+ (NSEntityDescription*) entityDescription
{
    return usZipDescription;
}


- (void) updateRecordWithGeoJSONDictionary:(NSDictionary*)dictionary
{
    [super updateRecordWithGeoJSONDictionary:dictionary];
    
    NSDictionary* properties = [dictionary objectForKey:@"properties"];
    
    if(properties) {

        NSString* string = [dictionary objectForKey:@"country"];
        if([self isValid:string])
            [self setCountry:string];
        
        string = [properties objectForKey:@"name"];
        if([self isValid:string])
            [self setName:string];
        
        NSNumber* number = [properties objectForKey:@"elevation"];
        if([self isValid:number])
            [self setElevation:[number doubleValue]];
        
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (double) elevation
{
    [self willAccessValueForKey:@"elevation"];
    NSNumber* number = [self primitiveElevation];
    [self didAccessValueForKey:@"elevation"];
    
    return [number doubleValue];
}


- (void) setElevation:(double)value
{
    [self willChangeValueForKey:@"elevation"];
    [self setPrimitiveElevation:[NSNumber numberWithDouble:value]];
    [self didChangeValueForKey:@"elevation"];
}


@end
