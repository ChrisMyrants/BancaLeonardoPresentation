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
float blurIntensity = 2.0;
float blurMaxValue = 10.0;
float blurMinValue = 0.0;
NSInteger backgroundImageIndex = 0;
float backgroundAlpha = 0.2;
NSString *showString = @"Mostra";
NSString *hideString = @"Nascondi";
bool isHidden = NO;
float scrollDimensions = 150.0;



@interface BLPresentationViewController () <UITableViewDataSource, UITableViewDelegate>

// Background Image View
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray *imagesArray;
@property (strong, nonatomic) UIImage *backgroundImage;

// Settings View
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
@property (weak, nonatomic) IBOutlet UISlider *parallaxIntensitySlider;
@property (weak, nonatomic) IBOutlet UILabel *parallaxIntensityValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *beforeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *blurIntensitySlider;
@property (weak, nonatomic) IBOutlet UILabel *blurIntensityValueLabel;


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
    self.backgroundImage = [UIImage imageNamed:[self.imagesArray objectAtIndex:backgroundImageIndex]];
    self.backgroundImageView.image = self.backgroundImage;
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
    self.backgroundImage = [UIImage imageNamed:[self.imagesArray objectAtIndex:backgroundImageIndex]];
    self.backgroundImageView.image = self.backgroundImage;
    // Add blur effect
    self.backgroundImageView.image = [self blurWithCoreImage:self.backgroundImage];
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
    self.backgroundImage = [UIImage imageNamed:[self.imagesArray objectAtIndex:backgroundImageIndex]];
    // Add blur effect
    self.backgroundImageView.image = [self blurWithCoreImage:self.backgroundImage];
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
    int integerForGaussian = (int)roundf(blurIntensity);
    NSNumber *numberForGaussian = [NSNumber numberWithInt:integerForGaussian];
    [gaussianBlurFilter setValue:numberForGaussian forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
//    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.width);

    // Draw base image.
//    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    float uiImageRatio = sourceImage.size.width / sourceImage.size.height;
    float halfViewHeight = self.view.frame.size.height / 2.0;
    float halfImageViewHeight = self.view.frame.size.width / uiImageRatio;
    halfImageViewHeight = halfImageViewHeight / 2.0;
    float yPosition = halfImageViewHeight - halfViewHeight;
    CGContextDrawImage(outputContext, CGRectMake(0, yPosition, self.view.frame.size.width, self.view.frame.size.width / uiImageRatio), cgImage);
    
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
    // Setting parallax intensity slider values
    self.parallaxIntensitySlider.maximumValue = parallaxMaxValue;
    self.parallaxIntensitySlider.minimumValue = parallaxMinValue;
    self.parallaxIntensitySlider.value = parallaxIntensity;
    self.parallaxIntensityValueLabel.text = [NSString stringWithFormat:@"%.00f", parallaxIntensity];
    // Setting blur intensity slider values
    self.blurIntensitySlider.maximumValue = blurMaxValue;
    self.blurIntensitySlider.minimumValue = blurMinValue;
    self.blurIntensitySlider.value = blurIntensity;
    self.blurIntensityValueLabel.text = [NSString stringWithFormat:@"%.00f", blurIntensity];
    // Setting show hide button
    [self.showHideButton setTitle:hideString forState:UIControlStateNormal];
    isHidden = NO;
}


- (IBAction)parallaxIntensityChangedValue:(id)sender {
    
    parallaxIntensity = self.parallaxIntensitySlider.value;
    self.parallaxIntensityValueLabel.text = [NSString stringWithFormat:@"%.00f", parallaxIntensity];
    self.backgroundImageView.parallaxIntensity = parallaxIntensity;
}



- (IBAction)blurIntensityChangedValue:(id)sender {
    
    blurIntensity = self.blurIntensitySlider.value;
    self.blurIntensityValueLabel.text = [NSString stringWithFormat:@"%.00f", blurIntensity];
    // Change background image based on index
    self.backgroundImage = [UIImage imageNamed:[self.imagesArray objectAtIndex:backgroundImageIndex]];
    // Add blur effect
    self.backgroundImageView.image = [self blurWithCoreImage:self.backgroundImage];
    /*
    for (int i = 0; i < [self.cellsContent count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        BLPresentationTableViewCell *cell = (BLPresentationTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
        cell.presentationImageView.image = [self blurWithCoreImage:cell.presentationImageView.image];
    }
     */
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
    // Impostazione dell'effetto blur all'immagine
    /*
     cell.presentationImageView.image = [self blurWithCoreImage:cell.presentationImageView.image];
     */
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



#pragma mark - UPDATE

// Questo metodo viene richiamato automaticamente ogni volta che la scroll view a cui è stato assegnato questo Controller come delegate viene scrollata
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self updateVisibleCellsWithMotion];
}


-(void)updateVisibleCellsWithMotion{

    // Cicliamo per ogni cella visibile sullo schermo
    for (int i = 0; i < self.tableView.indexPathsForVisibleRows.count; i++) {
        // La cella desiderata è una di quelle presenti su schermo e grazie alla objectAtIndex riusciamo a recuperarla (gli altri metodi provati sono stati inefficaci)
        BLPresentationTableViewCell *cell = (BLPresentationTableViewCell *)[self.tableView cellForRowAtIndexPath:[self.tableView.indexPathsForVisibleRows objectAtIndex:i]];
        // Calcolo della distance percentuale che il contenuto della scroll della cella dovrebbe avere rispetto al suo contenuto
        float distancePercentage = [self calculateDistancePercentageOfCell:cell];
        // Calcolo dell'offset vero e proprio basato sulla percentuale precedentemente calcolata
        float offsetForScroll = [self calculateOffsetForScrollView:cell.presentationScroller withPercentage:distancePercentage];
        // Applicazione dell'offset sul contenuto della scroll presente dentro la cella
        [cell.presentationScroller setContentOffset:CGPointMake(0, offsetForScroll)];
    }
}


// Calcolo del rapporto tra distanza della singola cella di raggiungere il Top della tabella (+ l'altezza della scroll) rispetto all'altezza totale da quando appare dallo schermo a quando scompare
-(float)calculateDistancePercentageOfCell:(UITableViewCell *)cell{
    
    // Altezza totale data dall'altezza della tabella + l'altezza (in questo caso fissata) della scroll view presente nella cella
    float totalHeight = self.tableView.bounds.size.height + scrollDimensions;
    // Distanza tra la posizione attuale della cella e il top
    CGRect distanceRect = [self.tableView convertRect:cell.frame toView:self.view];
    float distanceFromTopTable = distanceRect.origin.y;
    // Calcolo del rapporto
    float distanceFromTotalTop = distanceFromTopTable - scrollDimensions;
    
    return distanceFromTotalTop / totalHeight;
}


// Calcolo dell'offset del contenuto della scroll della singola cella in base al rapporto tra la distanza della cella stessa rispetto all'altezza massima che deve raggiungere
-(float)calculateOffsetForScrollView:(UIScrollView *)scrollView withPercentage:(float)percentage{
    
    float scrollContentHeightDifference = scrollView.bounds.size.height - scrollView.contentSize.height;
    
    return scrollContentHeightDifference * percentage;
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
