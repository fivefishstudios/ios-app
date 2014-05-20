//
//  LSSettingsTableViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 11.05.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSSettingsTableViewController.h"
#import "LSDropdownViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSSharedUser.h"
#import "LSWebAuthViewController.h"
#import "LSNetwork.h"

#import <Underscore.m/Underscore.h>
#import <SDWebImage/SDImageCache.h>

@interface LSSettingsTableViewController ()

@end

@implementation LSSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"settings opened"];
    
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api getNetworks:^(AFHTTPRequestOperation *operation, id networks) {
        for (NSDictionary *networkData in networks) {
            LSNetwork *network = [[LSNetwork alloc] initWithDictionary:networkData];
            LSSwitch *targetSwitch = Underscore.array(self.switches).find(^BOOL(LSSwitch *networkSwitch) {
                return [networkSwitch.service isEqualToString:network.service];
            });
            [targetSwitch setOn:YES animated:YES];
        }
    } failure:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    LSDropdownViewController *menu = (LSDropdownViewController *) [self parentViewController];
    [menu.logoView setHidden:YES];
    [menu.titleLabel setHidden:NO];
    
    [menu.inboxButton setHidden:YES];
    [menu.settingsButton setHidden:YES];
    [menu.searchButton setHidden:YES];
    
    [menu setMenubarTitle:@"Settings"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (selectedCell == self.signOutCell) {
        [self signOut];
    } else if (selectedCell == self.clearCacheCell) {
        [self clearCache];
    }
}

- (void)clearCache {
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearMemory];
    [cache clearDisk];
    [cache cleanDisk];
    [cache setValue:nil forKey:@"memCache"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Cache successfully cleared!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)signOut {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    [api logoutWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [LSSharedUser unauthorizeSharedUser];
        
        //segue to login
        [self performSegueWithIdentifier:@"showLoginAfterSignOut" sender:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Sorry, you cannot sign out now, please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (IBAction)toggleSwitch:(LSSwitch *)sender {
    LSLikeastoreHTTPClient *api = [LSLikeastoreHTTPClient create];
    
    if (sender.isOn) {
        if ([sender.service isEqualToString:@"dribbble"]) {
            // show dribbble find user modal
            
        } else {
            [api connectNetwork:sender.service success:^(AFHTTPRequestOperation *operation, id responseObject) {
                LSWebAuthViewController *webAuthCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"webAuth"];
                [webAuthCtrl setUrlString:[responseObject objectForKey:@"authUrl"]];
                [self presentViewController:webAuthCtrl animated:YES completion:nil];
            } failure:nil];
        }
    } else {
        [api deleteNetwork:sender.service success:nil failure:nil];
    }
}

#pragma mark - Table view data source

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
