//
//  SGSocialRecordTableCell.m
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

#import "SGSocialRecordTableCell.h"
#import "UIImageAdditions.h"

@implementation SGSocialRecordTableCell

@dynamic userProfile;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
                
        serviceImageView = [[UIImageView alloc] initWithImage:nil];
        [self.imageView addSubview:serviceImageView];
        
        userProfile = nil;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

- (void) setUserProfile:(SGSocialRecord*)profile
{
    if(userProfile)
        userProfile.helperView = nil;
    
    userProfile = profile;
    serviceImageView.image =  profile.serviceImage;
    userProfile.helperView = self;
    
    [self layoutSubviews];
}

- (SGSocialRecord*) userProfile
{
    return userProfile;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.text = userProfile.name;
    self.detailTextLabel.text = userProfile.body;
    self.imageView.image = userProfile.profileImage;
    serviceImageView.frame = CGRectMake(self.imageView.frame.size.width - 16.0,
                                        self.imageView.frame.size.height - 16.0,
                                        16.0, 16.0);
}

- (void) dealloc
{
    [serviceImageView release];
    [super dealloc];
}

@end
