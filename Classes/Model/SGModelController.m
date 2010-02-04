//
//  SGModelController.m
//  CCLocatorServices
//
//  Created by Derek Smith on 9/16/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGModelController.h"

static SGModelController* modelController = nil;

@implementation SGModelController

- (id) init
{
    if(self = [super init]) {
        
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

- (NSString*) stringForModelType:(SGModelType)type
{
    NSString* typeString = @"";
    
    switch (type) {
        case kSGModelType_Twitter:
            typeString = @"Twitter";
            break;
        case kSGModelType_Flickr:
            typeString = @"Flickr";
            break;
        case kSGModelType_Brightkite:
            typeString = @"Brightkite";
            break;
        case kSGModelType_Address:
            typeString = @"Reverse Geocode";
            break;
        case kSGModelType_USZip:
            typeString = @"USZip";
            break;
        case kSGModelType_USWeather:
            typeString = @"USWeather";
            break;
        case kSGModelType_GeoNames:
            typeString = @"GeoNames";
            break;
        default:
            break;
    }
    
    
    return typeString;
}


@end
