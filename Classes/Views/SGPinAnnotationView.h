//
//  SGPinAnnotationView.h
//  LocationDemo
//
//  Created by Derek Smith on 8/7/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SGPinAnnotationView : MKPinAnnotationView {

    @private
    UIImageView* recordImageView;
}

@end
