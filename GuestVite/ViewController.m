//
//  ViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-08.
//  Copyright © 2016 admin. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RegPageViewController.h"
#import "HomePageViewController.h"
#import "SignOut.h"

@import Firebase;

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *forgotButton;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (nonatomic) BOOL entryErrorEMail;

@end

@implementation ViewController

NSArray *viewControllers;

NSUInteger currIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // [self setNeedsStatusBarAppearanceUpdate];
    
    
    self.entryErrorEMail = YES;
    self.ref = [[FIRDatabase database] reference];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStylePlain target:self
                                                                  action:@selector(doneClicked:)];
    
    
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    self.emailField.inputAccessoryView = keyboardDoneButtonView;
    
    self.passwordField.inputAccessoryView = keyboardDoneButtonView;
    
    self.loginButton.layer.cornerRadius = 10.0;

    [[self.loginButton layer] setBorderWidth:1.0f];
    [[self.loginButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    self.forgotButton.layer.cornerRadius = 10.0;
    
    [[self.forgotButton layer] setBorderWidth:1.0f];
    [[self.forgotButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    [self.loginButton setBounds:CGRectMake(200, 200, 800, 800)];
    
    self.registerButton.layer.cornerRadius = 10.0;
    
    [[self.registerButton layer] setBorderWidth:1.0f];
    [[self.registerButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    

    
    if(!signedOut) {
    HomePageViewController *hPViewController =
    [[HomePageViewController alloc] init];
    
    
    [self presentViewController:hPViewController animated:YES completion:nil];
    }
    
}

-(void) autoLogin {
    HomePageViewController *hPViewController =
    [[HomePageViewController alloc] init];
    
    
    [self presentViewController:hPViewController animated:YES completion:nil];
}

-(void)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}


- (IBAction)forgotPasswordTapped:(id)sender {
    
     NSString *eMailEntered = self.emailField.text;
    
    [[FIRAuth auth] sendPasswordResetWithEmail:eMailEntered
                                    completion:^(NSError *_Nullable error) {
                                        
                                       
                                        if([eMailEntered length] == 0){
                                            
                                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"%@",@"Please Enter an E-Mail address for which you want to get the password"]preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                            
                                            [ac addAction:aa];
                                            [self presentViewController:ac animated:YES completion:nil];

                                        }
                                        
                                        else if(![self validateEmailWithString:eMailEntered]) {
                                            
                                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"%@",@"Sorry,Please Enter a valid E-Mail address for which you want to get the password"]preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                            
                                            [ac addAction:aa];
                                            [self presentViewController:ac animated:YES completion:nil];
                                        }
                                        
                                        
                                        else if (error) {
                                            // An error happened.
                                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"An Error Occured, Please try again"preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                            
                                            [ac addAction:aa];
                                            [self presentViewController:ac animated:YES completion:nil];
                                            // Password reset email sent.
                                        }
                                        
                                        else {
                                            
                                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Please check your Inbox for datils to reset your password"preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                            
                                            [ac addAction:aa];
                                            [self presentViewController:ac animated:YES completion:nil];
                                            // Password reset email sent.
                                        }
                                    }];
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


- (IBAction)loginTapped:(id)sender {
    
    signedOut = FALSE;

    
    NSString *eMailEntered = self.emailField.text;
    NSString *passwordEntered = self.passwordField.text;
    
    
    
    [[FIRAuth auth] signInWithEmail:eMailEntered
                           password:passwordEntered
                         completion:^(FIRUser *user, NSError *error) {
                        

                             
                             if(![self validateEmailWithString:eMailEntered] && [passwordEntered length] == 0) {
                                 
                                 UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"%@\n\n%@",@"Please check the format of your email address and try again",@"Password Field is empty, please enter the password"]preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 
                                 [ac addAction:aa];
                                 [self presentViewController:ac animated:YES completion:nil];
                                 
                             }

                             else if(![self validateEmailWithString:eMailEntered] && [passwordEntered length] <= 6) {
                                 
                                 UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:[NSString stringWithFormat:@"%@\n\n%@",@"Please check the format of your email address and try again",@"Please check your password and try again"]preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 
                                 [ac addAction:aa];
                                 [self presentViewController:ac animated:YES completion:nil];
                                 
                             }
                             
                             else if(![self validateEmailWithString:eMailEntered]) {
                                 
                                 UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Please check the format of your email address and try again"preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 
                                 [ac addAction:aa];
                                 [self presentViewController:ac animated:YES completion:nil];
                                 
                             }
                             
                             
                             else if([passwordEntered length] == 0) {
                                 
                                 UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Password Field is empty, please enter your password"preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 
                                 [ac addAction:aa];
                                 [self presentViewController:ac animated:YES completion:nil];
                             }
                             
                             else if(error){
                                 
                                 UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Incorrect password, please try again"preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 
                                 [ac addAction:aa];
                                 [self presentViewController:ac animated:YES completion:nil];
                                 
                             }
                             
                             else {
                                 
                                 
                                 HomePageViewController *hPViewController =
                                 [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
                                 
                                 [self.navigationController pushViewController:hPViewController animated:YES];
                                 
                                 [self presentViewController:hPViewController animated:YES completion:nil];
                                 
                                 
                             }
                             
                             
                         }];

}
- (IBAction)registerTapped:(id)sender {
    
    RegPageViewController *regPageViewController =
    [[RegPageViewController alloc] initWithNibName:@"RegPageViewController" bundle:nil];
    
    [self.navigationController pushViewController:regPageViewController animated:YES];
    
    [self presentViewController:regPageViewController animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
