//
//  SendAddressBookInviteViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-20.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SendAddressBookInviteViewController.h"
#import <MessageUI/MessageUI.h>
#import "SendBulkInviteViewController.h"
#import "SendNewInviteViewController.h"
#import "HomePageViewController.h"
#import "MapKit/MapKit.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "KBContactsSelectionViewController.h"

#import <ContactsUI/ContactsUI.h>
#import "SACalendar.h"

@import Firebase;

@interface SendAddressBookInviteViewController () <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UITextViewDelegate, CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate,SACalendarDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextView *eMailguestList;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (weak, nonatomic) IBOutlet UITextField *inviteForDateText;
@property (weak, nonatomic) IBOutlet UITextField *inviteExpireDateText;
@property (weak, nonatomic) IBOutlet UITextView *inviteMessage;

@property (weak, nonatomic) IBOutlet UITextView *smsGuestList;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UIButton *addressBookButton;

@property (nonatomic, strong) NSMutableArray *arrContactsData;

@property (nonatomic, strong) NSMutableArray *emailContactsData;

@property (nonatomic, strong) NSMutableArray *firstNameEmailContactsData;
@property (nonatomic, strong) NSMutableArray *lastNameEmailContactsData;

@property (nonatomic, strong) NSMutableArray *phoneContactsData;

@property (nonatomic, strong) NSMutableArray *firstNamePhoneContactsData;
@property (nonatomic, strong) NSMutableArray *lastNamePhoneContactsData;

@property (nonatomic, strong) NSDictionary *dictContactDetails;


@property (weak, nonatomic) IBOutlet UINavigationBar *sendAddressBookInviteBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UILabel *backLabel;


@property (nonatomic, strong) UITextField *currentTextField;

@property (nonatomic, strong) NSString *string;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerExpire;


@property (nonatomic, strong) NSString *startTime;

@property (nonatomic, strong) NSString *endTime;





@property BOOL  isCalanderRemoved;

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
-(void)showAddressBook;

-(void)populateContactData;

-(void)selectContactData;

@end

@implementation SendAddressBookInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
   //[self loadPhoneContacts];
    
    
    
    // Do any additional setup after loading the view from its nib.
    
    // Set the current date and time as date
    
    
    NSDateFormatter *currentDateFormatter = [[NSDateFormatter alloc] init];
    [currentDateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [currentDateFormatter stringFromDate:[NSDate date]];
    
    self.startTime = currentTime;
    NSLog(@"Start Time on load %@", self.startTime);
    
    self.endTime = currentTime;
    
    NSLog(@"End Time on load %@", self.endTime);
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_sendAddressBookInviteBack];

    
    
    
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
    
    
    self.inviteMessage.text = @"Personalized Message";
    self.inviteMessage.textColor = [UIColor lightGrayColor];
    self.inviteMessage.layer.cornerRadius = 10.0;
    self.inviteMessage.layer.borderWidth = 1.0;
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    
    self.eMailguestList.inputAccessoryView = keyboardDoneButtonView;
    self.smsGuestList.inputAccessoryView = keyboardDoneButtonView;
   // self.inviteForDateText.inputAccessoryView = keyboardDoneButtonView;
    self.inviteExpireDateText.inputAccessoryView = keyboardDoneButtonView;
    self.inviteMessage.inputAccessoryView = keyboardDoneButtonView;
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    self.phoneContactsData = [[NSMutableArray alloc]init];
    self.emailContactsData = [[NSMutableArray alloc]init];
    self.firstNamePhoneContactsData = [[NSMutableArray alloc]init];
    self.lastNamePhoneContactsData = [[NSMutableArray alloc]init];
    self.firstNameEmailContactsData = [[NSMutableArray alloc]init];
    self.lastNameEmailContactsData = [[NSMutableArray alloc]init];
    
    
    self.datePicker.frame = CGRectMake(40, 70, 300, 50); // set frame as your need

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


- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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



- (void)dateChanged:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePicker.date];
    //NSLog(@"Time For %@", currentTime);
    self.startTime = currentTime;
}

- (void)dateChangedExpire:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:self.datePickerExpire.date];
   // NSLog(@"Time Expire%@", currentTime);
    self.endTime = currentTime;
}


-(void)doneClicked:(id)sender
{
    //NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}

-(void)peoplePickerNavigationControllerDidCancel:(CNContactPickerViewController *)peoplePicker{
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editBegin:(id)sender {
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



/*
-(void)selectDateButtonPressed:(id)sender
{
    
    [self.view removeFromSuperview];
}
*/

-(void)peoplePickerNavigationController:(CNContactPickerViewController *)peoplePicker didSelectPerson:(ABRecordRef)person{
    
    
    
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"",@"", @"",@""]
                                            forKeys:@[@"firstName", @"lastName",@"mobileNumber", @"homeNumber",@"EMail"]];
    
    CFTypeRef generalCFObject;
    
    //Get First name
    
    generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    //Get Last Name
    
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    
    //Phone
    
    
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for (int i=0; i<ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        if(currentPhoneLabel)
        {
        CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue)
        {
            CFRelease(currentPhoneValue);
        }
    }
    if(phonesRef)
    {
    CFRelease(phonesRef);
    }
    
    //E-Mails
    
    ABMultiValueRef emailsRef = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    NSMutableArray *allEmails = [[NSMutableArray alloc] init];
    
    for (int i=0; i<ABMultiValueGetCount(emailsRef); i++) {
       // CFStringRef currentEmailLabel = ABMultiValueCopyLabelAtIndex(emailsRef, i);
       // CFStringRef currentEmailValue = ABMultiValueCopyValueAtIndex(emailsRef, i);
        
        //NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailsRef, i);
        [contactInfoDict setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(emailsRef, i) forKey:@"EMail"];
        //[email release];
    }
    
   // NSLog(@"ALL EMAILS %@",allEmails);
    if(emailsRef)
    {
    CFRelease(emailsRef);
    }
    
    
    
    
    if (_arrContactsData == nil) {
        _arrContactsData = [[NSMutableArray alloc] init];
    }
    [_arrContactsData addObject:contactInfoDict];
    
    
    //[self.tableView reloadData];
    
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
    
    
    
    NSString *tempo = [[NSString alloc]init];
    
    NSString *tempoEMail = [[NSString alloc]init];
    
    
    if(([[contactInfoDict objectForKey:@"mobileNumber"] length] !=0))
    {
        
        //Below Code Login to Remove the Extra Space When Last Name is not present
        if([[contactInfoDict objectForKey:@"lastName"] length] > 0) {
        tempo = [NSString stringWithFormat:@"%@ %@: %@",[contactInfoDict objectForKey:@"firstName"],[contactInfoDict objectForKey:@"lastName"],[contactInfoDict objectForKey:@"mobileNumber"]];
            [self.lastNamePhoneContactsData addObject:[contactInfoDict objectForKey:@"lastName"]];
        }
        
        else {
            tempo = [NSString stringWithFormat:@"%@: %@",[contactInfoDict objectForKey:@"firstName"],[contactInfoDict objectForKey:@"mobileNumber"]];
            
            [self.lastNamePhoneContactsData addObject:@"Not Specified"];
        }
        
        [self.firstNamePhoneContactsData addObject:[contactInfoDict objectForKey:@"firstName"]];
        [self.phoneContactsData addObject:[contactInfoDict objectForKey:@"mobileNumber"]];
    
        //NSLog(@"PHONE CONTACTS DATA %@",[contactInfoDict objectForKey:@"mobileNumber"]);
    if([self.smsGuestList.text isEqualToString:@"Enter Phone Numbers here"]){
        self.smsGuestList.text = [tempo stringByAppendingString:@"\n"];
        
    }
    
    else {
        
        //NSLog(@"PHONE CONTACTS DATA %@",[contactInfoDict objectForKey:@"mobileNumber"]);
        
        self.smsGuestList.text = [self.smsGuestList.text stringByAppendingString:[tempo stringByAppendingString:@"\n"]];
    }
    
    }
    
    // Take Home Number If Mobile Number is Not there
    
    else if(([[contactInfoDict objectForKey:@"homeNumber"] length] !=0))
    {
        //Below Code Login to Remove the Extra Space When Last Name is not present
        if([[contactInfoDict objectForKey:@"lastName"] length] > 0) {
        tempo = [NSString stringWithFormat:@"%@ %@: %@",[contactInfoDict objectForKey:@"firstName"],[contactInfoDict objectForKey:@"lastName"],[contactInfoDict objectForKey:@"homeNumber"]];
            
            [self.lastNamePhoneContactsData addObject:[contactInfoDict objectForKey:@"lastName"]];
            
        }
        
        else {
            tempo = [NSString stringWithFormat:@"%@: %@",[contactInfoDict objectForKey:@"firstName"],[contactInfoDict objectForKey:@"homeNumber"]];
            
            [self.lastNamePhoneContactsData addObject:@"Not Specified"];
        }
        
        [self.firstNamePhoneContactsData addObject:[contactInfoDict objectForKey:@"firstName"]];
        [self.phoneContactsData addObject:[contactInfoDict objectForKey:@"homeNumber"]];
        
        //NSLog(@"PHONE CONTACTS DATA %@",[contactInfoDict objectForKey:@"homeNumber"]);
        if([self.smsGuestList.text isEqualToString:@"Enter Phone Numbers here"]){
            self.smsGuestList.text = [tempo stringByAppendingString:@"\n"];
            
        }
        
        else {
            
            //NSLog(@"PHONE CONTACTS DATA %@",[contactInfoDict objectForKey:@"homeNumber"]);
            
            self.smsGuestList.text = [self.smsGuestList.text stringByAppendingString:[tempo stringByAppendingString:@"\n"]];
        }
        
    }
    
    
    // Check for E-Mail
    
    if([[contactInfoDict objectForKey:@"EMail"] length] !=0)
    {
        
        //Below Code Login to Remove the Extra Space When Last Name is not present
        if([[contactInfoDict objectForKey:@"lastName"] length] > 0) {
        tempoEMail = [NSString stringWithFormat:@"%@ %@: %@",[contactInfoDict objectForKey:@"firstName"],[contactInfoDict objectForKey:@"lastName"],[contactInfoDict objectForKey:@"EMail"]];
            
            [self.lastNameEmailContactsData addObject:[contactInfoDict objectForKey:@"lastName"]];
        }
        
        else {
            tempoEMail = [NSString stringWithFormat:@"%@: %@",[contactInfoDict objectForKey:@"firstName"],[contactInfoDict objectForKey:@"EMail"]];
            [self.lastNameEmailContactsData addObject:@"Not Specified"];
        }
        
        [self.firstNameEmailContactsData addObject:[contactInfoDict objectForKey:@"firstName"]];
        [self.emailContactsData addObject:[contactInfoDict objectForKey:@"EMail"]];
        
        
        //NSLog(@"EMAIL CONTACTS DATA %@",[contactInfoDict objectForKey:@"EMail"]);
    
    if([self.eMailguestList.text isEqualToString:@"Enter Email Addressses here"]){
        self.eMailguestList.text = [tempoEMail stringByAppendingString:@"\n"];
        
    }
    
    else {
        
        //NSLog(@"EMAIL CONTACTS DATA %@",[contactInfoDict objectForKey:@"EMail"]);
        
        self.eMailguestList.text = [self.eMailguestList.text stringByAppendingString:[tempoEMail stringByAppendingString:@"\n"]];
    }

    }

     
    //NSLog(@"Inside!!!");
    //return NO;
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

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


-(void)showAddressBook{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}


-(void)populateContactData{
    NSString *contactFullName = [NSString stringWithFormat:@"%@ %@", [_dictContactDetails objectForKey:@"firstName"], [_dictContactDetails objectForKey:@"lastName"]];
    
    //[self.eMailguestList setText:contactFullName];
    
}

-(void)selectContactData {

    CNContactPickerViewController * picker = [[CNContactPickerViewController alloc] init];
    
    picker.delegate = self;
    picker.displayedPropertyKeys = (NSArray *)CNContactGivenNameKey;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *test = contact.givenName;
    //NSLog(@"NAME IS  %@",test);
}

- (IBAction)addressButtonTapped:(id)sender {
    
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        [self showAddressBook];
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        NSLog(@"Not determined");
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4
                NSLog(@"Just denied");
                UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [cantAddContactAlert show];
                return;
            }
            else{
            //5
            NSLog(@"Just authorized");
                [self showAddressBook];
            }
        });
        
    }
    
    
    //[self selectContactData];
    
    //[self populateContactData];
    
    
    
}

- (IBAction)segmentTapped:(id)sender {
    
    if(self.segmentControl.selectedSegmentIndex ==0){
        
        
        SendNewInviteViewController *sendNewVC =
        [[SendNewInviteViewController alloc] initWithNibName:@"SendNewInviteViewController" bundle:nil];
        
        //hPViewController.userName  = eMailEntered;
        [self.navigationController pushViewController:sendNewVC animated:YES];
        
        [self presentViewController:sendNewVC animated:YES completion:nil];
    }
    
    if(self.segmentControl.selectedSegmentIndex ==1){
        
        
        SendBulkInviteViewController *sendBulkVC =
        [[SendBulkInviteViewController alloc] initWithNibName:@"SendBulkInviteViewController" bundle:nil];
        
        //hPViewController.userName  = eMailEntered;
        [self.navigationController pushViewController:sendBulkVC animated:YES];
        
        [self presentViewController:sendBulkVC animated:YES completion:nil];
    }
    
    
    
}

/*
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(self.inviteForDateText.isFirstResponder) {
        if(self.isCalanderRemoved){
        NSLog(@"Invite For Date");
        NSLog(@"String is %@",self.string);
        self.inviteForDateText.text = self.string;
        }
    }
    
    if(self.inviteExpireDateText.isFirstResponder) {
        if(self.isCalanderRemoved){
        NSLog(@"Invite End Date");
            NSLog(@"String is %@",self.string);
        self.inviteExpireDateText.text = self.string;
        }
    }

}

 */
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


- (IBAction)sendSMSTapped:(id)sender {
    
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
    
    //NSLog(@"FROM DATE %@",fromDate);
    
    //NSLog(@"TO DATE %@",toDate);
    
    //NSLog(@"SMS LIST %@", self.phoneContactsData);
    
    
   
   // NSComparisonResult result = [fromDate compare:toDate];
    
    if([self.phoneContactsData count] ==0) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"At Least One Guest Info is required"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    /*
    else if(result != NSOrderedDescending) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"To Date cannot be earlier than FROM Date"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
*/
    else{
        
        if([fromDate compare:toDate] == NSOrderedAscending) // ONLY if from is earlier
        {
        
        self.ref = [[FIRDatabase database] reference];
        
        
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        //NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;
            for(NSString *address in self.phoneContactsData){
                
                //NSLog(@"PRINTING Phone contacts Data %@", address);
                
                NSString *lastNameTemp = [[NSString alloc]init];
                NSString *phoneTemp = [[NSString alloc]init];
                
                NSLog(@"Phone Data First Name %@",[self.firstNamePhoneContactsData objectAtIndex:[self.phoneContactsData indexOfObject:address]]);
                
                if(![[self.lastNamePhoneContactsData objectAtIndex:[self.phoneContactsData indexOfObject:address]] isEqualToString:@"Not Specified"]){
                    
                    lastNameTemp = [self.lastNamePhoneContactsData objectAtIndex:[self.phoneContactsData indexOfObject:address]];
                }
                
                else {
                    lastNameTemp = @"BULK";
                }
                
                
                phoneTemp = [[address componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
                
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
                                       @"Receiver First Name": [self.firstNamePhoneContactsData objectAtIndex:[self.phoneContactsData indexOfObject:address]],
                                       
                                       @"Receiver Last Name": lastNameTemp,
                                       
                                       @"Receiver EMail": @"BULK",
                                       @"Receiver Phone": [phoneTemp substringFromIndex:[phoneTemp length]-10],
                                       @"Invite For Date": startDateTime,
                                       @"Invite Valid Till Date": endDateTime,
                                       @"Invitation Status": @"Pending",
                                       @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                       @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                       @"Guest Location Status" : @"NOT_STARTED",
                                       };//Dict post
                
                
                NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
                NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
                NSRange range = [intervalString rangeOfString:@"."];
                NSString *primarykey = [intervalString substringToIndex:range.location];
                NSString *pkey1 = [userID stringByAppendingString:primarykey];
                
                NSString *pkey2 = [pkey1 stringByAppendingString:@"_"] ;
                
                NSString *pKey = [pkey2 stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[self.phoneContactsData indexOfObject:address]]];
                
                [rowValue setString:pKey];
                [senderName setString:[dict valueForKey:@"First Name"]];
                [senderName appendString:@" "];
                [senderName appendString:[dict valueForKey:@"Last Name"]];
                NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", pKey]: post};
                [_ref updateChildValues:childUpdates];
                
                
            }
        }];
        
        while([rowValue length]== 0 && [senderName length] ==0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your Device Does not support SMS" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
            return;
        }
        
        NSString *message = [NSString stringWithFormat:@"Hey!, You are invited by %@ as a guest on %@ at %@, Please login/Register to GuestVite App for more Details ,Thanks!",senderName,self.inviteForDateText.text,self.startTime];
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:self.phoneContactsData];
        [messageController setBody:message];
        
        
        [self presentViewController:messageController animated:YES completion:nil];


    }
        else {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"From Date cannot be later than To Date"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
        }//Main else ends
    
    
    
}

- (IBAction)sendEMailTapped:(id)sender {
    
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

    
    //NSLog(@"E- Mail LIST %@", self.emailContactsData);
    
    if([self.emailContactsData count] ==0) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"At Least One Guest Info is required"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
    }
    
    
    else{
        
        if([fromDate compare:toDate] == NSOrderedAscending) // ONLY if from is earlier
        {

        self.ref = [[FIRDatabase database] reference];
        
        
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        //NSLog(@"User Id %@",userID);
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *dict = snapshot.value;

            for(NSString *address in self.emailContactsData){
                
                
                NSString *lastNameTemp = [[NSString alloc]init];
                
                NSLog(@"EMail Data First Name %@",[self.firstNameEmailContactsData objectAtIndex:[self.emailContactsData indexOfObject:address]]);
                
                if(![[self.lastNameEmailContactsData objectAtIndex:[self.emailContactsData indexOfObject:address]] isEqualToString:@"Not Specified"]){
                    
                    lastNameTemp = [self.lastNameEmailContactsData objectAtIndex:[self.emailContactsData indexOfObject:address]];
                }
                
                else {
                    lastNameTemp = @"BULK";
                }

                
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
                                       @"Receiver First Name": [self.firstNameEmailContactsData objectAtIndex:[self.emailContactsData indexOfObject:address]],
                                       @"Receiver Last Name": lastNameTemp,
                                       @"Receiver EMail": address,
                                       @"Receiver Phone": @"BULK",
                                       @"Invite For Date": startDateTime,
                                       @"Invite Valid Till Date": endDateTime,
                                       @"Invitation Status": @"Pending",
                                       @"Host Latitude": [NSNumber numberWithFloat:dest.latitude],
                                       @"Host Longitude": [NSNumber numberWithFloat:dest.longitude],
                                       @"Guest Location Status" : @"NOT_STARTED",
                                       };
                NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
                NSString *intervalString = [NSString stringWithFormat:@"%f", timeInSeconds];
                NSRange range = [intervalString rangeOfString:@"."];
                NSString *primarykey = [intervalString substringToIndex:range.location];
                
                NSString *pkey1 = [userID stringByAppendingString:primarykey];
                
                NSString *pkey2 = [pkey1 stringByAppendingString:@"_"] ;
                
                NSString *pKey = [pkey2 stringByAppendingString:[NSString stringWithFormat:@"%lu",(unsigned long)[self.emailContactsData indexOfObject:address]]];
                
                
                [rowValue setString:pKey];
                [senderName setString:[dict valueForKey:@"First Name"]];
                [senderName appendString:@" "];
                [senderName appendString:[dict valueForKey:@"Last Name"]];
                NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/invites/%@/", pKey]: post};
                [_ref updateChildValues:childUpdates];
                
                
            }

            
            
            
        }];
        
        while([rowValue length]== 0 && [senderName length] ==0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        
        // Email Subject
        NSString *emailTitle = @"Message From GeuestVite";
        // Email Content
        NSString *messageBody = [NSString stringWithFormat:@"Hey!, This is %@  and I want to invite you at my place on %@ at %@ , please login to this new cool App GuestVite! for all further details, Thanks and looking forward to see you soon!",senderName,self.inviteForDateText.text,self.startTime];
        // To address
        //NSArray *toRecipents = [NSArray arrayWithObject:self.guestEMailText.text];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:self.emailContactsData];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
        
            
        }
        else {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"From Date cannot be later than To Date"preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [ac addAction:aa];
            [self presentViewController:ac animated:YES completion:nil];
        }
        
        
        }// Main else ends
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
