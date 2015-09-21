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
float scrollDimensions = 200.0;
float spaceFromScrollToDescription = 37.0;
float descriptionHeight = 0;
int loreLipsumIndex = 0;
float headerMaxHeight = 150.0;
float headerMinimumHeight = 50.0;



@interface BLPresentationViewController () <UITableViewDataSource, UITableViewDelegate>

// Background Image View
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray *imagesArray;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

// Header View
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstraint;

// Settings View
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UIButton *showHideButton;
@property (weak, nonatomic) IBOutlet UISlider *parallaxIntensitySlider;
@property (weak, nonatomic) IBOutlet UILabel *parallaxIntensityValueLabel;
@property (weak, nonatomic) IBOutlet UIButton *beforeButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *blurIntensitySlider;
@property (weak, nonatomic) IBOutlet UILabel *blurIntensityValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *numParoleLabel;
@property (weak, nonatomic) IBOutlet UISlider *numParoleSlider;
@property float numParoleMaxValue;
@property float numParoleMinValue;
@property float numParoleIndex;

// Table View
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *cellsContent;
@property (strong, nonatomic) NSArray *loreLipsum;

@end



@implementation BLPresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Fare in modo che l'altezza delle celle della table view si adattino al loro contenuto, in particolare alla quantità di testo presente nella descriprion label
    self.tableView.estimatedRowHeight = 68.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Set the lore lipsum array for the cells
    [self initializeLoreLipsumArray];
    // Set the description settings based on lore lipsum array
    [self initializeNumParole];
    // Set the background image view
    [self  initializeBackgroundImage];
    // Set the settings view
    [self initializeSettings];
    // Set array for cells
    [self initializeCellsContentArray];
    // Add a clear background to the table view
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView reloadData];
}


// Metodo da richiamare per impostare la status bar con lo style light per ottenere le scritte della status bar in bianco
- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
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
    // Set Banca Leonardo blue for background
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:20.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
    
    // Set header background color
    self.headerView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:20.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
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
    // Setting num parole values
    self.numParoleSlider.minimumValue = self.numParoleMinValue;
    self.numParoleSlider.maximumValue = self.numParoleMaxValue;
    self.numParoleSlider.value = self.numParoleIndex;
    self.numParoleLabel.text = [NSString stringWithFormat:@"%.00f", self.numParoleIndex];
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


- (IBAction)numParoleChangedValue:(id)sender {
    
    self.numParoleIndex = self.numParoleSlider.value;
    self.numParoleLabel.text = [NSString stringWithFormat:@"%.00f", self.numParoleIndex];
    loreLipsumIndex = (int)roundf(self.numParoleIndex);
    [self initializeLoreLipsumArray];
    [self initializeCellsContentArray];
    [self.tableView reloadData];
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


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    BLPresentationTableViewCell *cellBL = (BLPresentationTableViewCell *)cell;
    
    // Calcolo l'altezza della label della descrizione in modo tale da avere una misura dinamica dell'altezza complessiva della cella
    descriptionHeight = [self heightToAddCaluclation:cellBL.descriptionLabel];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // Numero di celle pari al numero di elementi presente in cellsContent
    return [self.cellsContent count];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    // Una sola sezione prevista
    return 1;
}


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
    
    // Calcolo l'altezza della label della descrizione in modo tale da avere una misura dinamica dell'altezza complessiva della cella
    descriptionHeight = [self heightToAddCaluclation:cell.descriptionLabel];

    return cell;
}


-(void)initializeLoreLipsumArray{
    self.loreLipsum = [[NSArray alloc] initWithObjects:
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi convallis.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam aliquam interdum augue et ultrices. Praesent molestie augue non enim fringilla.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus eleifend ullamcorper egestas. Morbi nec ipsum cursus, elementum nunc vitae, molestie quam. Mauris sed leo felis. Praesent dignissim, lacus at mattis.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sollicitudin ex id mollis commodo. In sit amet ullamcorper purus, sit amet bibendum justo. Sed sodales ante et ipsum viverra, sed tristique eros condimentum. Nulla a risus sed ante molestie vehicula.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus eget aliquet magna. Ut nec nulla bibendum orci mollis commodo ut non nibh. Donec fringilla ex augue, ac suscipit odio sagittis vitae. Cras ornare rutrum orci non ultrices. Sed mattis lectus a purus posuere elementum. Cras mauris lectus, malesuada quis ultrices.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque luctus vitae diam mollis pulvinar. Duis aliquet lectus in sem vulputate, ut cursus diam condimentum. Nunc quis gravida tellus, venenatis aliquam nulla. Sed sit amet porttitor ante. Quisque vel eros lacinia, maximus arcu eu, placerat tortor. Nam iaculis, nisl sed scelerisque finibus, sapien lectus eleifend lorem, eget iaculis diam sapien et.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis ac auctor erat. Proin ut dui erat. Nam id felis eu sem ultricies gravida commodo non arcu. Ut eget risus in lorem dignissim dapibus vitae ut risus. Ut id tincidunt nulla. Vivamus sodales ligula eget nisl condimentum aliquam. Nulla ultricies leo ligula, vel pharetra dui facilisis at. Sed euismod felis fringilla arcu elementum dictum. Phasellus a finibus nulla. Fusce tincidunt vel.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam lacinia erat vel aliquam finibus. Phasellus massa augue, placerat et urna et, condimentum laoreet neque. Nam dapibus arcu suscipit, viverra dui cursus, porttitor ipsum. Curabitur mattis aliquet lacus, id facilisis lacus elementum sed. Quisque suscipit ultrices sapien sit amet accumsan. Vestibulum dictum laoreet lacinia. Fusce nulla odio, dignissim ut fermentum eu, facilisis non magna. Donec ut libero sed dolor dapibus tincidunt et nec quam. Duis non ultricies lorem. Quisque eu odio.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras aliquet ultrices orci at viverra. Donec ut orci eu neque lobortis feugiat eu eu nunc. Nulla sagittis orci ac suscipit fermentum. Nulla congue elit turpis, vitae lobortis ex tincidunt vitae. Vivamus sollicitudin facilisis ex efficitur varius. Fusce diam nisl, porta sit amet elit vitae, ornare malesuada erat. Nam porttitor magna in mollis convallis. Quisque consequat nisl quam, nec posuere enim vehicula sed. Suspendisse potenti. Quisque non ex molestie, luctus massa quis, suscipit nisl. Vivamus sed enim mattis, tristique lorem sit amet.",
                       @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla commodo lobortis ex, sit amet rutrum sem lacinia a. Vestibulum bibendum vel nulla sed ornare. Duis odio augue, ullamcorper nec venenatis vel, euismod sit amet neque. Aliquam porta viverra ipsum. Nam tempus malesuada ex in elementum. Sed et nulla tincidunt magna pellentesque suscipit a et ante. Aenean a auctor dui. In posuere semper urna at efficitur. Maecenas accumsan dictum velit et ultrices. Sed ullamcorper nunc ipsum, sed pharetra ex posuere ac. Duis vitae dapibus dolor, ut aliquet orci. Vestibulum at ipsum iaculis, dictum tellus ut, posuere lectus. Suspendisse blandit faucibus semper.",
                       nil];
}


-(void)initializeCellsContentArray{
    
    // Inizializzare l'array
    self.cellsContent = [[NSMutableArray alloc] init];
    
    // First cell
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 1", @"title", [self.loreLipsum objectAtIndex:loreLipsumIndex], @"description", @"Binoculars.png", @"image_name", nil];
    [self.cellsContent addObject:dict1];
    // First cell
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 2", @"title", [self.loreLipsum objectAtIndex:loreLipsumIndex], @"description", @"Camera.png", @"image_name", nil];
    [self.cellsContent addObject:dict2];
    // First cell
    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 3", @"title", [self.loreLipsum objectAtIndex:loreLipsumIndex], @"description", @"Desk Tidy.png", @"image_name", nil];
    [self.cellsContent addObject:dict3];
    // First cell
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 4", @"title", [self.loreLipsum objectAtIndex:loreLipsumIndex], @"description", @"Headphones.png", @"image_name", nil];
    [self.cellsContent addObject:dict4];
    // First cell
    NSDictionary *dict5 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 5", @"title", [self.loreLipsum objectAtIndex:loreLipsumIndex], @"description", @"Flightcase.png", @"image_name", nil];
    [self.cellsContent addObject:dict5];
    // First cell
    NSDictionary *dict6 = [NSDictionary dictionaryWithObjectsAndKeys:@"Title 6", @"title", [self.loreLipsum objectAtIndex:loreLipsumIndex], @"description", @"Microscope.png", @"image_name", nil];
    [self.cellsContent addObject:dict6];
}


-(void)initializeNumParole{

    self.numParoleMinValue = 0;
    self.numParoleMaxValue = [self.loreLipsum count] - 1.0;
    self.numParoleIndex = 0;
}



#pragma mark - UPDATE

// Questo metodo viene richiamato automaticamente ogni volta che la scroll view a cui è stato assegnato questo Controller come delegate viene scrollata
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self updateVisibleCellsWithMotion];

    if (scrollView.contentOffset.y >= 0) {
        if (scrollView.contentOffset.y <= headerMaxHeight - headerMinimumHeight) {
            self.headerHeightConstraint.constant = headerMaxHeight - scrollView.contentOffset.y;
        }
    }
    else{
        self.headerHeightConstraint.constant = headerMaxHeight;
    }
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


-(float)heightToAddCaluclation:(UILabel *)aLabel{
    
    CGRect rect = [aLabel.text boundingRectWithSize:CGSizeMake(aLabel.frame.size.width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName : aLabel.font}
                                            context:nil];
    float finalHeight = ceil(rect.size.height / aLabel.font.lineHeight) * 21.0;
    return finalHeight;
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
