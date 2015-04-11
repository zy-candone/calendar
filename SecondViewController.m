//
//  SecondViewController.m
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 04/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController (){
    
}

@end

@implementation SecondViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"task";//任务";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"image-2";
}

-(void)viewDidLoad{
    _uvTop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 65)];
    _uvTop.backgroundColor=[UIColor grayColor];
    [self.view addSubview:_uvTop];
    _sampleView= [[CalendarView alloc]initWithFrame:CGRectMake(0, 66, self.view.bounds.size.width, self.view.bounds.size.height-80)];
    _sampleView.delegate = self;
    [_sampleView setBackgroundColor:[UIColor whiteColor]];
    _sampleView.calendarDate = [NSDate date];
    [self.view addSubview:_sampleView];
}
@end
