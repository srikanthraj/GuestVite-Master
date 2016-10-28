//
//  PrevInvRecvdCell.m
//  GuestVite
//
//  Created by admin on 2016-10-27.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PrevInvRecvdCell.h"

@implementation PrevInvRecvdCell


@synthesize firstNameLabel = _firstNameLabel;
@synthesize lastNameLabel = _lastNameLabel;
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
