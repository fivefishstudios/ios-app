//
//  LSSetupViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 12.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSSetupViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSUser.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <ALPValidator/ALPValidator.h>
#import <NSURL+ParseQuery/NSURL+QueryParser.h>

@interface LSSetupViewController ()

@property (strong, nonatomic) LSUser *user;

@end

@implementation LSSetupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.activityIndicator startAnimating];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api getEmailAndAPIToken:self.userId success:^(AFHTTPRequestOperation *operation, id userData) {
        self.user = [[LSUser alloc] initWithDictionary:userData];
        
        [self.userAvatarView.layer setMasksToBounds:YES];
        [self.userAvatarView.layer setBorderWidth:2.0f];
        [self.userAvatarView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.userAvatarView.layer setCornerRadius:self.userAvatarView.frame.size.height/2];
        [self.userAvatarView setImageWithURL:[NSURL URLWithString:self.user.avatar] placeholderImage:[UIImage imageNamed:@"gravatar.png"]];
        
        // show email field only if local provider
        if (self.user.isLocalProvider) {
            [self.emailField removeFromSuperview];
        } else {
            [self.emailField setText:self.user.email];
        }
        
        [self.usernameField setText:self.user.username];
        
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        [self.setupScrollView setHidden:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showErrorAlert:@"Something went wrong. Please check your connection or try again later!"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)finishRegistration:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    ALPValidator *usernameValidator = [ALPValidator validatorWithType:ALPValidatorTypeString];
    [usernameValidator addValidationToEnsurePresenceWithInvalidMessage:@"Make sure you enter an username!"];
    [usernameValidator addValidationToEnsureRegularExpressionIsMetWithPattern:@"^[0-9A-z-_.+=@!#()&%?]+$" invalidMessage:@"Your username contains not allowed symbols"];
    [usernameValidator validate:username];
    
    if (!usernameValidator.isValid) {
        [self showErrorAlert:usernameValidator.errorMessages[0]];
        return;
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:username forKey:@"username"];
    [data setObject:self.userId forKey:@"userId"];
    
    if (!self.user.isLocalProvider) {
        NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        ALPValidator *emailValidator = [ALPValidator validatorWithType:ALPValidatorTypeString];
        [emailValidator addValidationToEnsurePresenceWithInvalidMessage:@"Make sure you enter an email!"];
        [emailValidator addValidationToEnsureValidEmailWithInvalidMessage:@"Your email looks incorrect!"];
        [emailValidator validate:email];
        
        if (!emailValidator.isValid) {
            [self showErrorAlert:emailValidator.errorMessages[0]];
            return;
        }
        
        [data setObject:email forKey:@"email"];
    }
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api setupUser:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSURL *appUrl = [NSURL URLWithString:[responseObject objectForKey:@"applicationUrl"]];
        NSDictionary *query = [appUrl parseQuery];
    
        [api getAccessToken:query success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self performSegueWithIdentifier:@"fromSetupAuthToFeed" sender:self];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error while getting access token %@", error);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)showErrorAlert:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
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