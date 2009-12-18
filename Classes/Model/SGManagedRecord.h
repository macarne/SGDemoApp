//
// SGManagedRecord.h
// CCLocatorServices
//
// Created by Derek Smith on 9/16/09.
// Copyright 2009 SimpleGeo. All rights reserved.
//

@interface SGManagedRecord : NSManagedObject <SGRecordAnnotation>
{
    
}

@property (nonatomic, retain) NSString* recordId;
@property (nonatomic, retain) NSString* layer;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@property (nonatomic, assign) NSTimeInterval creationTimeInterval;
@property (nonatomic, assign) NSTimeInterval expirationTimeInterval;

@property (nonatomic, retain) NSString* type;

/*
 * Ensures that an object is valid.
 */
- (BOOL) isValid:(NSObject*)object; 

@end



