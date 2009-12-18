/*
 *  SGEntityDescriptions.c
 *  Foursight
 *
 *  Created by Derek Smith on 9/4/09.
 *  Copyright 2009 SimpleGeo. All rights reserved.
 *
 */

#import "SGEntityDescriptions.h"

NSEntityDescription* twitterDescription, *flickrDescription, *brightkiteDescription;
NSEntityDescription *usZipDescription, *usWeatherDescription, *geoNamesDescription;
NSManagedObjectContext* context;


void InitializeEntityDescriptions(NSManagedObjectContext* c) {
    
    context = [c retain];
    
    twitterDescription = [[NSEntityDescription entityForName:@"Twitter" inManagedObjectContext:context] retain];
    flickrDescription = [[NSEntityDescription entityForName:@"Flickr" inManagedObjectContext:context] retain];    
    brightkiteDescription = [[NSEntityDescription entityForName:@"Brightkite" inManagedObjectContext:context] retain];
    
    usZipDescription = [[NSEntityDescription entityForName:@"USZip" inManagedObjectContext:context] retain];
    usWeatherDescription = [[NSEntityDescription entityForName:@"USWeather" inManagedObjectContext:context] retain];
    geoNamesDescription = [[NSEntityDescription entityForName:@"GeoNames" inManagedObjectContext:context] retain];    
}

void ReleaseEntityDescriptions() {

    [twitterDescription release];
    [flickrDescription release];
    [brightkiteDescription release];
    
    [usWeatherDescription release];
    [usZipDescription release];
    [geoNamesDescription release];
    
    [context release];
}

NSEntityDescription* descriptionForClassName(NSString* className) {
    
    NSEntityDescription* description = nil;
    if([className isEqualToString:@"SGTweet"])
        description = twitterDescription;
    else if([className isEqualToString:@"SGFlickr"])
        description = flickrDescription;
    else if([className isEqualToString:@"SGBrightkite"])
        description = brightkiteDescription;
        
    return description;
}