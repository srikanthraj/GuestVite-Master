//
//  SendBulkInviteViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-13.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SendBulkInviteViewController.h"
#import "SendAddressBookInviteViewController.h"
#import "SendNewInviteViewController.h"
#import <MessageUI/MessageUI.h>


@import Firebase;

@interface SendBulkInviteViewController () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *eMailguestList;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UITextField *inviteForDateText;
@property (weak, nonatomic) IBOutlet UITextField *inviteExpireDateText;
@property (weak, nonatomic) IBOutlet UITextView *inviteMessage;

@property (weak, nonatomic) IBOutlet UITextView *smsGuestList;

@property (strong, nonatomic) FIRDatabaseReference *ref;


@end

@implementation SendBulkInviteViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   
    self.ref = [[FIRDatabase database] reference];
    
    self.eMailguestList.text = @"Enter Email Addressses here";
    self.eMailguestList.textColor = [UIColor lightGrayColor];
    self.eMailguestList.layer.cornerRadius = 10.0;
    self.eMailguestList.layer.borderWidth = 1.0;
    self.eMailguestList.delegate = self;
    
    self.smsGuestList.text = @"Enter Phone Numbers here";
    self.smsGuestList.textColor = [UIColor lightGrayColor];
    self.smsGuestList.layer.cornerRadius = 10.0;
    self.smsGuestList.layer.borderWidth = 1.0;
    self.smsGuestList.delegate = self;
    
    self.inviteForDateText.layer.cornerRadius = 10.0;
    self.inviteForDateText.layer.borderWidth = 1.0;
    
    self.inviteExpireDateText.layer.cornerRadius = 10.0;
    self.inviteExpireDateText.layer.borderWidth = 1.0;
    
    self.inviteMessage.layer.cornerRadius = 10.0;
    self.inviteMessage.layer.borderWidth = 1.0;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    
    self.eMailguestList.inputAccessoryView = keyboardDoneButtonView;
    self.smsGuestList.inputAccessoryView = keyboardDoneButtonView;
    self.inviteForDateText.inputAccessoryView = keyboardDoneButtonView;
    self.inviteExpireDateText.inputAccessoryView = keyboardDoneButtonView;
    self.inviteMessage.inputAccessoryView = keyboardDoneButtonView;
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];

    
}


- (IBAction)segmentTapped:(id)sender {
    
    if(self.segmentControl.selectedSegmentIndex ==0){
        
        
        SendNewInviteViewController *sendNewVC =
        [[SendNewInviteViewController alloc] initWithNibName:@"SendNewInviteViewController" bundle:nil];
        
        //hPViewController.userName  = eMailEntered;
        [self.navigationController pushViewController:sendNewVC animated:YES];
        
        [self presentViewController:sendNewVC animated:YES completion:nil];
    }
    
    if(self.segmentControl.selectedSegmentIndex ==2){
        
        
        SendAddressBookInviteViewController *sendAddrVC =
        [[SendAddressBookInviteViewController alloc] initWithNibName:@"SendAddressBookInviteViewController" bundle:nil];
        
        //hPViewController.userName  = eMailEntered;
        [self.navigationController pushViewController:sendAddrVC animated:YES];
        
        [self presentViewController:sendAddrVC animated:YES completion:nil];
    }

    
}


- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if(self.eMailguestList.isFirstResponder)
    {
        if([self.eMailguestList.text isEqualToString:@"Enter Email Addressses here"]) {
    self.eMailguestList.text = @"";
    self.eMailguestList.textColor = [UIColor blackColor];
        }
        
        }
    
    if(self.smsGuestList.isFirstResponder)
    {
        if([self.smsGuestList.text isEqualToString:@"Enter Phone Numbers here"]) {
        self.smsGuestList.text = @"";
        self.smsGuestList.textColor = [UIColor blackColor];
    }
    }
    
}

-(void) textViewDidChangeSelection:(UITextView *)textView
{
    
    
    if(!self.eMailguestList.isFirstResponder)
        {
                if(self.eMailguestList.text.length == 0){
                    self.eMailguestList.textColor = [UIColor lightGrayColor];
                    self.eMailguestList.text = @"Enter Email Addressses here";
                    [self.eMailguestList resignFirstResponder];
                }
    }
    
    
    if(!self.smsGuestList.isFirstResponder)
    {
        if(self.smsGuestList.text.length == 0){
            self.smsGuestList.textColor = [UIColor lightGrayColor];
            self.smsGuestList.text = @"Enter Phone Numbers here";
            [self.smsGuestList resignFirstResponder];
        }
    }
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneClicked:(id)sender
{
    //NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}
- (IBAction)sendSMSTapped:(id)sender {
    
    
    // Get the invite Row
    
    __block NSMutableString *rowValue = [[NSMutableString alloc] init];
    
    __block NSMutableString *senderName = [[NSMutableString alloc] init];
    
    __block NSMutableArray *smsList = [[NSMutableArray alloc] init];
    
    //__block NSMutableArray *emailList = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *noneList = [[NSMutableArray alloc] init];
    
    
    
    if([self.smsGuestList.text length] ==0) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"At Least One Guest Info is required"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    else{
        
        self.ref = [[FIRDatabase database] reference];
        
        
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        //NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            
             NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
            int i =0;
            for(NSString *address in arr)
            {
                
                              if([address length] == 10)
                              {
                    NSDictionary *post = @{@"Sender First Name": [dict valueForKey:@"First Name"],
                                           @"Sender Last Name": [dict valueForKey:@"Last Name"],
                                           @"Sender EMail": [dict valueForKey:@"EMail"],
                                           @"Sender Address1": [dict valueForKey:@"Address1"],
                                           @"Sender Address2": [dict valueForKey:@"Address2"],
                                           @"Sender City": [dict valueForKey:@"City"],
                                           @"Sender Zip": [dict valueForKey:@"Zip"],
                                           @"Sender Phone": [dict valueForKey:@"Phone"],
                                           @"Mesage From Sender": self.inviteMessage.text,
                                           @"Receiver First Name": @"BULK",
                                           @"Receiver Last Name": @"BULK",
                                           @"Receiver EMail": @"BULK",
                                           @"Receiver Phone": address,
                                           @"Invite For Date": self.inviteForDateText.text,
                                           @"Invite Valid Till Date": self.inviteExpireDateText.text,
                                           @"Invitation Status": @"Pending",
                                           };//Dict post
                    
                    
                    
                    
                    
                    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
                    NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
                    NSRange range = [intervalString rangeOfString:@"."];
                    NSString *primarykey = [intervalString substringToIndex:range.location];
                    NSString *pkey1 = [userID stringByAppendingString:primarykey];
                    
                    NSString *pkey2 = [pkey1 stringByAppendingString:@"_"] ;
                
                    NSString *pKey = [pkey2 stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[arr indexOfObject:address]]];
                    
                    [rowValue setString:pKey];
                    [senderName setString:[dict valueForKey:@"First Name"]];
                    [senderName appendString:@" "];
                    [senderName appendString:[dict valueForKey:@"Last Name"]];
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", pKey]: post};
                    [_ref updateChildValues:childUpdates];
                    [smsList addObject:address];
                    //NSLog(@"PKEY for PHONE NUMBER %@",pKey);
                } // If addr length = 10 ends
    
                else {
                    
                    [noneList addObject:address];
                    
                } // else ends
                
                
                i++;
                
                
            } // for loop ends
            
            
            
        }]; // DB Query ends
        
        while([rowValue length]== 0 && [senderName length] ==0 && ([smsList count] == 0 || [noneList count] == 0)) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if([smsList count] > 0){
            
            
            
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [ac addAction:aa];
                [self presentViewController:ac animated:YES completion:nil];
                return;
            }
            
            
            
            
            
            //NSArray *recipents = [NSArray arrayWithObject:self.guestPhoneText.text];
            
            
            NSString *message = [NSString stringWithFormat:@"Hey!, You are invited by %@ as a guest, Please login/Register to GuestVite App for more Details ,Thanks!",senderName];
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:smsList];
            [messageController setBody:message];
            
            
            [self presentViewController:messageController animated:YES completion:nil];
            
        }
        
        
         if([noneList count] > 0) {
         
         NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
         NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.smsGuestList.text];
             
             for(NSString *temp in arr){
                 for(NSString *tempNone in noneList){
                 
                        if([temp isEqualToString:tempNone]){
                     
                            
                            NSRange range=[self.smsGuestList.text rangeOfString:temp];
                            NSLog(@"None String Range is %@",NSStringFromRange(range));
                            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                        }
                 }
             }
             [self.smsGuestList setAttributedText:string];
         
         }
        

        
        
    }
    
}

- (IBAction)sendEMailTapped:(id)sender {
    
    // Get the invite Row
    
    __block NSMutableString *rowValue = [[NSMutableString alloc] init];
    
    __block NSMutableString *senderName = [[NSMutableString alloc] init];
    
    //__block NSMutableArray *smsList = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *emailList = [[NSMutableArray alloc] init];
    
    __block NSMutableArray *noneList = [[NSMutableArray alloc] init];
    
    
    
    if([self.eMailguestList.text length] ==0) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"At Least One Guest Info is required"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    else{
        
        self.ref = [[FIRDatabase database] reference];
        
        
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        //NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            
            NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
            int i =0;
            for(NSString *address in arr)
            {
                
                
                if([address containsString:@".com"])
                {
                    
                    NSDictionary *post = @{@"Sender First Name": [dict valueForKey:@"First Name"],
                                           @"Sender Last Name": [dict valueForKey:@"Last Name"],
                                           @"Sender EMail": [dict valueForKey:@"EMail"],
                                           @"Sender Address1": [dict valueForKey:@"Address1"],
                                           @"Sender Address2": [dict valueForKey:@"Address2"],
                                           @"Sender City": [dict valueForKey:@"City"],
                                           @"Sender Zip": [dict valueForKey:@"Zip"],
                                           @"Sender Phone": [dict valueForKey:@"Phone"],
                                           @"Mesage From Sender": self.inviteMessage.text,
                                           @"Receiver First Name": @"BULK",
                                           @"Receiver Last Name": @"BULK",
                                           @"Receiver EMail": address,
                                           @"Receiver Phone": @"BULK",
                                           @"Invite For Date": self.inviteForDateText.text,
                                           @"Invite Valid Till Date": self.inviteExpireDateText.text,
                                           @"Invitation Status": @"Pending",
                                           };
                    
                    
                    
                    
                    
                    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
                    NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
                    NSRange range = [intervalString rangeOfString:@"."];
                    NSString *primarykey = [intervalString substringToIndex:range.location];
                    
                    NSString *pkey1 = [userID stringByAppendingString:primarykey];
                    
                    NSString *pkey2 = [pkey1 stringByAppendingString:@"_"] ;
                    
                    NSString *pKey = [pkey2 stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[arr indexOfObject:address]]];
                    
                    
                    [rowValue setString:pKey];
                    [senderName setString:[dict valueForKey:@"First Name"]];
                    [senderName appendString:@" "];
                    [senderName appendString:[dict valueForKey:@"Last Name"]];
                    NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", pKey]: post};
                    [_ref updateChildValues:childUpdates];
                    [emailList addObject:address];
                    
                }
                
                
                
                else {
                    
                    [noneList addObject:address];
                    
                }
                
                
                i++;
                
                
            }
            
            
            
        }];
        
        while([rowValue length]== 0 && [senderName length] ==0 && ([emailList count] == 0 || [noneList count] == 0)) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if([emailList count] > 0) {
            
            // Email Subject
            NSString *emailTitle = @"Message From GeuestVite";
            // Email Content
            NSString *messageBody = [NSString stringWithFormat:@"Hey!, This is %@  and I want to invite you at my place , please login to this new cool App GuestVite! for all further details, Thanks and looking forward to see you soon!",senderName];
            // To address
            //NSArray *toRecipents = [NSArray arrayWithObject:self.guestEMailText.text];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:emailList];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
            
            
        }
        
        
    }
    
    
    
    
    if([noneList count] > 0) {
        
        NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.eMailguestList.text];
        
        for(NSString *temp in arr){
            for(NSString *tempNone in noneList){
                
                if([temp isEqualToString:tempNone]){
                    
                    //NSLog(@"None String is %@",temp);
                    
                    NSRange range=[self.eMailguestList.text rangeOfString:temp];
                    [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                }
            }
        }
        
        [self.eMailguestList setAttributedText:string];
        
    }
    
    
    //NSLog(@"Email List: %@",emailList);
    
    //NSLog(@"None List: %@",noneList);
}

    



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
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
           // NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
           // NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent: {
            //NSLog(@"Mail SENT!!!");
            
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
