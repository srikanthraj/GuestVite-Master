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
#import "PageContentViewController.h"

#import "SignOut.h"

@import Firebase;

@interface ViewController () <UIPageViewControllerDataSource>



@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;


@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet TextFieldValidator *emailField;

@property (weak, nonatomic) IBOutlet TextFieldValidator *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *forgotButton;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;


@end

@implementation ViewController

NSArray *viewControllers;

NSUInteger currIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.pageTitles = @[@"Track the Status of your Guests", @"One Click Invite", @"Alerts when your Guest is near your place", @"Free Regular Update"];
    self.pageImages = @[@"background.png", @"orange-1.png", @"purple.png", @"guests.png"];
    
    
    currIndex = 0;
    
    //Try
   
    
    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(changeController:)
                                   userInfo:nil
                                    repeats:YES];
    

    
  
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
     self.pageViewController.dataSource = self;
    
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
  
    //Try
    
    
    
    
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (self.view.frame.size.height - 200));
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    

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

//Try

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return currIndex;
}

- (void) changeController:(NSTimer*)timer
{
    
    PageContentViewController *nextViewController = [self viewControllerAtIndex:currIndex++];
    if (nextViewController == nil) {
        
        currIndex = 0;
        nextViewController = [self viewControllerAtIndex:currIndex];
    }
    
    [self.pageViewController setViewControllers:@[nextViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
    
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

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return [self viewControllerAtIndex:[self.pageTitles count]];
    }
    
    else {
    index--;
    return [self viewControllerAtIndex:index];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index == [self.pageTitles count]) {
        return [self viewControllerAtIndex:0];
    }
    
    else {
    index++;
    
    return [self viewControllerAtIndex:index];
    }
}


- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}



@end
