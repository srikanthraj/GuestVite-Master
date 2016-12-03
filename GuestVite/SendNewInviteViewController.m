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
#import "HomePageViewController.h"
#import "MapKit/MapKit.h"
#import <MessageUI/MessageUI.h>
#import "Reachability.h"
#import "UIViewController+Reachability.m"
#import "CNPPopupController.h"

@import Firebase;

@interface SendNewInviteViewController () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIScrollViewDelegate,UITextViewDelegate,CNPPopupControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *guestNameText;
@property (weak, nonatomic) IBOutlet UITextField *guestEMailText;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UITextView *emailTextView;

@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;

@property (weak, nonatomic) IBOutlet UITextView *fNameTextView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *guestPhoneText;
@property (weak, nonatomic) IBOutlet UITextView *messageText;

@property (weak, nonatomic) IBOutlet UISwitch *informSwitch;

@property (weak, nonatomic) IBOutlet UIButton *sendInvite;
@property (weak, nonatomic) IBOutlet UIImageView *regView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerExpire;

@property (nonatomic, strong) CNPPopupController *popupController;

@property (weak, nonatomic) IBOutlet UINavigationBar *sendNewInviteBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;


@property (nonatomic, strong) UITextField *currentTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (nonatomic, strong) NSString *string;

@property (nonatomic, strong) NSString *startTime;

@property (nonatomic, strong) NSString *endTime;

@property (nonatomic, strong) NSString *currentTime;

@property (nonatomic, strong) NSString *currentTimeExpire;

@property (nonatomic) BOOL shouldKeyboardMoveUp;

@property (nonatomic) BOOL entryErrorFName;
@property (nonatomic) BOOL entryErrorEMail;
@property (nonatomic) BOOL entryErrorPhone;

@end

@implementation SendNewInviteViewController


//Test

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    
}

//Test Ends

-(void)viewDidAppear:(BOOL)animated {
    
    Reachability *kCFHostReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [kCFHostReachability currentReachabilityStatus];
   // NSLog(@"Netwrok Status %ld",(long)networkStatus);
    if (networkStatus == NotReachable) {
        
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"We are Sorry " attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
        
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

    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
   
    //Style the Send Invite Button
    
    self.sendInvite.layer.cornerRadius = 10.0;
    [[self.sendInvite layer] setBorderWidth:1.0f];
    [[self.sendInvite layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    // Set the Text Views
    
    self.fNameTextView.text = NSLocalizedString(@"😐", nil);
    self.fNameTextView.editable = NO;
    
    self.emailTextView.text = NSLocalizedString(@"😐", nil);
    self.emailTextView.editable = NO;
    
    self.phoneTextView.text = NSLocalizedString(@"😐", nil);
    self.phoneTextView.editable = NO;
    
    self.entryErrorFName = YES;
    self.entryErrorEMail = YES;
    self.entryErrorPhone = YES;
    
    
    [self.guestNameText addTarget:self action:@selector(firstNameTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.guestEMailText addTarget:self action:@selector(emailTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.guestPhoneText addTarget:self action:@selector(phoneTextChanged:) forControlEvents:UIControlEventEditingChanged];

    
    // Set the current date and time as date
    
    
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc] init];
    [currentDateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    NSString *currentTime = [currentDateFormatter stringFromDate:[NSDate date]];
    
    self.startTime = currentTime;
    //NSLog(@"Start Time on load %@", self.startTime);

    self.endTime = currentTime;
    
   // NSLog(@"End Time on load %@", self.endTime);
    
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_sendNewInviteBack];
    
    
    
    self.ref = [[FIRDatabase database] reference];
    
    //self.guestNameText.layer.backgroundColor = [UIColor colorWithRed:0.1 green:1.0 blue:0.1 alpha:0.1].CGColor;
    self.guestNameText.layer.cornerRadius = 10.0;
    self.guestNameText.layer.borderWidth = 1.0;
    
    self.guestEMailText.layer.cornerRadius = 10.0;
    self.guestEMailText.layer.borderWidth = 1.0;
    
    self.guestPhoneText.layer.cornerRadius = 10.0;
    self.guestPhoneText.layer.borderWidth = 1.0;
    
    
    self.messageText.text = @"Personalized Message";
    self.messageText.textColor = [UIColor lightGrayColor];
    self.messageText.layer.cornerRadius = 10.0;
    self.messageText.layer.borderWidth = 1.0;
    self.messageText.delegate = self;
    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    
    self.guestNameText.inputAccessoryView = keyboardDoneButtonView;
    self.guestEMailText.inputAccessoryView = keyboardDoneButtonView;
    self.guestPhoneText.inputAccessoryView = keyboardDoneButtonView;

    self.messageText.inputAccessoryView = keyboardDoneButtonView;
    
    
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



// Test-------------------------------


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
    
    
    if(self.messageText.isFirstResponder){
        buttonOrigin = self.messageText.frame.origin;
        
        buttonHeight = self.messageText.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }
    
    else if(self.guestPhoneText.isFirstResponder){
        buttonOrigin = self.guestPhoneText.frame.origin;
        
        buttonHeight = self.guestPhoneText.frame.size.height;
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
    
    
    if(self.shouldKeyboardMoveUp && self.messageText.isFirstResponder)
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


- (void)firstNameTextChanged:(UITextField *)sender
{
    
    if(sender.text.length > 0){
        self.fNameTextView.text = NSLocalizedString(@"😃", nil);
        self.guestNameText.backgroundColor = [UIColor whiteColor];
        self.entryErrorFName = NO;
       // NSLog(@"Error of First Name is %@",self.entryErrorFName ? @"YES" : @"NO");
    }
    
    
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.guestNameText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.fNameTextView.text = NSLocalizedString(@"😧", nil);
        self.fNameTextView.textColor = invalidRed;
        self.entryErrorFName = YES;
    }
    
    if(sender.text.length ==0) {
        
        self.guestNameText.backgroundColor = [UIColor whiteColor];
        self.fNameTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorFName = YES;
    }
    
    
    
    
}




- (void)emailTextChanged:(UITextField *)sender
{
    
    
    if([self validateEmailWithString:sender.text]){
        
        self.emailTextView.text = NSLocalizedString(@"😃", nil);
        self.guestEMailText.backgroundColor = [UIColor whiteColor];
        self.entryErrorEMail = NO;
        //NSLog(@"Error of E-Mail is %@",self.entryErrorEMail ? @"YES" : @"NO");
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.guestEMailText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.emailTextView.text = NSLocalizedString(@"😧", nil);
        self.emailTextView.textColor = invalidRed;
        self.entryErrorEMail = YES;
    }
    
    if(sender.text.length ==0) {
        
        self.guestEMailText.backgroundColor = [UIColor whiteColor];
        self.emailTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorEMail = YES;
    }
    
    
}


- (void)phoneTextChanged:(UITextField *)sender
{
    
    if([self validatePhoneWithString:sender.text] && [sender.text length] == 10){
        self.phoneTextView.text = NSLocalizedString(@"😃", nil);
        self.guestPhoneText.backgroundColor = [UIColor whiteColor];
        self.entryErrorPhone = NO;
       // NSLog(@"Error of Phone is %@",self.entryErrorPhone ? @"YES" : @"NO");
        
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.guestPhoneText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.phoneTextView.text = NSLocalizedString(@"😧", nil);
        self.phoneTextView.textColor = invalidRed;
        self.entryErrorPhone = YES;
    }
    
    if(sender.text.length ==0) {
        self.guestPhoneText.backgroundColor = [UIColor whiteColor];
        self.phoneTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorPhone = YES;
    }
    
    
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


// -------------------------------

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



- (void) textViewDidBeginEditing:(UITextView *) textView{
    
    if(self.messageText.isFirstResponder)
    {
        if([self.messageText.text isEqualToString:@"Personalized Message"]) {
            self.messageText.text = @"";
            self.messageText.textColor = [UIColor blackColor];
        }
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSUInteger len = textView.text.length;
    self.countLabel.text=[NSString stringWithFormat:@"%lu",100-(unsigned long)len];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return textView.text.length + (text.length - range.length) <= 100;
}

-(void) textViewDidChangeSelection:(UITextView *)textView
{
    if(!self.messageText.isFirstResponder)
    {
        if(self.messageText.text.length == 0){
            self.messageText.textColor = [UIColor lightGrayColor];
            self.messageText.text = @"Personalized Message";
            [self.messageText resignFirstResponder];
        }
    }

}



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


- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    
    // NSLog(@"RESULU is %@",result);
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



- (IBAction)sendInviteTapped:(id)sender {
    
   // Check Internet Connectivity
    
    Reachability *kCFHostReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [kCFHostReachability currentReachabilityStatus];
    //NSLog(@"Netwrok Status %ld",(long)networkStatus);
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

    else{
     // Get the invite Row
    __block NSMutableString *rowValue = [[NSMutableString alloc] init];
    
    __block NSMutableString *senderName = [[NSMutableString alloc] init];
    
    __block NSString *startDateTime  = [[NSString alloc] init];
    
    __block NSString *endDateTime = [[NSString alloc] init];
    
    
        //NSLog(@"Send Invite Tapped start datetime %@",self.startTime);
       // NSLog(@"Send Invite Tapped end datetime %@",self.endTime);
        
        startDateTime = self.startTime;
        endDateTime = self.endTime;
        
    
    
    NSDate *fromDate = [self dateToFormatedDate:startDateTime];
    
    NSDate *toDate = [self dateToFormatedDate:endDateTime];
    
    
    //NSLog(@"FROM DATE %@",fromDate);
    
   //NSLog(@"TILL DATE %@",toDate);

    // 4 conditions to be checked
        /*
         
         1. If( Error in fields and From Date > To Date)
         2. Else If (Error in Fields)
         3. Else If (From date > To Date)
         4. Else - Go Ahead and Add in DB
         
         */

        
        
        //1. If( Error in fields and From Date > To Date)
        
        
    if(([self entryErrorFName] || [self entryErrorEMail] || [self entryErrorPhone]) && !([fromDate compare:toDate] == NSOrderedAscending)) {
        
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"%@\n\n%@",@"Please check your input fields",@"From Date cannot be later than Till Date"]preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
        
        
   // 2. Else If (Error in Fields)
   
    else if([self entryErrorFName] || ([self entryErrorEMail] && [self entryErrorPhone])) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Please check your input fields"preferredStyle:UIAlertControllerStyleAlert];
        
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
        
            
        self.ref = [[FIRDatabase database] reference];
        
    

        NSString *userID = [FIRAuth auth].currentUser.uid;
        
       // NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
        
            NSArray * arr = [self.guestNameText.text componentsSeparatedByString:@" "];
            
            NSString *hostaddr = [[NSString alloc]init];
            NSString *sendMessages = [[NSString alloc]init];
            if(self.informSwitch.isOn)
                sendMessages = @"YES";
            else
                sendMessages = @"NO";
            
            NSDictionary *post = [[NSDictionary alloc] init];
            
            if([[dict valueForKey:@"Address2"] length] > 0)
            {
            hostaddr = [NSString stringWithFormat:@"%@,%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"Address2"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
            }
            
            else {
                hostaddr = [NSString stringWithFormat:@"%@,%@,%@",[dict valueForKey:@"Address1"],[dict valueForKey:@"City"],[dict valueForKey:@"Zip"]];
            }
            
            CLLocationCoordinate2D dest = [self geoCodeUsingAddress:hostaddr];
            //NSLog(@"Guest Name is %@",self.guestNameText.text);
            //NSLog(@"ARR is %@",arr);
           // NSLog(@"Name field Length is %lu",(unsigned long)[arr count]);
    
            if([arr count] > 1) // If Last Name present
                {
                            post = @{@"Sender First Name": [dict valueForKey:@"First Name"],
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
                                   @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                   @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                   @"Guest Location Status" : @"NOT_STARTED",
                                   @"Host Send Messages" : sendMessages,
                                   };
            
                }
                
            else if([arr count] == 1 && ![[arr objectAtIndex:0]isEqualToString:@""]){ // No last Name
                
                
                                post = @{@"Sender First Name": [dict valueForKey:@"First Name"],
                                       @"Sender Last Name": [dict valueForKey:@"Last Name"],
                                       @"Sender EMail": [dict valueForKey:@"EMail"],
                                       @"Sender Address1": [dict valueForKey:@"Address1"],
                                       @"Sender Address2": [dict valueForKey:@"Address2"],
                                       @"Sender City": [dict valueForKey:@"City"],
                                       @"Sender Zip": [dict valueForKey:@"Zip"],
                                       @"Sender Phone": [dict valueForKey:@"Phone"],
                                       @"Mesage From Sender": self.messageText.text,
                                       @"Receiver First Name": [arr objectAtIndex:0],
                                       @"Receiver Last Name": @"",
                                       @"Receiver EMail": self.guestEMailText.text,
                                       @"Receiver Phone": self.guestPhoneText.text,
                                       @"Invite For Date": startDateTime,
                                       @"Invite Valid Till Date": endDateTime,
                                       @"Invitation Status": @"Pending",
                                       @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                       @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                       @"Guest Location Status" : @"NOT_STARTED",
                                       @"Host Send Messages" : sendMessages,
                                       };

            }
            
            else {
                
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Name of the Guest is needed" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [ac addAction:aa];
                [self presentViewController:ac animated:YES completion:nil];
            }
           
            
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
       
        
        NSString *message = [NSString stringWithFormat:@"Hey! %@ , You are invited by %@ at their place on %@ , Please login/Register to GuestVite App for more Details ,Thanks!",self.guestNameText.text,senderName,self.startTime];
        
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
            NSString *messageBody = [NSString stringWithFormat:@"Hey! %@ , This is %@  and I want to invite you at my place on %@ , please login to this new cool App GuestVite! for all further details, Thanks and looking forward to see you soon!",self.guestNameText.text,senderName,self.startTime];
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
        
        
    }// Main else ends
        
    }// Network connectivity else ends
    
    
}




-(void) clearFields {
self.guestNameText.text = @"";
self.guestEMailText.text = @"";
self.guestPhoneText.text = @"";
self.messageText.text = @"Personalized Message";
self.messageText.textColor = [UIColor lightGrayColor];
self.countLabel.text = @"100";
    self.informSwitch.on = YES;
    
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
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent: {
                
                [self clearFields];
            
       
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
