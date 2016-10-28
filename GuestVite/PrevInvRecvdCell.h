//
//  PrevInvRecvdCell.h
//  GuestVite
//
//  Created by admin on 2016-10-27.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface PrevInvRecvdCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedFromDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedTillDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *actionTakenLabel;

@end
