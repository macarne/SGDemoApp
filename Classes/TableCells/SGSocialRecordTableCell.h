//
//  SGSocialRecordTableCell.h
//  SGLocatorServices
//
//  Created by Derek Smith on 8/18/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SGSocialRecord.h"

@interface SGSocialRecordTableCell : UITableViewCell {

    SGSocialRecord* userProfile;
    
    @private
    UIImageView* serviceImageView;
}

@property (nonatomic, assign) SGSocialRecord* userProfile;

@end
