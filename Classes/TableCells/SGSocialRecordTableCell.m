//
//  SGSocialRecordTableCell.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/18/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGSocialRecordTableCell.h"

#import "UIImageAdditions.h"

static UIImage* kDefaultImage = nil;

@implementation SGSocialRecordTableCell

@dynamic userProfile;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        if(!kDefaultImage)
            kDefaultImage = [[UIImage imageWithImage:[UIImage imageNamed:@"SGDefaultProfilePicture.png"] scaledToSize:CGSizeMake(38.0, 38.0)] retain];
        
        serviceImageView = [[UIImageView alloc] initWithImage:kDefaultImage];
        serviceImageView.frame = CGRectMake(22.0, 22.0, 16.0, 16.0);
        [self.imageView addSubview:serviceImageView];
    }
    
    return self;
}

- (void) setUserProfile:(SGSocialRecord*)profile
{
    userProfile = profile;
    
    serviceImageView.image =  profile.serviceImage;
    
    self.textLabel.text = profile.name;
    self.detailTextLabel.text = profile.body;
    
    UIImage* image = profile.profileImage;
    
    if(!image || (image && [image isKindOfClass:[NSNull class]]))
        image = kDefaultImage;
    else
        image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(38.0, 38.0)];
    
    self.imageView.image = image;
}

- (SGSocialRecord*) userProfile
{
    return userProfile;
}

- (void) dealloc
{
    [serviceImageView release];
    [super dealloc];
}


@end
