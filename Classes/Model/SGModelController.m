//
//  SGModelController.m
//  SGDemoApp
//
//  Copyright (c) 2009-2010, SimpleGeo
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, 
//  this list of conditions and the following disclaimer. Redistributions 
//  in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or 
//  other materials provided with the distribution.
//  
//  Neither the name of the SimpleGeo nor the names of its contributors may
//  be used to endorse or promote products derived from this software 
//  without specific prior written permission.
//   
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS 
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE 
//  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  Created by Derek Smith.
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
