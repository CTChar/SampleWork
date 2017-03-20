//
//  OverlayViewController.h
//  
//
//  Created by Cole Herzog on 9/9/15.
//
//

#import <UIKit/UIKit.h>
#import "CameraImaging.h"

@interface OverlayViewController : UIViewController

@property (strong, nonatomic) id<CameraImaging> cameraImaging;


@end
