//
//  SGWebViewController.h
//  SGiPhoneSDK
//
//  Created by Derek Smith on 11/13/09.
//  Copyright 2009 SimpleGeo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SGWebViewController : UIViewController {

    @private
    UIWebView* webView;
}

- (void) loadURLString:(NSString*)stringURL;

@end
