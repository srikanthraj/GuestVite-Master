//
//  UpdateInfoViewController.m
//  GuestVite
//
//  Created by admin on 2016-11-17.
//  Copyright © 2016 admin. All rights reserved.
//

#import "UpdateInfoViewController.h"
#import "HomePageViewController.h"
#import "CNPPopupController.h"
#import "Reachability.h"
#import "UIViewController+Reachability.m"
@import Firebase;

@interface UpdateInfoViewController ()<UIScrollViewDelegate,UITextFieldDelegate,CNPPopupControllerDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UITextField *addrLine1Field;

@property (strong, nonatomic) IBOutlet UITextField *addrLine2Field;
@property (strong, nonatomic) IBOutlet UITextField *cityField;
@property (strong, nonatomic) IBOutlet UITextField *zipField;

@property (strong, nonatomic) IBOutlet UILabel *resultField;
@property (weak, nonatomic) IBOutlet UINavigationBar *updateInfoBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (nonatomic, strong) CNPPopupController *popupController;

@property (nonatomic) BOOL shouldKeyboardMoveUp;

@property (nonatomic) BOOL entryErrorName;
@property (nonatomic) BOOL entryErrorPhone;
@property (nonatomic) BOOL entryErrorAdd1;
@property (nonatomic) BOOL entryErrorCity;
@property (nonatomic) BOOL entryErrorZip;


//Text Views

@property (weak, nonatomic) IBOutlet UITextView *nameTextView;


@property (weak, nonatomic) IBOutlet UITextView *addr1TextView;
@property (weak, nonatomic) IBOutlet UITextView *addr2TextView;
@property (weak, nonatomic) IBOutlet UITextView *cityTextView;
@property (weak, nonatomic) IBOutlet UITextView *zipTextView;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;

@end

@implementation UpdateInfoViewController

NSMutableString *name;
NSMutableString *email;
NSMutableString *phone;
NSMutableString *addr1;
NSMutableString *addr2;
NSMutableString *city;
NSMutableString *zip;


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Style the Update Button
    
    self.updateButton.layer.cornerRadius = 10.0;
    [[self.updateButton layer] setBorderWidth:1.0f];
    [[self.updateButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    //Initialize Text Views
    
    self.nameTextView.text = NSLocalizedString(@"😃", nil);
    self.addr1TextView.text = NSLocalizedString(@"😃", nil);
   
    
    self.cityTextView.text = NSLocalizedString(@"😃", nil);
    self.zipTextView.text = NSLocalizedString(@"😃", nil);
    self.phoneTextView.text = NSLocalizedString(@"😃", nil);
    
    self.nameTextView.editable = NO;
    self.addr1TextView.editable = NO;
    self.addr2TextView.editable = NO;
    self.cityTextView.editable = NO;
    self.zipTextView.editable = NO;
    self.phoneTextView.editable = NO;
    
    self.entryErrorName = NO;
    self.entryErrorAdd1 = NO;
    self.entryErrorCity = NO;
    self.entryErrorZip = NO;
    self.entryErrorPhone = NO;
    
    [self.nameField addTarget:self action:@selector(nameTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.cityField addTarget:self action:@selector(cityTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    [self.zipField addTarget:self action:@selector(zipTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.phoneField addTarget:self action:@selector(phoneTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    [self.addrLine1Field addTarget:self action:@selector(addr1TextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.addrLine2Field addTarget:self action:@selector(addr2TextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    
    self.resultField.hidden = YES;
    name = [[NSMutableString alloc]init];
    email = [[NSMutableString alloc]init];
    phone = [[NSMutableString alloc]init];
    addr1 = [[NSMutableString alloc]init];
    addr2 = [[NSMutableString alloc]init];
    city = [[NSMutableString alloc]init];
    zip  = [[NSMutableString alloc]init];
    
    __block NSMutableString *myFName = [[NSMutableString alloc]init];
    __block NSMutableString *myLName = [[NSMutableString alloc]init];
    __block NSMutableString *myEmail = [[NSMutableString alloc]init];
    __block NSMutableString *myPhone = [[NSMutableString alloc]init];
    __block NSMutableString *myAddr1 = [[NSMutableString alloc]init];
    __block NSMutableString *myAddr2 = [[NSMutableString alloc]init];
    __block NSMutableString *myCity = [[NSMutableString alloc]init];
    __block NSMutableString *myZip = [[NSMutableString alloc]init];
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_updateInfoBack];

    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    self.emailField.inputAccessoryView = keyboardDoneButtonView;
    self.nameField.inputAccessoryView = keyboardDoneButtonView;
    self.phoneField.inputAccessoryView = keyboardDoneButtonView;
    self.addrLine1Field.inputAccessoryView = keyboardDoneButtonView;
    self.addrLine2Field.inputAccessoryView = keyboardDoneButtonView;
    self.cityField.inputAccessoryView = keyboardDoneButtonView;
    self.zipField.inputAccessoryView = keyboardDoneButtonView;
    
    //Get the user Info
    
    self.ref = [[FIRDatabase database] reference];
    
     NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
         NSDictionary *dict = snapshot.value;
            myFName = [dict valueForKey:@"First Name"];
            myLName = [dict valueForKey:@"Last Name"];
            myEmail = [dict valueForKey:@"EMail"];
            myPhone = [dict valueForKey:@"Phone"];
            myAddr1 = [dict valueForKey:@"Address1"];
            myAddr2 = [dict valueForKey:@"Address2"];
            myCity = [dict valueForKey:@"City"];
            myZip = [dict valueForKey:@"Zip"];
    }];
    
    while([myFName length] ==0 && [myLName length] ==0 && [myEmail length] ==0 && [myPhone length] ==0 && [myAddr1 length] ==0 && [myAddr2 length] ==0 && [myCity length] ==0 && [myZip length] ==0) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        
    }
    
    [name setString:[NSString stringWithFormat:@"%@ %@",myFName,myLName]];
    [email setString:myEmail];
    [phone setString:myPhone];
    [addr1 setString:myAddr1];
    [addr2 setString:myAddr2];
    [city setString:myCity];
    [zip setString:myZip];
    
    // Setting the labels
    
    self.emailField.text = email;
    self.emailField.enabled = NO;
    self.nameField.text = name;
    self.phoneField.text = phone;
    self.addrLine1Field.text = addr1;
    self.addrLine2Field.text = addr2;
    self.cityField.text = city;
    self.zipField.text = zip;
    
    // Set Smiley in Address 2 Field accordingly
    if([self.addrLine2Field.text length] > 0)
        self.addr2TextView.text = NSLocalizedString(@"😃", nil);
    else
        self.addr2TextView.text = NSLocalizedString(@"😐", nil);
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
}



- (void)loadingNextView{
    
    
    HomePageViewController *homePageVC =
    [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
    
    [self.navigationController pushViewController:homePageVC animated:YES];
    
    [self presentViewController:homePageVC animated:YES completion:nil];
    
    
    
}



// Test


- (void)nameTextChanged:(UITextField *)sender
{
    
    if(sender.text.length > 0){
        self.nameTextView.text = NSLocalizedString(@"😃", nil);
        self.nameField.backgroundColor = [UIColor whiteColor];
        self.entryErrorName = NO;
        NSLog(@"Error of First Name is %@",self.entryErrorName ? @"YES" : @"NO");
    }
    
    
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.nameField.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.nameTextView.text = NSLocalizedString(@"😧", nil);
        self.nameTextView.textColor = invalidRed;
        self.entryErrorName = YES;
    }
    
    if(sender.text.length ==0) {
        self.nameField.backgroundColor = [UIColor whiteColor];
        self.nameTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorName = YES;
    }

    
}



- (void)cityTextChanged:(UITextField *)sender
{
    
    if([self validateCityWithString:sender.text]){
        self.cityTextView.text = NSLocalizedString(@"😃", nil);
        self.cityField.backgroundColor = [UIColor whiteColor];
        self.entryErrorCity = NO;
        NSLog(@"Error of City is %@",self.entryErrorCity ? @"YES" : @"NO");
        
    }
    
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.cityField.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.cityTextView.text = NSLocalizedString(@"😧", nil);
        self.cityTextView.textColor = invalidRed;
        self.entryErrorCity = YES;
    }
    
    if(sender.text.length ==0) {
        self.cityField.backgroundColor = [UIColor whiteColor];
        self.cityTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorCity = YES;
    }
    
}


- (void)zipTextChanged:(UITextField *)sender
{
    
    if([self validateZipPhoneWithString:sender.text]){
        
        self.zipTextView.text = NSLocalizedString(@"😃", nil);
        self.zipField.backgroundColor = [UIColor whiteColor];
        self.entryErrorZip = NO;
        NSLog(@"Error of Zip is %@",self.entryErrorZip ? @"YES" : @"NO");
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.zipField.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.zipTextView.text = NSLocalizedString(@"😧", nil);
        self.zipTextView.textColor = invalidRed;
        self.entryErrorZip = YES;
    }
    
    if(sender.text.length ==0) {
        self.zipField.backgroundColor = [UIColor whiteColor];
        self.zipTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorZip = YES;
    }
    
}

- (void)phoneTextChanged:(UITextField *)sender
{
    
    if([self validateZipPhoneWithString:sender.text] && [sender.text length] == 10){
        self.phoneTextView.text = NSLocalizedString(@"😃", nil);
        self.phoneField.backgroundColor = [UIColor whiteColor];
        self.entryErrorPhone = NO;
        NSLog(@"Error of Phone is %@",self.entryErrorPhone ? @"YES" : @"NO");
        
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.phoneField.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.phoneTextView.text = NSLocalizedString(@"😧", nil);
        self.phoneTextView.textColor = invalidRed;
        self.entryErrorPhone = YES;
    }
    
    if(sender.text.length ==0) {
        self.phoneField.backgroundColor = [UIColor whiteColor];
        self.phoneTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorPhone = YES;
    }
    
    
}



- (void)addr1TextChanged:(UITextField *)sender
{
    if([sender.text length] > 4){
        self.addr1TextView.text = NSLocalizedString(@"😃", nil);
        self.entryErrorAdd1 = NO;
        NSLog(@"Error of Address Line 1 is %@",self.entryErrorAdd1 ? @"YES" : @"NO");
    }
    if(sender.text.length ==0) {
        self.addrLine1Field.backgroundColor = [UIColor whiteColor];
        self.addr1TextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorAdd1 = YES;
    }
}



- (void)addr2TextChanged:(UITextField *)sender
{
    if([sender.text length] > 0)
        self.addr2TextView.text = NSLocalizedString(@"😃", nil);
    else
       self.addr2TextView.text = NSLocalizedString(@"😐", nil);
}


// Validators
- (BOOL)validateZipPhoneWithString:(NSString*)checkString

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

-(BOOL)validateCityWithString:(NSString*)checkString
{
    
    //Create character set
    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
    
    //Invert the set
    validChars = [validChars invertedSet];
    
    //Check against that
    NSRange  range = [checkString rangeOfCharacterFromSet:validChars];
    if (NSNotFound != range.location) {
        
        return NO;
    }
    
    else{
        return YES;
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



- (BOOL)validateNameWithString:(NSString*)checkString
{
    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"];
    
    //Invert the set
    validChars = [validChars invertedSet];
    
    //Check against that
    NSRange  range = [checkString rangeOfCharacterFromSet:validChars];
    if (NSNotFound != range.location) {
        
        return NO;
        
    }
    
    else {
        return YES;
    }
}


// Test




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
    
    
    if(self.nameField.isFirstResponder){
        buttonOrigin = self.nameField.frame.origin;
        
        buttonHeight = self.nameField.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }
    
    else if(self.phoneField.isFirstResponder){
        buttonOrigin = self.phoneField.frame.origin;
        
        buttonHeight = self.phoneField.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }
    
    else if(self.addrLine1Field.isFirstResponder){
        buttonOrigin = self.addrLine1Field.frame.origin;
        
        buttonHeight = self.addrLine1Field.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }

    
    else if(self.addrLine2Field.isFirstResponder){
        buttonOrigin = self.addrLine2Field.frame.origin;
        
        buttonHeight = self.addrLine2Field.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }

    else if(self.cityField.isFirstResponder){
        buttonOrigin = self.cityField.frame.origin;
        
        buttonHeight = self.cityField.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }
    
    else if(self.zipField.isFirstResponder){
        buttonOrigin = self.zipField.frame.origin;
        
        buttonHeight = self.zipField.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
        
    }
    
    
    if(self.shouldKeyboardMoveUp)
    {
        
        
        CGRect visibleRect = self.view.frame;
        
        visibleRect.size.height -= keyboardSize.height + 50; // Extra 40 for Done Button
        
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)updateTapped:(id)sender {
    
    /*
    1. Check Internet Connectivity
    else (If good)
    2. Check if any Fields have been updated - If Not updated - Alert user
    3. If updated , check if fields are error free
    4. If error free, only the update
     
    */
    
    
    
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
        [button setTitle:@"Okay, Got it!" forState:UIControlStateNormal];
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

    
    // 2. Check if any updates to any of the fields have been made
    
    else if([self.nameField.text isEqualToString:name] && [self.phoneField.text isEqualToString:phone]&& [self.addrLine1Field.text isEqualToString:addr1] && [self.addrLine2Field.text isEqualToString:addr2] && [self.cityField.text isEqualToString:city] && [self.zipField.text isEqualToString:zip]) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"No Information has been edited to update" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    
    // 3. Check if fields are error free
    
    else if([self entryErrorName] || [self entryErrorAdd1] || [self entryErrorCity] || [self entryErrorZip] || [self entryErrorPhone]) {
        
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Please check your input fields which has not a smiling face again"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }

    // 4, else go ahead and update all the fields
    
    else {
        
        
        
        self.ref = [[FIRDatabase database] reference];
        
        NSArray *tempNames  = [self.nameField.text componentsSeparatedByString:@" "];
        
        NSMutableString *fName = [tempNames objectAtIndex:0];
        NSMutableString *lName = [[NSMutableString alloc]init];
        
        for(int i=1;i<[tempNames count];i++){
        
            if(i ==1)
            lName = [NSMutableString stringWithFormat:@"%@",[tempNames objectAtIndex:i]];
            else
                [lName appendString:[NSString stringWithFormat:@" %@",[tempNames objectAtIndex:i]]];
        }
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            NSDictionary *post = @{@"uid" : userID,
                                   @"First Name": fName,
                                   @"Last Name": lName,
                                   @"EMail": self.emailField.text,
                                   @"Address1": self.addrLine1Field.text,
                                   @"Address2": self.addrLine2Field.text,
                                   @"City": self.cityField.text,
                                   @"Zip": self.zipField.text,
                                   @"Phone": self.phoneField.text,
                                   
                                   };
            NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/", userID]: post};
            [_ref updateChildValues:childUpdates];
            
        }];
        
        self.resultField.hidden = NO;
        self.resultField.text = @"Changes updated Successfully";
        self.resultField.textColor = [UIColor greenColor];
        
        
        [self performSelector:@selector(loadingNextView)
                   withObject:nil afterDelay:3.0f];
        
    }
    
}


@end
