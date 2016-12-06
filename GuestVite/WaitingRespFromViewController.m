//
//  WaitingRespFromViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-31.
//  Copyright © 2016 admin. All rights reserved.
//

#import "WaitingRespFromViewController.h"
#import "PrevInvSentCell.h"
#import "CNPPopupController.h"
#import <MessageUI/MessageUI.h>
#import "EmptyViewController.h"

@import Firebase;

@interface WaitingRespFromViewController () <UITableViewDelegate, UITableViewDataSource,CNPPopupControllerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,SWTableViewCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UINavigationBar *waitingRespFromBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CNPPopupController *popupController;

@end

@implementation WaitingRespFromViewController

EmptyViewController *wrfEmptyView;
NSMutableArray *wrfGuestEMailData;
NSMutableArray *wrfGuestPhoneData;
NSMutableArray *wrfinvitedFromData;
NSMutableArray *wrfinvitedTillData;
NSMutableArray *wrfactionTakenData;

NSMutableArray *wrfkeyData;

NSArray *wrfkeys;


-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:dateStr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    wrfEmptyView = [[EmptyViewController alloc]init];
    wrfGuestEMailData = [[NSMutableArray alloc]init];
    wrfGuestPhoneData = [[NSMutableArray alloc]init];
    wrfinvitedFromData = [[NSMutableArray alloc]init];
    wrfinvitedTillData = [[NSMutableArray alloc]init];
    wrfactionTakenData = [[NSMutableArray alloc]init];
    wrfkeyData = [[NSMutableArray alloc]init];
    
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    

    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_waitingRespFromBack];
    
    
    
    wrfkeys = [[NSArray alloc]init];
    
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
   // NSLog(@"DATE IS %@",[NSDate date]);
    
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    
    __block NSMutableArray *myGuestEMailData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myGuestPhoneData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myactionTakenData = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *myKeyData = [[NSMutableArray alloc] init];
    
    
    __block NSString *currentUserEMail = [[NSString alloc] init];
    __block NSString *currentUserPhone = [[NSString alloc] init];
    
    __block NSUInteger inviteTableIterator;
    
    __block NSUInteger inviteTableLength;
    
    self.ref = [[FIRDatabase database] reference];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dictUser = snapshot.value;
        
        currentUserEMail =  [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"EMail"]];
        currentUserPhone  = [NSString stringWithFormat:@"%@",[dictUser valueForKey:@"Phone"]];
        
        
    }];
    while([currentUserEMail length]== 0 || [currentUserPhone length] ==0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    //NSLog(@"Current User Email %@",currentUserEMail);
    //NSLog(@"Current User Phone %@",currentUserPhone);
    
    
    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        
        NSString *endDateTime = [[NSString alloc] init];
        NSString *startDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        wrfkeys = [dict allKeys];
        
        
        //NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        
        
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            startDateTime = arr[i][@"Invite For Date"];
            //NSLog(@"EMail %lu",[arr[i][@"Receiver EMail"] length]);
            
            if([currentUserEMail length] > 0 && ([arr[i][@"Sender EMail"] isEqualToString:currentUserEMail])
                && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending) && [arr[i][@"Invitation Status"] isEqualToString:@"Pending"])
            {
                
                //NSLog(@"INSIDE EMAIL");
                
                if([arr[i][@"Receiver EMail"] length] == 0) {
                    [myGuestEMailData addObject: @"Not Specified"];
                    //NSLog(@"Receiver E-Mail Empty");
                }
                else if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                    //NSLog(@"Receiver E-Mail NOT BULK");
                }
                
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                    //NSLog(@"Receiver E-Mail BULK");
                }
                
                if([arr[i][@"Receiver Phone"] length] == 0) {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    //NSLog(@"Receiver Phone Empty");
                }
                
                else if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                   // NSLog(@"Receiver Phone NOT BULK");
                }
                
                
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                    //NSLog(@"Receiver Phone BULK");
                }
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:wrfkeys[i]];
                continue;
                
            }
            
            
            
            if([currentUserPhone length] > 0 && ([arr[i][@"Sender Phone"] isEqualToString:currentUserPhone])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedAscending)&& [arr[i][@"Invitation Status"] isEqualToString:@"Pending"])
            {
                
                if([arr[i][@"Receiver EMail"] length] == 0) {
                    [myGuestEMailData addObject: @"Not Specified"];
                    //NSLog(@"Receiver E-Mail Empty");
                }
                
                else if(!([arr[i][@"Receiver EMail"] isEqualToString:@"BULK"])) {
                    [myGuestEMailData addObject: arr[i][@"Receiver EMail"]];
                    //NSLog(@"Receiver E-Mail NOT BULK");
                }
                
                else {
                    [myGuestEMailData addObject: @"Not Specified"];
                    //NSLog(@"Receiver E-Mail BULK");
                }
                
                if([arr[i][@"Receiver Phone"] length] == 0) {
                    [myGuestPhoneData addObject: @"Not Specified"];
                   // NSLog(@"Receiver Phone Empty");
                }
                
                else if(!([arr[i][@"Receiver Phone"] isEqualToString:@"BULK"])) {
                    [myGuestPhoneData addObject: arr[i][@"Receiver Phone"]];
                    //NSLog(@"Receiver Phone NOT BULK");
                }
                
                else {
                    [myGuestPhoneData addObject: @"Not Specified"];
                   // NSLog(@"Receiver Phone BULK");
                }
                
                
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:wrfkeys[i]];
                
                continue;
                
            }
            
            
            
            
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
                //NSLog(@"Last Iteration");
                if([myGuestEMailData count]== 0 && [myGuestPhoneData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0)
                {
                    [myGuestEMailData addObject: @"No Invites"];
                    [myGuestPhoneData addObject: @"No Invites"];
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                    [myactionTakenData addObject: @"No Invites"];
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myinvitedFromData count]== 0 && [myinvitedTillData count]== 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
   // NSLog(@"myinvitedFromData count is %lu",(unsigned long)[myinvitedFromData count]);
    for(int i =0;i<[myinvitedFromData count];i++){
        [wrfGuestEMailData addObject:[myGuestEMailData objectAtIndex:i]];
        [wrfGuestPhoneData addObject:[myGuestPhoneData objectAtIndex:i]];
        [wrfinvitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [wrfinvitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [wrfactionTakenData addObject:[myactionTakenData objectAtIndex:i]];
        [wrfkeyData addObject:[myKeyData objectAtIndex:i]];
    }
    
    //    NSLog(@"Guest E-Mail data is %@",wrfGuestEMailData);
   //  NSLog(@"Guest Phone data is %@",wrfGuestPhoneData);
    
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [wrfinvitedFromData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView registerNib:[UINib nibWithNibName:@"PrevInvSentCell" bundle:nil] forCellReuseIdentifier:@"PrevInvSentCell"];
    
    static NSString *cellIdentifier = @"PrevInvSentCell";
    
    
    
    PrevInvSentCell *cell = (PrevInvSentCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:128.0f green:0.0f blue:0.0 alpha:0.7f]
                                                title:@"Cancel Invite"];
    
    
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    
    if(!([[wrfGuestEMailData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestEMailLabel.text = [wrfGuestEMailData objectAtIndex:indexPath.row];
    }
    
    else {
        cell.guestEMailLabel.text = @"Not Specified";
    }
    
    if(!([[wrfGuestPhoneData objectAtIndex:indexPath.row] isEqualToString:@"Not Specified"])) {
        cell.guestPhoneLabel.text = [wrfGuestPhoneData objectAtIndex:indexPath.row];
    }
    
    else {
        cell.guestPhoneLabel.text = @"Not Specified";
    }
    
    
    cell.invitedFromDateLabel.text = [wrfinvitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [wrfinvitedTillData objectAtIndex:indexPath.row];
    cell.actionTakenLabel.text = [wrfactionTakenData objectAtIndex:indexPath.row];
    
    
   // if (indexPath.row % 2 == 0)
   // {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
  //  }
    
   // else
   // {
        
    /*
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-orange"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"test-orange"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        
    }
    */
    if([[wrfkeyData objectAtIndex:indexPath.row]integerValue] == -1){ // No entries in the Table
        
        
        
        
        [cell.guestEMail setHidden:YES];
        [cell.guestEMailLabel setHidden:YES];
        [cell.guestPhone setHidden:YES];
        [cell.guestPhoneLabel setHidden:YES];
        [cell.invitedFromDateLabel setHidden:YES];
        [cell.invitedTillDateLabel setHidden:YES];
        [cell.actionTakenLabel setHidden:YES];
        
        
        cell.userInteractionEnabled = NO;
        self.tableView.hidden = YES;
        self.waitingRespFromBack.hidden = YES;
        wrfEmptyView.view.frame = self.view.bounds;
        [self.view addSubview:wrfEmptyView.view];
        
        //[self.view sizeToFit];
        
    }


    
    //cell.userInteractionEnabled = NO;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 214;
}

#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
   // NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
   // NSLog(@"Popup controller presented.");
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
            {
                
                NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                paragraphStyle.alignment = NSTextAlignmentCenter;
                
                
                NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Do You really want to Cancel this Invite?" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
                NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"Once deleted, it can't be reverted" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
                
                CNPPopupButton *buttonGoBack = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
                [buttonGoBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                buttonGoBack.titleLabel.font = [UIFont boldSystemFontOfSize:18];
                [buttonGoBack setTitle:@"Go Back" forState:UIControlStateNormal];
                buttonGoBack.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
                buttonGoBack.layer.cornerRadius = 4;
                buttonGoBack.selectionHandler = ^(CNPPopupButton *buttonGoBack){
                    [self.popupController dismissPopupControllerAnimated:YES];
                    //NSLog(@"Block for button: %@", buttonGoBack.titleLabel.text);
                };
                
                CNPPopupButton *buttonCancelComm = [[CNPPopupButton alloc] initWithFrame:CGRectMake(50, 50, 200, 60)];
                [buttonCancelComm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                buttonCancelComm.titleLabel.font = [UIFont boldSystemFontOfSize:12];
                [buttonCancelComm setTitle:@"Cancel and Let My Guest Know" forState:UIControlStateNormal];
                buttonCancelComm.backgroundColor = [UIColor colorWithRed:1.0 green:0.231f blue:0.188 alpha:1.0];
                buttonCancelComm.layer.cornerRadius = 4;
                buttonCancelComm.selectionHandler = ^(CNPPopupButton *buttonDelete){
                    // Delete button is pressed
                    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                   // NSLog(@"KEY DATA IS %@",[wrfkeyData objectAtIndex:cellIndexPath.row]);
                    // Send Communication
                    
                    if(!([[wrfGuestEMailData objectAtIndex:cellIndexPath.row] isEqualToString:@"Not Specified"]))
                    {
                        
                        
                        //Send Email
                        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                        
                        // Email Subject
                        NSString *emailTitle = @"Message From GuestVite";
                        // Email Content
                        NSString *messageBody = [NSString stringWithFormat:@"Hey!, I am extremely sorry that I would have to cancel this invite"];
                        // To address
                        NSArray *toRecipents = [NSArray arrayWithObject:[wrfGuestEMailData objectAtIndex:cellIndexPath.row]];
                        
                        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                        mc.mailComposeDelegate = self;
                        [mc setSubject:emailTitle];
                        [mc setMessageBody:messageBody isHTML:NO];
                        [mc setToRecipients:toRecipents];
                        
                        // Present mail view controller on screen
                        [self presentViewController:mc animated:YES completion:NULL];
                        
                    }
                    
                    
                    if(!([[wrfGuestPhoneData objectAtIndex:cellIndexPath.row] isEqualToString:@"Not Specified"]))
                    {
                        
                        
                        //Send SMS
                        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                        
                        if(![MFMessageComposeViewController canSendText]) {
                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                            
                            [ac addAction:aa];
                            [self presentViewController:ac animated:YES completion:nil];
                            return;
                        }
                        
                        
                        
                        
                        
                        NSArray *recipents = [NSArray arrayWithObject:[wrfGuestPhoneData objectAtIndex:cellIndexPath.row]];
                        
                        
                        NSString *message = [NSString stringWithFormat:@"Hey!, I am extremely sorry that I would have to cancel this invite"];
                        
                        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                        messageController.messageComposeDelegate = self;
                        [messageController setRecipients:recipents];
                        [messageController setBody:message];
                        
                        
                        [self presentViewController:messageController animated:YES completion:nil];

                        
                    }

                    
                    
                    
                    
                    
                    
                    [[[_ref child:@"invites"] child:[wrfkeyData objectAtIndex:cellIndexPath.row]] removeValue];
                    
                    
                    [wrfGuestEMailData removeObjectAtIndex:cellIndexPath.row];
                    [wrfGuestPhoneData removeObjectAtIndex:cellIndexPath.row];
                    [wrfinvitedFromData removeObjectAtIndex:cellIndexPath.row];
                    [wrfinvitedTillData removeObjectAtIndex:cellIndexPath.row];
                    [wrfkeyData removeObjectAtIndex:cellIndexPath.row];
                    
                    [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    [self.popupController dismissPopupControllerAnimated:YES];
                   // NSLog(@"Block for button: %@", buttonDelete.titleLabel.text);
                    
                    
                };
                
                // Just Cancel
                
                CNPPopupButton *justCancel = [[CNPPopupButton alloc] initWithFrame:CGRectMake(50, 50, 200, 60)];
                [justCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                justCancel.titleLabel.font = [UIFont boldSystemFontOfSize:18];
                [justCancel setTitle:@"Just Cancel the Invite" forState:UIControlStateNormal];
                justCancel.backgroundColor = [UIColor colorWithRed:1.0 green:0.231f blue:0.188 alpha:1.0];
                justCancel.layer.cornerRadius = 4;
                justCancel.selectionHandler = ^(CNPPopupButton *buttonDelete){
                    // Delete button is pressed
                    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                    //NSLog(@"KEY DATA IS %@",[wrfkeyData objectAtIndex:cellIndexPath.row]);
                    
                    [[[_ref child:@"invites"] child:[wrfkeyData objectAtIndex:cellIndexPath.row]] removeValue];
                    
                    
                    [wrfGuestEMailData removeObjectAtIndex:cellIndexPath.row];
                    [wrfGuestPhoneData removeObjectAtIndex:cellIndexPath.row];
                    [wrfinvitedFromData removeObjectAtIndex:cellIndexPath.row];
                    [wrfinvitedTillData removeObjectAtIndex:cellIndexPath.row];
                    [wrfkeyData removeObjectAtIndex:cellIndexPath.row];
                    
                    [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    [self.popupController dismissPopupControllerAnimated:YES];
                    //NSLog(@"Block for button: %@", buttonDelete.titleLabel.text);
                    
                    
                };

                
                
                
           
                
                UILabel *lineOneLabel = [[UILabel alloc] init];
                lineOneLabel.numberOfLines = 0;
                lineOneLabel.attributedText = lineOne;
                
                // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
                
                UILabel *lineTwoLabel = [[UILabel alloc] init];
                lineTwoLabel.numberOfLines = 0;
                lineTwoLabel.attributedText = lineTwo;
                
                
                //UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 55)];
                //customView.backgroundColor = [UIColor lightGrayColor];
                
                // UITextField *textFied = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 230, 35)];
                // textFied.borderStyle = UITextBorderStyleRoundedRect;
                // textFied.placeholder = @"Custom view!";
                //[customView addSubview:textFied];
                
                self.popupController = [[CNPPopupController alloc] initWithContents:@[lineOneLabel, lineTwoLabel, buttonGoBack,buttonCancelComm,justCancel]];
                self.popupController.theme = [CNPPopupTheme defaultTheme];
                self.popupController.theme.popupStyle = CNPPopupStyleCentered;
                self.popupController.delegate = self;
                [self.popupController presentPopupControllerAnimated:YES];
                
                
                
                
                
                break;

                
                
                
                
                
            }
        default:
            break;
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Failed to send SMS!" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            
            break;
        case MFMailComposeResultSent: {
            break;
        }
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
