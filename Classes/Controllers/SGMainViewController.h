//
//  SGMainViewController.h
//  LocationDemo
//
//  Created by Derek Smith on 8/7/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SGLayerMapView.h"
#import "SGModelController.h"
#import "SGWebViewController.h"

@interface SGMainViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, SGLocationServiceDelegate> { 
    
    @private    
    UITableView* socialRecordTableView;
    UITableView* censusTableView;
                
    UISegmentedControl* segmentedControl;
    
    SGWebViewController* webViewController;
    SGARNavigationViewController* arNavigationViewController;
    SGLayerMapView* layerMapView;
                    
    SGModelController* modelController;
    CLLocationManager* locationManager;
    SGLocationService* locationService;
    
    SGCoverFlowView* albumScrollView;
    
    NSMutableArray* layers;
    NSMutableArray* currentLocationResponseIds;
    NSMutableArray* nearbySocialRecords;
    NSDictionary* addressInformation;
    
    UIBarButtonItem* leftButton, *rightButton, *locateButton;
    UILabel* bucketLabel;
    UILabel* loadingLabel;
}


@end
