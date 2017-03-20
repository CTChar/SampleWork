//
//  OverlayViewController.m
//  
//
//  Created by Cole Herzog on 9/9/15.
//
//

#import "OverlayViewController.h"
#import "TransitionViewController.h"

@interface OverlayViewController ()

@property (strong, nonatomic) IBOutlet UIView *cornOverlay;
@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) NSURL *pictureUrl;

@end

@implementation OverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
#if UI_TESTING
    self.pictureUrl = nil;
    [self performSegueWithIdentifier: @"TransitionSegue" sender: self];
#else
    [self.cameraImaging pauseAndCaptureImageWithCompletion:^(UIImage *cameraImage) {
        NSData *jpegData = UIImageJPEGRepresentation(cameraImage, 1.0f);
        self.pictureUrl = self.buildTempFileUrl;
        [jpegData writeToURL:self.pictureUrl atomically:NO];
        [self performSegueWithIdentifier: @"TransitionSegue" sender: self];
        }];
#endif
    self.cornOverlay.hidden = YES;
    self.cameraButton.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.cornOverlay.hidden = NO;
    self.cameraButton.hidden = !(UI_TESTING); //YES;
    if(self.cameraImaging.hasCamera) {
        self.cameraButton.hidden = NO;
    }
#if !UI_TESTING
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Disabled" message:@"You have disabled your camera. For full app functionality please enable it." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
    }
#endif
    [super viewWillAppear:animated];
    [self.cameraImaging resumeLiveCapture];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TransitionSegue"]) {
        TransitionViewController *transitionView = segue.destinationViewController;
        transitionView.picturePath = self.pictureUrl;
    }
}

- (NSURL *) buildTempFileUrl {
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", NSUUID.UUID.UUIDString];
    NSURL *fullUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    return fullUrl;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
