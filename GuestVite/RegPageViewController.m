//
//  RegPageViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-08.
//  Copyright © 2016 admin. All rights reserved.
//

#import "RegPageViewController.h"
#import "HomePageViewController.h"
#import "CNPPopupController.h"
#import "Reachability.h"
#import "UIViewController+Reachability.m"
@import Firebase;




@interface RegPageViewController ()
<UIScrollViewDelegate,UITextFieldDelegate,CNPPopupControllerDelegate>





@property (weak, nonatomic) IBOutlet UITextField *fNameText;
@property (weak, nonatomic) IBOutlet UITextField *lNameText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *reEnterPasswordText;
@property (weak, nonatomic) IBOutlet UITextField *addr1Text;

@property (weak, nonatomic) IBOutlet UITextField *addr2Text;
@property (weak, nonatomic) IBOutlet UINavigationBar *registrationBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

//@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *cityText;
@property (weak, nonatomic) IBOutlet UITextField *zipText;

@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *regView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (nonatomic, strong) CNPPopupController *popupController;

//Text Views

@property (weak, nonatomic) IBOutlet UITextView *fNameTextView;
@property (weak, nonatomic) IBOutlet UITextView *lNameTextView;

@property (weak, nonatomic) IBOutlet UITextView *emailTextView;
@property (weak, nonatomic) IBOutlet UITextView *passTextView;
@property (weak, nonatomic) IBOutlet UITextView *rePassTextView;

@property (weak, nonatomic) IBOutlet UITextView *addr1TextView;
@property (weak, nonatomic) IBOutlet UITextView *addr2TextView;
@property (weak, nonatomic) IBOutlet UITextView *cityTextView;
@property (weak, nonatomic) IBOutlet UITextView *zipTextView;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;

@property (nonatomic) BOOL shouldKeyboardMoveUp;

@property (nonatomic) BOOL entryErrorFName;

@property (nonatomic) BOOL entryErrorEMail;

@property (nonatomic) BOOL entryErrorPassword;

@property (nonatomic) BOOL entryErrorRePassword;

@property (nonatomic) BOOL entryErrorAdd1;

@property (nonatomic) BOOL entryErrorCity;


@property (nonatomic) BOOL entryErrorZip;

@property (nonatomic) BOOL entryErrorPhone;
@end

@implementation RegPageViewController




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
    
    
    
    self.emailText.delegate = self;
    
    //Style the Register Button
    
    self.registerButton.layer.cornerRadius = 10.0;
    [[self.registerButton layer] setBorderWidth:1.0f];
    [[self.registerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    //Test
    
    
    self.fNameTextView.text = NSLocalizedString(@"😐", nil);
    self.lNameTextView.text = NSLocalizedString(@"😐", nil);
    self.emailTextView.text = NSLocalizedString(@"😐", nil);
    self.passTextView.text = NSLocalizedString(@"😐", nil);
    self.rePassTextView.text = NSLocalizedString(@"😐", nil);
    self.addr1TextView.text = NSLocalizedString(@"😐", nil);
    self.addr2TextView.text = NSLocalizedString(@"😐", nil);
    self.cityTextView.text = NSLocalizedString(@"😐", nil);
    self.zipTextView.text = NSLocalizedString(@"😐", nil);
    self.phoneTextView.text = NSLocalizedString(@"😐", nil);
    
    self.fNameTextView.editable = NO;
    self.lNameTextView.editable = NO;
    self.emailTextView.editable = NO;
    self.passTextView.editable = NO;
    self.rePassTextView.editable = NO;
    self.addr1TextView.editable = NO;
    self.addr2TextView.editable = NO;
    self.cityTextView.editable = NO;
    self.zipTextView.editable = NO;
    self.phoneTextView.editable = NO;
    
    
    self.entryErrorFName = YES;
    self.entryErrorEMail = YES;
    self.entryErrorPassword = YES;
    self.entryErrorRePassword = YES;
    self.entryErrorAdd1 = YES;
    self.entryErrorCity = YES;
    self.entryErrorZip = YES;
    self.entryErrorPhone = YES;
    
    
    [self.fNameText addTarget:self action:@selector(firstNameTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.lNameText addTarget:self action:@selector(lastNameTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.cityText addTarget:self action:@selector(cityTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    [self.emailText addTarget:self action:@selector(emailTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    [self.passwordText addTarget:self action:@selector(passTextChanged:) forControlEvents:UIControlEventEditingChanged];

    
    [self.reEnterPasswordText addTarget:self action:@selector(rePassTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.zipText addTarget:self action:@selector(zipTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.phoneText addTarget:self action:@selector(phoneTextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    [self.addr1Text addTarget:self action:@selector(addr1TextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [self.addr2Text addTarget:self action:@selector(addr2TextChanged:) forControlEvents:UIControlEventEditingChanged];
    
    
    
    //Test
    
    
 
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"blue-orange-backgrounds-wallpaper"];
    [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    
    
    self.navigationItem.leftBarButtonItem = _backButton;
    
    [self.view addSubview:_registrationBack];
    
    
    self.ref = [[FIRDatabase database] reference];
    

    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    
    
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    self.fNameText.inputAccessoryView = keyboardDoneButtonView;
    self.lNameText.inputAccessoryView = keyboardDoneButtonView;
    self.emailText.inputAccessoryView = keyboardDoneButtonView;
    self.passwordText.inputAccessoryView = keyboardDoneButtonView;
    self.reEnterPasswordText.inputAccessoryView = keyboardDoneButtonView;
    self.addr1Text.inputAccessoryView = keyboardDoneButtonView;
    self.addr2Text.inputAccessoryView = keyboardDoneButtonView; 
    self.cityText.inputAccessoryView = keyboardDoneButtonView;
    self.zipText.inputAccessoryView = keyboardDoneButtonView;
    self.phoneText.inputAccessoryView = keyboardDoneButtonView;
}


- (void)emailTextChanged:(UITextField *)sender
{
    
    
    if([self validateEmailWithString:sender.text]){
        
        self.emailTextView.text = NSLocalizedString(@"😃", nil);
        self.emailText.backgroundColor = [UIColor whiteColor];
        self.entryErrorEMail = NO;
        NSLog(@"Error of E-Mail is %@",self.entryErrorEMail ? @"YES" : @"NO");
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.emailText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.emailTextView.text = NSLocalizedString(@"😧", nil);
        self.emailTextView.textColor = invalidRed;
        self.entryErrorEMail = YES;
    }
    
    if(sender.text.length ==0) {
        
        self.emailText.backgroundColor = [UIColor whiteColor];
        self.emailTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorEMail = YES;
    }


    
}


- (void)firstNameTextChanged:(UITextField *)sender
{

    if(sender.text.length > 0){
        self.fNameTextView.text = NSLocalizedString(@"😃", nil);
        self.fNameText.backgroundColor = [UIColor whiteColor];
        self.entryErrorFName = NO;
        NSLog(@"Error of First Name is %@",self.entryErrorFName ? @"YES" : @"NO");
    }
    
    
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.fNameText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.fNameTextView.text = NSLocalizedString(@"😧", nil);
        self.fNameTextView.textColor = invalidRed;
        self.entryErrorFName = YES;
    }
    
    if(sender.text.length ==0) {
        
        self.fNameText.backgroundColor = [UIColor whiteColor];
        self.fNameTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorFName = YES;
    }
    
    

    
}

- (void)lastNameTextChanged:(UITextField *)sender
{
    
    if(sender.text.length > 0){
        self.lNameTextView.text = NSLocalizedString(@"😃", nil);
        
    }
    
    else if(sender.text.length ==0) {
        self.lNameTextView.text = NSLocalizedString(@"😐", nil);
    }
    
}




- (void)passTextChanged:(UITextField *)sender
{
    
    if([self.passwordText.text length] > 6){
        self.passTextView.text = NSLocalizedString(@"😃", nil);
        self.passwordText.backgroundColor = [UIColor whiteColor];
        self.entryErrorPassword = NO;
        NSLog(@"Error of Password is %@",self.entryErrorPassword ? @"YES" : @"NO");
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.passwordText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.passTextView.text = NSLocalizedString(@"😧", nil);
        self.passTextView.textColor = invalidRed;
        self.entryErrorPassword = YES;
    }
    
    if(sender.text.length ==0) {
        self.passwordText.backgroundColor = [UIColor whiteColor];
        self.passTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorPassword = YES;
    }
    
}


- (void)rePassTextChanged:(UITextField *)sender
{
    
    if([self.reEnterPasswordText.text length] > 6 && [self.passwordText.text isEqualToString:self.reEnterPasswordText.text]){
    
        self.rePassTextView.text = NSLocalizedString(@"😃", nil);
        self.reEnterPasswordText.backgroundColor = [UIColor whiteColor];
        self.entryErrorRePassword = NO;
        NSLog(@"Error of Re Password is %@",self.entryErrorRePassword ? @"YES" : @"NO");
        
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.reEnterPasswordText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.rePassTextView.text = NSLocalizedString(@"😧", nil);
        self.rePassTextView.textColor = invalidRed;
        self.entryErrorRePassword = YES;
    }
    
    if(sender.text.length ==0) {
        self.reEnterPasswordText.backgroundColor = [UIColor whiteColor];
        self.rePassTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorRePassword = YES;
    }
    
    
}


- (void)cityTextChanged:(UITextField *)sender
{
    
    if([self validateCityWithString:sender.text]){
        self.cityTextView.text = NSLocalizedString(@"😃", nil);
        self.cityText.backgroundColor = [UIColor whiteColor];
        self.entryErrorCity = NO;
        NSLog(@"Error of City is %@",self.entryErrorCity ? @"YES" : @"NO");
        
    }
    
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.cityText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.cityTextView.text = NSLocalizedString(@"😧", nil);
        self.cityTextView.textColor = invalidRed;
        self.entryErrorCity = YES;
    }
    
    if(sender.text.length ==0) {
        self.cityText.backgroundColor = [UIColor whiteColor];
        self.cityTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorCity = YES;
    }
    
}


- (void)zipTextChanged:(UITextField *)sender
{
    
    if([self validateZipPhoneWithString:sender.text]){
        
        self.zipTextView.text = NSLocalizedString(@"😃", nil);
        self.zipText.backgroundColor = [UIColor whiteColor];
        self.entryErrorZip = NO;
        NSLog(@"Error of Zip is %@",self.entryErrorZip ? @"YES" : @"NO");
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.zipText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.zipTextView.text = NSLocalizedString(@"😧", nil);
        self.zipTextView.textColor = invalidRed;
        self.entryErrorZip = YES;
    }

    if(sender.text.length ==0) {
        self.zipText.backgroundColor = [UIColor whiteColor];
        self.zipTextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorZip = YES;
    }
    
}

- (void)phoneTextChanged:(UITextField *)sender
{
    
    if([self validateZipPhoneWithString:sender.text] && [sender.text length] == 10){
            self.phoneTextView.text = NSLocalizedString(@"😃", nil);
        self.phoneText.backgroundColor = [UIColor whiteColor];
        self.entryErrorPhone = NO;
        NSLog(@"Error of Phone is %@",self.entryErrorPhone ? @"YES" : @"NO");
        
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.phoneText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.phoneTextView.text = NSLocalizedString(@"😧", nil);
        self.phoneTextView.textColor = invalidRed;
        self.entryErrorPhone = YES;
    }
    
    if(sender.text.length ==0) {
        self.phoneText.backgroundColor = [UIColor whiteColor];
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
        self.addr1Text.backgroundColor = [UIColor whiteColor];
        self.addr1TextView.text = NSLocalizedString(@"😢", nil);
        self.entryErrorAdd1 = YES;
    }
}

- (void)addr2TextChanged:(UITextField *)sender
{
    if([sender.text length] > 0){
        self.addr2TextView.text = NSLocalizedString(@"😃", nil);
    }
    else if(sender.text.length ==0) {
        //self.addr2Text.backgroundColor = [UIColor whiteColor];
        self.addr2TextView.text = NSLocalizedString(@"😐", nil);
    }
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

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)Back
{
    [self dismissViewControllerAnimated:YES completion:nil]; // ios 6
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



- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
}


- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint buttonOrigin = CGPointMake(0, 0);
    CGFloat buttonHeight = 0.0;
    
    
    if(self.addr1Text.isFirstResponder){
        buttonOrigin = self.addr1Text.frame.origin;
        
        buttonHeight = self.addr1Text.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
    }

    
    else if(self.addr2Text.isFirstResponder){
        buttonOrigin = self.addr2Text.frame.origin;
        
        buttonHeight = self.addr2Text.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
    }

    
    else if(self.cityText.isFirstResponder){
    buttonOrigin = self.cityText.frame.origin;
    
    buttonHeight = self.cityText.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
    }
    
    else if(self.phoneText.isFirstResponder){
        buttonOrigin = self.phoneText.frame.origin;
        
        buttonHeight = self.phoneText.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
    }
    
    
    else if(self.reEnterPasswordText.isFirstResponder){
        buttonOrigin = self.reEnterPasswordText.frame.origin;
        
        buttonHeight = self.reEnterPasswordText.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
    }
    

    else if(self.zipText.isFirstResponder){
        buttonOrigin = self.zipText.frame.origin;
        
        buttonHeight = self.zipText.frame.size.height;
        self.shouldKeyboardMoveUp = TRUE;
    }
    
    
if(self.shouldKeyboardMoveUp)
{
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height + 10; // Extra 10 for Done Button

    
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}



- (IBAction)registerTapped:(id)sender {
    
    
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


    
    // If any Fields has error
   else if([self entryErrorFName] || [self entryErrorEMail] || [self entryErrorPassword] || [self entryErrorRePassword] || [self entryErrorAdd1] || [self entryErrorCity] || [self entryErrorZip] || [self entryErrorPhone]) {
        
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Please check your input fields which has not a smiling face again"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    
    else {
    
    
    NSString *eMailAddress = self.emailText.text;
    NSString *password = self.passwordText.text;
    
    
    [[FIRAuth auth]
     createUserWithEmail:eMailAddress
     password:password
     completion:^(FIRUser *_Nullable user,
                  NSError *_Nullable error) {
         
         if (error) {
             UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"There was an error creating your account - Maybe an account already exists with the same E-Mail address"preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
             
             [ac addAction:aa];
             [self presentViewController:ac animated:YES completion:nil];
         }
         
            else {
             
                
                
               NSString *phoneTemp = [[self.phoneText.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]componentsJoinedByString:@""];
                
                NSDictionary *post = @{@"uid" : user.uid,
                                       @"First Name": self.fNameText.text,
                                       @"Last Name": self.lNameText.text,
                                       @"EMail": self.emailText.text,
                                       @"Address1": self.addr1Text.text,
                                       @"Address2": self.addr2Text.text,
                                       @"City": self.cityText.text,
                                       @"Zip": self.zipText.text,
                                       @"Phone": phoneTemp,
                                       
                                       };
                NSDictionary *childUpdates = @{[NSString stringWithFormat:@"/users/%@/", user.uid]: post};
                [_ref updateChildValues:childUpdates];
                
                
                            NSDictionary *childCurrentUserUpdates = @{[NSString stringWithFormat:@"/current_loggedIn_users/%@/", user.uid]: post};
                [_ref updateChildValues:childCurrentUserUpdates];

                
            
                
                HomePageViewController *hpViewController =
                [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
                
                
                [self.navigationController pushViewController:hpViewController animated:YES];
                
                
                [self presentViewController:hpViewController animated:YES completion:nil];

         }
         
     }];

   }// Main else ends
    
    }


@end
