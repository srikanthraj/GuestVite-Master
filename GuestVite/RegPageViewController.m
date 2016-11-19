//
//  RegPageViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-08.
//  Copyright © 2016 admin. All rights reserved.
//

#import "RegPageViewController.h"
#import "HomePageViewController.h"
#include "TextFieldValidator.h"
#import "VMaskTextField.h"

@import Firebase;




@interface RegPageViewController ()
<UIScrollViewDelegate,UITextFieldDelegate>





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

@property (weak, nonatomic) IBOutlet VMaskTextField *phoneText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *regView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;


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

@end

@implementation RegPageViewController

//Test AJW


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


//Test AJW



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.emailText.delegate = self;
    
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
    
    
    //Telephone with Code Area
    self.phoneText.mask = @"(###)###-####";
    self.phoneText.delegate = (id)self;
    
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
                                                                   style:UIBarButtonItemStyleBordered target:self
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

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return  [self.phoneText shouldChangeCharactersInRange:range replacementString:string];
}

*/

// Test

- (void)emailTextChanged:(UITextField *)sender
{
    
    
    if([self validateEmailWithString:sender.text]){
        UIColor *validGreen = [UIColor colorWithRed:0.27 green:0.63 blue:0.27 alpha:1];
        self.emailText.backgroundColor = [validGreen colorWithAlphaComponent:0.3];
        self.emailTextView.text = NSLocalizedString(@"😃", nil);
        self.emailTextView.textColor = validGreen;
        
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.emailText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.emailTextView.text = NSLocalizedString(@"😧", nil);
        self.emailTextView.textColor = invalidRed;
    }

    
}


- (void)firstNameTextChanged:(UITextField *)sender
{

    if([self validateNameWithString:sender.text]){
        self.fNameTextView.text = NSLocalizedString(@"😃", nil);
    }
    
    
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.fNameText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.fNameTextView.text = NSLocalizedString(@"😧", nil);
        self.fNameTextView.textColor = invalidRed;
    }
    
    if(sender.text.length ==0) {
        
        self.fNameText.backgroundColor = [UIColor whiteColor];
        self.fNameTextView.text = NSLocalizedString(@"😢", nil);
    }
    
    

    
}

- (void)lastNameTextChanged:(UITextField *)sender
{
    
    if([self validateNameWithString:sender.text]){
        self.lNameTextView.text = NSLocalizedString(@"😃", nil);
    }
    
   
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.lNameText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.lNameTextView.text = NSLocalizedString(@"😧", nil);
        self.lNameTextView.textColor = invalidRed;
    }
    
    if(sender.text.length ==0) {
        self.lNameText.backgroundColor = [UIColor whiteColor];
        self.lNameTextView.text = NSLocalizedString(@"😢", nil);
    }
    
}


- (void)cityTextChanged:(UITextField *)sender
{
    
    if([self validateNameWithString:sender.text]){
        self.cityTextView.text = NSLocalizedString(@"😃", nil);
        
    }
    
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.cityText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.cityTextView.text = NSLocalizedString(@"😧", nil);
        self.cityTextView.textColor = invalidRed;
    }
    
    if(sender.text.length ==0) {
        self.cityText.backgroundColor = [UIColor whiteColor];
        self.cityTextView.text = NSLocalizedString(@"😢", nil);
    }
    
}


- (void)passTextChanged:(UITextField *)sender
{
    
    if([self.passwordText.text length] > 6 && [self validateZipPhoneWithString:sender.text]){
        self.passTextView.text = NSLocalizedString(@"😃💪", nil);
        
    }
    
    else if ([self.passwordText.text length] > 6 && ![self validateZipPhoneWithString:sender.text]){
        self.passTextView.text = NSLocalizedString(@"😃", nil);
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.passwordText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.passTextView.text = NSLocalizedString(@"😧", nil);
        self.passTextView.textColor = invalidRed;
    }
    
    if(sender.text.length ==0) {
        self.passwordText.backgroundColor = [UIColor whiteColor];
        self.passTextView.text = NSLocalizedString(@"😢", nil);
    }
    
}


- (void)rePassTextChanged:(UITextField *)sender
{
    
    if([self.reEnterPasswordText.text length] > 6 && [self.passwordText.text isEqualToString:self.reEnterPasswordText.text] && [self validateZipPhoneWithString:sender.text]){
    
        self.rePassTextView.text = NSLocalizedString(@"😃💪", nil);
        
    }
    
    else if([self.reEnterPasswordText.text length] > 6 && [self.passwordText.text isEqualToString:self.reEnterPasswordText.text] && ![self validateZipPhoneWithString:sender.text]) {
        
        self.rePassTextView.text = NSLocalizedString(@"😃", nil);
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.reEnterPasswordText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.rePassTextView.text = NSLocalizedString(@"😧", nil);
        self.rePassTextView.textColor = invalidRed;
    }
    
    if(sender.text.length ==0) {
        self.reEnterPasswordText.backgroundColor = [UIColor whiteColor];
        self.rePassTextView.text = NSLocalizedString(@"😢", nil);
    }
    
    
}

- (void)zipTextChanged:(UITextField *)sender
{
    
    if([self validateZipPhoneWithString:sender.text]){
        
        self.zipTextView.text = NSLocalizedString(@"😃", nil);
        
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.zipText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.zipTextView.text = NSLocalizedString(@"😧", nil);
        self.zipTextView.textColor = invalidRed;
    }

    if(sender.text.length ==0) {
        self.zipText.backgroundColor = [UIColor whiteColor];
        self.zipTextView.text = NSLocalizedString(@"😢", nil);
    }
    
}

- (void)phoneTextChanged:(VMaskTextField *)sender
{
    
    if([self validateZipPhoneWithString:sender.text]){
            self.phoneTextView.text = NSLocalizedString(@"😃", nil);
        
        
    }
    
    else {
        UIColor *invalidRed = [UIColor colorWithRed:0.89 green:0.18 blue:0.16 alpha:1];
        self.phoneText.backgroundColor = [invalidRed colorWithAlphaComponent:0.3];
        self.phoneTextView.text = NSLocalizedString(@"😧", nil);
        self.phoneTextView.textColor = invalidRed;
    }
    
    if(sender.text.length ==0) {
        self.phoneText.backgroundColor = [UIColor whiteColor];
        self.phoneTextView.text = NSLocalizedString(@"😢", nil);
    }
    
    
}



- (void)addr1TextChanged:(UITextField *)sender
{
    if([sender.text length] > 0){
        self.addr1TextView.text = NSLocalizedString(@"😃", nil);
    }
    if(sender.text.length ==0) {
        self.addr1Text.backgroundColor = [UIColor whiteColor];
        self.addr1TextView.text = NSLocalizedString(@"😢", nil);
    }
}

- (void)addr2TextChanged:(UITextField *)sender
{
    if([sender.text length] > 0){
        self.addr2TextView.text = NSLocalizedString(@"😃", nil);
    }
    if(sender.text.length ==0) {
        self.addr2Text.backgroundColor = [UIColor whiteColor];
        self.addr2TextView.text = NSLocalizedString(@"😢", nil);
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
    
    CGPoint buttonOrigin;
    CGFloat buttonHeight;
    
    
    if(self.cityText.isFirstResponder){
    buttonOrigin = self.cityText.frame.origin;
    
    buttonHeight = self.cityText.frame.size.height;
    }
    
    else if(self.phoneText.isFirstResponder){
        buttonOrigin = self.phoneText.frame.origin;
        
        buttonHeight = self.phoneText.frame.size.height;
    }
    
    
    else if(self.reEnterPasswordText.isFirstResponder){
        buttonOrigin = self.reEnterPasswordText.frame.origin;
        
        buttonHeight = self.reEnterPasswordText.frame.size.height;
    }
    
    else if(self.addr1Text.isFirstResponder){
        buttonOrigin = self.addr1Text.frame.origin;
        
        buttonHeight = self.addr1Text.frame.size.height;
    }
    else if(self.zipText.isFirstResponder){
        buttonOrigin = self.zipText.frame.origin;
        
        buttonHeight = self.zipText.frame.size.height;
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}



- (IBAction)registerTapped:(id)sender {
    
    NSString *eMailAddress = self.emailText.text;
    NSString *password = self.passwordText.text;
    
    
    [[FIRAuth auth]
     createUserWithEmail:eMailAddress
     password:password
     completion:^(FIRUser *_Nullable user,
                  NSError *_Nullable error) {
         
         if (error) {
             UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"There was an error creating your account"preferredStyle:UIAlertControllerStyleAlert];
             
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

    
    }


@end
