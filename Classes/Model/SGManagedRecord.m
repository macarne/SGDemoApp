//
//  SGManagedRecord.m
//  CCLocatorServices
//
//  Created by Derek Smith on 9/16/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGManagedRecord.h"

#import "SGLocationTypes.h"

@interface SGManagedRecord (NSManagedObjectMethods)

- (void) setPrimitiveLatitude:(NSNumber*)latitude;
- (NSNumber*) primitiveLatitude;

- (void) setPrimitiveLongitude:(NSNumber*)longitude;
- (NSNumber*) primitiveLongitude;

- (void) setPrimitiveExpirationTimeInterval:(NSNumber*)number;
- (NSNumber*) primitiveExpirationTimeInterval;

- (void) setPrimitiveCreationTimeInterval:(NSNumber*)number;
- (NSNumber*) primitiveCreationTimeInterval;

- (BOOL) isValid:(NSObject *)object;

@end


@implementation SGManagedRecord 

@dynamic longitude, latitude, creationTimeInterval, expirationTimeInterval, layer, type, recordId;

- (void) awakeFromInsert
{
    NSString* recordLayer = self.layer;
    
    if(!recordLayer)
        [self setLayer:[[NSBundle mainBundle] bundleIdentifier]];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) setLongitude:(double)newLongitude
{
    [self willChangeValueForKey:@"longitude"];
    [self setPrimitiveLongitude:[NSNumber numberWithDouble:newLongitude]];
    [self didChangeValueForKey:@"longitude"];
}

- (double) longitude
{
    [self willAccessValueForKey:@"longitude"];
    double lon = [[self primitiveLongitude] doubleValue];
    [self didAccessValueForKey:@"longitude"];
    
    return lon;
}

- (void) setLatitude:(double)newLatitude
{
    [self willChangeValueForKey:@"latitude"];
    [self setPrimitiveLatitude:[NSNumber numberWithDouble:newLatitude]];
    [self didChangeValueForKey:@"latitude"];        
}

- (double) latitude
{
    [self willAccessValueForKey:@"latitude"];
    double lat = [[self primitiveLatitude] doubleValue];
    [self didAccessValueForKey:@"latitude"];
    
    return lat;
}

- (double) creationTimeInterval
{
    [self willAccessValueForKey:@"creationTimeInterval"];
    double timeInterval = [[self primitiveCreationTimeInterval] doubleValue];
    [self didAccessValueForKey:@"creationTimeInterval"];
    
    return timeInterval;
}

- (void) setCreationTimeInterval:(NSTimeInterval)date
{
    [self willChangeValueForKey:@"creationTimeInterval"];
    [self setPrimitiveCreationTimeInterval:[NSNumber numberWithDouble:date]];
    [self didChangeValueForKey:@"creationTimeInterval"];
}

- (NSTimeInterval) expirationTimeInterval
{
    [self willAccessValueForKey:@"expirationTimeInterval"];
    double timeInterval = [[self primitiveExpirationTimeInterval] doubleValue];
    [self didAccessValueForKey:@"expirationTimeInterval"];
        
    return timeInterval;
}

- (void) setExpirationTimeInterval:(NSTimeInterval)date
{
    [self willChangeValueForKey:@"expirationTimeInterval"];
    [self setPrimitiveExpirationTimeInterval:[NSNumber numberWithDouble:date]];
    [self didChangeValueForKey:@"expirationTimeInterval"];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MKAnnotation methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (CLLocationCoordinate2D) coordinate
{    
    CLLocationCoordinate2D myCoordinate = {[self latitude], [self longitude]};
    
    return myCoordinate;
}

- (NSString*) title
{
    return [self recordId];
}

- (NSString*) subtitle
{
    return [self layer];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Dictionary/Records 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) updateRecordWithGeoJSONDictionary:(NSDictionary*)dictionary
{
    if(dictionary && [dictionary count]) {
        
        NSArray* coordinates = [dictionary objectForKey:@"coordinates"];
        
        if([self isValid:coordinates]) {
            
            NSNumber* number = [coordinates objectAtIndex:0];
            if([self isValid:number])
                [self setLatitude:[number doubleValue]];
            
            number = [coordinates objectAtIndex:1];
            if([self isValid:number])
                [self setLongitude:[number doubleValue]];
            
        }
        
        NSDictionary* properties = [dictionary objectForKey:@"properties"];
        
        if([self isValid:properties]) {
            
            NSNumber* number = [properties objectForKey:@"expires"];
            if([self isValid:number])
                [self setExpirationTimeInterval:[number doubleValue]];
            
            number = [properties objectForKey:@"created"];
            if([self isValid:number])
                [self setCreationTimeInterval:[number doubleValue]];
            
            NSString* value = [properties objectForKey:@"id"];
            if([self isValid:value]) {
                
                if([value isKindOfClass:[NSNumber class]])
                    value = [(NSNumber*)value stringValue];
                
                [self setRecordId:value];
            }
            
            value = [properties objectForKey:@"type"];
            if([self isValid:value])
                [self setType:value];
            
            value = [properties objectForKey:@"layer"];
            if([self isValid:value])
                [self setLayer:value];
        }
        
    }
}

- (NSDictionary*) propertiesForRecord
{
    NSDictionary* dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [self layer], @"layer",
                                       [self recordId], @"id",
                                       [self type], @"type",
                                       [NSNumber numberWithDouble:[self expirationTimeInterval]], @"expires",
                                       [NSNumber numberWithDouble:[self creationTimeInterval]], @"created", 
                                       nil];
    
    
    return dictionary;
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<id=%@: type=%@, layer=%@, lat=%f, lon=%f, expires=%i, created=%i>", [self recordId], self.type,
            self.layer, self.latitude, self.longitude, (int)self.expirationTimeInterval, (int)self.creationTimeInterval];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Helper methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (BOOL) isValid:(NSObject*)object
{
    return object && ![object isKindOfClass:[NSNull class]];
}

@end
