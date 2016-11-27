//
//  AMRCellTapped.h
//  GuestVite
//
//  Created by admin on 2016-10-26.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMRCellTapped : UIViewController
@property(nonatomic) NSString *inviteByFirstName;
@property(nonatomic) NSString *inviteByLastName;
@property(nonatomic) NSString *hostEMail;
@property(nonatomic) NSString *hostPhone;

@property(nonatomic) NSString *hostAddrLineOne;
@property(nonatomic) NSString *hostAddrLineTwo;
@property(nonatomic) NSString *hostAddrCity;
@property(nonatomic) NSString *hostAddrZip;

@property(nonatomic) NSString *informHost;

@property(nonatomic) NSString *invitedOn;
@property(nonatomic) NSString *invitedTill;
@property(nonatomic) NSString *personalMessage;
@property(nonatomic) NSString *key;


@end
