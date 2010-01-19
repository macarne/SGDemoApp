//
//  SGModelController.h
//  CCLocatorServices
//
//  Created by Derek Smith on 9/16/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGLocationTypes.h"
#import "SGSocialRecord.h"

enum SGLayerType {
    
    kSGLayerType_Twitter = 0,
    kSGLayerType_Flickr,
    kSGLayerType_Brightkite,
    
    kSGLayerType_USWeather,
    kSGLayerType_USZip,
    kSGLayerType_GeoNames,
    
    kSGLayerType_Amount
};

typedef NSInteger SGLayerType;

@interface SGModelController : NSObject {
    
    @private
    NSLock* imageLock;
    NSMutableArray* objectsInNeedOfImage;
    NSInteger threadCount;
}

+ (SGModelController*) modelController;

- (void) addObjectToImageLoader:(SGSocialRecord*)profile;
- (void) removeObjectFromImageLoader:(SGSocialRecord*)profile;

- (NSString*) stringForModelType:(SGLayerType)type;


@end
