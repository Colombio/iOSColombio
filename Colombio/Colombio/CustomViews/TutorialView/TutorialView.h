//
//  TutorialView.h
//  Colombio
//
//  Created by Vlatko Šprem on 01/06/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TutorialViewDelegate <NSObject>
@optional
- (void)tutorialTapped;

@end


@interface TutorialView : UIView <UIGestureRecognizerDelegate>
{
    NSInteger numberOfImages;
    NSInteger currentImage;
}
@property (weak, nonatomic) id<TutorialViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgTutorial;
@property (weak, nonatomic) IBOutlet UIButton *btnSkipTutorial;
@property (assign, nonatomic) NSInteger tutorialSet;

- (id)initWithFrame:(CGRect)frame andTutorialSet:(NSInteger)tutorialSet;
@end
