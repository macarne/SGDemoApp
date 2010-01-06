//
//  UIImageAdditions.m
//  SGDemoApp
//
//  Created by Derek Smith on 12/21/09.
//  Copyright 2009 CrashCorp. All rights reserved.
//

#import "UIImageAdditions.h"

@implementation UIImage (SimpleGeoDemoApp)

+ (UIImage*) imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    
    UIImage* newImage = nil;
    if(image) {
        
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0.0, 0.0, newSize.width, newSize.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    return newImage;
}


@end
