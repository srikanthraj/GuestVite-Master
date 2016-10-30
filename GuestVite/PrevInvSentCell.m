//
//  PrevInvSentCell.m
//  GuestVite
//
//  Created by admin on 2016-10-30.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PrevInvSentCell.h"

@implementation PrevInvSentCell

@synthesize guestEMail = _guestEMail;
@synthesize guestEMailLabel = _guestEMailLabel;
@synthesize guestPhone = _guestPhone;
@synthesize guestPhoneLabel = _guestPhoneLabel;
@synthesize invitedFromDateLabel = _invitedFromDateLabel;
@synthesize invitedTillDateLabel = _invitedTillDateLabel;
@synthesize actionTakenLabel = _actionTakenLabel;


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
