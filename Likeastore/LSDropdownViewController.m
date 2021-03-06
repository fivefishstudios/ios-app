//
//  LSDropdownViewController.m
//  Likeastore
//
//  Created by Dmitri Voronianski on 29.04.14.
//  Copyright (c) 2014 Dmitri Voronianski. All rights reserved.
//

#import "LSDropdownViewController.h"
#import "LSLikeastoreHTTPClient.h"
#import "LSAllFavoritesViewController.h"
#import "LSExploreTableViewController.h"
#import "UIImage+Color.h"

#import <FontAwesomeKit/FAKFontAwesome.h>
#import <FontAwesomeKit/FAKFoundationIcons.h>

@interface LSDropdownViewController ()

@end

@implementation LSDropdownViewController

CAShapeLayer *openMenuShape;
CAShapeLayer *closedMenuShape;

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
    
    FAKFontAwesome *listIcon = [FAKFontAwesome barsIconWithSize:22.0f];
    [self.menuButton setTitle:nil forState:UIControlStateNormal];
    [self.menuButton setImage:[listIcon imageWithSize:CGSizeMake(22.0f, 22.0f)] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    FAKFontAwesome *inboxIcon = [FAKFontAwesome inboxIconWithSize:23.0f];
    [self.inboxButton setTitle:nil forState:UIControlStateNormal];
    [self.inboxButton setImage:[inboxIcon imageWithSize:CGSizeMake(23.0f, 23.0f)] forState:UIControlStateNormal];
    [self.inboxButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    FAKFontAwesome *settingsIcon = [FAKFontAwesome cogIconWithSize:22.0f];
    [self.settingsButton setTitle:nil forState:UIControlStateNormal];
    [self.settingsButton setImage:[settingsIcon imageWithSize:CGSizeMake(22.0f, 22.0f)] forState:UIControlStateNormal];
    [self.settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    FAKFontAwesome *searchIcon = [FAKFontAwesome searchIconWithSize:21.0f];
    [self.searchButton setTitle:nil forState:UIControlStateNormal];
    [self.searchButton setImage:[searchIcon imageWithSize:CGSizeMake(21.0f, 21.0f)] forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self customizeMenu];
    // Do any additional setup after loading the view.
}

- (void)customizeMenu {
    UIColor *menuColor = [UIColor colorWithHexString:@"#636577"];
    UIColor *menuColorHover = [UIColor colorWithHexString:@"#3D3F52"];
    CGFloat icon_size = 25.5f;
    
    for (UIButton *button in self.buttons) {
        if ([button.titleLabel.text isEqualToString:@"Feed"]) {
            FAKFoundationIcons *feedIcon = [FAKFoundationIcons homeIconWithSize:icon_size];
            
            [feedIcon addAttribute:NSForegroundColorAttributeName value:menuColor];
            [button setImage:[feedIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateNormal];
            
            [feedIcon addAttribute:NSForegroundColorAttributeName value:menuColorHover];
            [button setImage:[feedIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateHighlighted];
        }
        
        if ([button.titleLabel.text isEqualToString:@"Favorites"]) {
            FAKFoundationIcons *heartIcon = [FAKFoundationIcons heartIconWithSize:icon_size];
            
            [heartIcon addAttribute:NSForegroundColorAttributeName value:menuColor];
            [button setImage:[heartIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateNormal];
            
            [heartIcon addAttribute:NSForegroundColorAttributeName value:menuColorHover];
            [button setImage:[heartIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateHighlighted];
        }
        
        if ([button.titleLabel.text isEqualToString:@"Explore"]) {
            FAKFoundationIcons *exploreIcon = [FAKFoundationIcons compassIconWithSize:icon_size];
            
            [exploreIcon addAttribute:NSForegroundColorAttributeName value:menuColor];
            [button setImage:[exploreIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateNormal];
            
            [exploreIcon addAttribute:NSForegroundColorAttributeName value:menuColorHover];
            [button setImage:[exploreIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateHighlighted];
        }
        
        if ([button.titleLabel.text isEqualToString:@"Profile"]) {
            FAKFoundationIcons *profileIcon = [FAKFoundationIcons torsoIconWithSize:icon_size];
            
            [profileIcon addAttribute:NSForegroundColorAttributeName value:menuColor];
            [button setImage:[profileIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateNormal];
            
            [profileIcon addAttribute:NSForegroundColorAttributeName value:menuColorHover];
            [button setImage:[profileIcon imageWithSize:CGSizeMake(icon_size, icon_size)] forState:UIControlStateHighlighted];
        }
        
        // align image and text
        [button sizeToFit];
        button.frame = CGRectMake(0.0f, 132.0f, 0.0f, 0.0f);
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 132.0f - button.titleLabel.frame.size.width/2.4f, 0.0f, 0.0f);
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 0.0f);
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        // set button states
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#161625" alpha:0.9f]] forState:UIControlStateHighlighted];
        
        // toggle bottom border on taps
        [button addTarget:self action:@selector(hideBottomBorder:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(showBottomBorder:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(showBottomBorder:) forControlEvents:UIControlEventTouchDragOutside];
        
        // add bottom border
        if (button != self.buttons.lastObject) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(8.0f, 50.0f, button.frame.size.width-16.0f, 1.4f)];
            lineView.tag = 1;
            lineView.backgroundColor = [UIColor colorWithHexString:@"#3D3F52" alpha:0.9f];
            [button addSubview:lineView];
        }
    }
}

- (void)hideBottomBorder:(UIButton *)button {
    for (UIView *border in button.subviews) {
        if (border.tag == 1) {
            [border setHidden:YES];
        }
    }
}

- (void)showBottomBorder:(UIButton *)button {
    for (UIView *border in button.subviews) {
        if (border.tag == 1 && [border isHidden]) {
            [border setHidden:NO];
        }
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawOpenLayer {
    openMenuShape = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = self.menubar.frame.size.height;
    int width = self.menubar.frame.size.width;
    float trianglePlacement = 0.046;
    int triangleDirection = -1; // 1 for down, -1 for up.
    int triangleSize = 5;
    int trianglePosition = trianglePlacement*width;
    
    // The path for the triangle (showing that the menu is open).
    UIBezierPath *triangleShape = [[UIBezierPath alloc] init];
    [triangleShape moveToPoint:CGPointMake(trianglePosition, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+triangleSize, height+triangleDirection*triangleSize)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+2*triangleSize, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition, height)];
    
    [openMenuShape setPath:triangleShape.CGPath];
    [openMenuShape setFillColor:[self.menu.backgroundColor CGColor]];
    [openMenuShape setBounds:CGRectMake(0.0f, 0.0f, height+triangleSize, width)];
    [openMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [openMenuShape setPosition:CGPointMake(0.0f, 0.0f)];
}

- (void)drawClosedLayer {
    closedMenuShape = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    CGFloat height = self.menubar.frame.size.height;
    CGFloat width = self.menubar.frame.size.width;
    
    [closedMenuShape setBounds:CGRectMake(0.0f, 0.0f, height, width)];
    [closedMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [closedMenuShape setPosition:CGPointMake(0.0f, 0.0f)];
}

- (void) showMenu {
    self.menu.hidden = NO;
    
    [closedMenuShape removeFromSuperlayer];
    [[[self view] layer] addSublayer:openMenuShape];
    
    // Set new origin of menu
    CGRect menuFrame = self.menu.frame;
    menuFrame.origin.y = self.menubar.frame.size.height;
    
    // Set new alpha of Container View (to get fade effect)
    float containerAlpha = 0.98f;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:4.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.menu.frame = menuFrame;
                         [self.container setAlpha: containerAlpha];
                     }
                     completion:^(BOOL finished){
                     }];
    [UIView commitAnimations];
    
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFavoritesFromMenu"]) {
        [(LSAllFavoritesViewController *) [segue destinationViewController] setFavoritesType:@"all"];
        return;
    }
    
    if ([segue.identifier isEqualToString:@"showInbox"]) {
        [(LSAllFavoritesViewController *) [segue destinationViewController] setFavoritesType:@"inbox"];
        return;
    }
}

#pragma mark - Search bar

- (IBAction)searchButtonClickHandle:(id)sender {
    // check if destination view contoller is embed in navigation
    if ([self.childViewControllers.firstObject class] == [UINavigationController class]) {
        UIViewController *nestedCtrl = self.childViewControllers.firstObject;
        [nestedCtrl.childViewControllers.firstObject toggleSearchBar];
    } else {
        [self.childViewControllers.firstObject toggleSearchBar];
    }
}

@end
