//
//  LSLoginViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 07.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSLoginViewController.h"
#import "LSWebAuthViewController.h"

@interface LSLoginViewController ()

@end

@implementation LSLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)connectWithFacebook:(id)sender {
    LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
    [webAuthCtrl setAuthServiceName:@"facebook"];
    [self presentViewController:webAuthCtrl animated:YES completion:nil];
}

- (IBAction)connectWithGithub:(id)sender {
    LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
    [webAuthCtrl setAuthServiceName:@"github"];
    [self presentViewController:webAuthCtrl animated:YES completion:nil];
}

- (IBAction)connectWithTwitter:(id)sender {
    LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
    [webAuthCtrl setAuthServiceName:@"twitter"];
    [self presentViewController:webAuthCtrl animated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end