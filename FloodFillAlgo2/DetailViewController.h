//
//  DetailViewController.h
//  FloodFillAlgo2
//
//  Created by Gaurav Singh on 10/10/13.
//  Copyright (c) 2013 Gaurav Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
