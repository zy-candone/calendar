//
//  ThirdViewController.m
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 04/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

#import "ThirdViewController.h"
#import "LKAppDelegate.h"
#define addText(fmt, ...) [self add:[NSString stringWithFormat:fmt,##__VA_ARGS__]]

@interface ThirdViewController ()
@property(strong,nonatomic)NSMutableString* ms;
@property(unsafe_unretained,nonatomic)UITextView* tv;
@end

@implementation ThirdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"设置";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"image_configuration";
}

-(void)viewDidLoad{
     self.ms = [NSMutableString string];
     UITextView* textview = [[UITextView alloc]init];
     textview.frame = CGRectMake(0, 20, 320, self.view.bounds.size.height);
     textview.textColor = [UIColor blackColor];
     textview.delegate =self;
     [self.view addSubview:textview];
     self.tv = textview;
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
     [self test];
     });
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
-(void)add:(NSString*)txt
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_ms appendString:@"\n"];
        [_ms appendString:txt];
        [_ms appendString:@"\n"];
        
        self.tv.text = _ms;
    });
}

-(void)test
{
    addText(@"示例 开始 example start \n\n");
    ///获取 LKTest 类使用的 LKDBHelper
    LKDBHelper* globalHelper = [LKTest getUsingLKDBHelper];
    
    ///删除所有表   delete all table
    // [globalHelper dropAllTable];
    
    addText(@"LKTest create table sql :\n%@\n",[LKTest getCreateTableSQL]);
    addText(@"LKTestForeign create table sql :\n%@\n",[LKTestForeign getCreateTableSQL]);
    
    //清空表数据  clear table data
    //[LKDBHelper clearTableData:[LKTest class]];
    
    //初始化数据模型  init object
    LKTest* test = [[LKTest alloc]init];
    test.firstName = @"tony_35";
    
    //外键  foreign key
    LKTestForeign* foreign = [[LKTestForeign alloc]init];
    foreign.address = @":asdasdasdsadasdsdas";
    foreign.postcode  = 123341;
    foreign.addid = 0035;
    
    test.address = foreign;
    [test saveToDB];
    [globalHelper insertToDB:test];
    
    //事物  transaction
    [globalHelper executeForTransaction:^BOOL(LKDBHelper *helper) {
        test.firstName = @"firstname_02";
        BOOL success = [helper insertToDB:test];
        test.firstName = @"lastname_02";
        success = [helper insertToDB:test];
        //重复主键   duplicate primary key
        test.rowid = 0;     //no new object,should set rowid:0
        BOOL insertSucceed = [helper insertWhenNotExists:test];
        //insert fail
        if(insertSucceed == NO)
        {
            ///rollback
            return NO;
        }
        else
        {
            ///commit
            return YES;
        }
    }];
    
    
    addText(@"同步插入 完成!  Insert completed synchronization");
    
    sleep(1);
    
    test.firstName = @"firstname_03";

    [globalHelper insertToDB:test callback:^(BOOL isInsert) {
        addText(@"asynchronization insert complete: %@",isInsert>0?@"YES":@"NO");
    }];
    
    //查询   search
    NSMutableArray* searchResultArray = nil;
    
    addText(@"\n search one: \n");
    ///同步搜索 执行sql语句 把结果变为LKTest对象
    ///Synchronous search executes the SQL statement put the results into a LKTest object
    searchResultArray = [globalHelper searchWithSQL:@"select * from @t" toClass:[LKTest class]];
    for (id obj in searchResultArray) {
        addText(@"%@",[obj printAllPropertys]);
    }
    
    addText(@"\n search two: \n");
    ///搜索所有值     search all
    searchResultArray = [LKTest searchWithWhere:nil orderBy:nil offset:0 count:100];
    for (id obj in searchResultArray) {
        addText(@"%@",[obj printAllPropertys]);
    }
    
    addText(@"查询 单个 列   search single column");
    ///只获取name那列的值   search with column 'name' results
    NSArray* nameArray = [LKTest searchColumn:@"name" where:nil orderBy:nil offset:0 count:0];
    addText(@"%@",[nameArray componentsJoinedByString:@","]);
    
    
    ///
    addText(@"休息2秒 开始  为了说明 是异步插入的\n"
            "rest for 2 seconds to start is asynchronous inserted to illustrate");
    
    sleep(2);
    
    addText(@"休息2秒 结束 \n rest for 2 seconds at the end");
    
    //异步 asynchronous
    [globalHelper search:[LKTest class] where:nil orderBy:nil offset:0 count:100 callback:^(NSMutableArray *array) {
        
        addText(@"异步搜索 结束,  async search end");
        for (NSObject* obj in array) {
            addText(@"%@",[obj printAllPropertys]);
        }
        
        sleep(1);
        
        ///修改    update object
        LKTest* test2 = [array objectAtIndex:0];
        test2.firstName = @"firstname_04";
        
        [globalHelper updateToDB:test2 where:nil];
        
        addText(@"修改完成 , update completed ");
        
        ///all
        array =  [globalHelper search:[LKTest class] where:nil orderBy:nil offset:0 count:100];
        for (NSObject* obj in array) {
            addText(@"%@",[obj printAllPropertys]);
        }
        
        
        ///delete
        test2.rowid = 0;
        BOOL ishas = [globalHelper isExistsModel:test2];
        if(ishas)
        {
            //删除    delete
            [globalHelper deleteToDB:test2];
        }
        
        addText(@"删除完成, delete completed");
        sleep(1);
        
        ///all
        array =  [globalHelper search:[LKTest class] where:nil orderBy:nil offset:0 count:100];
        for (NSObject* obj in array) {
            addText(@"%@",[obj printAllPropertys]);
        }
        
        addText(@"示例 结束  example finished\n\n");
        
        
        
        //Expansion: Delete the picture is no longer stored in the database record
        addText(@"扩展:  删除已不再数据库中保存的 图片记录 \n expansion: Delete the picture is no longer stored in the database record");
        //目前 已合并到LKDBHelper 中  就先写出来 给大家参考下
        
        [LKDBHelper clearNoneImage:[LKTest class] columns:[NSArray arrayWithObjects:@"img",nil]];
    }];
}


@end
