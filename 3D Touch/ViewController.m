//
//  ViewController.m
//  3D Touch
//
//  Created by Jay Versluis on 21/09/2015.
//  Copyright © 2015 Pinkstone Pictures LLC. All rights reserved.
//

#import "ViewController.h"
#import "PreviewViewController.h"

@interface ViewController () <UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
@property (nonatomic, strong) NSNumber *cnt;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.cnt=@0;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self check3DTouch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)check3DTouch {
    
    // register for 3D Touch (if available)
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        
        [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
        NSLog(@"3D Touch is available! Hurra!");
        
        // no need for our alternative anymore
        self.longPress.enabled = NO;
        
    } else {
        
        NSLog(@"3D Touch is not available on this device. Sniff!");
        
        // handle a 3D Touch alternative (long gesture recognizer)
        self.longPress.enabled = YES;
        
    }
}

- (UILongPressGestureRecognizer *)longPress {
    
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showPeek)];
        [self.view addGestureRecognizer:_longPress];
    }
    return _longPress;
}


# pragma mark - 3D Touch Delegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    // check if we're not already displaying a preview controller
    if ([self.presentedViewController isKindOfClass:[PreviewViewController class]]) {
        return nil;
    }
    self.cnt=@(self.cnt.intValue+1);
    
    // shallow press: return the preview controller here (peek)
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *previewController = [storyboard instantiateViewControllerWithIdentifier:@"PreviewView"];
    //    previewController =[[UIViewController alloc]init];
    //    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0,0, 200,200)];
    //    [view setBackgroundColor:[UIColor redColor]];
    //    [previewController.view addSubview:view];
    //    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    //    label.text=[NSString stringWithFormat:@"counter is %@",self.cnt];
    //    [view addSubview:label];
    return previewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    // deep press: bring up the commit view controller (pop)
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *commitController = [storyboard instantiateViewControllerWithIdentifier:@"CommitView"];
    
    [self showViewController:commitController sender:self];
    
    // alternatively, use the view controller that's being provided here (viewControllerToCommit)
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    // called when the interface environment changes
    // one of those occasions would be if the user enables/disables 3D Touch
    // so we'll simply check again at this point
    
    [self check3DTouch];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGFloat force = touch.force;
        CGFloat percentage = force/touch.maximumPossibleForce;
        CGPoint po=[touch locationInView:touch.view];
        NSLog(@"%f %f",po.x,po.y);
        NSLog(@"Printing force : %f", force);
        NSLog(@"Printing percentage: %f", percentage);
        NSLog(@"Printing maximum possible force: %f",    touch.maximumPossibleForce);
        // break;
    }
}
#pragma mark - 3D Touch Alternative

- (void)showPeek {
    
    // disable gesture so it's not called multiple times
    self.longPress.enabled = NO;
    
    // present the preview view controller (peek)
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PreviewViewController *preview = [storyboard instantiateViewControllerWithIdentifier:@"PreviewView"];
    
    UIViewController *presenter = [self grabTopViewController];
    [presenter showViewController:preview sender:self];
    
}

- (UIViewController *)grabTopViewController {
    
    // helper method to always give the top most view controller
    // avoids "view is not in the window hierarchy" error
    // http://stackoverflow.com/questions/26022756/warning-attempt-to-present-on-whose-view-is-not-in-the-window-hierarchy-sw
    
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    
    return top;
}

@end
