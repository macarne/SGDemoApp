// 
//  SGTweet.m
//  SGLocatorServices
//
//  Created by Derek Smith on 8/17/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import "SGTweet.h"

#import "SGEntityDescriptions.h"
#import "SGLocationTypes.h"

static UIImage* twitterServiceImage = nil;

@interface SGTweet (NSManagedObjectContextMethods)

- (void) setPrimitiveMessage:(NSString*)message;
- (NSString*) primitiveMessage;

@end


@implementation SGTweet 

+ (NSEntityDescription*) entityDescription
{
    return twitterDescription;
}

- (void) awakeFromInsert
{
    if(!twitterServiceImage)
        twitterServiceImage = [[UIImage imageNamed:@"Twitter.png"] retain];
}

- (void) awakeFromFetch
{
    if(!twitterServiceImage)
        twitterServiceImage = [[UIImage imageNamed:@"Twitter.png"] retain];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessor methods 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (void) setMessage:(NSString*)newMessage
{
    if(newMessage) {
     
        [self willChangeValueForKey:@"message"];
        [self setPrimitiveMessage:newMessage];
        [self didChangeValueForKey:@"message"];
    }
}

- (NSString*) message
{
    NSString* m = nil;
     
    [self willAccessValueForKey:@"message"];
    m = [self primitiveMessage];
    [self didAccessValueForKey:@"message"];
    
    return m;
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SGRecord overrides 
//////////////////////////////////////////////////////////////////////////////////////////////// 

- (UIImage*) serviceImage
{
    return twitterServiceImage;
}

- (NSString*) profileURL
{
    return [NSString stringWithFormat:@"http://m.twitter.com/%@/status/%@", self.username, self.recordId];
}

@end

