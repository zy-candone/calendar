//
//  LKAppDelegate.m
//  LKDBHelper
//
//  Created by upin on 13-4-15.
//  Copyright (c) 2013年 ljh. All rights reserved.
//

#import "LKAppDelegate.h"
#import "MasterCustomerListViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface LKAppDelegate()<UITextViewDelegate>
//@property(strong,nonatomic)NSMutableString* ms;
//@property(unsafe_unretained,nonatomic)UITextView* tv;
@end

@implementation LKAppDelegate
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self.window endEditing:YES];
//}
//-(void)add:(NSString*)txt
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_ms appendString:@"\n"];
//        [_ms appendString:txt];
//        [_ms appendString:@"\n"];
//        
//        self.tv.text = _ms;
//    });
//}
#define addText(fmt, ...) [self add:[NSString stringWithFormat:fmt,##__VA_ARGS__]]

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // If the device is an iPad, we make it taller.
    _tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 70 : 50];
    [_tabBarController setMinimumHeightToDisplayTitle:40.0];
    
    UITableViewController *tableViewController = [[MasterCustomerListViewController alloc] init];//initWithStyle:UITableViewStylePlain];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    
    [_tabBarController setViewControllers:[NSMutableArray arrayWithObjects:
                                           navigationController,
                                           [[SecondViewController alloc] init],
                                           [[ThirdViewController alloc] init],nil]];
    [_window setRootViewController:_tabBarController];
    [_window makeKeyAndVisible];
    
    /*self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.ms = [NSMutableString string];
    UITextView* textview = [[UITextView alloc]init];
    textview.frame = CGRectMake(0, 20, 320, self.window.bounds.size.height);
    textview.textColor = [UIColor blackColor];
    textview.delegate =self;
    [self.window addSubview:textview];
    self.tv = textview;
    [self.window makeKeyAndVisible];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self test];
    });
    return YES;*/
}
@end

