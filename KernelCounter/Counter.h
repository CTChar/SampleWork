//
//  Counter.h
//  
//
//  Created by Cole Herzog on 9/6/15.
//
//

#import <Foundation/Foundation.h>

@interface Counter : NSObject

+ (NSInteger)calculateKernelsFromImageURL:(NSURL *) url;

+ (NSArray *)calculateRowsAndColumnsFromImageURL:(NSURL *) url;
@end
