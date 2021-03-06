//
//  SGMainViewController.m
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
    
    kCensusSection_Address = 0,
    kCensusSection_Weather,
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

enum Address {
 
    kAddress_Country = 0,
    kAddress_CountyCode,
    kAddress_CountyName,
    kAddress_PlaceName,
    kAddress_PostalCode,
    kAddress_StateCode,
    kAddress_Street,
    kAddress_StreetNumber,
    
    kAddress_Amount
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
- (SGModelType) modelTypeForResponseId:(NSString *)requestId;

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
        layerMapView.limit = 40;
        layerMapView.delegate = self;
        [layerMapView stopRetrieving];
        
        addressInformation = nil;
        
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
        
    SGSetEnvironmentViewingRadius(1000.0f);         // 1km
    
    // The Token.plist file is just a file that contains the OAuth access
    // and secret key. Either create your own Token.plist file or just 
    // create the OAuth object with the proper string values.
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* path = [mainBundle pathForResource:@"Token" ofType:@"plist"];
    NSDictionary* token = [NSDictionary dictionaryWithContentsOfFile:path];
    
    SGOAuth* oAuth = [[SGOAuth alloc] initWithKey:[token objectForKey:@"key"] secret:[token objectForKey:@"secret"]];
    locationService.HTTPAuthorizer = oAuth;
}

- (void) initializeLayers
{
    layers = [[NSMutableArray alloc] init];
    
    nearbySocialRecords = [[NSMutableArray alloc] init];
    currentLocationResponseIds = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < kSGModelType_Amount; i++) {
        
        [nearbySocialRecords addObject:[NSMutableArray array]];

        SGLayer* layer = nil;
        switch (i) {
                
            case kSGModelType_Brightkite:
            {
                layer = [[SGBrightkiteLayer alloc] initWithLayerName:@"com.simplegeo.global.brightkite"];
                [layerMapView addLayer:layer];                
            }
                break;
            case kSGModelType_Twitter:
            {
                layer = [[SGTwitterLayer alloc] initWithLayerName:@"com.simplegeo.global.twitter"];
                [layerMapView addLayer:layer];
            }
                break;
            case kSGModelType_Flickr:
            {
                layer = [[SGFlickrLayer alloc] initWithLayerName:@"com.simplegeo.global.flickr"];
                [layerMapView addLayer:layer];
            }
                break;
            case kSGModelType_GeoNames:
            {
                layer = [[SGLayer alloc] initWithLayerName:@"com.simplegeo.global.geonames"];            
            }
                break;
            case kSGModelType_USZip:
            {
                layer = [[SGLayer alloc] initWithLayerName:@"com.simplegeo.us.zip"];
            }
                break;
            case kSGModelType_USWeather:
            {
                layer = [[SGLayer alloc] initWithLayerName:@"com.simplegeo.us.weather"];
            }
                break;
            case kSGModelType_Address:
            {
                layer = [NSNull null];
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
    arNavigationViewController.arView.movableStack.maxStackAmount = 1;
    
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
    locateButton = [[UIBarButtonItem alloc] initWithCustomView:button];
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
    bucketLabel.frame = CGRectMake(0.0, 0.0, 200.0, 20.0);
    
    UIBarButtonItem* middleButton = [[UIBarButtonItem alloc] initWithCustomView:bucketLabel];
    [arNavigationViewController setToolbarItems:[NSArray arrayWithObjects:leftButton, middleButton,
                                             rightButton, nil]
                                   animated:NO];
    
    [arNavigationViewController setToolbarHidden:NO animated:NO];    
    
    [self lockScreen:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIButton methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) changeViews:(UISegmentedControl*)sc
{
    [layerMapView stopRetrieving];
    
    if(segmentedControl.selectedSegmentIndex == 0) {
     
        locateButton.enabled = NO;
        [arNavigationViewController reloadAllBuckets];
        [self.navigationController presentModalViewController:arNavigationViewController animated:YES];
        segmentedControl.selectedSegmentIndex = 1;
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {
            
        [layerMapView startRetrieving];
        locateButton.enabled = YES;
        self.title = @"Demo";
        [self.view bringSubviewToFront:layerMapView];
        
    } else {
        
        locateButton.enabled = NO;
        self.title = @"Nearby Records";
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
                bucketLabel.text = @"All";
        } else
            bucketLabel.text = [modelController stringForModelType:bucketIndex];
    }
    
}

- (void) previousBucket:(id)button
{
    
    if([arNavigationViewController loadPreviousBucket]) {

        NSInteger bucketIndex = arNavigationViewController.bucketIndex;
        if(bucketIndex == 3)
            bucketLabel.text = @"All";
        else
            bucketLabel.text = [modelController stringForModelType:bucketIndex];
        
        rightButton.enabled = bucketIndex != 3;
        leftButton.enabled = bucketIndex != 0;
    }
    
}

- (void) containerSelected:(id)container
{
    [albumScrollView addAlbums:[((SGAnnotationViewContainer*)container) getRecordAnnotations]];
    [arNavigationViewController.arView addSubview:albumScrollView];
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
        
        SGSocialRecordTableCell* socialCell = (SGSocialRecordTableCell*)[tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
    
        if(!socialCell)
            socialCell = [[[SGSocialRecordTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NormalCell"] autorelease];
        
        SGSocialRecord* record = [[nearbySocialRecords objectAtIndex:section] objectAtIndex:row];
        socialCell.userProfile = record;
            
        cell = socialCell;
        
    } else {
        
        
        NSArray* recordAnnotations = [nearbySocialRecords objectAtIndex:section+3];
        if(section == kCensusSection_Address) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
            if(!cell)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AddressCell"] autorelease];
            
            
            NSString* text = @"N/A";
            NSString* key = nil;
            
            if(row == kAddress_Country) {
                
                text = @"Country";
                key = @"country";
                
            } else if(row == kAddress_CountyCode) {
                
                text = @"County Code";
                key = @"county_code";
                
            } else if(row == kAddress_CountyName) {
                
                text = @"County Name";
                key = @"country_name";
                
            } else if(row == kAddress_PlaceName) {
                
                text = @"Place Name";
                key = @"place_name";
                
            } else if(row == kAddress_PostalCode) {
                
                text = @"Postal Code";
                key = @"postal_code";
                
            } else if(row == kAddress_StateCode) {
                
                text = @"State Code";
                key = @"state_code";
                
            } else if(row == kAddress_Street) {
                
                text = @"Street";
                key = @"street";
                
            } else if(row == kAddress_StreetNumber) {
                
                text = @"Street Number";
                key = @"street_number";
                
            }
            
            cell.textLabel.text = text;
            cell.detailTextLabel.text = @"N/A";
            
            if(key && addressInformation) {
                
                key = [addressInformation objectForKey:key];
                
                if(key)
                    cell.detailTextLabel.text = key;
            }
            
            
        } else if(section == kCensusSection_Weather) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"WeatherCell"];
            if(!cell)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"WeatherCell"] autorelease];
            
            
            SGRecord* record = (SGRecord*)[self getClosestAnnotation:recordAnnotations];
            if(row == kWeatherRow_Weather) {
                
                cell.textLabel.text = @"Weather";
                
                if(record) {
                    
                    NSDictionary* userDefinedProp = [record properties];
//                    NSString* iconURL = [userDefinedProp objectForKey:@"icon_url_base"];
//                    iconURL = [iconURL stringByAppendingString:[userDefinedProp objectForKey:@"icon_url_name"]];
//                
//                    UIImage* image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]] retain];
//                
//                    cell.imageView.image = image;
                  
                    cell.detailTextLabel.text = [self getStringValue:@"weather" properties:userDefinedProp];
                    
                } else {
                    
                    cell.detailTextLabel.text = @"N/A";
                    
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
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"ZipCell"];
            if(!cell)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ZipCell"] autorelease];
            
            
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
                                                          properties:[annotation properties]];                    
                }
                    break;
                case kZipRow_HouseIncome:
                {
                    cell.textLabel.text = @"Avg House Value";
                    cell.detailTextLabel.text = [self getStringValue:@"averagehousevalue"
                                                          properties:[annotation properties]];                    
                }
                    break;
                case kZipRow_HouseValue:
                {
                    cell.textLabel.text = @"Avg Household Income";
                    cell.detailTextLabel.text = [self getStringValue:@"incomeperhousehold"
                                                          properties:[annotation properties]];                                        
                }
                    break;
                case kZipRow_City:
                {
                    cell.textLabel.text = @"City";
                    cell.detailTextLabel.text = [self getStringValue:@"city"
                                                          properties:[annotation properties]];                                        
                }
                    break;                    
                default:
                    break;
            }
            
        } else if(section == kCensusSection_GeoNames) {
            
            cell = [tableView dequeueReusableCellWithIdentifier:@"GeoNamesCell"];
            if(!cell)
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GeoNamesCell"] autorelease];
            
            
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
    return tableView == socialRecordTableView ? 3 : kCensusSection_Amount;
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
            amount = 0;
        else if(section == kCensusSection_GeoNames)
            amount = 0;
        else if(section == kCensusSection_Address)
            amount = kAddress_Amount;
            
    }
        
    return amount;
}

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;
    
    if(tableView != socialRecordTableView && (section == kCensusSection_GeoNames || section == kCensusSection_Zip))
        title = @"";
    
    if(tableView != socialRecordTableView)
        section += 3;
    
    if(!title)
        title = [modelController stringForModelType:section];
            

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
        
        segmentedControl.selectedSegmentIndex = 3;
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

- (void) locationService:(SGLocationService*)service succeededForResponseId:(NSString*)requestId responseObject:(NSObject*)object
{    
    
    // Search through all response ids that were created on the initial value
    // of the device's location.
    SGModelType modelType = -1;
    NSString* layerResponse = nil;
    for(int i = 0; i < kSGModelType_Amount; i++) {
        
        layerResponse = [currentLocationResponseIds objectAtIndex:i];
        if(![layerResponse isKindOfClass:[NSNull class]] && [layerResponse isEqualToString:requestId]) {
            modelType = i;
            break;
        }
    }
    
    // Make sure we have a valid layer type.
    if(modelType >= 0) {
        
        loadingLabel.text = [NSString stringWithFormat:@"Loaded %@. %i more left...",
                             [modelController stringForModelType:modelType], kSGModelType_Amount - modelType - 1];
     
        if(modelType == kSGModelType_Address) {
            
            if(object) {
                
                NSDictionary* geoJSONObject = (NSDictionary*)object;
                
                NSDictionary* properties = [geoJSONObject properties];
                if(properties)
                    addressInformation = [[NSDictionary alloc] initWithDictionary:properties];
            }            
            
        } else {
        
            SGLayer* layer = [layers objectAtIndex:modelType];
        
            NSMutableArray* annotationViewRecords = nil;
            if(modelType < [nearbySocialRecords count])
                annotationViewRecords = [nearbySocialRecords objectAtIndex:modelType];
        
            if(annotationViewRecords) {
        
                NSDictionary* geoJSONObject = (NSDictionary*)object;
                NSArray* features = [geoJSONObject features];
                
                SGRecord* record = nil;
                for(NSDictionary* feature in features) {
                
                    record = [layer recordAnnotationFromGeoJSONObject:feature];
            
                    if(record) {
                    
                        if([record isKindOfClass:[SGSocialRecord class]])
                            [modelController addObjectToImageLoader:(SGSocialRecord*)record];
                    
                        [annotationViewRecords addObject:record];
                    }
                }        
            
            }
        }
        
        [currentLocationResponseIds replaceObjectAtIndex:modelType withObject:[NSNull null]];        
        
    }
        
    if(modelType == kSGModelType_Amount - 1) {
        
        [self lockScreen:NO];
        [layerMapView startRetrieving];
        [service removeDelegate:self];
        
    }
    
}

- (void) locationService:(SGLocationService*)service failedForResponseId:(NSString*)requestId error:(NSError*)error
{
    
    // Search through all response ids that were created on the initial value
    // of the device's location.
    SGModelType modelType = -1;
    NSString* layerResponse = nil;
    for(int i = 0; i < kSGModelType_Amount; i++) {
        
        layerResponse = [currentLocationResponseIds objectAtIndex:i];
        if(![layerResponse isKindOfClass:[NSNull class]] && [layerResponse isEqualToString:requestId]) {
            modelType = i;
            break;
        }
    }
    
    // Make sure we have a valid layer type.
    if(modelType >= 0) {
                
        [currentLocationResponseIds replaceObjectAtIndex:modelType withObject:[NSNull null]];
        
        // Once we get to the last layer, we allow the map view to retrieve
        // records when needed.
        if(modelType == 5) {
            
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
        for(int i = 0; i < kSGModelType_Amount; i++) {
            
            if(i != kSGModelType_Address) {
            
                // For some of the census data layers,
                // we need to enlarge the radius to find the proper
                // weather station and points of interest.
                radius = (i > 2) ? 100.0 : 1.0;
        
                layer = [layers objectAtIndex:i];
                requestId = [layer retrieveRecordsForCoordinate:coordinate radius:radius types:nil limit:15];
        
                if(requestId) 
                    [currentLocationResponseIds replaceObjectAtIndex:i
                                                          withObject:requestId];
                
            } else {
                
                [currentLocationResponseIds replaceObjectAtIndex:i withObject:[locationService reverseGeocode:newLocation.coordinate]];       
            }
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
    return 4;
}

- (SGAnnotationView*) viewController:(SGARNavigationViewController*)nvc
                   viewForAnnotation:(id<SGRecordAnnotation>)annotation
                                    atBucketIndex:(NSInteger)bucketIndex
{
    
    SGAnnotationView* annotationView = [nvc.arView dequeueReuseableAnnotationViewWithIdentifier:@"SocialRecord"];
    
    if(!annotationView)
        annotationView = [[[SGAnnotationView alloc] initAtPoint:CGPointZero reuseIdentifier:@"SocialRecord"] autorelease];
    
    ((SGSocialRecord*)annotation).helperView = annotationView;
    annotationView.annotation = annotation;
    
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
    
    annotationView.targetType = kSGAnnotationViewTargetType_Glass;
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
