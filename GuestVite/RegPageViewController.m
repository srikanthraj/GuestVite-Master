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
@import Firebase;




@interface RegPageViewController ()
<UIScrollViewDelegate>




@property (weak, nonatomic) IBOutlet UITextField *fNameText;
@property (weak, nonatomic) IBOutlet UITextField *lNameText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *reEnterPasswordText;
@property (weak, nonatomic) IBOutlet UITextField *addr1Text;

@property (weak, nonatomic) IBOutlet UITextField *addr2Text;

//@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITextField *cityText;
@property (weak, nonatomic) IBOutlet UITextField *zipText;
@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *regView;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@end

@implementation RegPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
             
                
                //Update all the values to the DB
               /*
                if([self.fNameText.text length] >0 && [self.lNameText.text length] >0 && [self.emailText.text length] > 0 && [self.addr1Text.text length] >0 && [self.addr2Text.text length] > 0 && [self.cityText.text length] > 0 && [self.zipText.text length] > 0 && [self.phoneText.text length] > 0)
                {
                */
               
                NSDictionary *post = @{@"uid" : user.uid,
                                       @"First Name": self.fNameText.text,
                                       @"Last Name": self.lNameText.text,
                                       @"EMail": self.emailText.text,
                                       @"Address1": self.addr1Text.text,
                                       @"Address2": self.addr2Text.text,
                                       @"City": self.cityText.text,
                                       @"Zip": self.zipText.text,
                                       @"Phone": self.phoneText.text,
                                       
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
