//
//  SGPinAnnotationView.m
//  LocationDemo
//
//  Created by Derek Smith on 8/7/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGPinAnnotationView.h"
#import "SGSocialRecord.h"

static UIImage* DefaultImage = nil;

@implementation SGPinAnnotationView

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString*)ident
{
    if(self = [super initWithAnnotation:annotation reuseIdentifier:ident]) {
        
        
        if(!DefaultImage)
            DefaultImage = [[UIImage imageNamed:@"SGDefaultProfilePicture.png"] retain];
        
        self.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
        
        objectImageView = [[UIImageView alloc] initWithImage:nil];
        objectImageView.frame = CGRectMake(12.0, 12.0, 16.0, 16.0);
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:DefaultImage];
        imageView.frame = CGRectMake(0.0, 0.0, 28.0, 28.0);
        [imageView addSubview:objectImageView];
        
        self.leftCalloutAccessoryView = imageView;
    }
    
    return self;
}

- (void) prepareForReuse
{
    if(self.annotation)
        ((SGSocialRecord*)self.annotation).helperView = nil;
    
    [super prepareForReuse];    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
        
    SGSocialRecord* record = (SGSocialRecord*)self.annotation;
    
    UIImage* image = record.profileImage;
    
    if(!image || [image isKindOfClass:[NSNull class]])
        image = DefaultImage;    
    
    objectImageView.image = record.serviceImage;
    
    ((UIImageView*)self.leftCalloutAccessoryView).image = image; 
}


@end
