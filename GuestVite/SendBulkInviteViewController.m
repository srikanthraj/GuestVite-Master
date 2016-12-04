//
//  SendBulkInviteViewController.m
//  GuestVite
//
//  Created by Srikanth Raj on 2016-10-13.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SendBulkInviteViewController.h"
#import "HomePageViewController.h"
#import "SendAddressBookInviteViewController.h"
#import "SendNewInviteViewController.h"
#import <MessageUI/MessageUI.h>
#import "MapKit/MapKit.h"
#import "Reachability.h"
#import "UIViewController+Reachability.m"
#import "CNPPopupController.h"

@import Firebase;

@interface SendBulkInviteViewController () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate,CNPPopupControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *eMailguestList;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UISwitch *informSwitch;

@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;

@property (weak, nonatomic) IBOutlet UITextView *emailTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendSMS;
@property (weak, nonatomic) IBOutlet UIButton *sendEMail;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UITextView *inviteMessage;

@property (weak, nonatomic) IBOutlet UITextView *smsGuestList;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerExpire;

@property (nonatomic, strong) CNPPopupController *popupController;

@property (weak, nonatomic) IBOutlet UINavigationBar *sendBulkInviteBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;


@property (nonatomic, strong) UITextField *currentTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (nonatomic, strong) NSString *string;

@property (nonatomic, strong) NSString *startTime;

@property (nonatomic, strong) NSString *endTime;

@property (nonatomic) BOOL shouldKeyboardMoveUp;

@property (nonatomic) BOOL entryErrorEMail;
@property (nonatomic) BOOL entryErrorPhone;

@end

@implementation SendBulkInviteViewController

//Test

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    
}

//Test Ends


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    //Style the Buttons
    
    self.sendSMS.layer.cornerRadius = 10.0;
    [[self.sendSMS layer] setBorderWidth:1.0f];
    [[self.sendSMS layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    self.sendEMail.layer.cornerRadius = 10.0;
    [[self.sendEMail layer] setBorderWidth:1.0f];
    [[self.sendEMail layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    
    // Set the Text Views
    
    self.emailTextView.text = NSLocalizedString(@"😐", nil);
    self.emailTextView.editable = NO;
    
    self.phoneTextView.text = NSLocalizedString(@"😐", nil);
    self.phoneTextView.editable = NO;
    
    self.entryErrorEMail = YES;
    self.entryErrorPhone = YES;
    
    
    
    // Set the current date and time as date
    
    
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc] init];
    [currentDateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSString *currentTime = [currentDateFormatter stringFromDate:[NSDate date]];
    
    self.startTime = currentTime;
    //NSLog(@"Start Time on load %@", self.startTime);
    
    self.endTime = currentTime;
    
    //NSLog(@"End Time on load %@", self.endTime);
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_sendBulkInviteBack];
    
    
    
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
    
    
    self.inviteMessage.text = @"Personalized Message";
    self.inviteMessage.textColor = [UIColor lightGrayColor];
    self.inviteMessage.layer.cornerRadius = 10.0;
    self.inviteMessage.layer.borderWidth = 1.0;
    self.inviteMessage.delegate = self;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    
    self.eMailguestList.inputAccessoryView = keyboardDoneButtonView;
    self.smsGuestList.inputAccessoryView = keyboardDoneButtonView;
    self.inviteMessage.inputAccessoryView = keyboardDoneButtonView;
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    
    
    [self.datePicker setValue:[UIColor whiteColor]forKey:@"textColor"];
    
    
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    
    [self.datePickerExpire setValue:[UIColor whiteColor]forKey:@"textColor"];
    
    
    [self.datePickerExpire  addTarget:self action:@selector(dateChangedExpire:) forControlEvents:UIControlEventValueChanged];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)Back
{
    HomePageViewController *homePageVC =
    [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
    
    
    [self.navigationController pushViewController:homePageVC animated:YES];
    
    [self presentViewController:homePageVC animated:YES completion:nil];
}



- (BOOL)validateEmailWithString:(NSString*)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)validatePhoneWithString:(NSString*)checkString

{
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:checkString];
    
    // Not numeric
    if (![alphaNums isSupersetOfSet:inStringSet]){
        return NO;
    }
    
    else {
        return YES;
    }
    
}



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



- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}


- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = CGPointMake(0, 0);
    CGFloat buttonHeight = 0.0;
    
    
    if(self.inviteMessage.isFirstResponder){
        buttonOrigin = self.inviteMessage.frame.origin;
        
        buttonHeight = self.inviteMessage.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }
    
    else if(self.eMailguestList.isFirstResponder){
        buttonOrigin = self.eMailguestList.frame.origin;
        
        buttonHeight = self.eMailguestList.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }
    
    if(self.shouldKeyboardMoveUp)
    {
        
        
        CGRect visibleRect = self.view.frame;
        
        visibleRect.size.height -= keyboardSize.height + 40; // Extra 40 for Done Button
        
        if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
            
            CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
            
            [self.scrollView setContentOffset:scrollPoint animated:YES];
            
        }
        
        
        
    }
    
    
    // If Message Text is first Responder, the move 70 for Characters remaining to be visible
    
    
    if(self.shouldKeyboardMoveUp && self.inviteMessage.isFirstResponder)
    {
        
        
        CGRect visibleRect = self.view.frame;
        
        visibleRect.size.height -= keyboardSize.height + 70; // Extra 70 for Done Button and characters remaining
        
        if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
            
            CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
            
            [self.scrollView setContentOffset:scrollPoint animated:YES];
            
        }
        
        
        
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







// ---------------------------------

- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePicker.date];
    //NSLog(@"Time For %@", currentTime);
    self.startTime = currentTime;
}

- (void)dateChangedExpire:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePickerExpire.date];
    //NSLog(@"Time Expire%@", currentTime);
    self.endTime = currentTime;
}

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
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
        
        if([self.smsGuestList.text isEqualToString:@""]) {
            self.smsGuestList.text = @"Enter Phone Numbers here";
            self.smsGuestList.textColor = [UIColor grayColor];
        }
        
        if([self.inviteMessage.text isEqualToString:@""]) {
            self.inviteMessage.text = @"Personalized Message";
            self.inviteMessage.textColor = [UIColor grayColor];
        }
        
        
    }
    
    if(self.smsGuestList.isFirstResponder)
    {
        if([self.smsGuestList.text isEqualToString:@"Enter Phone Numbers here"]) {
            self.smsGuestList.text = @"";
            self.smsGuestList.textColor = [UIColor blackColor];
        }
        
        if([self.eMailguestList.text isEqualToString:@""]) {
            self.eMailguestList.text = @"Enter Email Addressses here";
            self.eMailguestList.textColor = [UIColor grayColor];
        }
        
        if([self.inviteMessage.text isEqualToString:@""]) {
            self.inviteMessage.text = @"Personalized Message";
            self.inviteMessage.textColor = [UIColor grayColor];
        }
        
    }
    
    if(self.inviteMessage.isFirstResponder)
    {
        if([self.inviteMessage.text isEqualToString:@"Personalized Message"]) {
            self.inviteMessage.text = @"";
            self.inviteMessage.textColor = [UIColor blackColor];
        }
        
        if([self.eMailguestList.text isEqualToString:@""]) {
            self.eMailguestList.text = @"Enter Email Addressses here";
            self.eMailguestList.textColor = [UIColor grayColor];
        }
        
        if([self.smsGuestList.text isEqualToString:@""]) {
            self.smsGuestList.text = @"Enter Phone Numbers here";
            self.smsGuestList.textColor = [UIColor grayColor];
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
    
    if(!self.inviteMessage.isFirstResponder)
    {
        if(self.inviteMessage.text.length == 0){
            self.inviteMessage.textColor = [UIColor lightGrayColor];
            self.inviteMessage.text = @"Personalized Message";
            [self.inviteMessage resignFirstResponder];
        }
    }
    
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    if(self.inviteMessage.isFirstResponder)
    {
        NSUInteger len = textView.text.length;
        self.countLabel.text=[NSString stringWithFormat:@"%lu",100-(unsigned long)len];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if(self.inviteMessage.isFirstResponder)
    {
        return self.inviteMessage.text.length + (text.length - range.length) <= 100;
    }
    
    else {
        return 100;
    }
    
}



-(void) clearFields {
    self.smsGuestList.text = @"Enter Phone Numbers here";
    self.smsGuestList.textColor = [UIColor lightGrayColor];
    
    self.eMailguestList.text = @"Enter Email Addresses here";
    self.eMailguestList.textColor = [UIColor lightGrayColor];
    
    self.inviteMessage.text = @"Personalized Message";
    self.inviteMessage.textColor = [UIColor lightGrayColor];
    
    self.countLabel.text = @"100";
    self.informSwitch.on = YES;
    
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




- (void) setCurrentTextField:(UITextField *)currentTextField{
    self.currentTextField.text = self.string;
}

//Utility Function to convert String to date

-(NSDate *)dateToFormatedDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    return [dateFormatter dateFromString:dateStr];
}


- (IBAction)sendSMSTapped:(id)sender {
    
    // Check Internet Connectivity
    
    Reachability *kCFHostReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [kCFHostReachability currentReachabilityStatus];
    //NSLog(@"Netwrok Status %ld",(long)networkStatus);
    if (networkStatus == NotReachable) {
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"We are Sorry" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Looks like there's poor Internet connectivity, because of which your data might not saved " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
        
        CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [button setTitle:@"Okay, Got it" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
        button.layer.cornerRadius = 4;
        button.selectionHandler = ^(CNPPopupButton *button){
            [self.popupController dismissPopupControllerAnimated:YES];
        };
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title;
        
        UILabel *lineOneLabel = [[UILabel alloc] init];
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.attributedText = lineOne;
        
        // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sad-smiley"]];
        
        self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, lineOneLabel,button]];
        self.popupController.theme = [CNPPopupTheme defaultTheme];
        self.popupController.theme.popupStyle = CNPPopupStyleCentered;
        self.popupController.delegate = self;
        [self.popupController presentPopupControllerAnimated:YES];
        
    }
    
    
    else {
        
        
        // Get the invite Row
        
        __block NSMutableString *rowValue = [[NSMutableString alloc] init];
        
        __block NSMutableString *senderName = [[NSMutableString alloc] init];
        
        __block NSMutableArray *smsList = [[NSMutableArray alloc] init];
        
        //__block NSMutableArray *emailList = [[NSMutableArray alloc] init];
        
        
        NSMutableArray *badPhoneList = [[NSMutableArray alloc] init];
        
        
        __block NSString *startDateTime  = [[NSString alloc] init];
        
        __block NSString *endDateTime = [[NSString alloc] init];
        
        //NSLog(@"Send Invite Tapped start datetime %@",self.startTime);
        //NSLog(@"Send Invite Tapped end datetime %@",self.endTime);
        
        
        startDateTime = self.startTime;
        
        endDateTime= self.endTime;
        
        
        
        NSDate *fromDate = [self dateToFormatedDate:startDateTime];
        
        NSDate *toDate = [self dateToFormatedDate:endDateTime];
        
        
        //NSLog(@"FROM DATE %@",fromDate);
        
        //NSLog(@"TILL DATE %@",toDate);
        
        
        // Check all phone numbers to see if anything is present in Bad Phone List
        
        NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
        
        for(NSString *address in arr)
        {
            
            
            
            if(![self validatePhoneWithString:address] || [address length] != 10 || [address length] ==0)
                
                [badPhoneList addObject:address];
            
            
        }
        
        //NSLog(@"Bad Phone numbers are %@",badPhoneList);
        
        
        // 4 conditions to be checked
        /*
         
         1. If( Error in Phone and From Date > To Date)
         2. Else If (Error in Phone)
         3. Else If (From date > To Date)
         4. Else - Go Ahead and Add in DB
         
         */
        
        //1. If( Error in fields and From Date > To Date)
        
        if([badPhoneList count] > 0 && !([fromDate compare:toDate] == NSOrderedAscending)) {
            
            // Mark bad Phone with red
            
            NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.smsGuestList.text];
            
            for(NSString *temp in arr){
                for(NSString *tempNone in badPhoneList){
                    
                    //NSLog(@"Comparing %@ against %@",tempNone,temp);
                    if([temp isEqualToString:tempNone]){
                        
                        //NSLog(@"None String is %@",temp);
                        
                        NSRange range=[temp rangeOfString:tempNone options:NSCaseInsensitiveSearch];
                        //NSLog(@"RANGE IS %lu",(unsigned long)range.location);
                        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                    }
                }
            }
            
            [self.smsGuestList setAttributedText:string];
            
            
            self.phoneTextView.text = NSLocalizedString(@"😧", nil);
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"%@\n\n%@",@"Please check the Phone numbers marked in red (May be you left an empty line?)",@"From Date cannot be later than Till Date"]preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
        
        // 2. Else If (Error in Fields)
        
        else if([badPhoneList count] > 0) {
            
            // Mark bad Phone with red
            
            NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.smsGuestList.text];
            
            for(NSString *temp in arr){
                for(NSString *tempNone in badPhoneList){
                    
                    if([temp isEqualToString:tempNone]){
                        
                        //NSLog(@"None String is %@",temp);
                        
                        NSRange range=[self.smsGuestList.text rangeOfString:temp];
                        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                    }
                }
            }
            
            [self.smsGuestList setAttributedText:string];
            
            
            self.phoneTextView.text = NSLocalizedString(@"😧", nil);
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Please check the Phone numbers marked in red (May be you left an empty line?)"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            
            
        }
        
        //  3. Else If (From date > To Date)
        else if(!([fromDate compare:toDate] == NSOrderedAscending)) {
            
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"From Date cannot be later than Till Date"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
        
        //4. Else - Go Ahead and Add in DB
        
        else{
            
            // Mark phone numbers with Black
            
            self.smsGuestList.textColor = [UIColor blackColor];
            
            
            
            // Make face smiling Again
            self.phoneTextView.text = NSLocalizedString(@"😃", nil);
            
            
            self.ref = [[FIRDatabase database] reference];
            
            
            
            NSString *userID = [FIRAuth auth].currentUser.uid;
            
            //NSLog(@"User Id %@",userID);
            
            [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSDictionary *dict = snapshot.value;
                
                NSString *sendMessages = [[NSString alloc]init];
                if(self.informSwitch.isOn)
                    sendMessages = @"YES";
                else
                    sendMessages = @"NO";
                
                
                NSArray * arr = [self.smsGuestList.text componentsSeparatedByString:@"\n"];
                int i =0;
                for(NSString *address in arr)
                {
                    
                    NSString *hostaddr = [[NSString alloc]init];
                    
                    if([[dict valueForKey:@"Address2"] length] > 0)
                    {
                        hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"Address2"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                    }
                    
                    else {
                        hostaddr = [NSString stringWithFormat:@"%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                    }
                    
                    CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];
                    
                    
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
                                           @"Invite For Date": startDateTime,
                                           @"Invite Valid Till Date": endDateTime,
                                           @"Invitation Status": @"Pending",
                                           @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                           @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                           @"Guest Location Status" : @"NOT_STARTED",
                                           @"Host Send Messages" : sendMessages,
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
                    
                    
                    
                    
                    i++;
                    
                    
                } // for loop ends
                
                
                
            }]; // DB Query ends
            
            while([rowValue length]== 0 && [senderName length] ==0 && [smsList count] == 0) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            
            if([smsList count] > 0){
                
                
                
                if(![MFMessageComposeViewController canSendText]) {
                    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Sorry, your Device does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [self clearFields];
                    }];
                    
                    [ac addAction:aa];
                    [self presentViewController:ac animated:YES completion:nil];
                    return;
                }
                
                
                
                
                
                //NSArray *recipents = [NSArray arrayWithObject:self.guestPhoneText.text];
                
                
                NSString *message = [NSString stringWithFormat:@"Hey!, This is %@ and you are invited at our place on %@ , Please Login/Register to this cool App, GuestVite @ %@ for more details, Thanks!",senderName,self.startTime,@"https://itunes.apple.com/us/app/guestvite/id1182204052?ls=1&mt=8"];
                
                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                messageController.messageComposeDelegate = self;
                [messageController setRecipients:smsList];
                [messageController setBody:message];
                
                
                [self presentViewController:messageController animated:YES completion:nil];
                
            }
            
        } // Main else ends
    }// Internet connectivity else ends
    
}




- (IBAction)sendEMailTapped:(id)sender {
    
    
    // Check Internet Connectivity
    
    Reachability *kCFHostReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [kCFHostReachability currentReachabilityStatus];
    // NSLog(@"Netwrok Status %ld",(long)networkStatus);
    if (networkStatus == NotReachable) {
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"We are Sorry " attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
        
        NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"Looks like there's poor Internet connectivity, your data could not be saved " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
        
        CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [button setTitle:@"Okay, Got it" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithRed:0.46 green:0.8 blue:1.0 alpha:1.0];
        button.layer.cornerRadius = 4;
        button.selectionHandler = ^(CNPPopupButton *button){
            [self.popupController dismissPopupControllerAnimated:YES];
        };
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title;
        
        UILabel *lineOneLabel = [[UILabel alloc] init];
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.attributedText = lineOne;
        
        // UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sad-smiley"]];
        
        self.popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, lineOneLabel,button]];
        self.popupController.theme = [CNPPopupTheme defaultTheme];
        self.popupController.theme.popupStyle = CNPPopupStyleCentered;
        self.popupController.delegate = self;
        [self.popupController presentPopupControllerAnimated:YES];
        
    }
    
    
    else {
        // Get the invite Row
        
        __block NSMutableString *rowValue = [[NSMutableString alloc] init];
        
        __block NSMutableString *senderName = [[NSMutableString alloc] init];
        
        //__block NSMutableArray *smsList = [[NSMutableArray alloc] init];
        
        NSMutableArray *badEMailList = [[NSMutableArray alloc] init];
        
        __block NSMutableArray *emailList = [[NSMutableArray alloc] init];
        
        
        __block NSString *startDateTime  = [[NSString alloc] init];
        
        __block NSString *endDateTime = [[NSString alloc] init];
        
        //NSLog(@"Send Invite Tapped start datetime %@",self.startTime);
        //NSLog(@"Send Invite Tapped end datetime %@",self.endTime);
        
        startDateTime = self.startTime;
        endDateTime = self.endTime;
        
        
        
        NSDate *fromDate = [self dateToFormatedDate:startDateTime];
        
        NSDate *toDate = [self dateToFormatedDate:endDateTime];
        
        //NSLog(@"FROM DATE %@",fromDate);
        
        //NSLog(@"TILL DATE %@",toDate);
        
        
        // Check all E-Mails to see if anything is present in Bad E-Mail List
        
        NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
        
        for(NSString *address in arr)
        {
            
            
            
            if(![self validateEmailWithString:address] || [address length] ==0)
                
                [badEMailList addObject:address];
            
            
        }
        
        //NSLog(@"Bad E-Mail Addresses are %@",badEMailList);
        
        // 4 conditions to be checked
        /*
         
         1. If( Error in E-Mail and From Date > To Date)
         2. Else If (Error in E-Mail)
         3. Else If (From date > To Date)
         4. Else - Go Ahead and Add in DB
         
         */
        
        
        //1. If( Error in fields and From Date > To Date)
        
        if([badEMailList count] > 0 && !([fromDate compare:toDate] == NSOrderedAscending)) {
            
            // Mark bad E-Mail with red
            
            NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.eMailguestList.text];
            
            for(NSString *temp in arr){
                for(NSString *tempNone in badEMailList){
                    
                    if([temp isEqualToString:tempNone]){
                        
                        //NSLog(@"None String is %@",temp);
                        
                        NSRange range=[self.eMailguestList.text rangeOfString:temp];
                        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                    }
                }
            }
            
            [self.eMailguestList setAttributedText:string];
            
            
            self.emailTextView.text = NSLocalizedString(@"😧", nil);
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"%@\n\n%@",@"Please check the E-Mail addresses marked in red (May be you left an empty line?)",@"From Date cannot be later than Till Date"]preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
        
        
        
        // 2. Else If (Error in Fields)
        
        else if([badEMailList count] > 0) {
            
            // Mark bad Phone with red
            
            NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
            NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:self.eMailguestList.text];
            
            for(NSString *temp in arr){
                for(NSString *tempNone in badEMailList){
                    
                    if([temp isEqualToString:tempNone]){
                        
                        //NSLog(@"None String is %@",temp);
                        
                        NSRange range=[self.eMailguestList.text rangeOfString:temp];
                        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
                    }
                }
            }
            
            [self.eMailguestList setAttributedText:string];
            
            
            self.emailTextView.text = NSLocalizedString(@"😧", nil);
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Please check the E-Mail Addresses marked in red (May be you left an empty line?)"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            
            
        }
        
        
        //  3. Else If (From date > To Date)
        else if(!([fromDate compare:toDate] == NSOrderedAscending)) {
            
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"From Date cannot be later than To Date"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
        
        
        //4. Else - Go Ahead and Add in DB
        
        else{
            
            // Mark E-Mail Addresses with Black
            
            self.eMailguestList.textColor = [UIColor blackColor];
            
            
            
            // Make face smiling Again
            self.emailTextView.text = NSLocalizedString(@"😃", nil);
            
            self.ref = [[FIRDatabase database] reference];
            
            
            
            NSString *userID = [FIRAuth auth].currentUser.uid;
            
            //NSLog(@"User Id %@",userID);
            
            [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                
                NSDictionary *dict = snapshot.value;
                
                NSString *sendMessages = [[NSString alloc]init];
                if(self.informSwitch.isOn)
                    sendMessages = @"YES";
                else
                    sendMessages = @"NO";
                
                
                NSArray * arr = [self.eMailguestList.text componentsSeparatedByString:@"\n"];
                int i =0;
                for(NSString *address in arr)
                {
                    
                    
                    
                    NSString *hostaddr = [[NSString alloc]init];
                    
                    if([[dict valueForKey:@"Address2"] length] > 0)
                    {
                        hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"Address2"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                    }
                    
                    else {
                        hostaddr = [NSString stringWithFormat:@"%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
                    }
                    
                    CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];
                    
                    
                    
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
                                           @"Invite For Date": startDateTime,
                                           @"Invite Valid Till Date": endDateTime,
                                           @"Invitation Status": @"Pending",
                                           @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                           @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                           @"Guest Location Status" : @"NOT_STARTED",
                                           @"Host Send Messages" : sendMessages,
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
                    
                    
                    i++;
                    
                    
                }// For loop ends
                
                
                
            }]; // DB Query ends
            
            while([rowValue length]== 0 && [senderName length] ==0 && [emailList count] == 0) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            
            if([emailList count] > 0) {
                
                // Email Subject
                NSString *emailTitle = @"Message From GuestVite";
                // Email Content
                NSString *messageBody = [NSString stringWithFormat:@"Hey!, This is %@ and you are invited at our place on %@, Please Login/Register to this cool App, <a href = '%@'> GuestVite </a> for more details, Thanks!",senderName,self.startTime,@"https://itunes.apple.com/us/app/guestvite/id1182204052?ls=1&mt=8"];
                
                // To address
                //NSArray *toRecipents = [NSArray arrayWithObject:self.guestEMailText.text];
                
                MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                mc.mailComposeDelegate = self;
                [mc setSubject:emailTitle];
                [mc setMessageBody:messageBody isHTML:YES];
                [mc setToRecipients:emailList];
                
                // Present mail view controller on screen
                [self presentViewController:mc animated:YES completion:NULL];
                
                
            }
            
            
        }// Main else ends
        
        
    }// Network connectivity else ends
}




- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
            
        case MessageComposeResultFailed:
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Failed to send SMS!"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self clearFields];
            }];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            
            break;
        }
            
        case MessageComposeResultSent: {
            [self clearFields];
            break;
        }
            
            
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
            [self clearFields];
            
            break;
        }
        case MFMailComposeResultFailed: {
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Failed to send E-Mail, please try again." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self clearFields];
            }];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}




@end
