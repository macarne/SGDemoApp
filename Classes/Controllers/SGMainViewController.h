//
//  SGMainViewController.h
//  LocationDemo
//
//  Created by Derek Smith on 8/7/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "SimpleGeo.h"

#import "SGModelController.h"
#import "SGWebViewController.h"

@interface SGMainViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, SGLocationServiceDelegate> { 
    
    @private    
    UITableView* recordTableView;
    UITableView* censusTableView;
                
    UISegmentedControl* segmentedControl;
    
    SGWebViewController* webViewController;
    SGARNavigationViewController* arNavigationViewController;
    SGLayerMapView* layerMapView;
                    
    SGModelController* modelController;
    SGLocationService* locationService;
    
    SGCoverFlowView* albumScrollView;
    
    NSMutableArray* layers;
    NSMutableArray* currentLocationResponseIds;
    NSMutableArray* closeRecordAnnotations;
    
    UIBarButtonItem* leftButton, *rightButton;
    UILabel* bucketLabel;
    UILabel* loadingLabel;
}


@end
