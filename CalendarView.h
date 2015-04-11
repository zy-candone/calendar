

#import <UIKit/UIKit.h>
@protocol CalendarDelegate <NSObject>

-(void)tappedOnDate:(NSDate *)selectedDate;

@end

@interface CalendarView : UIView
{
    NSInteger _selectedDate;
    NSArray *_weekNames;
}

@property (nonatomic,strong) NSDate *calendarDate;
@property (nonatomic,strong) id<CalendarDelegate> delegate;

@end
