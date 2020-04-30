//
//  BeautyPageViewController.m
//  BeautyPageViewController
//
//  Created by iverson1234tw on 2020/4/30.
//  Copyright © 2020 josh.chen. All rights reserved.
//

#import "BeautyPageViewController.h"

@interface BeautyPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource> {
    NSInteger ld_currentIndex; // 當前頁面
}
@property (strong, nonatomic) HMSegmentedControl *mainSegmentControl;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *viewcontrollersArr;
@property (strong, nonatomic) NSArray *segmentTitleArr;

@end

@implementation BeautyPageViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 加入對應的VC
    _viewcontrollersArr = [NSArray arrayWithObjects:[storyBoard instantiateViewControllerWithIdentifier:@"FirstPageViewController"], [storyBoard instantiateViewControllerWithIdentifier:@"SecondPageViewController"], [storyBoard instantiateViewControllerWithIdentifier:@"ThirdPageViewController"], [storyBoard instantiateViewControllerWithIdentifier:@"FourPageViewController"], nil];
    
    // 填寫Segment的標題
    _segmentTitleArr = [NSArray arrayWithObjects:@"First", @"Second", @"Third", @"Fourth", nil];
    
    _mainSegmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:_segmentTitleArr];
    [self setHMSegmentControl:_mainSegmentControl];
    
    [_mainSegmentControl addTarget:self action:@selector(manageTransferSegmentAction:) forControlEvents:UIControlEventValueChanged];
    
    [self pageViewController];
    [self.view addSubview:_mainSegmentControl];

}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    // 若不合規會在此處攔住並且觸發錯誤
    NSAssert(_viewcontrollersArr.count > 0, @"ChildViewController必須至少有一個");
    NSAssert(_segmentTitleArr.count == _viewcontrollersArr.count, @"ChildViewController的數量和Segment的Title數量不相符");
    
    UIViewController *vc = [_viewcontrollersArr objectAtIndex:[_mainSegmentControl selectedSegmentIndex]];
    
    [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
}

#pragma mark - 設置Segment -

- (void)setHMSegmentControl:(HMSegmentedControl *)inputControl {
 
    inputControl.frame = CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, SCREEN_WIDTH, [UIApplication sharedApplication].statusBarFrame.size.height + adaptX(60));
    inputControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    inputControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    inputControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    inputControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    inputControl.backgroundColor = [UIColor colorWithRed:173.0/255.0 green:217.0/255.0 blue:237.0/255.0 alpha:1.0];
    inputControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor]};
    inputControl.segmentEdgeInset = UIEdgeInsetsMake(0, 20, 0, 20);
    inputControl.titleTextAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size: 20],NSForegroundColorAttributeName : [UIColor whiteColor]};
    
}

#pragma mark - 設置PageView -

- (UIPageViewController *)pageViewController {
    
    if (_pageViewController == nil) {
        
        NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:UIPageViewControllerOptionInterPageSpacingKey];
        _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        
    }
    
    return _pageViewController;
}

- (void)manageTransferSegmentAction:(id)sender {
 
    UIViewController *vc = [_viewcontrollersArr objectAtIndex:[sender selectedSegmentIndex]];
    
    if ([sender selectedSegmentIndex] > ld_currentIndex) {
        
        [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
            
        }];
        
    } else {
        
        [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
            
        }];
    }
    
    ld_currentIndex = [sender selectedSegmentIndex];
    
}

#pragma mark - UIPageViewDelegate -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [_viewcontrollersArr indexOfObject:viewController];
    
    if (index == 0 || (index == NSNotFound)) {
        
        return nil;
    }
    
    index--;
    
    return [_viewcontrollersArr objectAtIndex:index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [_viewcontrollersArr indexOfObject:viewController];
    
    if (index == _viewcontrollersArr.count - 1 || (index == NSNotFound)) {
        
        return nil;
    }
    
    index++;
    
    return [_viewcontrollersArr objectAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    
    UIViewController *nextVC = [pendingViewControllers firstObject];
    
    NSInteger index = [_viewcontrollersArr indexOfObject:nextVC];
    
    ld_currentIndex = index;
    
    NSLog(@"準備轉 %ld", ld_currentIndex);
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed == true) {
        
        [_mainSegmentControl setSelectedSegmentIndex:ld_currentIndex animated:YES];
        
        NSLog(@"目前頁面 ==== %ld", (long)ld_currentIndex);
        
    } else {
        
        UIViewController *previousVC = [previousViewControllers firstObject];
        
        NSInteger index = [_viewcontrollersArr indexOfObject:previousVC];
        
        NSLog(@"前一頁是 ==== %ld", index);
        
        ld_currentIndex = index;
        
    }
    
    
}

@end
