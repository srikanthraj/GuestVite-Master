//
//  ViewController.m
//  GuestVite
//
//  Created by admin on 2016-10-08.
//  Copyright © 2016 admin. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HomePageViewController.h"
#import "RegPageViewController.h"
#import "TextFieldValidator.h"
#import "SignOut.h"

@import Firebase;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet TextFieldValidator *emailField;

@property (weak, nonatomic) IBOutlet TextFieldValidator *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *forgotButton;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    self.ref = [[FIRDatabase database] reference];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
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
    
    

    
    
    
    
   //if([[_ref child:@"current_loggedIn_users"] child:userID] != nil)
      //  {
     
           // NSLog(@"NOTTTTT NULLLLL");
    

           // }
    
    
}

-(void) viewWillLayoutSubviews{
    
    
    /*
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    NSString *str = [NSString stringWithFormat: @"%@",[[_ref child:@"current_loggedIn_users"] child:userID]];
    NSLog(@"LOGIN PAGE :  %lu",(unsigned long)[str rangeOfString:userID].location);
    if([str rangeOfString:userID].location != NSNotFound)
        {
    [self autoLogin];
        }
     */
}

-(void) autoLogin {
    HomePageViewController *hPViewController =
    [[HomePageViewController alloc] init];
    
    
    [self presentViewController:hPViewController animated:YES completion:nil];
}
-(void)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}
- (IBAction)forgotPasswordTapped:(id)sender {
    
     NSString *eMailEntered = self.emailField.text;
    
    [[FIRAuth auth] sendPasswordResetWithEmail:eMailEntered
                                    completion:^(NSError *_Nullable error) {
                                        if (error) {
                                            // An error happened.
                                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"An Error Occured, Please try again"preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                            
                                            [ac addAction:aa];
                                            [self presentViewController:ac animated:YES completion:nil];
                                            // Password reset email sent.
                                        }
                                        
                                        else {
                                            
                                            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Check your inbox for details"preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                            
                                            [ac addAction:aa];
                                            [self presentViewController:ac animated:YES completion:nil];
                                            // Password reset email sent.
                                        }
                                    }];
}

- (IBAction)loginTapped:(id)sender {
    
    signedOut = FALSE;
    // Add regex for validating email id
    [self.emailField addRegx:@"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" withMsg:@"Enter valid email."];
    
    [self.passwordField addRegx:@"[A-Z0-9a-z._%+-]{3,}" withMsg:@"Password Field does not meet requirements"];
    
    NSString *eMailEntered = self.emailField.text;
    NSString *passwordEntered = self.passwordField.text;
    
    
    [[FIRAuth auth] signInWithEmail:eMailEntered
                           password:passwordEntered
                         completion:^(FIRUser *user, NSError *error) {
                        

                             
                             if(error){
                                 
                                 UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"Incorrect Password, please try again!"preferredStyle:UIAlertControllerStyleAlert];
                                 
                                 UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                 
                                 [ac addAction:aa];
                                 [self presentViewController:ac animated:YES completion:nil];
                                 
                             }
                             
                             else {
                                 
                                 
                                 HomePageViewController *hPViewController =
                                 [[HomePageViewController alloc] initWithNibName:@"HomePageViewController" bundle:nil];
                                 
                                 //hPViewController.userName  = eMailEntered;
                                 [self.navigationController pushViewController:hPViewController animated:YES];
                                 
                                 [self presentViewController:hPViewController animated:YES completion:nil];
                                 
                                 
                             }
                             
                             
                         }];

}
- (IBAction)registerTapped:(id)sender {
    
    RegPageViewController *regPageViewController =
    [[RegPageViewController alloc] initWithNibName:@"RegPageViewController" bundle:nil];
    
    //hPViewController.userName  = eMailEntered;
    [self.navigationController pushViewController:regPageViewController animated:YES];
    
    [self presentViewController:regPageViewController animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
