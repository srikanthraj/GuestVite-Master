//
//  UpdateInfoViewController.m
//  GuestVite
//
//  Created by admin on 2016-11-17.
//  Copyright © 2016 admin. All rights reserved.
//

#import "UpdateInfoViewController.h"
@import Firebase;

@interface UpdateInfoViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
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

NSMutableString *fName;
NSMutableString *lName;
NSMutableString *email;
NSMutableString *phone;
NSMutableString *addr1;
NSMutableString *addr2;
NSMutableString *city;
NSMutableString *zip;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    fName = [[NSMutableString alloc]init];
    lName = [[NSMutableString alloc]init];
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

    
    
    //Get the user Info
    
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
    
    [fName setString:myFName];
    [lName setString:myLName];
    [email setString:myEmail];
    [phone setString:myPhone];
    [addr1 setString:myAddr1];
    [addr2 setString:myAddr2];
    [city setString:myCity];
    [zip setString:myZip];
    
    // Setting the labels
    
    self.emailField.text = email;
    self.emailField.enabled = NO;
    self.firstNameField.text = fName;
    self.lastNameField.text = lName;
    self.phoneField.text = phone;
    self.addrLine1Field.text = addr1;
    self.addrLine2Field.text = addr2;
    self.cityField.text = city;
    self.zipField.text = zip;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
