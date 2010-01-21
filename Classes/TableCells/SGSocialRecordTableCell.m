//
//  SGSocialRecordTableCell.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/18/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
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
