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
    NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT count(*) FROM newsdemandlist where isread = 0 AND end_timestamp >= '%@'",[NSDate date]];
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

+ (NSString*)getFilePaths:(NSString *)filePathName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:filePathName];
}

+ (UIImage *)convertImageToGrayScale:(UIImage *)image {
    
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

+ (NSString*)getStringFromDate:(NSDate*)date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

+ (NSDate*)getDateFromAPIString:(NSString*)date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter dateFromString:date];
}

+ (NSDate*)getDateFromString:(NSString*)date{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
    return [formatter dateFromString:date];
}

+ (NSInteger)daysDifferenceBetween:(NSDate*)startDate And:(NSDate*)endDate{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    return [components day]+1;
}

+ (NSString*)getStringFromDateString:(NSString*)strDate withFormat:(NSString*)strFormat{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSDate *date = [formatter dateFromString:strDate];
    [formatter setDateFormat:strFormat];
    return [formatter stringFromDate:date];
}
@end
