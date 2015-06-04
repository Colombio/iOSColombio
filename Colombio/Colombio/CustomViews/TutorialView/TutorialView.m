//
//  TutorialView.m
//  Colombio
//
//  Created by Vlatko Šprem on 01/06/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "TutorialView.h"

@implementation TutorialView

- (id)initWithFrame:(CGRect)frame andTutorialSet:(NSInteger)tutorialSet
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TutorialView"
                        owner:self
                        options:nil];
        self = [nib objectAtIndex:0];
        self.frame = frame;
        _imgTutorial.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapRecognizer:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setDelegate:self];
        
        [_imgTutorial addGestureRecognizer:tapRecognizer];
        
        _tutorialSet=tutorialSet;
        
        if (_tutorialSet==3){
            numberOfImages=3;
        }else if(_tutorialSet==5){
            numberOfImages=2;
        }
        currentImage=1;
    }
    return self;
}



- (void)handleTapRecognizer:(id)sender{
    if (_tutorialSet==1) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL1];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self removeFromSuperview];
        
    }else if(_tutorialSet==2){
        
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL2];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self removeFromSuperview];
        
    }else if(_tutorialSet==3){
        if (currentImage==1) {
            
            currentImage++;
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL3];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _imgTutorial.image = [UIImage imageNamed:@"tut4"];
            
        }else if(currentImage==2){
            
            currentImage++;
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL4];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _imgTutorial.image = [UIImage imageNamed:@"tut5"];
            
        }else{
         
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL5];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self removeFromSuperview];
            
        }
        
    }else if(_tutorialSet==4){
        
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL6];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self removeFromSuperview];
        
    }else if(_tutorialSet==5){
        
        if (currentImage==1) {
            
            currentImage++;
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL7];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _imgTutorial.image = [UIImage imageNamed:@"tut8"];
            
        }else if(currentImage==2){
            
            currentImage++;
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:TUTORIAL8];
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:SHOW_TUTORIAL];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(tutorialTapped)]) {
                [self.delegate tutorialTapped];
            }
        }
    }

    
}

- (IBAction)btnSkipSelected:(id)sender{
    if ([self.delegate respondsToSelector:@selector(tutorialTapped)]) {
        [self.delegate tutorialTapped];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:SHOW_TUTORIAL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self removeFromSuperview];
}


@end
