//
//  ViewController.m
//  FollowMe
//
//  Created by sebastien FOCK CHOW THO on 3/11/15.
//  Copyright (c) 2015 Dlg developpement. All rights reserved.
//

#import "ViewController.h"

#import "LocationViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self makeTheView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)makeTheView {
    self.view.backgroundColor = [UIColor colorWithRed:237/255.0f green:237/255.0f blue:237/255.0f alpha:1.0f];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    /** Background **/
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SWIDTH, SHEIGHT)];
    background.image = [UIImage imageNamed:@"bc_home_font.png"];
    
    [self.view addSubview:background];
    int yRep = 100;
    
    /** Logo area **/
    UIView *whitearea = [[UIView alloc] initWithFrame:CGRectMake(20, yRep + 2, SWIDTH - 40, SWIDTH - 40)];
    whitearea.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1];
    
    [self.view addSubview:whitearea];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = whitearea.bounds;
    [whitearea addSubview:visualEffectView];
    yRep += 20;
    
    /** Logo **/
    UIView *backlogo1 = [[UIView alloc] initWithFrame:CGRectMake(40 + ((SWIDTH - 80) / 2) - 2, yRep + 2, ((SWIDTH - 80) / 2), ((SWIDTH - 80) / 2))];
    backlogo1.backgroundColor = [UIColor colorWithRed:155/255.0f green:155/255.0f blue:155/255.0f alpha:1.0f];
    
    [self.view addSubview:backlogo1];
    
    UIView *logo1 = [[UIView alloc] initWithFrame:CGRectMake(40 + ((SWIDTH - 80) / 2), yRep, ((SWIDTH - 80) / 2), ((SWIDTH - 80) / 2))];
    logo1.backgroundColor = [UIColor colorWithRed:33/255.0f green:49/255.0f blue:120/255.0f alpha:1.0f];
    
    [self.view addSubview:logo1];
    
    UILabel *name1 = [[UILabel alloc] initWithFrame:CGRectMake(40 + ((SWIDTH - 80) / 2), yRep, ((SWIDTH - 80) / 2), ((SWIDTH - 80) / 2))];
    name1.textColor = [UIColor whiteColor];
    name1.font = [UIFont fontWithName:@"Arial-BoldMT" size:110];
    name1.text = @"W";
    name1.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:name1];
    yRep += ((SWIDTH - 80) / 2);
    
    UIView *backlogo2 = [[UIView alloc] initWithFrame:CGRectMake(40 - 2, yRep + 2, ((SWIDTH - 80) / 2), ((SWIDTH - 80) / 2))];
    backlogo2.backgroundColor = [UIColor colorWithRed:155/255.0f green:155/255.0f blue:155/255.0f alpha:1.0f];
    
    [self.view addSubview:backlogo2];
    
    
    UIView *logo2 = [[UIView alloc] initWithFrame:CGRectMake(40, yRep, ((SWIDTH - 80) / 2), ((SWIDTH - 80) / 2))];
    logo2.backgroundColor = [UIColor colorWithRed:0/255.0f green:129/255.0f blue:0/255.0f alpha:1.0f];
    
    [self.view addSubview:logo2];
    
    UILabel *name2 = [[UILabel alloc] initWithFrame:CGRectMake(40, yRep, ((SWIDTH - 80) / 2), ((SWIDTH - 80) / 2))];
    name2.textColor = [UIColor whiteColor];
    name2.font = [UIFont fontWithName:@"Arial-BoldMT" size:110];
    name2.text = @"D";
    name2.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:name2];
    yRep += (((SWIDTH - 80) / 2) / 2) - 20;
    
    /** Title **/
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(40 + ((SWIDTH - 80) / 2), yRep, ((SWIDTH - 80) / 2), 40)];
    title.textColor = [UIColor colorWithRed:33/255.0f green:49/255.0f blue:120/255.0f alpha:1.0f];
    title.font = [UIFont fontWithName:@"Arial-BoldMT" size:25];
    title.text = @"Follow Me";
    title.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:title];
    yRep += 170;
    
    /** Connection **/
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(60, yRep + 50, SWIDTH - 120, 40)];
    btn1.backgroundColor = [UIColor whiteColor];
    [btn1.layer setCornerRadius:8.0];
    [btn1 addTarget:self action:@selector(connectController) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn1];
    
    UILabel *btn1design = [[UILabel alloc] initWithFrame:CGRectMake(0, yRep + 50, SWIDTH, 40)];
    btn1design.textColor = [UIColor colorWithRed:33/255.0f green:49/255.0f blue:120/255.0f alpha:1.0f];
    btn1design.font = [UIFont fontWithName:@"Arial" size:20];
    btn1design.text = @"Connexion";
    btn1design.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:btn1design];
    
    UIImageView *btn1pic = [[UIImageView alloc] initWithFrame:CGRectMake((SWIDTH / 2) - 120, yRep + 55, 30, 29)];
    btn1pic.image = [UIImage imageNamed:@"ic_home_connect.png"];
    
    [self.view addSubview:btn1pic];
    
    yRep += btn1.frame.size.height + 20;
    
}

#pragma mark - actions

- (void)connectController {
    LocationViewController *lvc = [[LocationViewController alloc] init];
    [self.navigationController pushViewController:lvc animated:YES];
}

@end
