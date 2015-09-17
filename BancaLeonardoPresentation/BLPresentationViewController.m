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
float parallaxIntensity = 50.0;
float parallaxMaxValue = 200.0;
float parallaxMinValue = 0;

@interface BLPresentationViewController ()

// Background Image View
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

// Settings View
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
@property (weak, nonatomic) IBOutlet UISlider *parallaxIntensitySlider;
@property (weak, nonatomic) IBOutlet UILabel *parallaxIntensityValueLabel;


@end

@implementation BLPresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image view
    [self  initializeBackgroundImage];
    // Set the settings view
    [self initializeSettings];
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


#pragma mark - SETTINGS

-(void)initializeSettings{

    // Set background color
    self.settingsView.backgroundColor = [UIColor lightGrayColor];
    // Setting slider values
    self.parallaxIntensitySlider.maximumValue = parallaxMaxValue;
    self.parallaxIntensitySlider.minimumValue = parallaxMinValue;
    self.parallaxIntensitySlider.value = parallaxIntensity;
    self.parallaxIntensityValueLabel.text = [NSString stringWithFormat:@"%.00f", parallaxIntensity];
}


- (IBAction)parallaxIntensityChangedValue:(id)sender {
    
    parallaxIntensity = self.parallaxIntensitySlider.value;
    self.parallaxIntensityValueLabel.text = [NSString stringWithFormat:@"%.00f", parallaxIntensity];
    self.backgroundImageView.parallaxIntensity = parallaxIntensity;
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
