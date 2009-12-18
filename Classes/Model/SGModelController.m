//
//  SGModelController.m
//  CCLocatorServices
//
//  Created by Derek Smith on 9/16/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGModelController.h"

#import "SGEntityDescriptions.h"

static SGModelController* modelController = nil;

@implementation SGModelController

@synthesize locationManager;

- (id) init
{
    if(self = [super init]) {
        
        locationManager = [[CLLocationManager alloc] init];
        
        objectsInNeedOfImage = [[NSMutableArray alloc] init];
        imageLock = [[NSLock alloc] init];
        threadCount = 0;
    }
    
    return self;
}

+ (SGModelController*) modelController 
{
    if(!modelController)
        modelController = [[SGModelController alloc] init];
    
    return modelController;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Queries 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (NSArray*) getAllRecords
{
    NSMutableArray* records = [NSMutableArray array];
    for(int i = 0; i < kSGLayerType_Amount; i++)
        [records addObjectsFromArray:[self getRecordsOfType:i]];
    
    return records;
}

- (NSArray*) getRecordsOfType:(SGLayerType)modelType
{
    NSMutableArray* records = [NSMutableArray array];
    
    NSEntityDescription* description = nil;
    switch (modelType) {
        case kSGLayerType_Twitter:
            description = twitterDescription;
            break;
        case kSGLayerType_Flickr:
            description = flickrDescription;
            break;            
        case kSGLayerType_Brightkite:
            description = brightkiteDescription;
            break;
        case kSGLayerType_USZip:
            description = usZipDescription;
            break;
        case kSGLayerType_USWeather:
            description = usWeatherDescription;
            break;
        case kSGLayerType_GeoNames:
            description = geoNamesDescription;
            break;
        default:
            break;
    }
    
    if(description) {
     
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        [request setEntity:description];
        [request setReturnsObjectsAsFaults:NO];
        
        NSArray* array = [context executeFetchRequest:request error:nil];
        [request release];
        
        if(array)
            [records addObjectsFromArray:array];
        
    }
    
    return records;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Image loaders 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) addObjectToImageLoader:(SGSocialRecord*)object
{
    if(object) {
        
        [objectsInNeedOfImage addObject:object];
        
        if(threadCount < 2) {
            
            threadCount++;
            [NSThread detachNewThreadSelector:@selector(runImageLoader) toTarget:self withObject:nil];
            
        }    
    }
}

- (void) removeObjectFromImageLoader:(SGSocialRecord*)profile
{
    if(profile) {
     
        [objectsInNeedOfImage removeObject:profile];
        
    }
}

- (void) runImageLoader
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    SGSocialRecord* object = nil;
    while([objectsInNeedOfImage count]) {
        
        [imageLock lock];
        if([objectsInNeedOfImage count]) {
            
            object = [[objectsInNeedOfImage objectAtIndex:0] retain]; 
            [objectsInNeedOfImage removeObjectAtIndex:0];
            
        }
        [imageLock unlock];
        
        if(object) {
            
            [object fetchImages];
            [object release];
        }
        
        object = nil;
    }
    
    threadCount--;
    
    [pool release];
}

- (NSString*) stringForModelType:(SGLayerType)type
{
    NSString* typeString = @"";
    
    switch (type) {
        case kSGLayerType_Twitter:
            typeString = @"Twitter";
            break;
        case kSGLayerType_Flickr:
            typeString = @"Flickr";
            break;
        case kSGLayerType_Brightkite:
            typeString = @"Brightkite";
            break;
        case kSGLayerType_USZip:
            typeString = @"USZip";
            break;
        case kSGLayerType_USWeather:
            typeString = @"USWeather";
            break;
        case kSGLayerType_GeoNames:
            typeString = @"GeoNames";
            break;
        default:
            break;
    }
    
    
    return typeString;
}


@end
