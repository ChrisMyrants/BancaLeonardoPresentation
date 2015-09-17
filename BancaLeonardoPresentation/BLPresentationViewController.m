//
//  BLPresentationViewController.m
//  BancaLeonardoPresentation
//
//  Created by Altran_chmiranti on 17/09/15.
//  Copyright (c) 2015 Christian Miranti. All rights reserved.
//



#import "BLPresentationViewController.h"
#import "BLPresentationTableViewCell.h"
#import "NGAParallaxMotion.h"



// Variables declaration
float parallaxIntensity = 50.0;
float parallaxMaxValue = 200.0;
float parallaxMinValue = 0;
NSInteger backgroundImageIndex = 0;
float backgroundAlpha = 0.2;
NSString *showString = @"Mostra";
NSString *hideString = @"Nascondi";
bool isHidden = NO;



@interface BLPresentationViewController () <UITableViewDataSource, UITableViewDelegate>

// Background Image View
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray *imagesArray;

// Settings View
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
@property (weak, nonatomic) IBOutlet UISlider *parallaxIntensitySlider;
@property (weak, nonatomic) IBOutlet UILabel *parallaxIntensityValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *beforeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

// Table View
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cellsContent;

@end



@implementation BLPresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the background image view
    [self  initializeBackgroundImage];
    // Set the settings view
    [self initializeSettings];
    // Set array for cells
    [self initializeCellsContentArray];
    // Add a clear background to the table view
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



#pragma mark - BACKGROUND

-(void)initializeBackgroundImage{
    
    // Set initial parallax value
    parallaxIntensity = 50.0;
    // Use parallax value on the image view
    self.backgroundImageView.parallaxIntensity = parallaxIntensity;
    // Initialize the images names array
    self.imagesArray = @[@"Bicycle.png", @"Binoculars.png", @"Camera.png", @"Desk Tidy.png", @"Flightcase.png", @"Headphones.png", @"Lightbulb.png", @"Microscope.png", @"Stopwatch.png", @"Violin.png"];
    // Set the image
    self.backgroundImageView.image = [UIImage imageNamed:[self.imagesArray objectAtIndex:backgroundImageIndex]];
    // Blur the image
    self.backgroundImageView.image = [self blurWithCoreImage:self.backgroundImageView.image];
    // Set alpha with backgroundAlpha
    self.backgroundImageView.alpha = backgroundAlpha;
}


- (IBAction)beforeButtonPressed:(id)sender {

    // Set back background image index
    if (backgroundImageIndex == 0) {
        backgroundImageIndex = [self.imagesArray count] - 1;
    }
    else{
        backgroundImageIndex--;
    }
    
    // Change background image based on index
    self.backgroundImageView.image = [UIImage imageNamed:[self.imagesArray objectAtIndex:backgroundImageIndex]];
}


- (IBAction)nextButtonPressed:(id)sender {
    
    // Set back background image index
    if (backgroundImageIndex == [self.imagesArray count] - 1) {
        backgroundImageIndex = 0;
    }
    else{
        backgroundImageIndex++;
    }
    
    // Change background image based on index
    self.backgroundImageView.image = [UIImage imageNamed:[self.imagesArray objectAtIndex:backgroundImageIndex]];
}


- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@10 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
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
    // Setting show hide button
    [self.showHideButton setTitle:hideString forState:UIControlStateNormal];
    isHidden = NO;
}


- (IBAction)parallaxIntensityChangedValue:(id)sender {
    
    parallaxIntensity = self.parallaxIntensitySlider.value;
    self.parallaxIntensityValueLabel.text = [NSString stringWithFormat:@"%.00f", parallaxIntensity];
    self.backgroundImageView.parallaxIntensity = parallaxIntensity;
}

- (IBAction)showHideTapped:(id)sender {
    
    if (isHidden) {
        isHidden = NO;
        [self.showHideButton setTitle:hideString forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^(void){
            self.settingsView.alpha = 1.0;
        }];
    }
    else{
        isHidden = YES;
        [self.showHideButton setTitle:showString forState:UIControlStateNormal];
        [UIView animateWithDuration:0.2 animations:^(void){
            self.settingsView.alpha = 0;
        }];
    }
}



#pragma mark - TABLE

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // Numero di celle pari al numero di elementi presente in cellsContent
    return [self.cellsContent count];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    // Una sola sezione prevista
    return 1;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
#warning - Still to complete
    return 0.0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

#warning - Still to complete
    return 0.0;
}
*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Inizializzare la cella da restituire passando l'identificatore assegnato alla cella della table nella Storyboard
    BLPresentationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    // Recuperare le informazioni corrispondenti all'indice della cella
    NSDictionary *dict = [self.cellsContent objectAtIndex:indexPath.row];
    // Impostazione dell'immagine
    UIImage *imageToShow = [UIImage imageNamed:[dict valueForKey:@"image_name"]];
    cell.presentationImageView.image = imageToShow;
    // Impostazione del titolo
    NSString *title = [dict valueForKey:@"title"];
    cell.titleLabel.text = title;
    // Impostazione della descrizione
    NSString *description = [dict valueForKey:@"description"];
    cell.descriptionLabel.text = description;
    
    // Impostiamo lo sfondo della cella trasparente
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}


-(void)initializeCellsContentArray{
    
    // Inizializzare l'array
    self.cellsContent = [[NSMutableArray alloc] init];
    
    // First cell
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 1", @"title", @"Description.......", @"description", @"Binoculars.png", @"image_name", nil];
    [self.cellsContent addObject:dict1];
    // First cell
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 2", @"title", @"Description.......", @"description", @"Camera.png", @"image_name", nil];
    [self.cellsContent addObject:dict2];
    // First cell
    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 3", @"title", @"Description.......", @"description", @"Desk Tidy.png", @"image_name", nil];
    [self.cellsContent addObject:dict3];
    // First cell
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 4", @"title", @"Description.......", @"description", @"Headphones.png", @"image_name", nil];
    [self.cellsContent addObject:dict4];
    // First cell
    NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 5", @"title", @"Description.......", @"description", @"Flightcase.png", @"image_name", nil];
    [self.cellsContent addObject:dict5];
    // First cell
    NSDictionary *dict6 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 6", @"title", @"Description.......", @"description", @"Microscope.png", @"image_name", nil];
    [self.cellsContent addObject:dict6];
    
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
