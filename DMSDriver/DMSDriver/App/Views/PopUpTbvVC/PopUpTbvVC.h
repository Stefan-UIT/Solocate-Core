
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PopUpTbvTypeNormal,
    PopUpTbvTypebackToList,
} PopUpTbvType;

typedef void (^PopUpTbvCallback)(NSString *typeCash , NSInteger index);

@interface PopUpTbvVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tbvContent;
@property (weak, nonatomic) IBOutlet UIView *vCashTbv;

@property (strong, nonatomic) PopUpTbvCallback callback;
@property (strong, nonatomic) NSArray *arrUnableUserInterface;

+ (void)showPopUpTbvHaveSubtiteAtView:(UIView*)view
                          withArrData:(NSArray *)arrData
                           arrSubtile:(NSArray*)arrSubtite
                       indexCheckmark:(NSInteger)index
                                 atVC:(UIViewController *)rootVC
                        callBackLater:(BOOL)callBackLater
                             callback:(PopUpTbvCallback)callback;

+ (void) showPopUpTbvAtView:(UIView*)view
                withArrData:(NSArray*)arrData
             indexCheckmark:(NSInteger)index
                       atVC:(UIViewController*)rootVC
                   callback:(PopUpTbvCallback)callback;

+ (void) showPopUpTbvAtView:(UIView*)view
                withArrData:(NSArray*)arrData
                 arrayColor:(NSArray *)arrColor
             indexCheckmark:(NSInteger)index
                       atVC:(UIViewController*)rootVC
                   callback:(PopUpTbvCallback)callback;

+ (void) showPopUpTbvAtView:(UIView*)view
                withArrData:(NSArray*)arrData
             indexCheckmark:(NSInteger)index
                       atVC:(UIViewController*)rootVC
              callBackLater:(BOOL)callBackLater
                   callback:(PopUpTbvCallback)callback ;

+ (void) showPopUpTbvAtView:(UIView*)view
        unableUserInterface:(NSArray*)arrUnable
                withArrData:(NSArray*)arrData
             indexCheckmark:(NSInteger)index
                       atVC:(UIViewController*)rootVC
                   callback:(PopUpTbvCallback)callback;

+ (void) showPopUpTbvWithType:(PopUpTbvType)type
                      arrData:(NSArray*)arrData
                     urlIcons:(NSArray*)icons
                       atView:(UIView*)view
               indexCheckmark:(NSInteger)index
                         atVC:(UIViewController*)rootVC
                     callback:(PopUpTbvCallback)callback;

@end
