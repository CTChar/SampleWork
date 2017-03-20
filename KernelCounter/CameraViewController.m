//
//  ViewController.m
//  KernelCounter
//
//  Created by Cole Herzog on 9/6/15.
//  Copyright (c) 2015 com.CTChar. All rights reserved.
//

#include <AVFoundation/AVFoundation.h>
#include <QuartzCore/QuartzCore.h>
#include <ImageIO/ImageIO.h>
#include <CoreVideo/CoreVideo.h>
#include <CoreMedia/CoreMedia.h>

#import "CameraViewController.h"
#import "OverlayViewController.h"

@interface CameraViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *cameraView;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIWindow *overlayWindow;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    //CALayer *viewLayer = self.cameraView.layer;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    captureVideoPreviewLayer.frame = self.cameraView.bounds;
    [self.cameraView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (input) {
        [self.session addInput:input];
    }
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [self.session addOutput:self.stillImageOutput];
    
    //Establish Overlay Window
    self.overlayWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navController = [mainStoryboard instantiateViewControllerWithIdentifier:@"OverlayView"];
    OverlayViewController *overlayViewController = (OverlayViewController *)navController.topViewController;
    overlayViewController.cameraImaging = self;
    self.overlayWindow.rootViewController = navController;
    self.overlayWindow.windowLevel = UIWindowLevelAlert + 1;
}


- (void) pauseAndCaptureImageWithCompletion:(ImageCompletionBlock)blk {
    __block UIImage *image;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        image = [[UIImage alloc] initWithData:imageData];
        blk(image);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.session stopRunning];
            self.cameraView.image = image;
        });
        
     }];
}

- (BOOL)hasCamera {
    return self.session.inputs.count > 0;
}

- (void)resumeLiveCapture {
    self.cameraView.image = nil;
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.overlayWindow makeKeyAndVisible];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    self.overlayWindow.hidden = YES;
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}

- (IBAction)openCVTest:(id)sender {
    
}

@end
