//
//  PageContentViewController.m
//  GuestVite
//
//  Created by admin on 2016-11-14.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PageContentViewController.h"


@interface PageContentViewController()

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;




@end

@implementation PageContentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backGroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
}
@end
