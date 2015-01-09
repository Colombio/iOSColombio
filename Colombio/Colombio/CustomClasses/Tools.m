//
//  Tools.m
//  colombio
//
//  Created by Vlatko Šprem on 19/10/14.
//  Copyright (c) 2014 Colombio. All rights reserved.
//

#import "Tools.h"
#import "AppDelegate.h"

@implementation Tools

+ (NSInteger)getNumberOfNewDemands{
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT count(*) FROM newsdemandlist where isread = 0 AND end_timestamp >= '%@' AND status = 1",[NSDate date]];
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    return [[appdelegate.db getColForSQL:sql] integerValue];
}

+ (UILabel*)getBadgeObject:(long )count frame:(CGRect)frame{
    UILabel *lblBadge = [[UILabel alloc] init];
    lblBadge.textAlignment = NSTextAlignmentCenter;
    lblBadge.clipsToBounds = YES;
    lblBadge.layer.cornerRadius=9;
    //lblBadge.layer.borderColor = [UIColor whiteColor].CGColor;
    //lblBadge.layer.borderWidth=1.0f;
    lblBadge.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    lblBadge.backgroundColor = [UIColor redColor];
    
    lblBadge.hidden=NO;
    CGSize stringsize = [[NSString stringWithFormat:@"%ld", (long)count] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
    //lblBadge.frame = CGRectMake(newsDemand.frame.origin.x+newsDemand.frame.size.width-10-stringsize.width,newsDemand.frame.origin.y,(stringsize.width<21?20:stringsize.width+10),20);
    lblBadge.frame = CGRectMake(frame.origin.x+8,frame.origin.y+7,(stringsize.width<21?18:stringsize.width+8),18);
    lblBadge.textColor = [UIColor whiteColor];
    lblBadge.text = [NSString stringWithFormat:@"%ld", (long)count];
    return lblBadge;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
