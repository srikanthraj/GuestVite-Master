//
//  SendNewInviteViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-11.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SendNewInviteViewController.h"
#import "SendBulkInviteViewController.h"
#import "SendAddressBookInviteViewController.h"

#import <MessageUI/MessageUI.h>
#import "SACalendar.h"

@import Firebase;

@interface SendNewInviteViewController () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate,SACalendarDelegate>

@property (weak, nonatomic) IBOutlet UITextField *guestNameText;
@property (weak, nonatomic) IBOutlet UITextField *guestEMailText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UITextField *guestPhoneText;
@property (weak, nonatomic) IBOutlet UITextField *inviteForDateText;
@property (weak, nonatomic) IBOutlet UITextField *inviteExpireDateText;
@property (weak, nonatomic) IBOutlet UITextView *messageText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *sendInvite;
@property (weak, nonatomic) IBOutlet UIImageView *regView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerExpire;

@property (nonatomic, strong) UITextField *currentTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (nonatomic, strong) NSString *string;

@property (nonatomic, strong) NSString *startTime;

@property (nonatomic, strong) NSString *endTime;

@end

@implementation SendNewInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    
    //self.guestNameText.layer.backgroundColor = [UIColor colorWithRed:0.1 green:1.0 blue:0.1 alpha:0.1].CGColor;
    self.guestNameText.layer.cornerRadius = 10.0;
    self.guestNameText.layer.borderWidth = 1.0;
    
    self.guestEMailText.layer.cornerRadius = 10.0;
    self.guestEMailText.layer.borderWidth = 1.0;
    
    self.guestPhoneText.layer.cornerRadius = 10.0;
    self.guestPhoneText.layer.borderWidth = 1.0;
    
    self.inviteForDateText.layer.cornerRadius = 10.0;
    self.inviteForDateText.layer.borderWidth = 1.0;
    
    self.inviteExpireDateText.layer.cornerRadius = 10.0;
    self.inviteExpireDateText.layer.borderWidth = 1.0;
    
    self.messageText.text = @"Personalized Message";
    self.messageText.textColor = [UIColor lightGrayColor];
    self.messageText.layer.cornerRadius = 10.0;
    self.messageText.layer.borderWidth = 1.0;
    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    
    self.guestNameText.inputAccessoryView = keyboardDoneButtonView;
    self.guestEMailText.inputAccessoryView = keyboardDoneButtonView;
    self.guestPhoneText.inputAccessoryView = keyboardDoneButtonView;
    //self.inviteForDateText.inputAccessoryView = keyboardDoneButtonView;
    //self.inviteExpireDateText.inputAccessoryView = keyboardDoneButtonView;
    self.messageText.inputAccessoryView = keyboardDoneButtonView;
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    
    
    [self.datePicker setValue:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]forKey:@"textColor"];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    [self.view addSubview: self.datePicker];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    self.datePickerExpire.frame = CGRectMake(40, 70, 300, 50); // set frame as your need
    [self.datePickerExpire setValue:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]forKey:@"textColor"];
    
    
    self.datePickerExpire.datePickerMode = UIDatePickerModeTime;
    [self.view addSubview: self.datePickerExpire];
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    [self.datePickerExpire  addTarget:self action:@selector(dateChangedExpire:) forControlEvents:UIControlEventValueChanged];
    
    
}


- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePicker.date];
    NSLog(@"Time For %@", currentTime);
    self.startTime = currentTime;
}

- (void)dateChangedExpire:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePickerExpire.date];
    NSLog(@"Time Expire%@", currentTime);
    self.endTime = currentTime;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.regView;
}

-(void)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}


- (IBAction)forDateBeginEdit:(id)sender {
    
    self.inviteExpireDateText.enabled = FALSE;
    
    SACalendar *calendar = [[SACalendar alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
    
    calendar.delegate = self;
    [self.view addSubview:calendar];
    
    [self.view endEditing:YES];
}

- (IBAction)forDateBeginEditExpire:(id)sender {
    
    self.inviteForDateText.enabled = FALSE;
    
    SACalendar *calendar1 = [[SACalendar alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
    
    calendar1.delegate = self;
    [self.view addSubview:calendar1];
    
    [self.view endEditing:YES];
}



- (void) setCurrentTextField:(UITextField *)currentTextField{
    self.currentTextField.text = self.string;
}

// Prints out the selected date
-(void) SACalendar:(SACalendar*)calendar didSelectDate:(int)day month:(int)month year:(int)year
{
    
    [self.view endEditing:YES];
    self.string = [NSString stringWithFormat:@"%02d/%02d/%02d",month,day,year];
    
    NSLog(@"Date Selected is : %@",self.string);
    
    if(self.inviteForDateText.isEnabled){
        self.inviteForDateText.text = self.string;
        self.inviteExpireDateText.enabled = TRUE;
        NSLog(@"FOR DATE ");
    }
    
    else if(self.inviteExpireDateText.isEnabled){
        self.inviteExpireDateText.text = self.string;
        self.inviteForDateText.enabled = TRUE;
        NSLog(@"EXPIRE DATE ");
    }
    
    [calendar removeFromSuperview];
    
    
    
}

//Utility Function to convert String to date

-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    return [dateFormatter dateFromString:dateStr];
}



- (IBAction)editEnded:(id)sender {
    [sender resignFirstResponder];
}

// Prints out the month and year displaying on the calendar
-(void) SACalendar:(SACalendar *)calendar didDisplayCalendarForMonth:(int)month year:(int)year{
    [self.view endEditing:YES];
}


//-------------------------------


- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}


- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin;
    CGFloat buttonHeight;
    
    
    if(self.messageText.isFirstResponder){
        buttonOrigin = self.messageText.frame.origin;
        
        buttonHeight = self.messageText.frame.size.height;
    }
    
    else if(self.sendInvite.isFirstResponder){
        buttonOrigin = self.sendInvite.frame.origin;
        
        buttonHeight = self.sendInvite.frame.size.height;
    }
    
    else if(self.inviteExpireDateText.isFirstResponder){
        buttonOrigin = self.inviteExpireDateText.frame.origin;
        
        buttonHeight = self.inviteExpireDateText.frame.size.height;
    }
    
    
    
    
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//---------------------------------


- (IBAction)segmentTapped:(id)sender {

if(self.segmentControl.selectedSegmentIndex ==1){
    
    
    SendBulkInviteViewController *sendBulkVC =
    [[SendBulkInviteViewController alloc] initWithNibName:@"SendBulkInviteViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:sendBulkVC animated:YES];
    
    [self presentViewController:sendBulkVC animated:YES completion:nil];
}
    
    if(self.segmentControl.selectedSegmentIndex ==2){
        
        
        SendAddressBookInviteViewController *sendAddrVC =
        [[SendAddressBookInviteViewController alloc] initWithNibName:@"SendAddressBookInviteViewController" bundle:nil];
        
        //hPViewController.userName  = eMailEntered;
        [self.navigationController pushViewController:sendAddrVC animated:YES];
        
        [self presentViewController:sendAddrVC animated:YES completion:nil];
    }

    
}

- (IBAction)sendInviteTapped:(id)sender {
    
    // Get the invite Row
    
    __block NSMutableString *rowValue = [[NSMutableString alloc] init];
    
    __block NSMutableString *senderName = [[NSMutableString alloc] init];
    
    __block NSString *startDateTime  = [[NSString alloc] init];
    
    __block NSString *endDateTime = [[NSString alloc] init];
    
    startDateTime= [NSString stringWithFormat:@"%@ %@",self.inviteForDateText.text,self.startTime];
    
    endDateTime= [NSString stringWithFormat:@"%@ %@",self.inviteExpireDateText.text,self.endTime];
    
    //startDateTime = [self.inviteForDateText.text self.startTime];
    
    //endDateTime = [self.inviteExpireDateText.text stringByAppendingString:self.endTime];
    
    
    
    NSDate *fromDate = [self dateToFormatedDate:startDateTime];
    
    NSDate *toDate = [self dateToFormatedDate:endDateTime];
    
    
    NSLog(@"FROM DATE %@",fromDate);
    
    NSLog(@"TO DATE %@",toDate);

    

    if([self.guestEMailText.text length] ==0 && [self.guestPhoneText.text length] ==0) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"At Least One field amonf E-Mail Address or Phone is required"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    else{
        
        if([fromDate compare:toDate] == NSOrderedAscending) // ONLY if from is earlier
        {
        
        self.ref = [[FIRDatabase database] reference];
        
    

        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
        
            NSArray * arr = [self.guestNameText.text componentsSeparatedByString:@" "];
    
            
            NSDictionary *post = @{@"Sender First Name": [dict valueForKey:@"First Name"],
                                   @"Sender Last Name": [dict valueForKey:@"Last Name"],
                                   @"Sender EMail": [dict valueForKey:@"EMail"],
                                   @"Sender Address1": [dict valueForKey:@"Address1"],
                                   @"Sender Address2": [dict valueForKey:@"Address2"],
                                   @"Sender City": [dict valueForKey:@"City"],
                                   @"Sender Zip": [dict valueForKey:@"Zip"],
                                   @"Sender Phone": [dict valueForKey:@"Phone"],
                                   @"Mesage From Sender": self.messageText.text,
                                   @"Receiver First Name": [arr objectAtIndex:0],
                                   @"Receiver Last Name": [arr objectAtIndex:1],
                                   @"Receiver EMail": self.guestEMailText.text,
                                   @"Receiver Phone": self.guestPhoneText.text,
                                   @"Invite For Date": startDateTime,
                                   @"Invite Valid Till Date": endDateTime,
                                   @"Invitation Status": @"Pending",
                                   };
            
            
            
           
            
            NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
            NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
            NSRange range = [intervalString rangeOfString:@"."];
             NSString *primarykey = [intervalString substringToIndex:range.location];
            NSString *pKey = [userID stringByAppendingString:primarykey];
            [rowValue setString:pKey];
            [senderName setString:[dict valueForKey:@"First Name"]];
            [senderName appendString:@" "];
            [senderName appendString:[dict valueForKey:@"Last Name"]];
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", pKey]: post};
            [_ref updateChildValues:childUpdates];
            
           }];
    
        while([rowValue length]== 0 && [senderName length] ==0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        
     // -------------------- SEND SMS  When Email not defined and Phone Defined OR Both Phone and E Mail Defined------------------------------------
    
    if(([self.guestEMailText.text length] ==0  && [self.guestPhoneText.text length] > 0) ||  ([self.guestEMailText.text length] > 0  && [self.guestPhoneText.text length] > 0)){
        
        
        
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            return;
        }
        
        
        
        
       
        NSArray *recipents = [NSArray arrayWithObject:self.guestPhoneText.text];
       
        
        NSString *message = [NSString stringWithFormat:@"Hey! %@ , You are invited by %@ at their place on %@ at %@, Please login/Register to GuestVite App for more Details ,Thanks!",self.guestNameText.text,senderName,self.inviteForDateText.text,self.startTime];
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        
        
        [self presentViewController:messageController animated:YES completion:nil];
        
    }
    
        
        // -------------------- SEND EMAIL ------------------------------------
        
        
        if([self.guestEMailText.text length] > 0  && [self.guestPhoneText.text length] == 0) {
            
            // Email Subject
            NSString *emailTitle = @"Message From GeuestVite";
            // Email Content
            NSString *messageBody = [NSString stringWithFormat:@"Hey! %@ , This is %@  and I want to invite you at my place on %@ at %@ , please login to this new cool App GuestVite! for all further details, Thanks and looking forward to see you soon!",self.guestNameText.text,senderName,self.inviteForDateText.text,self.startTime];
            // To address
            NSArray *toRecipents = [NSArray arrayWithObject:self.guestEMailText.text];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];

            
        }
        }
        
        else {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"From Date cannot be later than To Date"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
        
    }// Main else ends
    
    
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
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent: {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Success" message:[NSString stringWithFormat:@"E-Mail sent successfully to %@",self.guestNameText.text]preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
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
