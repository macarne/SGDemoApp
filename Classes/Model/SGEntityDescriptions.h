/*
 *  SGEntityDescriptions.h
 *  Foursight
 *
 *  Created by Derek Smith on 8/31/09.
 *  Copyright 2009 SimpleGeo. All rights reserved.
 *
 */

#import <CoreData/CoreData.h>


extern NSEntityDescription* twitterDescription, *flickrDescription, *brightkiteDescription;
extern NSEntityDescription* usZipDescription, *usWeatherDescription, *geoNamesDescription;

extern NSManagedObjectContext* context;

/* Initializes all entity descriptions used in CoreData. */
extern void InitializeEntityDescriptions(NSManagedObjectContext* c);

/* Releases all entity descriptions used in CoreData. */
extern void ReleaseEntityDescriptions();

extern NSEntityDescription* descriptionForClassName(NSString* className);