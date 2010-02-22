//
//  SGPinAnnotationView.m
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
        
        recordImageView = [[UIImageView alloc] initWithImage:nil];
        recordImageView.frame = CGRectMake(14.0, 14.0, 16.0, 16.0);
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:DefaultImage];
        imageView.frame = CGRectMake(0.0, 0.0, 28.0, 28.0);
        [imageView addSubview:recordImageView];
        
        self.animatesDrop = YES;
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
    
    recordImageView.image = record.serviceImage;
    
    ((UIImageView*)self.leftCalloutAccessoryView).image = image; 
}


@end
