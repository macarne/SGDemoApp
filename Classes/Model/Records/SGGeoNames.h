//
//  SGGeoNames.h
//  SGiPhoneSDK
//
//  Created by Derek Smith on 11/13/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGManagedRecord.h"

@interface SGGeoNames : SGManagedRecord {

}

@property (nonatomic, retain) NSString* country;
@property (nonatomic, assign) double elevation;

@end
