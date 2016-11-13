//
//  PrevInvRecvdViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-27.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PrevInvRecvdViewController.h"
#import "SimpleTableCellTableViewCell.h"
#import "PrevInvRecvdCell.h"
#import "CNPPopupController.h"
#import <MessageUI/MessageUI.h>

@import Firebase;

@interface PrevInvRecvdViewController () <UITableViewDelegate, UITableViewDataSource,SWTableViewCellDelegate,CNPPopupControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UINavigationBar *prevInvRecvdBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;


@property (nonatomic, strong) CNPPopupController *popupController;

@end

@implementation PrevInvRecvdViewController

NSMutableArray *pirfirstNameData;
NSMutableArray *pirlastNameData;
NSMutableArray *pirinvitedFromData;
NSMutableArray *pirinvitedTillData;
NSMutableArray *pirsenderPhoneData;
NSMutableArray *pirsenderEMailData;
NSMutableArray *piractionTakenData;

NSMutableArray *pirkeyData;

NSArray *pirkeys;


-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    [dateFormatter setTimeZone:timeZone];
    return [dateFormatter dateFromString:dateStr];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    pirfirstNameData = [[NSMutableArray alloc]init];
    pirlastNameData = [[NSMutableArray alloc]init];
    pirinvitedFromData = [[NSMutableArray alloc]init];
    pirinvitedTillData = [[NSMutableArray alloc]init];
    pirsenderPhoneData = [[NSMutableArray alloc]init];
    pirsenderEMailData = [[NSMutableArray alloc]init];
    piractionTakenData = [[NSMutableArray alloc]init];
    pirkeyData = [[NSMutableArray alloc]init];
    
    

    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
   
    
    
    
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_prevInvRecvdBack];
    
    
    
    
    pirkeys = [[NSArray alloc]init];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSLog(@"DATE IS %@",[NSDate date]);
    
    
    NSDate *loginDate = [self dateToFormatedDate:[dateFormatter stringFromDate:[NSDate date]]];
    
    
    __block NSMutableArray *myfirstNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mylastNameData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedFromData = [[NSMutableArray alloc] init];
    __block NSMutableArray *myinvitedTillData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mysenderPhoneData = [[NSMutableArray alloc] init];
    __block NSMutableArray *mysenderEMailData = [[NSMutableArray alloc] init];
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
        NSArray * arrUser = [dictUser allValues];
        //NSLog(@"ARR USER %@",arrUser);
        
        currentUserEMail =  [NSString stringWithFormat:@"%@",arrUser[0]];
        currentUserPhone  = [NSString stringWithFormat:@"%@",arrUser[3]];
        
        
    }];
    while([currentUserEMail length]== 0 || [currentUserPhone length] ==0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    NSLog(@"Current User Email %@",currentUserEMail);
    NSLog(@"Current User Phone %@",currentUserPhone);
    
    
    [[_ref child:@"invites"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *dict = snapshot.value;
        //NSString *startDateTime  = [[NSString alloc] init];
        NSString *endDateTime = [[NSString alloc] init];
        NSArray * arr = [dict allValues];
        pirkeys = [dict allKeys];
        //NSLog(@"Array %@",arr[0][@"Sender First Name"]);
        
        NSLog(@"Login date is %@",loginDate);
        
        inviteTableLength = [arr count];
        //NSLog(@"ARR count %lu",(unsigned long)[arr count]);
        
        
        for(int i=0;i < [arr count];i++)
        {
            
            endDateTime = arr[i][@"Invite Valid Till Date"];
            NSLog(@"END DATE TIME %@",endDateTime);
            
            if([currentUserEMail length] > 0 && ([arr[i][@"Receiver EMail"] isEqualToString:currentUserEMail])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedDescending))
            {
                
                NSLog(@"INSIDE EMAIL");
                
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [mysenderPhoneData addObject:arr[i][@"Sender Phone"]];
                [mysenderEMailData addObject:arr[i][@"Sender EMail"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:pirkeys[i]];
                continue;
                
            }
            
            
            
            if([currentUserPhone length] > 0 && ([arr[i][@"Receiver Phone"] isEqualToString:currentUserPhone])
               && ([loginDate compare:[self dateToFormatedDate:endDateTime]] == NSOrderedDescending))
            {
                
                [myfirstNameData addObject: arr[i][@"Sender First Name"]];
                [mylastNameData addObject:arr[i][@"Sender Last Name"]];
                [myinvitedFromData addObject:arr[i][@"Invite For Date"]];
                [myinvitedTillData addObject:arr[i][@"Invite Valid Till Date"]];
                [mysenderPhoneData addObject:arr[i][@"Sender Phone"]];
                [mysenderEMailData addObject:arr[i][@"Sender EMail"]];
                [myactionTakenData addObject:arr[i][@"Invitation Status"]];
                [myKeyData addObject:pirkeys[i]];
                
                continue;
                
            }
            
            
            
            
            
            if(i == ([arr count]-1)){ // Check in case of last iteration and Add "No Invites" Only if no data is added to invites list
                
                
                NSLog(@"Last Iteration");
                if([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0)
                {
                    [myfirstNameData addObject: @"No Invites"];
                    [mylastNameData addObject: @"No Invites"];
                    [myinvitedFromData addObject: @"No Invites"];
                    [myinvitedTillData addObject: @"No Invites"];
                    [mysenderPhoneData addObject: @"No Invites"];
                    [mysenderEMailData addObject: @"No Invites"];
                    [myactionTakenData addObject: @"No Invites"];
                    [myKeyData addObject:@"-1"];
                }
                
            }
            
            inviteTableIterator = i;
            
        }
        
    }];
    
    while([myfirstNameData count]== 0 && [mylastNameData count]== 0 && [myinvitedFromData count]== 0 && [myinvitedTillData count]== 0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    
    NSLog(@"myfirstNameData count is %lu",(unsigned long)[myfirstNameData count]);
    for(int i =0;i<[myinvitedFromData count];i++){
        [pirfirstNameData addObject:[myfirstNameData objectAtIndex:i]];
        [pirlastNameData addObject:[mylastNameData objectAtIndex:i]];
        [pirinvitedFromData addObject:[myinvitedFromData objectAtIndex:i]];
        [pirinvitedTillData addObject:[myinvitedTillData objectAtIndex:i]];
        [pirsenderPhoneData addObject:[mysenderPhoneData objectAtIndex:i]];
        [pirsenderEMailData addObject:[mysenderEMailData objectAtIndex:i]];
        
        [piractionTakenData addObject:[myactionTakenData objectAtIndex:i]];
        [pirkeyData addObject:[myKeyData objectAtIndex:i]];
        
    }
    
    
    
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
    
    return [pirfirstNameData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView registerNib:[UINib nibWithNibName:@"PrevInvRecvdCell" bundle:nil] forCellReuseIdentifier:@"PrevInvRecvdCell"];
    
    static NSString *cellIdentifier = @"PrevInvRecvdCell";
    
   
    
    PrevInvRecvdCell *cell = (PrevInvRecvdCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
                                                title:@"E-Mail"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor greenColor]
                                                title:@"SMS"];
    
    
    /*
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    */
    
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    
    
    cell.firstNameLabel.text = [pirfirstNameData objectAtIndex:indexPath.row];
    cell.lastNameLabel.text = [pirlastNameData objectAtIndex:indexPath.row];
    cell.invitedFromDateLabel.text = [pirinvitedFromData objectAtIndex:indexPath.row];
    cell.invitedTillDateLabel.text = [pirinvitedTillData objectAtIndex:indexPath.row];
    cell.actionTakenLabel.text = [piractionTakenData objectAtIndex:indexPath.row];
    
    if([[pirkeyData objectAtIndex:indexPath.row]integerValue] == -1 || [[piractionTakenData objectAtIndex:indexPath.row]isEqualToString:@"Accepted"] || [[piractionTakenData objectAtIndex:indexPath.row]isEqualToString:@"Declined"]){
        
        cell.userInteractionEnabled = NO;
    }
    
    if (indexPath.row % 2 == 0)
    {
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"purple"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    }
    
    else
    {
        
        
        cell.backgroundView = [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        cell.selectedBackgroundView =  [[UIImageView alloc] initWithImage:[ [UIImage imageNamed:@"orange-1"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
        
        
    }

    
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 186;
}


#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}



- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    switch (index) {
        case 0:
        {
            
            NSLog(@"FIRST NAMES %@",pirfirstNameData);
            NSLog(@"LAST NAMES %@",pirlastNameData);
            NSLog(@"INVITED FROM %@",pirinvitedFromData);
            NSLog(@"INVITED TILL %@",pirinvitedTillData);
            NSLog(@"SENDER PHONE %@",pirsenderPhoneData);
            NSLog(@"SENDER EMAIL %@",pirsenderEMailData);
            NSLog(@"ACTION TAKEN %@",piractionTakenData);
            
            
            
            
            //Send Email
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            
            // Email Subject
            NSString *emailTitle = @"Message From GeuestVite";
            // Email Content
            NSString *messageBody = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that I could not respond to your invitation. I thank You for the invite and hope to see you soon!",[pirfirstNameData objectAtIndex:cellIndexPath.row]];
            // To address
            NSArray *toRecipents = [NSArray arrayWithObject:[pirsenderEMailData objectAtIndex:cellIndexPath.row]];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
            
            
            
            break;
        }
        case 1:
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
            
            
            
            
            
            NSArray *recipents = [NSArray arrayWithObject:[pirsenderPhoneData objectAtIndex:cellIndexPath.row]];
            
            
            NSString *message = [NSString stringWithFormat:@"Hey %@!, I am extremely sorry that I could not respond to your invitation. I thank You for the invite and hope to see you soon!",[pirfirstNameData objectAtIndex:cellIndexPath.row]];
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:recipents];
            [messageController setBody:message];
            
            
            [self presentViewController:messageController animated:YES completion:nil];

            break;
        }
         
            /*
        case 2: // Delete
        {
            
            
            
            NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            
            NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Just One Confirmation!" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
            NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Do You really want to delete this Invite?" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
            NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"Once deleted, it cannot be reverted" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
            
            CNPPopupButton *buttonGoBack = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
            [buttonGoBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buttonGoBack.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            [buttonGoBack setTitle:@"Go Back" forState:UIControlStateNormal];
            buttonGoBack.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
            buttonGoBack.layer.cornerRadius = 4;
            buttonGoBack.selectionHandler = ^(CNPPopupButton *buttonGoBack){
                [self.popupController dismissPopupControllerAnimated:YES];
                NSLog(@"Block for button: %@", buttonGoBack.titleLabel.text);
            };
            
            CNPPopupButton *buttonDelete = [[CNPPopupButton alloc] initWithFrame:CGRectMake(50, 50, 200, 60)];
            [buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buttonDelete.titleLabel.font = [UIFont boldSystemFontOfSize:18];
            [buttonDelete setTitle:@"Delete" forState:UIControlStateNormal];
            buttonDelete.backgroundColor = [UIColor colorWithRed:1.0 green:0.231f blue:0.188 alpha:1.0];
            buttonDelete.layer.cornerRadius = 4;
            buttonDelete.selectionHandler = ^(CNPPopupButton *buttonDelete){
                // Delete button is pressed
                NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
                NSLog(@"KEY DATA IS %@",[pirkeyData objectAtIndex:cellIndexPath.row]);
               // [[[_ref child:@"invites"] child:[pirkeyData objectAtIndex:cellIndexPath.row]] removeValue];
        
                [pirfirstNameData removeObjectAtIndex:cellIndexPath.row];
                [pirlastNameData removeObjectAtIndex:cellIndexPath.row];
                [pirinvitedFromData removeObjectAtIndex:cellIndexPath.row];
                [pirinvitedTillData removeObjectAtIndex:cellIndexPath.row];
                [pirsenderPhoneData removeObjectAtIndex:cellIndexPath.row];
                [pirsenderEMailData removeObjectAtIndex:cellIndexPath.row];
                [piractionTakenData removeObjectAtIndex:cellIndexPath.row];
                [pirkeyData removeObjectAtIndex:cellIndexPath.row];
                
                [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                
                [self.popupController dismissPopupControllerAnimated:YES];
                NSLog(@"Block for button: %@", buttonDelete.titleLabel.text);
            };
            
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.numberOfLines = 0;
            titleLabel.attributedText = title;
            
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
            
            self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, lineOneLabel, lineTwoLabel, buttonGoBack,buttonDelete]];
            self.popupController.theme = [CNPPopupTheme defaultTheme];
            self.popupController.theme.popupStyle = CNPPopupStyleCentered;
            self.popupController.delegate = self;
            [self.popupController presentPopupControllerAnimated:YES];

            
            
            
            
            break;

            
        }
         */
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
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}






@end
