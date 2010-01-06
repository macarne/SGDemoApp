//
//  SGSocialLayer.h
//  SGDemoApp
//
//  Created by Derek Smith on 12/21/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGLayer.h"

@interface SGSocialLayer : SGLayer {

    Class socialRecordClass;
}

@property (nonatomic, readwrite) Class socialRecordClass;

@end
