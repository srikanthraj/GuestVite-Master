//
//  AcceptedGuestsCellTapped.m
//  GuestVite
//
//  Created by admin on 2016-11-06.
//  Copyright © 2016 admin. All rights reserved.
//

#import "AcceptedGuestsCellTapped.h"

@implementation AcceptedGuestsCellTapped


@synthesize guestEMail = _guestEMail;
@synthesize guestEMailLabel = _guestEMailLabel;
@synthesize guestPhone = _guestPhone;
@synthesize guestPhoneLabel = _guestPhoneLabel;
@synthesize invitedFromDateLabel = _invitedFromDateLabel;
@synthesize invitedTillDateLabel = _invitedTillDateLabel;



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
