//
//  AcceptedGuestsCellTapped.h
//  GuestVite
//
//  Created by admin on 2016-11-06.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcceptedGuestsCellTapped : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel *guestEMail;


@property (nonatomic, weak) IBOutlet UILabel *guestEMailLabel;

@property (nonatomic, weak) IBOutlet UILabel *guestPhone;

@property (nonatomic, weak) IBOutlet UILabel *guestPhoneLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedFromDateLabel;

@property (nonatomic, weak) IBOutlet UILabel *invitedTillDateLabel;

@end
