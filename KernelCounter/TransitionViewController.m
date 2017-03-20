//
//  TransitionViewController.m
//  
//
//  Created by Cole Herzog on 9/10/15.
//
//

#import "TransitionViewController.h"
#import "Counter.h"
#import "ResultsViewController.h"

#import "CameraImaging.h"

#define CORN_COUNTER_DELAY 2

@interface TransitionViewController ()

@end

@implementation TransitionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self invokeKernelCounter];
}

- (void)invokeKernelCounter {
    __weak TransitionViewController *weakSelf = self;
    double delaySecs = 2.0;
#if UI_TESTING
    delaySecs = 0.005;
#endif
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaySecs * NSEC_PER_SEC));
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_after(when, queue, ^{
        
#if UI_TESTING
        weakSelf.kernelTotal = [NSNumber numberWithInt:UI_TESTING_TOTAL];
#else
        // we have shown the spinner for CORN_COUNTER_DELAY secs
        weakSelf.kernelTotal = [NSNumber numberWithLong:[Counter calculateKernelsFromImageURL:weakSelf.picturePath]];
        NSArray *totalArray = [Counter calculateRowsAndColumnsFromImageURL:weakSelf.picturePath];
        weakSelf.colCount = [totalArray objectAtIndex:0];
        weakSelf.rowCount = [totalArray objectAtIndex:1];
#endif
        dispatch_async(dispatch_get_main_queue(), ^ {
            [weakSelf performSegueWithIdentifier: @"ResultsSegue" sender: self];
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ResultsSegue"]) {
        ResultsViewController *resultsView = segue.destinationViewController;
        resultsView.kernelCount = self.kernelTotal;
        resultsView.rows = self.rowCount;
        resultsView.columns = self.colCount;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
