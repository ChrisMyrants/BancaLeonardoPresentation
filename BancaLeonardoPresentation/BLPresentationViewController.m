//
//  BLPresentationViewController.m
//  BancaLeonardoPresentation
//
//  Created by Altran_chmiranti on 17/09/15.
//  Copyright (c) 2015 Christian Miranti. All rights reserved.
//

#import "BLPresentationViewController.h"
#import "NGAParallaxMotion.h"

// Variables declaration
float parallaxIntensity;

@interface BLPresentationViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation BLPresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image view
    [self  initializeBackgroundImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - BACKGROUND

-(void)initializeBackgroundImage{
    
    // Set initial parallax value
    parallaxIntensity = 50.0;
    // Use parallax value on the image view
    self.backgroundImageView.parallaxIntensity = parallaxIntensity;
    // Set the image
    self.backgroundImageView.image = [UIImage imageNamed:@"Bicycle.png"];
    
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
