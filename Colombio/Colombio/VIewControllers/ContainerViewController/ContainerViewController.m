//
//  ContainerViewController.m
//  Colombio
//
//  Created by Vlatko Šprem on 13/01/15.
//  Copyright (c) 2015 Colombio. All rights reserved.
//

#import "ContainerViewController.h"
enum HeaderMovement{
    toLeft = 1,
    toRight = 0,
    dontMove = 2
};


@interface ContainerViewController ()
{
    UIScrollView *pageScrollView;
    NSInteger currentPageIndex;
    NSInteger numberOfPages;
    BOOL isScrollToRight;
    int headerMovement;
    CGFloat xFromCenterLastPosition;
}

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIView *viewProgressBar;
@property (strong, nonatomic) NSMutableArray *headerBtnsArray;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_progressBarWidth;

@end

@implementation ContainerViewController
@synthesize viewControllersArray=_viewControllersArray, nextButtonTitle=_nextButtonTitle;

/*- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andControllers:(NSArray*)controllers{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _viewControllersArray = controllers;
    }
    return self;
}*/
- (void)viewDidLoad {
    [super viewDidLoad];
    currentPageIndex = 0;
    headerMovement = dontMove;
    xFromCenterLastPosition= 0.0;
    numberOfPages = _viewControllersArray.count;
    _headerBtnsArray = [[NSMutableArray alloc] init];
    [self setupHeader];
    [self setupProgressBar];
    [self setupPageViewController];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupHeader{
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=0;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"backgrey_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"backgrey_pressed"] forState:UIControlStateHighlighted];
        btn.frame = CGRectMake(10, 0, 44, 44);
        [_headerBtnsArray addObject:btn];
        [_viewHeader addSubview:btn];
    }
    
    for(int i=0;i<_viewControllersArray.count;i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=i+1;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        NSString *title = (((UIViewController*)_viewControllersArray[i]).title.length?((UIViewController*)_viewControllersArray[i]).title:@"    ");
        
        [btn setTitle:title  forState:UIControlStateNormal];
        btn.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
        CGSize stringsize = [title sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT]];
        btn.frame = CGRectMake(100, 0, stringsize.width, 20);
        btn.center = CGPointMake(btn.tag*(self.view.bounds.size.width/2), _viewHeader.frame.size.height/2);
        if (btn.tag==currentPageIndex+1) {
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTONLABEL] forState:UIControlStateNormal];
            btn.userInteractionEnabled=NO;
        }else{
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON] forState:UIControlStateNormal];
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] forState:UIControlStateHighlighted];
        }
        [_headerBtnsArray addObject:btn];
        [_viewHeader addSubview:btn];
        
    }
    //next button - navcontroller
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=_headerBtnsArray.count;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.nextButtonTitle.length>0) {
            [btn setTitle:self.nextButtonTitle  forState:UIControlStateNormal];
            btn.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
            CGSize stringsize = [self.nextButtonTitle sizeWithFont:[[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT]];
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON] forState:UIControlStateNormal];
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] forState:UIControlStateHighlighted];
            btn.frame = CGRectMake((numberOfPages+1)*(_viewHeader.frame.size.width/2)-stringsize.width-10, 0, stringsize.width, 20);
            btn.center = CGPointMake(btn.center.x, _viewHeader.frame.size.height/2);
        }else{
            [btn setBackgroundImage:_imgNextBtnNormal forState:UIControlStateNormal];
            [btn setBackgroundImage:_imgNextBtnPressed forState:UIControlStateHighlighted];
            btn.frame = CGRectMake((numberOfPages+1)*(_viewHeader.frame.size.width/2)-44, 0, 44, 44);
        }
        [_headerBtnsArray addObject:btn];
        [_viewHeader addSubview:btn];
    }
}

- (void)setupProgressBar{
    _CS_progressBarWidth.constant = self.view.bounds.size.width/numberOfPages;
}

-(void)setupPageViewController
{
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.view.frame = CGRectMake(0, 0, _viewContainer.frame.size.width, _viewContainer.frame.size.height);
    [_viewContainer addSubview:_pageViewController.view];
    [self addChildViewController:_pageViewController];
    [_pageViewController didMoveToParentViewController:self];
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self syncScrollView];
}

//%%% this allows us to get information back from the scrollview, namely the coordinate information that we can link to the selection bar.
#pragma mark ScrollView

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    double delayInSeconds = 0.5;
    _pageViewController.view.userInteractionEnabled=NO;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _pageViewController.view.userInteractionEnabled=YES;
            });
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat xFromCenter = self.view.frame.size.width-pageScrollView.contentOffset.x;
    //%%% positive for right swipe, negative for left
    
        [self headerMovementWithScroll:((xFromCenter!=0?xFromCenter-xFromCenterLastPosition:0))/2];
        [self progressBarMovement:((xFromCenter!=0?xFromCenter-xFromCenterLastPosition:0))/numberOfPages];
        xFromCenterLastPosition = xFromCenter;
}

-(void)syncScrollView
{
    for (UIView* view in _pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]])
        {
            pageScrollView = (UIScrollView *)view;
            pageScrollView.delegate = self;
        }
    }
}
#pragma mark HeaderMovement
- (void)headerMovement:(enum HeaderMovement)movement{
    [UIView animateWithDuration:0.1
                     animations:^{
                         for(UIButton *btn in _headerBtnsArray){
                             CGRect frame = btn.frame;
                             if (movement) {
                                 frame.origin.x -= self.view.bounds.size.width/2;
                             }else{
                                 frame.origin.x += self.view.bounds.size.width/2;
                             }
                             
                             btn.frame = frame;
                         }
                     }];
}

- (void)headerMovementWithScroll:(CGFloat)xmovement{
    
    [UIView animateWithDuration:0.0
                     animations:^{
                             for(UIButton *btn in _headerBtnsArray){
                                 CGRect frame = btn.frame;
                                 frame.origin.x += xmovement;
                                 btn.frame = frame;
                             pageScrollView.scrollEnabled=YES;
                         }
                     }];
}

- (void)progressBarMovement:(CGFloat)movement{
    [UIView animateWithDuration:0.0
                     animations:^{
                         _CS_progressBarWidth.constant -=movement;
                         pageScrollView.scrollEnabled=YES;
                     }];
}

- (void)setHeaderButtonsAfterMovement{
    for(UIButton *btn in _headerBtnsArray){
        if (btn.tag == currentPageIndex+1) {
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTONLABEL] forState:UIControlStateNormal];
            btn.userInteractionEnabled=NO;
        }else{
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON] forState:UIControlStateNormal];
            [btn setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTON_HIGHLIGHT] forState:UIControlStateHighlighted];
            btn.userInteractionEnabled=YES;
        }
    }
    pageScrollView.userInteractionEnabled=YES;
}

#pragma mark PageViewController delegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = [self indexOfController:viewController];
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    index--;
    return [_viewControllersArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = [self indexOfController:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [_viewControllersArray count]) {
        return nil;
    }
    return [_viewControllersArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        currentPageIndex = [self indexOfController:[pageViewController.viewControllers lastObject]];
        [self setHeaderButtonsAfterMovement];
        /* NSInteger tempIndex = [self indexOfController:[previousViewControllers lastObject]];
        if (tempIndex<currentPageIndex) {
            [self headerMovement:toRight];
        }else{
            [self headerMovement:toLeft];
        }*/
       
        
    }
}

-(NSInteger)indexOfController:(UIViewController *)viewController
{
    for (int i = 0; i<[_viewControllersArray count]; i++) {
        if (viewController == [_viewControllersArray objectAtIndex:i])
        {
            return i;
        }
    }
    return NSNotFound;
}

#pragma mark Header Button Action
- (void)btnAction:(UIButton*)sender{
    if (sender.tag == 0) {
        if ([self isModal])
            [self dismissViewControllerAnimated:NO completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }else if(sender.tag == _headerBtnsArray.count-1){
        [self navigateNext];
    }else {
        NSInteger tempIndex = currentPageIndex;
        __weak typeof(self) weakSelf = self;
        if (sender.tag>tempIndex+1) {
                [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:tempIndex+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                    
                    //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                    //then it updates the page that it's currently on
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:tempIndex+1];
                        [weakSelf setHeaderButtonsAfterMovement];
                    }
                }];
        }else if (sender.tag < tempIndex) {
                [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:tempIndex-1]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                    if (complete) {
                        [weakSelf updateCurrentPageIndex:tempIndex-1];
                        [weakSelf setHeaderButtonsAfterMovement];
                    }
                }];
        
        }
    }
}

- (void)navigateNext{
    /**
    *****Override in subclass!!!
    **/
}

-(void)updateCurrentPageIndex:(int)newIndex
{
    currentPageIndex = newIndex;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}


@end
