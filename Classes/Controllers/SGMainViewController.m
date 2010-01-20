//
//  SGMainViewController.m
//  LocationDemo
//
//  Created by Derek Smith on 8/7/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGMainViewController.h"

#import "SGFlickrLayer.h"
#import "SGBrightkiteLayer.h"
#import "SGTwitterLayer.h"

/* Records */
#import "SGFlickr.h"
#import "SGTweet.h"
#import "SGBrightkite.h"
#import "SGUSZip.h"
#import "SGUSWeather.h"
#import "SGGeoNames.h"

#import "SGPinAnnotationView.h"                                                                                             
#import "SGSocialRecordTableCell.h"


enum CensusSection {
    
    kCensusSection_Weather = 0,
    kCensusSection_Zip,
    kCensusSection_GeoNames,
    
    kCensusSection_Amount
};

enum WeatherRow {
 
    kWeatherRow_Weather = 0,
    kWeatherRow_StationDistance,
    
    kWeatherRow_Amount  
};

enum ZipRow {
 
    kZipRow_City = 0,
    kZipRow_ZipCode,
    kZipRow_Population,
    kZipRow_HouseValue,
    kZipRow_HouseIncome,
    
    kZipRow_Amount
};

enum GeoNames {
 
    kGeoNames_Name = 0,
    kGeoNames_Population,
    
    kGeoNames_Amount
};


@interface SGMainViewController (Private) <UITableViewDelegate, UITableViewDataSource, SGARNavigationViewControllerDataSource, SGCoverFlowViewDelegate>

- (void) initializeLocationService;
- (void) initializeLayers;
- (void) initializeARView;

- (void) presentError:(NSError *)error;
- (void) lockScreen:(BOOL)lock;

- (id<SGRecordAnnotation>) getClosestAnnotation:(NSArray*)annotations;
- (NSString*) getStringValue:(NSString*)key properties:(NSDictionary*)properties;

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
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];        
        
        [self initializeLocationService];
        [self initializeARView];
            
        layerMapView = [[SGLayerMapView alloc] initWithFrame:CGRectZero];
        layerMapView.delegate = self;
        [layerMapView stopRetrieving];
        
        [self initializeLayers];
    
        webViewController = [[SGWebViewController alloc] init];
    }
    
    return self;
}

- (void) initializeLocationService
{
    locationService = [SGLocationService sharedLocationService];
    [locationService addDelegate:self];
    [SGLocationService callbackOnMainThread:YES];
        
    SGSetEnvironmentViewingRadius(100.0f);         // 1km
    
    // The Token.plist file is just a file that contains the OAuth access
    // and secret key. Either create your own Token.plist file or just 
    // create the OAuth object with the proper string values.
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* path = [mainBundle pathForResource:@"MyToken" ofType:@"plist"];
    NSDictionary* token = [NSDictionary dictionaryWithContentsOfFile:path];
    
    SGOAuth* oAuth = [[SGOAuth alloc] initWithKey:[token objectForKey:@"key"] secret:[token objectForKey:@"secret"]];
    locationService.HTTPAuthorizer = oAuth;
}

- (void) initializeLayers
{
    layers = [[NSMutableArray alloc] init];
    
    nearbySocialRecords = [[NSMutableArray alloc] init];
    currentLocationResponseIds = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < kSGLayerType_Amount; i++) {
        
        [nearbySocialRecords addObject:[NSMutableArray array]];

        SGLayer* layer = nil;
        switch (i) {
                
            case kSGLayerType_Brightkite:
            {
                layer = [[SGBrightkiteLayer alloc] initWithLayerName:@"com.simplegeo.global.brightkite"];
                [layerMapView addLayer:layer];                
            }
                break;
            case kSGLayerType_Twitter:
            {
                layer = [[SGTwitterLayer alloc] initWithLayerName:@"com.simplegeo.global.twitter"];
                [layerMapView addLayer:layer];
            }
                break;
            case kSGLayerType_Flickr:
            {
                layer = [[SGFlickrLayer alloc] initWithLayerName:@"com.simplegeo.global.flickr"];
                [layerMapView addLayer:layer];
            }
                break;
            case kSGLayerType_GeoNames:
            {
                layer = [[SGLayer alloc] initWithLayerName:@"com.simplegeo.global.geonames"];            
            }
                break;
            case kSGLayerType_USZip:
            {
                layer = [[SGLayer alloc] initWithLayerName:@"com.simplegeo.us.zip"];
            }
                break;
            case kSGLayerType_USWeather:
            {
                layer = [[SGLayer alloc] initWithLayerName:@"com.simplegeo.us.weather"];
            }
                break;                
            default:
                break;
        }
        
        [layers addObject:layer];
        [currentLocationResponseIds addObject:[NSNull null]];
    }    
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
            
    socialRecordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                    0.0,
                                                                    self.view.bounds.size.width,
                                                                    self.view.bounds.size.height - (self.navigationController.toolbar.frame.size.height * 2.))
                                                   style:UITableViewStylePlain];
    socialRecordTableView.dataSource = self;
    socialRecordTableView.delegate = self;
    [self.view addSubview:socialRecordTableView];
    
    censusTableView = [[UITableView alloc] initWithFrame:socialRecordTableView.bounds style:UITableViewStyleGrouped];
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
    bucketLabel.frame = CGRectMake(0.0, 0.0, 0.0, 320.0);
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

        [socialRecordTableView reloadData];
        [self.view bringSubviewToFront:socialRecordTableView];
    }
}

- (void) locateMe:(id)button
{
    [self centerMap:locationManager.location.coordinate animated:YES];
}

- (void) showCensusInfo:(id)button
{
    UIButton* infoButton = (UIButton*)button;
    
    [censusTableView reloadData];
    
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
    
    if(tableView == socialRecordTableView) {
        
        SGSocialRecordTableCell* socialCell = (SGSocialRecordTableCell*)[socialRecordTableView dequeueReusableCellWithIdentifier:@"NormalCell"];
    
        if(!socialCell)
            socialCell = [[[SGSocialRecordTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NormalCell"] autorelease];
        
        SGSocialRecord* record = [[nearbySocialRecords objectAtIndex:section] objectAtIndex:row];
        socialCell.userProfile = record;
            
        cell = socialCell;
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"CensusCell"];
        if(!cell)
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CensusCell"] autorelease];
        
        NSArray* recordAnnotations = [nearbySocialRecords objectAtIndex:section+3];
        if(section == kCensusSection_Weather) {
            
            SGRecord* record = (SGRecord*)[self getClosestAnnotation:recordAnnotations];
            if(row == kWeatherRow_Weather) {
                
                if(record) {
                    
                    NSDictionary* userDefinedProp = [record userDefinedProperties];
//                    NSString* iconURL = [userDefinedProp objectForKey:@"icon_url_base"];
//                    iconURL = [iconURL stringByAppendingString:[userDefinedProp objectForKey:@"icon_url_name"]];
//                
//                    UIImage* image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]] retain];
//                
//                    cell.imageView.image = image;
                    cell.textLabel.text = @"Weather";
                    cell.detailTextLabel.text = [self getStringValue:@"weather" properties:userDefinedProp];
                }
                
                
            } else if(row == kWeatherRow_StationDistance) {
                
                CLLocation* recordLocation = [[CLLocation alloc] initWithLatitude:record.coordinate.latitude
                                                                        longitude:record.coordinate.longitude];
                double distance = [locationManager.location getDistanceFrom:recordLocation];
                [recordLocation release];
                
                cell.textLabel.text = @"Station Distance";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fm", distance];
                
            }
            
        } else if(section == kCensusSection_Zip) {
            
            SGRecord* annotation = (SGRecord*)[self getClosestAnnotation:recordAnnotations];
            switch (row) {
                case kZipRow_ZipCode:
                {
                    cell.textLabel.text = @"Zip Code";
                    cell.detailTextLabel.text = annotation.recordId;
                }
                    break;
                case kZipRow_Population:
                {
                    cell.textLabel.text = @"Population";
                    cell.detailTextLabel.text = [self getStringValue:@"population"
                                                          properties:[annotation userDefinedProperties]];                    
                }
                    break;
                case kZipRow_HouseIncome:
                {
                    cell.textLabel.text = @"Avg House Value";
                    cell.detailTextLabel.text = [self getStringValue:@"averagehousevalue"
                                                          properties:[annotation userDefinedProperties]];                    
                }
                    break;
                case kZipRow_HouseValue:
                {
                    cell.textLabel.text = @"Avg Household Income";
                    cell.detailTextLabel.text = [self getStringValue:@"incomeperhousehold"
                                                          properties:[annotation userDefinedProperties]];                                        
                }
                    break;
                case kZipRow_City:
                {
                    cell.textLabel.text = @"City";
                    cell.detailTextLabel.text = [self getStringValue:@"city"
                                                          properties:[annotation userDefinedProperties]];                                        
                }
                    break;                    
                default:
                    break;
            }
            
        } else if(section == kCensusSection_GeoNames) {
            
            if(row == kGeoNames_Name) {
                
                cell.textLabel.text = @"Name";
                cell.detailTextLabel.text = @"";
                
            } else if(row == kGeoNames_Population) {
                
                cell.textLabel.text = @"Population";
                cell.detailTextLabel.text = @"";
                
            }
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
    if(tableView == socialRecordTableView)
        amount = [[nearbySocialRecords objectAtIndex:section] count];
    else {
        
        if(section == kCensusSection_Weather)
            amount = kWeatherRow_Amount;
        else if(section == kCensusSection_Zip)
            amount = kZipRow_Amount;
        else if(section == kCensusSection_GeoNames)
            amount = 0;
//            amount = kGeoNames_Amount;            TODO: Enable GeoNames
            
    }
        
    return amount;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView != socialRecordTableView)
        section += 3;
    
    NSString* title = [modelController stringForModelType:section];

    return title;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableView delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == socialRecordTableView) {
        
        SGSocialRecord* record = [[nearbySocialRecords objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [webViewController loadURLString:[record profileURL]];
        webViewController.title = record.name;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (NSIndexPath*) tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    return tableView == censusTableView ? nil : indexPath;
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
     
        SGLayer* layer = [layers objectAtIndex:layerType];
        
        NSMutableArray* annotationViewRecords = nil;
        if(layerType < [nearbySocialRecords count])
            annotationViewRecords = [nearbySocialRecords objectAtIndex:layerType];
        
        if(annotationViewRecords) {
        
            NSArray* records = (NSArray*)objects;
            SGRecord* record = nil;
            for(NSDictionary* geoJSONDictionary in records) {
                
                record = [layer recordAnnotationFromGeoJSONDictionary:geoJSONDictionary];
            
                if(record)
                    [annotationViewRecords addObject:record];
            }        
            
        }
        
        [currentLocationResponseIds replaceObjectAtIndex:layerType withObject:[NSNull null]];
        
        // Once we get to the last layer, we allow the map view to retrieve
        // records when needed.
        if(layerType == kSGLayerType_Amount - 1) {
            
            [self lockScreen:NO];
            [layerMapView startRetrieving];
            [service removeDelegate:self];
        }
    }
}

- (void) locationService:(SGLocationService*)service failedForResponseId:(NSString*)requestId error:(NSError*)error
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
                
        [currentLocationResponseIds replaceObjectAtIndex:layerType withObject:[NSNull null]];
        
        // Once we get to the last layer, we allow the map view to retrieve
        // records when needed.
        if(layerType == 5) {
            
            [self lockScreen:NO];
            
            [layerMapView startRetrieving];
            [self presentError:error];
        }
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CLLocationManager delegate methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // This will only be executed once.
    if(!oldLocation) {
        
        CLLocationCoordinate2D coordinate = newLocation.coordinate;
        [self centerMap:coordinate animated:YES];
        
        // Gather all current information.
        SGLayer* layer = nil;
        NSString* requestId = nil;
        int radius = 10.0;
        for(int i = 0; i < kSGLayerType_Amount; i++) {
            
            // For some of the census data layers,
            // we need to enlarge the radius to find the proper
            // weather station and points of interest.
            radius = (i > 2) ? 10000.0 : 1.0;
        
            layer = [layers objectAtIndex:i];
            requestId = [layer retrieveRecordsForCoordinate:coordinate radius:radius types:nil limit:100];
        
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
        for(NSMutableArray* annotations in nearbySocialRecords)
            [annotations addObjectsFromArray:annotations];
    else
        [annotations addObjectsFromArray:[nearbySocialRecords objectAtIndex:bucketIndex]];
    
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

/* 
 There are times when we can recieve multiple record annotations for
 a large enough radius. We want to grab the closest annotation
 */
- (id<SGRecordAnnotation>) getClosestAnnotation:(NSArray*)recordAnnotations
{
    id<SGRecordAnnotation> annotation = nil;
    double currentDistance = -1.0;
    
    CLLocation* currentLocation = [locationManager location];
    if(recordAnnotations && [recordAnnotations count]) {
     
        CLLocation* location = nil;
        CLLocationCoordinate2D coord;
        for(id<SGRecordAnnotation> recordAnnotation in recordAnnotations) {
            coord = recordAnnotation.coordinate;
            location = [[CLLocation alloc] initWithLatitude:coord.latitude
                                                  longitude:coord.longitude];
            if(currentDistance < 0.0 || [currentLocation getDistanceFrom:location] < currentDistance)
            {
                currentDistance = [currentLocation getDistanceFrom:location];
                annotation = recordAnnotation;
            }
            
            [location release];
        }
    }
    
    return annotation;
}

- (NSString*) getStringValue:(NSString*)key properties:(NSDictionary*)properties
{
    NSString* stringValue = @"N/A";
    NSObject* value = [properties objectForKey:key];
    if(value && ![value isKindOfClass:[NSNull class]])        
        if([value isKindOfClass:[NSNumber class]])
            stringValue = [(NSNumber*)value stringValue];
        else if([value isKindOfClass:[NSString class]])
            stringValue = (NSString*)value;
    
    return stringValue;
}

- (void) dealloc 
{
    [socialRecordTableView release];
    [censusTableView release];
    
    [segmentedControl release];
    
    [arNavigationViewController release];
    [layerMapView release];
    
    [modelController release];
    [locationService release];
    
    [layers release];
    [currentLocationResponseIds release];
    [nearbySocialRecords release];
    
    [leftButton release];
    [rightButton release];
    
    [super dealloc];
}


@end
