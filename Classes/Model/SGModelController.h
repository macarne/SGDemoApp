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

enum SGModelType {
    
    kSGModelType_Twitter = 0,
    kSGModelType_Flickr,
    kSGModelType_Brightkite,
    
    kSGModelType_Address,
    kSGModelType_USWeather,
    kSGModelType_USZip,
    kSGModelType_GeoNames,
    
    kSGModelType_Amount
};

typedef NSInteger SGModelType;

@interface SGModelController : NSObject {
    
    @private
    NSLock* imageLock;
    NSMutableArray* objectsInNeedOfImage;
    NSInteger threadCount;
}

+ (SGModelController*) modelController;

- (void) addObjectToImageLoader:(SGSocialRecord*)profile;
- (void) removeObjectFromImageLoader:(SGSocialRecord*)profile;

- (NSString*) stringForModelType:(SGModelType)type;


@end
