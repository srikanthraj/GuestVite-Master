//
//  HomePageViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-08.
//  Copyright © 2016 admin. All rights reserved.
//

#import "HomePageViewController.h"
#import "SignOut.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "ViewController.h"
#import "HTPressableButton.h"
#import "UIColor+HTColor.h"
#import "SendNewInviteViewController.h"
#import "AwaitMyResponseViewController.h"
#import "PrevInvRecvdViewController.h"
#import "PrevInvSentViewController.h"
#import "WaitingRespFromViewController.h"

@import Firebase;
@interface HomePageViewController ()
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@property (strong, nonatomic) IBOutlet HTPressableButton *sendNewInviteButton;

@property (strong, nonatomic) IBOutlet HTPressableButton *waitingRespButton;

@property (strong, nonatomic) IBOutlet HTPressableButton *prevInvSentButton;

@property (strong, nonatomic) IBOutlet HTPressableButton *prevInvRecvdButton;

@property (strong, nonatomic) IBOutlet HTPressableButton *trackButton;

@property (strong, nonatomic) IBOutlet HTPressableButton *awaitMyRespButton;

@property (strong, nonatomic) IBOutlet HTPressableButton *settingsButton;

@property (strong, nonatomic) IBOutlet HTPressableButton *signOutButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@end

@implementation HomePageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.ref = [[FIRDatabase database] reference];
    
    [self addFirstName];
    
     [self configureButtons];
    
  
}


- (void) configureButtons {
    
    // Stylize the Tweet text View
    
    
    
    // Rounded rectangular default color button
    CGRect frame = CGRectMake(14, 55, 294, 30);
    self.sendNewInviteButton = [[HTPressableButton alloc] initWithFrame:frame buttonStyle:HTPressableButtonStyleRounded];
    
    [self.sendNewInviteButton setButtonColor:[UIColor ht_grassColor]];
    [self.sendNewInviteButton setShadowColor:[UIColor ht_grassDarkColor]];
    [self.sendNewInviteButton setTitle:@"Send New Invite" forState:UIControlStateNormal];
    [self.sendNewInviteButton addTarget:self action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.sendNewInviteButton];
    
    
    CGRect frame1 = CGRectMake(14, 119, 294, 30);
    self.waitingRespButton = [[HTPressableButton alloc] initWithFrame:frame1 buttonStyle:HTPressableButtonStyleRounded];
    
    [self.waitingRespButton setButtonColor:[UIColor ht_grassColor]];
    [self.waitingRespButton setShadowColor:[UIColor ht_grassDarkColor]];
    [self.waitingRespButton setTitle:@"Waiting Responses From:" forState:UIControlStateNormal];
    [self.waitingRespButton addTarget:self action:@selector(waitingRespButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.waitingRespButton];
    
    CGRect frame2 = CGRectMake(14, 195, 294, 30);
    self.prevInvSentButton = [[HTPressableButton alloc] initWithFrame:frame2 buttonStyle:HTPressableButtonStyleRounded];
    [self.prevInvSentButton setButtonColor:[UIColor ht_grassColor]];
    [self.prevInvSentButton setShadowColor:[UIColor ht_grassDarkColor]];
    [self.prevInvSentButton setTitle:@"Previous Invites Sent" forState:UIControlStateNormal];
    [self.prevInvSentButton addTarget:self action:@selector(prevInvSentButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.prevInvSentButton];
    
    CGRect frame3 = CGRectMake(14, 255, 294, 30);
    self.prevInvRecvdButton = [[HTPressableButton alloc] initWithFrame:frame3 buttonStyle:HTPressableButtonStyleRounded];
    [self.prevInvRecvdButton setButtonColor:[UIColor ht_grassColor]];
    [self.prevInvRecvdButton setShadowColor:[UIColor ht_grassDarkColor]];
    [self.prevInvRecvdButton setTitle:@"Previous Invites Received" forState:UIControlStateNormal];
    [self.prevInvRecvdButton addTarget:self action:@selector(prevInvRecvdButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.prevInvRecvdButton];
    
    
    CGRect frame4 = CGRectMake(14, 315, 294, 30);
    self.trackButton = [[HTPressableButton alloc] initWithFrame:frame4 buttonStyle:HTPressableButtonStyleRounded];
    [self.trackButton setButtonColor:[UIColor ht_grassColor]];
    [self.trackButton setShadowColor:[UIColor ht_grassDarkColor]];
    [self.trackButton setTitle:@"Track My Guests" forState:UIControlStateNormal];
    
    [self.view addSubview:self.trackButton];
    
    
    
    CGRect frame5 = CGRectMake(14, 389, 294, 30);
    self.awaitMyRespButton = [[HTPressableButton alloc] initWithFrame:frame5 buttonStyle:HTPressableButtonStyleRounded];
    [self.awaitMyRespButton setButtonColor:[UIColor ht_grassColor]];
    [self.awaitMyRespButton setShadowColor:[UIColor ht_grassDarkColor]];
    [self.awaitMyRespButton setTitle:@"Previous Invites Received" forState:UIControlStateNormal];
    [self.awaitMyRespButton addTarget:self action:@selector(awaitMyRespButtonPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.awaitMyRespButton];
    
    
    CGRect frame6 = CGRectMake(14, 449, 294, 30);
    self.settingsButton = [[HTPressableButton alloc] initWithFrame:frame6 buttonStyle:HTPressableButtonStyleRounded];
    [self.settingsButton setButtonColor:[UIColor ht_grassColor]];
    [self.settingsButton setShadowColor:[UIColor ht_grassDarkColor]];
    [self.settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    
    [self.view addSubview:self.settingsButton];


    
    CGRect frame7 = CGRectMake(121, 527, 100, 30);
    self.signOutButton = [[HTPressableButton alloc] initWithFrame:frame7 buttonStyle:HTPressableButtonStyleRounded];
    [self.signOutButton setButtonColor:[UIColor ht_bitterSweetColor]];
    [self.signOutButton setShadowColor:[UIColor ht_bitterSweetDarkColor]];
    [self.signOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    [self.signOutButton addTarget:self action:@selector(signOutButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.signOutButton];

    
}



- (void)buttonPressed:(UIButton *)button {
    SendNewInviteViewController *sendNewVC =
    [[SendNewInviteViewController alloc] initWithNibName:@"SendNewInviteViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:sendNewVC animated:YES];
    
    [self presentViewController:sendNewVC animated:YES completion:nil];
}


- (void)waitingRespButtonPressed:(UIButton *)button {
    WaitingRespFromViewController *wrfVC =
    [[WaitingRespFromViewController alloc] initWithNibName:@"WaitingRespFromViewController" bundle:nil];
    
    [self.navigationController pushViewController:wrfVC animated:YES];
    
    [self presentViewController:wrfVC animated:YES completion:nil];
}




- (void)prevInvSentButtonPressed:(UIButton *)button {
    PrevInvSentViewController *prevInvSentVC =
    [[PrevInvSentViewController alloc] initWithNibName:@"PrevInvSentViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:prevInvSentVC animated:YES];
    
    [self presentViewController:prevInvSentVC animated:YES completion:nil];
}




- (void)prevInvRecvdButtonPressed:(UIButton *)button {

PrevInvRecvdViewController *prevInvRecvdVC =
[[PrevInvRecvdViewController alloc] initWithNibName:@"PrevInvRecvdViewController" bundle:nil];

//hPViewController.userName  = eMailEntered;
[self.navigationController pushViewController:prevInvRecvdVC animated:YES];

[self presentViewController:prevInvRecvdVC animated:YES completion:nil];

}





- (void)awaitMyRespButtonPressed:(UIButton *)button {
    
    AwaitMyResponseViewController *awaitresponseVC =
    [[AwaitMyResponseViewController alloc] initWithNibName:@"AwaitMyResponseViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:awaitresponseVC animated:YES];
    
    [self presentViewController:awaitresponseVC animated:YES completion:nil];
    
}





- (void)signOutButtonPressed:(UIButton *)button {
    
    // Remove entry from Current Users Table
    
    signedOut = TRUE;
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[_ref child:@"current_loggedIn_users"] child:userID] removeValue];
    
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"myViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
    
}



-(void) addFirstName {
    
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    NSLog(@"Home Page : user ID is %@",userID);
    
    NSLog(@"Home Page : %@",[[_ref child:@"users"] child:userID]);
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        NSString *firstName = [dict valueForKey:@"First Name"];
       // NSLog(@"First Name is %@" , firstName);
        
        self.welcomeLabel.text = [self.welcomeLabel.text stringByAppendingFormat:@" %@"  ,firstName];
        
        
        NSDictionary *post = @{@"uid" : [dict valueForKey:@"uid"],
                               @"First Name": [dict valueForKey:@"First Name"],
                               @"Last Name": [dict valueForKey:@"Last Name"],
                               @"EMail": [dict valueForKey:@"EMail"],
                               @"Address1": [dict valueForKey:@"Address1"],
                               @"Address2": [dict valueForKey:@"Address2"],
                               @"City": [dict valueForKey:@"City"],
                               @"Zip": [dict valueForKey:@"Zip"],
                               @"Phone": [dict valueForKey:@"Phone"],
                               
                               };
        
       // NSLog(@"On Login Tapped %@",[dict valueForKey:@"uid"]);
        
        NSDictionary *childCurrentUserUpdates = @{[NSString stringWithFormat:@"/current_loggedIn_users/%@/", [dict valueForKey:@"uid"]]: post};
        [_ref updateChildValues:childCurrentUserUpdates];
        
        
        
        
        
              } withCancelBlock:^(NSError * _Nonnull error) {
                  NSLog(@"%@", error.localizedDescription);
              }];

    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
