//
//  DetailViewController.m
//  FloodFillAlgo2
//
//  Created by Gaurav Singh on 10/10/13.
//  Copyright (c) 2013 Gaurav Singh. All rights reserved.
//

#import "FloodFill.h"
#import "DetailViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import "UIImage+FloodFill.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        
        UIImage *img = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageNamed:_detailItem], 1)];
        [self.imageView setBounds:CGRectMake(0, 0, img.size.width, img.size.height)];
        [self.imageView setImage:img];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"touchesMoved");
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 1)
    {
        UITouch * touch = [touches anyObject];
        if ([touch tapCount] == 1)
        {
       
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
              //  UIImage *filledImage = [self floodFillAtPoint:[touch locationInView:self.imageView]];
                 UIImage *filledImage= [self.imageView.image floodFillFromPoint:[touch locationInView:self.imageView] withColor:[self getRandomColor] andTolerance:0];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.imageView.image = filledImage;
                });
            });

        
        }
    }

}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (UIImage*)floodFillAtPoint:(CGPoint)fillCenter
{
    unsigned char *rawData = [self rawDataFromImage:self.imageView.image];
    
    color fromColor = [FloodFill getColorForX:fillCenter.x Y:fillCenter.y fromImage:rawData imageWidth:self.imageView.image.size.width];
    int fromColorInt = [self mkcolorI:fromColor.red G:fromColor.green B:fromColor.blue A:fromColor.alpha];
    
    CGFloat r, g, b, a;
    
    [[self getRandomColor] getRed: &r green:&g blue:&b alpha:&a];
    
    CGFloat alpha = 255.0 * ((100.0 - 0.9) / 100.0);
    int toColorInt = [self mkcolorI:r*255 G:g*255 B:b*255 A:alpha];
    
   
    
    
    [FloodFill floodfillX:fillCenter.x Y:fillCenter.y image:rawData width:self.imageView.image.size.width height:self.imageView.image.size.height origIntColor:fromColorInt replacementIntColor:toColorInt];
    
    UIImage *filledImage = [self imageFromRawData:rawData];
    
	free(rawData);
    
	return filledImage;
}

// creates color int from RGBA
- (int)mkcolorI:(int)red G:(int)green B:(int)blue A:(int)alpha {
    int x = 0;
    x |= (red & 0xff) << 24;
    x |= (green & 0xff) << 16;
    x |= (blue & 0xff) << 8;
    x |= (alpha & 0xff);
    return x;
}

- (unsigned char*)rawDataFromImage:(UIImage*)image
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
												 bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
	
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}

- (UIImage*)imageFromRawData:(unsigned char*)rawData
{
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * self.imageView.image.size.width;
    CGImageRef imageRef = [self.imageView.image CGImage];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    
	CGContextRef context = CGBitmapContextCreate(rawData,
                                                 self.imageView.image.size.width,
                                                 self.imageView.image.size.height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
	
	imageRef = CGBitmapContextCreateImage (context);
	UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
	
	CGContextRelease(context);
    
    CGImageRelease(imageRef);
    
    return rawImage;
}


- (UIColor*)getRandomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
