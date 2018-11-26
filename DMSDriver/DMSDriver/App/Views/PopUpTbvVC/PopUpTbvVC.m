
#import "PopUpTbvVC.h"
#import "PopupTbvCell.h"
#import "define.h"

@interface PopUpTbvVC () <UITableViewDelegate,UITableViewDataSource,UIPopoverPresentationControllerDelegate>{
    NSString *_typeCash;
}

@property (assign , nonatomic) NSInteger indexSelected;
@property (strong , nonatomic) NSString *typeOfMoney;
@property (assign, nonatomic) BOOL callBackLater;
@property (strong, nonatomic) NSArray *arrData;
@property (strong, nonatomic) NSArray *arrUrlIcon;
@property (strong, nonatomic) NSArray *arrColor;
@property (strong, nonatomic) NSArray *arrSubtite;
@property (strong, nonatomic) UILabel *lblNoti;
@property (assign, nonatomic) PopUpTbvType type;

@end

@implementation PopUpTbvVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(140, _arrData.count * 40);
    
    _lblNoti = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - (self.view.frame.size.width/3)/2 , self.view.center.y - 100, self.view.frame.size.width/3, 50)];
    _lblNoti.text = @"No Results.";
    _lblNoti.textAlignment = NSTextAlignmentCenter;
    _lblNoti.textColor = [UIColor blackColor];
    
    [self.view addSubview:_lblNoti];
    
    if (_arrData.count == 0) {
        [_lblNoti setHidden:NO];
    } else {
        [_lblNoti setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.08];
    self.view.alpha = 0;
    [UIView animateWithDuration:0.24 animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_indexSelected != -1) {
        [_tbvContent scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_indexSelected inSection:0]
                           atScrollPosition:(UITableViewScrollPositionMiddle) animated:YES];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrData.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return VALCond(_arrSubtite, 55, 40);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PopupTbvCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopupTbvCell"
                                                         forIndexPath:indexPath];
    cell.lblTitle.text = _arrData[indexPath.row];
    cell.lblTitle.textAlignment = NSTextAlignmentLeft;
    (indexPath.row == _indexSelected) ? (cell.vLine.hidden = NO) : (cell.vLine.hidden = YES);
    
    if (_arrColor != nil) {
        cell.lblTitle.textColor = _arrColor[indexPath.row];
    } else {
        (indexPath.row == _indexSelected) ? (cell.lblTitle.textColor = MAINCOLOR) : (cell.lblTitle.textColor = GRAY_DARK_TEXT_COLOR);
    }
    
    if (_arrSubtite) {
        cell.constraintHeightLblSubtite.constant = 20.0;
        cell.constraintHeightLblTitle.constant = 5.0;

        cell.lblSubtitle.text = _arrSubtite[indexPath.row];
        if (_arrColor != nil) {
            cell.lblSubtitle.textColor = _arrColor[indexPath.row];
        } else {
            (indexPath.row == _indexSelected) ? (cell.lblSubtitle.textColor = MAINCOLOR) : (cell.lblSubtitle.textColor = GRAY_TEXT_COLOR);
        }

    } else {
        cell.constraintHeightLblSubtite.constant = 0;
        cell.constraintHeightLblTitle.constant = 1.0;
    }
    // Check Can UserInteractionEnabled
    if (_arrUnableUserInterface) {
        NSInteger value = [_arrUnableUserInterface[indexPath.row] integerValue];
        if (value == 0) {
            cell.userInteractionEnabled = YES;
            cell.lblTitle.textColor = GRAY_DARK_TEXT_COLOR;
        } else {
            cell.lblTitle.textColor = GRAY_LIGHT_PLACEHOLDER_COLOR;
            cell.userInteractionEnabled = NO;
        }
    }
    cell.vLine2.hidden = (indexPath.row == _arrData.count - 1);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self onTapDismiss:nil];
    _indexSelected = indexPath.row;
    _typeCash = _arrData[_indexSelected];
    
    if (_callback) {
        _callback(_typeCash , _indexSelected);
        _callback = nil;
    }
}

- (IBAction)onTapDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (void)showPopUpTbvHaveSubtiteAtView:(UIView*)view
                          withArrData:(NSArray *)arrData
                           arrSubtile:(NSArray*)arrSubtite
                       indexCheckmark:(NSInteger)index
                                 atVC:(UIViewController *)rootVC
                        callBackLater:(BOOL)callBackLater
                             callback:(PopUpTbvCallback)callback   {
    PopUpTbvVC *vc = VCFromSB(PopUpTbvVC, SB_Common);
    [vc setCallBack:callback];
    vc.arrData = arrData;
    vc.arrUnableUserInterface = nil;
    vc.indexSelected = index;
    vc.callBackLater = NO;
    vc.arrSubtite = arrSubtite;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = rootVC;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.sourceRect = view.bounds;
    
    [rootVC presentViewController:vc animated:YES completion:^{
        
    }];

}

+ (void)showPopUpTbvWithType:(PopUpTbvType)type
                     arrData:(NSArray *)arrData
                    urlIcons:(NSArray *)icons
                      atView:(UIView *)view
              indexCheckmark:(NSInteger)index
                        atVC:(UIViewController *)rootVC
                    callback:(PopUpTbvCallback)callback {
    
    PopUpTbvVC *vc = VCFromSB(PopUpTbvVC, SB_Common);
    [vc setCallBack:callback];
    vc.type = type;
    vc.arrData = arrData;
    vc.arrUrlIcon = icons;
    vc.arrUnableUserInterface = nil;
    vc.indexSelected = index;
    vc.callBackLater = NO;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = rootVC;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.sourceRect = view.bounds;
    
    [rootVC presentViewController:vc animated:YES completion:^{
    }];
}

+ (void)showPopUpTbvAtView:(UIView *)view
               withArrData:(NSArray *)arrData
            indexCheckmark:(NSInteger)index
                      atVC:(UIViewController *)rootVC
             callBackLater:(BOOL)callBackLater
                  callback:(PopUpTbvCallback)callback  {
    PopUpTbvVC *vc = VCFromSB(PopUpTbvVC, SB_Common);
    [vc setCallBack:callback];
    vc.arrData = arrData;
    vc.arrUnableUserInterface = nil;
    vc.indexSelected = index;
    vc.callBackLater = callBackLater;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    vc.popoverPresentationController.delegate = rootVC;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.sourceRect = view.bounds;
    [rootVC presentViewController:vc animated:YES completion:^{
    }];
}

+ (void) showPopUpTbvAtView:(UIView*)view
                withArrData:(NSArray*)arrData
             indexCheckmark:(NSInteger)index
                       atVC:(UIViewController*)rootVC
                   callback:(PopUpTbvCallback)callback {
    PopUpTbvVC *vc = VCFromSB(PopUpTbvVC, SB_Common);
    [vc setCallBack:callback];
    vc.arrData = arrData;
    vc.arrUnableUserInterface = nil;
    vc.indexSelected = index;
    vc.callBackLater = NO;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = rootVC;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.sourceRect = view.bounds;

    [rootVC presentViewController:vc animated:YES completion:^{
    }];
}

+ (void) showPopUpTbvAtView:(UIView*)view
                withArrData:(NSArray*)arrData
                 arrayColor:(NSArray *)arrColor
             indexCheckmark:(NSInteger)index
                       atVC:(UIViewController*)rootVC
                   callback:(PopUpTbvCallback)callback {
    PopUpTbvVC *vc = VCFromSB(PopUpTbvVC, SB_Common);
    [vc setCallBack:callback];
    vc.arrData = arrData;
    vc.arrColor = arrColor;
    vc.arrUnableUserInterface = nil;
    vc.indexSelected = index;
    vc.callBackLater = NO;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = rootVC;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.sourceRect = view.bounds;
    
    [rootVC presentViewController:vc animated:YES completion:^{
    }];
}

+ (void) showPopUpTbvAtView:(UIView*)view
        unableUserInterface:(NSArray*)arrUnable
                withArrData:(NSArray*)arrData
             indexCheckmark:(NSInteger)index
                       atVC:(UIViewController*)rootVC
                   callback:(PopUpTbvCallback)callback {
    
    PopUpTbvVC *vc = VCFromSB(PopUpTbvVC, SB_Common);
    [vc setCallBack:callback];
    vc.arrData = arrData;
    vc.arrUnableUserInterface = arrUnable;
    vc.indexSelected = index;
    vc.callBackLater = NO;
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = rootVC;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.sourceRect = view.bounds;
    
    [rootVC presentViewController:vc animated:YES completion:^{
    }];
}

- (void) setCallBack:(PopUpTbvCallback)callback {
    _callback = [callback copy];
}

@end
