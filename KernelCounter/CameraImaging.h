//
//  CameraImaging.h
//  KernelCounter
//
//  Created by Cole Herzog on 9/11/15.
//  Copyright (c) 2015 com.CTChar. All rights reserved.
//

#ifndef KernelCounter_CameraImaging_h
#define KernelCounter_CameraImaging_h

#define UI_TESTING (0)
#define UI_TESTING_TOTAL (498)

@protocol CameraImaging <NSObject>

typedef void (^ImageCompletionBlock)(UIImage *);
@property (readonly) BOOL hasCamera;


- (void) pauseAndCaptureImageWithCompletion:(ImageCompletionBlock)blk;

- (void) resumeLiveCapture;

@end

#endif
