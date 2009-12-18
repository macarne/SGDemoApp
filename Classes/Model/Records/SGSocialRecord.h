//
//  SGSocialRecord.h
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGManagedRecord.h"

@interface SGSocialRecord :  SGManagedRecord  
{
    UIImage* profileImage;
    UIImage* serviceImage;    
    
    UIView* helperView;
}

@property (nonatomic, retain) UIImage* profileImage;
@property (nonatomic, retain) UIImage* serviceImage;

@property (retain) UIView* helperView;

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* profileImageURL;
@property (nonatomic, retain) NSString* name;

@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) UIImage* photo;
@property (nonatomic, retain) NSString* photoURL;

- (NSString*) profileURL;
- (void) fetchImages;

@end



