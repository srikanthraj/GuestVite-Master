//
//  SimpleTableCellTableViewCell.m
//  GuestVite
//
//  Created by admin on 2016-10-24.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SimpleTableCellTableViewCell.h"

@implementation SimpleTableCellTableViewCell

@synthesize nameLabel = _nameLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
