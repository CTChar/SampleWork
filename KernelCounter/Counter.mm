//
//  Counter.mm
//  
//
//  Created by Cole Herzog on 9/6/15.
//
//

#import "Counter.h"
#include "kernel_counter.h"
#include <string>

//using namespace std;

@implementation Counter


+ (NSInteger)calculateKernelsFromImageURL:(NSURL *) url {
    const char *filePath = url.path.UTF8String;
    std::string fileName = filePath;
    double col_count, row_count = 0.0;
    int col_count_int, row_count_int = 0;
    single_corn(fileName, col_count, col_count_int, row_count, row_count_int);
    NSInteger total = col_count_int * row_count_int;
    //NSLog(@"%ld", (long)total);
    return total;
}


// COLUMNS WILL BE THE FIRST ELEMENT IN THE ARRAY
+ (NSArray *)calculateRowsAndColumnsFromImageURL:(NSURL *) url {
    const char *filePath = url.path.UTF8String;
    std::string fileName = filePath;
    double col_count, row_count = 0.0;
    int col_count_int, row_count_int = 0;
    single_corn(fileName, col_count, col_count_int, row_count, row_count_int);
    NSNumber *columns = [NSNumber numberWithDouble:col_count];
    NSNumber *rows = [NSNumber numberWithDouble:row_count];
    NSArray *returnArray = [NSArray arrayWithObjects:columns, rows, nil];
    return returnArray;
}
@end

