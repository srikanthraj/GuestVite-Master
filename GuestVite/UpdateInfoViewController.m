//
//  UpdateInfoViewController.m
//  GuestVite
//
//  Created by admin on 2016-11-17.
//  Copyright © 2016 admin. All rights reserved.
//

#import "UpdateInfoViewController.h"
#import "HomePageViewController.h"
@import Firebase;

@interface UpdateInfoViewController ()

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

@end

@implementation UpdateInfoViewController

NSMutableString *name;
NSMutableString *email;
NSMutableString *phone;
NSMutableString *addr1;
NSMutableString *addr2;
NSMutableString *city;
NSMutableString *zip;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)updateTapped:(id)sender {
    
    // First Check if any updates to any of the fields have been made
    
    if([self.nameField.text isEqualToString:name] && [self.phoneField.text isEqualToString:phone]&& [self.addrLine1Field.text isEqualToString:addr1] && [self.addrLine2Field.text isEqualToString:addr2] && [self.cityField.text isEqualToString:city] && [self.zipField.text isEqualToString:zip]) {
        
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"GuestVite" message:@"No Information has been edited to update" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *aa = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [ac addAction:aa];
        [self presentViewController:ac animated:YES completion:nil];
        
    }
    
    
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
