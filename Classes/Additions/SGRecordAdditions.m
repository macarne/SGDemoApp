//
//  SGRecordAdditions.m
//  SGDemoApp
//
//  Created by Derek Smith on 12/21/09.
//  Copyright 2009 CrashCorp. All rights reserved.
//

#import "SGRecordAdditions.h"

@implementation SGRecord (SimpleGeoAdditions)


- (BOOL) isValid:(NSObject*)object
{
    return object && ![object isKindOfClass:[NSNull class]];
}

@end
