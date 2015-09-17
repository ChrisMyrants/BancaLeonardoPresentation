//
//  BLPresentationTableViewCell.h
//  BancaLeonardoPresentation
//
//  Created by Altran_chmiranti on 17/09/15.
//  Copyright (c) 2015 Christian Miranti. All rights reserved.
//



#import <UIKit/UIKit.h>



@interface BLPresentationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *presentationImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
