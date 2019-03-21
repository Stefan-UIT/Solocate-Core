//
//  PopupTbvCell.h
//  DMSDriver
//
//  Created by machnguyen_uit on 10/23/18.
//  Copyright © 2018 machnguyen_uit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopupTbvCell : UITableViewCell

@property (weak ,nonatomic) IBOutlet UILabel *lblTitle;
@property (weak ,nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak ,nonatomic) IBOutlet UIView *vLine;
@property (weak ,nonatomic) IBOutlet UIView *vLine2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightLblSubtite;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightLblTitle;


@end

NS_ASSUME_NONNULL_END
