//
//  PrevInvSentCell.h
//  GuestVite
//
//  Created by admin on 2016-10-30.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface PrevInvSentCell : SWTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *guestEMail;


@property (nonatomic, weak) IBOutlet UILabel *guestEMailLabel;

@property (nonatomic, weak) IBOutlet UILabel *guestPhone;

@property (nonatomic, weak) IBOutlet UILabel *guestPhoneLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedFromDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedTillDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *actionTakenLabel;

@end
