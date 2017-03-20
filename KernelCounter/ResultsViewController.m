//
//  ResultsViewController.m
//  
//
//  Created by Cole Herzog on 9/11/15.
//
//

#import "ResultsViewController.h"
#import "CameraImaging.h"

#define kernelLowerBound 300
#define kernelUpperBound 700

@interface ResultsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *countView;
@property (weak, nonatomic) IBOutlet UISlider *plantingPopulation;
@property (weak, nonatomic) IBOutlet UILabel *populationView;
@property (weak, nonatomic) IBOutlet UILabel *yieldEstimate;

@end

@implementation ResultsViewController

- (void)updateValues {
    NSInteger sliderVal = (NSInteger)self.plantingPopulation.value;
    NSInteger kernelVal = self.kernelCount.integerValue;
    self.populationView.text = [NSString stringWithFormat:@"Planting Populations: %ldk", (long)sliderVal];
    NSInteger estimate = ((sliderVal) * kernelVal) / 87.5;
    self.yieldEstimate.text = [NSString stringWithFormat:@"%ld bu/ac", (long) estimate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *rowFormat = [NSString stringWithFormat:@"%.05f", self.rows.floatValue];
    NSString *colFormat = [NSString stringWithFormat:@"%.05f", self.columns.floatValue];
    self.countView.text = [NSString stringWithFormat:@"%@ Rows: %@ Columns: %@", self.kernelCount.stringValue, rowFormat, colFormat];
    [self updateValues];
    if (self.kernelCount.integerValue < kernelLowerBound || self.kernelCount.integerValue > kernelUpperBound) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unexpected Kernel Count" message:@"The calculated kernel count is abnormal for an average ear of corn. Please take another picture." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            UINavigationController *navController = self.navigationController;
            [navController popToRootViewControllerAnimated:NO];
        }];
        
        [alert addAction:okay];
        [self presentViewController:alert animated:NO completion:nil];

    }
    self.plantingPopulation.continuous = YES;
    [self.plantingPopulation addTarget:self action:@selector(updateValues) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)restartCamera:(id)sender {
    UINavigationController *navController = self.navigationController;
    [navController popToRootViewControllerAnimated:NO];
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
