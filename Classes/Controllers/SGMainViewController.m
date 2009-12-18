//
//  SGMainViewController.m
//  LocationDemo
//
//  Created by Derek Smith on 8/7/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGMainViewController.h"

/* Records */
#import "SGFlickr.h"
#import "SGTweet.h"
#import "SGBrightkite.h"
#import "SGUSZip.h"
#import "SGUSWeather.h"
#import "SGGeoNames.h"

#import "SGSpecificLayer.h"

#import "SGPinAnnotationView.h"                                                                                             
#import "SGSocialRecordTableCell.h"


#define kCensusSection_Weather          0
#define kCensusSection_Zip              1
#define kCensusSection_GeoNames         2


@interface SGMainViewController (Private) <UITableViewDelegate, UITableViewDataSource, SGARNavigationViewControllerDataSource, SGCoverFlowViewDelegate>

- (void) initializeLocationService;
- (void) initializeLayers;
- (void) initializeARView;

- (void) presentError:(NSError *)error;
- (void) lockScreen:(BOOL)lock;

- (void) setupAnnotationView:(SGAnnotationView *)annotationView;
- (void) centerMap:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (SGLayerType) layerTypeForResponseId:(NSString *)requestId;

@end


@implementation SGMainViewController 


- (id) init
{
    if(self = [super init]) {
                        
        self.title = @"Demo";
        self.hidesBottomBarWhenPushed = NO;
        
        modelController = [SGModelController modelController];
        modelController.locationManager.delegate = self;
        [modelController.locationManager startUpdatingLocation];        
        
        [self initializeLocationService];
        [self initializeARView];
            
        layerMapView = [[SGLayerMapView alloc] initWithFrame:CGRectZero];
        layerMapView.delegate = self;
        layerMapView.limit = 30;
        [layerMapView stopRetrieving];
        
        [self initializeLayers];
     
        closeRecordAnnotations = [[NSArray arrayWithObjects:
                                  [NSMutableArray array],
                                  [NSMutableArray array],
                                  [NSMutableArray array],
                                  [NSMutableArray array],
                                  [NSMutableArray array],
                                  [NSMutableArray array],
                                  nil] retain];
        
        webViewController = [[SGWebViewController alloc] init];
    }
    
    return self;
}

- (void) initializeLocationService
{
    locationService = [SGLocationService sharedLocationService];
    [locationService addDelegate:self];
    [SGLocationService callbackOnMainThread:YES];
        
    SGSetEnvironmentViewingRadius(1000.0f);         // 1km
    
    SGOAuth* oAuth = [[SGOAuth alloc] initWithKey:@"" secret:@""];
    locationService.HTTPAuthorizer = oAuth;
}

- (void) initializeLayers
{
    layers = [[NSMutableArray alloc] init];
    
    currentLocationResponseIds = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < kSGLayerType_Amount; i++) {

        Class recordClass;
        NSString* layerName;
        
        switch (i) {
                
            case kSGLayerType_Brightkite:
            {
                recordClass = [SGBrightkite class];
                layerName = @"com.simplegeo.global.brightkite";
            }
                break;
            case kSGLayerType_Twitter:
            {
                recordClass = [SGTweet class];
                layerName = @"com.simplegeo.global.twitter";
            }
                break;
            case kSGLayerType_Flickr:
            {
                recordClass = [SGFlickr class];
                layerName = @"com.simplegeo.global.flickr";
            }
                break;
            case kSGLayerType_GeoNames:
            {
                recordClass = [SGGeoNames class];
                layerName = @"com.simplegeo.global.geonames";
            }
                break;
            case kSGLayerType_USZip:
            {
                recordClass = [SGUSZip class];
                layerName = @"com.simplegeo.us.zip";
            }
                break;
            case kSGLayerType_USWeather:
            {
                recordClass = [SGUSWeather class];
                layerName = @"com.simplegeo.us.weather";
            }
                break;                
            default:
                break;
        }
        
        SGSpecificLayer* layer = [[SGSpecificLayer alloc] initWithLayerName:layerName recordClass:recordClass];
        [layers addObject:layer];
        [currentLocationResponseIds addObject:[NSNull null]];
    }
    
    // Add the layers that we want to view in the map.
    [layerMapView addLayer:[layers objectAtIndex:kSGLayerType_Brightkite]];
    [layerMapView addLayer:[layers objectAtIndex:kSGLayerType_Flickr]];
    [layerMapView addLayer:[layers objectAtIndex:kSGLayerType_Twitter]];
    
}

- (void) initializeARView
{
    arNavigationViewController = [[SGARNavigationViewController alloc] init];
    arNavigationViewController.dataSource = self;
    
    arNavigationViewController.arView.enableWalking = NO;
    
    
    SGAnnotationViewContainer* container = [[[SGAnnotationViewContainer alloc] initWithFrame:CGRectZero] autorelease];
    container.frame = CGRectMake(200.0,
                                 300.0,
                                 container.frame.size.width,
                                 container.frame.size.height);
    
    [container addTarget:self action:@selector(containerSelected:) forControlEvents:UIControlEventTouchDown];
    [arNavigationViewController.arView addContainer:container];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController overrides 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) loadView
{
    [super loadView];
            
    recordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    self.view.bounds.size.width,
                                                                    self.view.bounds.size.height - self.navigationController.toolbar.frame.size.height)
                                                   style:UITableViewStylePlain];
    recordTableView.dataSource = self;
    recordTableView.delegate = self;
    [self.view addSubview:recordTableView];
    
    censusTableView = [[UITableView alloc] initWithFrame:recordTableView.bounds style:UITableViewStyleGrouped];
    censusTableView.backgroundColor = [UIColor lightGrayColor];
    censusTableView.dataSource = self;
    censusTableView.delegate = self;
    [self.view addSubview:censusTableView];
    
    layerMapView.frame = self.view.bounds;    
    [self.view addSubview:layerMapView];
 
    arNavigationViewController.title = @"Ground Level";
    
    albumScrollView = [[SGCoverFlowView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 350.0) 
                                               maximumAlbums:10];
    [albumScrollView.closeButton addTarget:self action:@selector(closeAlbumView:) forControlEvents:UIControlEventTouchDown];
    albumScrollView.delegate = self;
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"BlueTargetButton.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(locateMe:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0, 0.0, 30.0, 44.0);
    UIBarButtonItem* locateButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    locateButton.width = 30.0;
    
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [infoButton addTarget:self action:@selector(showCensusInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    // When tag == 0 then censusTableView is hidden.
    infoButton.tag = 0;
    
    // Add the bar button to both nav controllers.
    self.navigationItem.rightBarButtonItem = barButton;
    [barButton release];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"3D", @"Map", @"List", nil]];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;  
    [segmentedControl setWidth:70.0 forSegmentAtIndex:0];
    [segmentedControl setWidth:70.0 forSegmentAtIndex:1];
    [segmentedControl setWidth:70.0 forSegmentAtIndex:2];
    [segmentedControl addTarget:self action:@selector(changeViews:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 1;
    segmentedControl.frame = CGRectMake(0.0, 0.0, segmentedControl.frame.size.width, segmentedControl.frame.size.height);
    UIBarButtonItem* segmentedControlButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    [self setToolbarItems:[NSArray arrayWithObjects:locateButton, segmentedControlButton, nil] animated:NO];
    [locateButton release];
    [segmentedControlButton release];    
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 64.0, self.view.frame.size.width, self.view.frame.size.height - 88.0)];
    loadingLabel.text = @"Loading Records...";
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.font = [UIFont boldSystemFontOfSize:18.0];
    loadingLabel.textColor = [UIColor grayColor];
    loadingLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    [[[UIApplication sharedApplication] keyWindow] addSubview:loadingLabel];
    
    
    leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftButton.png"]
                                                  style:UIBarButtonItemStylePlain 
                                                 target:self
                                                 action:@selector(previousBucket:)];
    leftButton.enabled = NO;
    
    rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightButton.png"]
                                                   style:UIBarButtonItemStylePlain 
                                                  target:self
                                                  action:@selector(nextBucket:)];
    
    bucketLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    bucketLabel.textColor = [UIColor whiteColor];
    bucketLabel.backgroundColor = [UIColor clearColor];
    bucketLabel.font = [UIFont boldSystemFontOfSize:12.0];
    bucketLabel.textAlignment = UITextAlignmentCenter;
    bucketLabel.frame = CGRectMake(0.0, 0.0, 200.0, 44.0);
    bucketLabel.text = @"Bucket Title";
    
    UIBarButtonItem* middleButton = [[UIBarButtonItem alloc] initWithCustomView:bucketLabel];
    [arNavigationViewController setToolbarItems:[NSArray arrayWithObjects:leftButton, middleButton,
                                             rightButton, nil]
                                   animated:NO];
    
    [arNavigationViewController setToolbarHidden:NO animated:NO];    
    
    [self lockScreen:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];   
    [segmentedControl setSelectedSegmentIndex:1];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIButton methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) changeViews:(UISegmentedControl*)sc
{
    if(segmentedControl.selectedSegmentIndex == 0) {
     
        [arNavigationViewController reloadAllBuckets];
        [self.navigationController presentModalViewController:arNavigationViewController animated:YES];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {
            
        [self.view bringSubviewToFront:layerMapView];
        
    } else {

        [recordTableView reloadData];
        [self.view bringSubviewToFront:recordTableView];
    }
}

- (void) locateMe:(id)button
{
    [self centerMap:modelController.locationManager.location.coordinate animated:YES];
}

- (void) showCensusInfo:(id)button
{
    UIButton* infoButton = (UIButton*)button;
    
    [UIView beginAnimations:@"ShowCensus" context:nil];
    [UIView setAnimationDuration:1.2];
     
     if(infoButton.tag) {
      
         censusTableView.hidden = YES;
         [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
         
     } else {
         
         [self.view bringSubviewToFront:censusTableView];
         censusTableView.hidden = NO;
         [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
         
     }
        
    
    [UIView commitAnimations];
    
    infoButton.tag = !infoButton.tag;
}

- (void) closeAlbumView:(id)button
{
    [albumScrollView removeAllAlbums];
    [albumScrollView removeFromSuperview];
}

- (void) nextBucket:(id)button
{
    if([arNavigationViewController loadNextBucket]) {
     
        NSInteger bucketIndex = arNavigationViewController.bucketIndex;
        
        rightButton.enabled = bucketIndex != 3;
        leftButton.enabled = bucketIndex != 0;
        
        if(!rightButton.enabled) {
            arNavigationViewController.title = @"All";
        } else
            arNavigationViewController.title = [modelController stringForModelType:bucketIndex];
    }
    
}

- (void) previousBucket:(id)button
{
    
    if([arNavigationViewController loadPreviousBucket]) {

        NSInteger bucketIndex = arNavigationViewController.bucketIndex;
        if(bucketIndex == 3)
            arNavigationViewController.title = @"All";
        else
            arNavigationViewController.title = [modelController stringForModelType:bucketIndex];
        
        rightButton.enabled = bucketIndex != 3;
        leftButton.enabled = bucketIndex != 0;
    }
    
}

- (void) containerSelected:(id)container
{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGCoverFlowView delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) coverFlowView:(SGCoverFlowView*)view didSelectAlbum:(id<SGAlbum>)album
{
    // There is only one container.
    SGAnnotationViewContainer* container = [[arNavigationViewController.arView getContainers] objectAtIndex:0];
    
    NSArray* annotaitonViews = [container getRecordAnnotationViews];
    
    SGAnnotationView* selectedAnnotationView = nil;
    for(SGAnnotationView* annotaitonView in annotaitonViews) {
        
        if([annotaitonView.annotation isEqual:album]) {

            selectedAnnotationView = annotaitonView;
            break;
        }
    }
    
    if(selectedAnnotationView) {
        
        [self closeAlbumView:nil];
        
        selectedAnnotationView.frame = CGRectMake(0.0, 200.0, selectedAnnotationView.frame.size.width, selectedAnnotationView.frame.size.height);
        [selectedAnnotationView inspectView:YES];
        [[[UIApplication sharedApplication] keyWindow] addSubview:selectedAnnotationView];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark MKMapView delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) centerMap:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated
{
    MKCoordinateSpan span = {0.01, 0.011};
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [layerMapView setRegion:region animated:animated];
}

- (MKAnnotationView*) mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    SGPinAnnotationView* annotationView = (SGPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PinView"];
    
    if(!annotationView && ![annotation isKindOfClass:[MKUserLocation class]])
        annotationView = [[[SGPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinView"] autorelease];
    
    [annotationView setAnnotation:annotation];
    
    SGSocialRecord* record = (SGSocialRecord*)annotation;
    
    if([record isKindOfClass:[MKUserLocation class]]) {
    
        annotationView = nil;
        
    } else {
        
        annotationView.canShowCallout = YES;
        [modelController addObjectToImageLoader:record];
        record.helperView = annotationView;
        
        if([record isKindOfClass:[SGTweet class]])
            annotationView.pinColor = MKPinAnnotationColorGreen;
        else if([record isKindOfClass:[SGFlickr class]])
            annotationView.pinColor = MKPinAnnotationColorPurple;    
        else if([record isKindOfClass:[SGBrightkite class]])
            annotationView.pinColor = MKPinAnnotationColorRed;
    }
    
    return annotationView;
}

- (void) mapView:(MKMapView*)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl*)control
{
    if(control == view.rightCalloutAccessoryView) {
 
        SGSocialRecord* record = (SGSocialRecord*)view.annotation;

        SGAnnotationView* annotationView = [[[SGAnnotationView alloc] initAtPoint:CGPointZero reuseIdentifier:@"Blah:)"] autorelease];
        annotationView.annotation = record;
        [annotationView.closeButton addTarget:annotationView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
        
        [self setupAnnotationView:annotationView];
                
        [annotationView inspectView:YES];
        
        // Once the view is inspected the dimensions change.
        annotationView.frame = CGRectMake((self.view.frame.size.width - annotationView.frame.size.width) / 2.0,
                                          (self.view.frame.size.height - annotationView.frame.size.height) / 2.0,
                                          annotationView.frame.size.width,
                                          annotationView.frame.size.height);
        
        [self.view addSubview:annotationView];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView data source methods 
////////////////////////////////////////////////////////////////////////////////////////////////

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if(tableView == recordTableView) {
        
        SGSocialRecordTableCell* socialCell = (SGSocialRecordTableCell*)[recordTableView dequeueReusableCellWithIdentifier:@"NormalCell"];
    
        if(!socialCell)
            socialCell = [[[SGSocialRecordTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NormalCell"] autorelease];
        
        SGSocialRecord* record = [[closeRecordAnnotations objectAtIndex:section] objectAtIndex:indexPath.row];
                
        socialCell.userProfile = record;
        record.helperView = cell;
            
        socialCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = socialCell;
        
    } else {
        
        if(section == kCensusSection_Weather) {
         
            
        } else if(section == kCensusSection_Zip) {
            
            
        } else if(section == kCensusSection_GeoNames) {
            
        }
        
    }
    
    return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    int amount = 0;
    
    if(tableView == recordTableView) {
    
        amount = [[closeRecordAnnotations objectAtIndex:section] count];
        
    } else {
        
        if(section == kCensusSection_Weather) {
            
            
        } else if(section == kCensusSection_Zip) {
            
            
        } else if(section == kCensusSection_GeoNames) {
            
        }        
        
    }

    return amount;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return [modelController stringForModelType:section];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SGSocialRecord* record = [[[layers objectAtIndex:indexPath.section] recordAnnotations] 
                                                    objectAtIndex:indexPath.row];
    
    [webViewController loadURLString:[record profileURL]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGLocationService delegate methods
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) locationService:(SGLocationService*)service succeededForResponseId:(NSString*)requestId responseObject:(NSObject*)objects
{    
    
    // Search through all response ids that were created on the initial value
    // of the device's location.
    SGLayerType layerType = -1;
    NSString* layerResponse = nil;
    for(int i = 0; i < kSGLayerType_Amount; i++) {
        
        layerResponse = [currentLocationResponseIds objectAtIndex:i];
        if(![layerResponse isKindOfClass:[NSNull class]] && [layerResponse isEqualToString:requestId]) {
            layerType = i;
            break;
        }
    }
    
    // Make sure we have a valid layer type.
    if(layerType >= 0) {
     
        SGSpecificLayer* layer = [layers objectAtIndex:layerType];
        
        NSMutableArray* annotationViewRecords = nil;
        if(layerType < [closeRecordAnnotations count])
            annotationViewRecords = [closeRecordAnnotations objectAtIndex:layerType];
        
        NSArray* records = (NSArray*)objects;
        for(NSDictionary* geoJSONDictionary in records) {
            
            // This will create a new record and insert it in CoreData; also returning the record.
            SGManagedRecord* managedRecord = [layer recordAnnotationFromGeoJSONDictionary:geoJSONDictionary];
            
            if(annotationViewRecords && managedRecord)
                [annotationViewRecords addObject:managedRecord];
        }        
        
        [currentLocationResponseIds replaceObjectAtIndex:layerType withObject:[NSNull null]];
        
        // Once we get to the last layer, we allow the map view to retrieve
        // records when needed.
        if(layerType == 5) {
            
            [self lockScreen:NO];
            [layerMapView startRetrieving];
            
        }
    }
}

- (void) locationService:(SGLocationService*)service failedForResponseId:(NSString*)requestId error:(NSError*)error
{
    [self presentError:error];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocationManager delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // This will only be executed once.
    if(!oldLocation) {
        
        [self centerMap:newLocation.coordinate animated:YES];
    
        SGGeohash region = SGGeohashMake(newLocation.coordinate.latitude,
                                       newLocation.coordinate.longitude,
                                       10);
    
        // Gather all current information.
        SGSpecificLayer* layer = nil;
        NSString* requestId = nil;
        for(int i = 0; i < kSGLayerType_Amount; i++) {
        
            layer = [layers objectAtIndex:i];
            requestId = [layer retrieveRecordsInRegion:region radius:10.0 types:nil limit:100];
        
            if(requestId) 
                [currentLocationResponseIds replaceObjectAtIndex:i
                                                      withObject:requestId];
        }
    }
}

-  (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self presentError:error];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGARView delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (NSArray*) viewController:(SGARNavigationViewController*)nvc
                                            annotationsForBucketAtIndex:(NSInteger)bucketIndex
{   
    NSMutableArray* annotations = [NSMutableArray array];
    
    if(bucketIndex == 3)
        for(NSMutableArray* annotations in closeRecordAnnotations)
            [annotations addObjectsFromArray:annotations];
    else
        [annotations addObjectsFromArray:[closeRecordAnnotations objectAtIndex:bucketIndex]];
    
    return annotations;
}

- (NSInteger) viewControllerNumberOfBuckets:(SGARNavigationViewController*)nvc
{
    return 3;
}

- (SGAnnotationView*) viewController:(SGARNavigationViewController*)nvc
                   viewForAnnotation:(id<SGRecordAnnotation>)annotation
                                    atBucketIndex:(NSInteger)bucketIndex
{
    
    SGAnnotationView* annotationView = [nvc.arView dequeueReuseableAnnotationViewWithIdentifier:@"SocialRecord"];
    
    if(!annotationView)
        annotationView = [[[SGAnnotationView alloc] initAtPoint:CGPointZero reuseIdentifier:@"SocialRecord"] autorelease];
    
    annotationView.annotation;
    
    [self setupAnnotationView:annotationView];
    
    return annotationView;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Helper methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) lockScreen:(BOOL)lock
{
    loadingLabel.hidden = !lock;
    
    self.navigationController.toolbar.userInteractionEnabled = !lock;
    self.navigationController.navigationBar.userInteractionEnabled = !lock;
}

- (void) setupAnnotationView:(SGAnnotationView*)annotationView
{
    SGSocialRecord* record = (SGSocialRecord*)annotationView.annotation;
    annotationView.inspectorType = kSGAnnotationViewInspectorType_Photo;
    
    annotationView.titleLabel.text = record.name;
    annotationView.photoImageView.image = record.photo;
    annotationView.messageLabel.text = record.body;
    annotationView.targetImageView.image = record.profileImage;
    
    [annotationView.radarTargetButton setImage:record.serviceImage forState:UIControlStateNormal];
    
}

- (void) presentError:(NSError*)error
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ %i", error.domain, [error code]]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
}

- (void) dealloc 
{
    [recordTableView release];
    [censusTableView release];
    
    [segmentedControl release];
    
    [arNavigationViewController release];
    [layerMapView release];
    
    [modelController release];
    [locationService release];
    
    [layers release];
    [currentLocationResponseIds release];
    [closeRecordAnnotations release];
    
    [leftButton release];
    [rightButton release];
    
    [super dealloc];
}


@end
