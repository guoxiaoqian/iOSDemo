//
//  ViewController.h
//  UNODemo
//
//  Created by gavinxqguo on 2021/2/7.
//

#import <UIKit/UIKit.h>

@interface EntryModel : NSObject

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) Class targetVCClass;

+ (EntryModel *)modelWithClass:(Class)cls;
+(EntryModel*)modelWithName:(NSString*)name class:(Class)class_;

@end

@interface ClickModel : NSObject

@property(strong, nonatomic) NSString *gtestFilter;
@property(strong, nonatomic) NSString *name;
@property(assign, nonatomic) SEL targetSelector;

+ (ClickModel *)modelWithSelector:(SEL)selector;
+ (ClickModel *)modelWithGTestFilter:(NSString *)filter;

@end

@interface BaseViewController : UIViewController

@property(strong, nonatomic) NSMutableArray *dataSource;

- (void)logTimeWithEventBegin:(NSString*)event;
- (void)logTimeWithEventEnd:(NSString*)event;
- (void)logMemoryWithEventBegin:(NSString*)event;
- (void)logMemoryWithEventEnd:(NSString*)event;

@end

