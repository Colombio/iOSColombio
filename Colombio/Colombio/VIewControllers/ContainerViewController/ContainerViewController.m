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
    UILabel *lblHeader;
    BOOL hideBackButton;
}

@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIView *viewProgressBar;
@property (strong, nonatomic) NSMutableArray *headerBtnsArray;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_progressBarWidth;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *CS_containerBottomMargin;
@property (strong, nonatomic) UIButton *nextButton;


@end

@implementation ContainerViewController
@synthesize viewControllersArray=_viewControllersArray, nextButtonTitle=_nextButtonTitle, currentPageIndex;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withSingleTitle:(BOOL)singleTitle{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSingleTitle = singleTitle;
        currentPageIndex = index;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil focusOnControllerIndex:(NSInteger)index withSingleTitle:(BOOL)singleTitle andProgressBarAnimation:(BOOL)progress{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSingleTitle = singleTitle;
        currentPageIndex = index;
        _progressBarAnimation = progress;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentPageIndex = 0;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    //currentPageIndex = 0;
    headerMovement = dontMove;
    xFromCenterLastPosition= 0.0;
    numberOfPages = _viewControllersArray.count;
    _headerBtnsArray = [[NSMutableArray alloc] init];
    if (_isSingleTitle) {
        [self setupSingleHeader];
    }else{
        [self setupHeader];
    }
    [self setupProgressBar];
    [self setupPageViewController];
    /*if ([self.parentViewController.parentViewController isKindOfClass:[UITabBarController class]]) {
        _CS_containerBottomMargin.constant = 49.0;
    }else{
        _CS_containerBottomMargin.constant = 0;
    }*/
}

- (void)viewWillAppear:(BOOL)animated{
    hideBackButton = _btnBack.isHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSingleHeader{
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBack.tag=0;
    [_btnBack addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnBack setBackgroundImage:[UIImage imageNamed:@"backgrey_normal"] forState:UIControlStateNormal];
    [_btnBack setBackgroundImage:[UIImage imageNamed:@"backgrey_pressed"] forState:UIControlStateHighlighted];
    _btnBack.frame = CGRectMake(10, 0, 44, 44);
    [_headerBtnsArray addObject:_btnBack];
    [_viewHeader addSubview:_btnBack];
    
    lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 20)];
    lblHeader.center = CGPointMake(_viewHeader.frame.size.width/2, _viewHeader.frame.size.height/2);
    lblHeader.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_LIGHT];
    lblHeader.textColor = [[UIConfiguration sharedInstance] getColor:COLOR_TEXT_NAVIGATIONBAR_BUTTONLABEL];
    if (_flexibleHeader) {
        lblHeader.adjustsFontSizeToFitWidth = YES;
        lblHeader.minimumScaleFactor = 0.5;
    }
    lblHeader.textAlignment = NSTextAlignmentCenter;
    lblHeader.text = ((UIViewController*)_viewControllersArray[currentPageIndex]).title;
    [_viewHeader addSubview:lblHeader];
    
    if (!_staticHeader) {
        {
            _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_nextButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            _nextButton.titleLabel.font = [[UIConfiguration sharedInstance] getFont:FONT_HELVETICA_NEUE_NEXT];
            [_nextButton setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON] forState:UIControlStateNormal];
            [_nextButton setTitleColor:[[UIConfiguration sharedInstance] getColor:COLOR_NEXT_BUTTON_SELECTED] forState:UIControlStateHighlighted];
            _nextButton.frame = CGRectMake(self.view.bounds.size.width-80, 11, 80, 20);
            _nextButton.titleLabel.textAlignment = NSTextAlignmentRight;
            [self setNextButtonTitle];
            [_viewHeader addSubview:_nextButton];
        }
    }
    
}

- (void)setNextButtonTitle{
    [_nextButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    if (currentPageIndex+1 == _viewControllersArray.count) {
        [_nextButton setTitle:_lastNextBtnText  forState:UIControlStateNormal];
    }else{
        [_nextButton setTitle:[Localized string:@"header_next"]  forState:UIControlStateNormal];
    }
}

- (void)setBackButton{
    if (hideBackButton && currentPageIndex==0) {
        _btnBack.hidden=YES;
    }else{
        _btnBack.hidden=NO;
    }
}

- (void)setupHeader{
    {
        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnBack.tag=0;
        [_btnBack addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
        [_btnBack setBackgroundImage:[UIImage imageNamed:@"backgrey_normal"] forState:UIControlStateNormal];
        [_btnBack setBackgroundImage:[UIImage imageNamed:@"backgrey_pressed"] forState:UIControlStateHighlighted];
        _btnBack.frame = CGRectMake(10, 0, 44, 44);
        [_headerBtnsArray addObject:_btnBack];
        [_viewHeader addSubview:_btnBack];
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
    if (!_progressBarAnimation) {
        _CS_progressBarWidth.constant = self.view.bounds.size.width;
        _viewProgressBar.backgroundColor = [UIColor lightGrayColor];
    }else{
        _CS_progressBarWidth.constant = self.view.bounds.size.width/numberOfPages;
    }
    
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
    [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:currentPageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self syncScrollView];
}

//%%% this allows us to get information back from the scrollview, namely the coordinate information that we can link to the selection bar.
#pragma mark ScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

}
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
    if (_progressBarAnimation) {
        [self headerMovementWithScroll:((xFromCenter!=0?xFromCenter-xFromCenterLastPosition:0))/2];
        [self progressBarMovement:((xFromCenter!=0?xFromCenter-xFromCenterLastPosition:0))/numberOfPages];
        xFromCenterLastPosition = xFromCenter;
    }
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
    if (!_isSingleTitle) {
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
    
}

- (void)progressBarMovement:(CGFloat)movement{
    [UIView animateWithDuration:0.0
                     animations:^{
                         _CS_progressBarWidth.constant -=movement;
                         pageScrollView.scrollEnabled=YES;
                     }];
}

- (void)setHeaderButtonsAfterMovement{
    if (_isSingleTitle) {
        lblHeader.text = ((UIViewController*)_viewControllersArray[currentPageIndex]).title;
        [self setNextButtonTitle];
        [self setBackButton];
    }else{
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
        [self currentPageIndexShown:currentPageIndex];
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
- (void)btnBack:(UIButton*)sender{
    /**
     *****Override in subclass!!!
     **/
}

- (void)btnAction:(UIButton*)sender{
    /*if (sender.tag == 0) {
        if ([self isModal])
            [self dismissViewControllerAnimated:NO completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }else*/
    
    if (_staticHeader) {
        [self btnBack:sender];
    }else{
        if (_isSingleTitle) {
            if(sender==_nextButton && currentPageIndex+1==_viewControllersArray.count){
                [self navigateNext];
            }else if(sender==_btnBack && currentPageIndex==0){
                [self btnBack:sender];
            }else {
                NSInteger tempIndex = currentPageIndex;
                __weak typeof(self) weakSelf = self;
                if (sender==_nextButton) {
                    [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:tempIndex+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                        
                        //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                        //then it updates the page that it's currently on
                        if (complete) {
                            [weakSelf updateCurrentPageIndex:(int)tempIndex+1];
                            [weakSelf setHeaderButtonsAfterMovement];
                            [weakSelf currentPageIndexShown:(int)tempIndex+1];
                        }
                    }];
                }else if (sender==_btnBack) {
                    [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:tempIndex-1]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                        if (complete) {
                            [weakSelf updateCurrentPageIndex:(int)tempIndex-1];
                            [weakSelf setHeaderButtonsAfterMovement];
                            [weakSelf currentPageIndexShown:(int)tempIndex-1];
                        }
                    }];
                    
                }
            }
        }else{
            if(sender.tag == _headerBtnsArray.count-1){
                [self navigateNext];
            }else {
                NSInteger tempIndex = currentPageIndex;
                __weak typeof(self) weakSelf = self;
                if (sender.tag>tempIndex+1) {
                    [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:tempIndex+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                        
                        //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                        //then it updates the page that it's currently on
                        if (complete) {
                            [weakSelf updateCurrentPageIndex:(int)tempIndex+1];
                            [weakSelf setHeaderButtonsAfterMovement];
                            [weakSelf currentPageIndexShown:(int)tempIndex+1];
                        }
                    }];
                }else if (sender.tag < tempIndex) {
                    [_pageViewController setViewControllers:@[[_viewControllersArray objectAtIndex:tempIndex-1]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                        if (complete) {
                            [weakSelf updateCurrentPageIndex:(int)tempIndex-1];
                            [weakSelf setHeaderButtonsAfterMovement];
                            [weakSelf currentPageIndexShown:(int)tempIndex-1];
                        }
                    }];
                    
                }
            }
        }
    }
}

- (void)navigateNext{
    /**
    *****Override in subclass!!!
    **/
}

- (void)currentPageIndexShown:(NSInteger)currentPageIndex{
    /**
     *****Override in subclass!!!
     *****For Tutorial purpose only!!!
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
