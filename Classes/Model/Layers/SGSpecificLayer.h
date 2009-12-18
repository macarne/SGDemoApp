//
//  SGFlickrLayer.h
//  CCLocatorServices
//
//  Created by Derek Smith on 10/1/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGLayer.h"

/*
 * A simple sublcass of SGLayer that can create the specific SGManagedRecords
 * when recieving a new GeoJSON object from SimpleGeo.
 */
@interface SGSpecificLayer : SGLayer {
    
    NSString* title;
    
    @private
    Class recordClass;
    
}

@property (nonatomic, readonly) NSString* title;

- (id) initWithLayerName:(NSString*)name recordClass:(Class)recordClass;

@end
