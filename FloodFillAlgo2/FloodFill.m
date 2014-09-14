//
//  FloodFill.m
//  FloodFillAlgo2
//
//  Created by Gaurav Singh on 10/10/13.
//  Copyright (c) 2013 Gaurav Singh. All rights reserved.
//

#import "FloodFill.h"

@implementation FloodFill

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/*
 * Flood Fill 4 algorythm, stack based
 */
+(int)floodfillX:(int)x Y:(int)y image:(unsigned char*)image width:(int)w height:(int)h origIntColor:(int)iOrigColor replacementIntColor:(int)iColor {
    // Replacement color
    color replacement = [FloodFill imkcolor:iColor];
    color target = [FloodFill imkcolor:iOrigColor];
    
    // Target color
    //int index = [FloodFill getIndexX:x Y:y W:w BPC:bpc];
    //color target = [FloodFill getColorForINDEX:index fromImage:image BPC:bpc]; //getColor(getIndex(x, y, w, bpc), image, bpc);
    
    if ([FloodFill compareColor:target withTargetColor:replacement]) // if colors identical we don't need to fill
        return 0;
    
    // Creating the list/stack
    node *list = (node*) malloc(sizeof(struct node_st));
    (*list).x = x;
    (*list).y = y;
    (*list).next = NULL;
    
    // The algorithm itself
    int iterations=0;
    
    while (list != NULL) {
        
        node *pointer_to_free = list;
        node current = *list;
        list = current.next;
        
        int index = [FloodFill getIndexX:current.x Y:current.y W:w];
        color current_color = [FloodFill getColorForINDEX:index fromImage:image];
        int blending_alpha = [FloodFill compareColor:current_color withTargetColor:target];
        if (blending_alpha != (int)0x00) {
            color result = [FloodFill blendColor:current_color withColor:replacement alpha:blending_alpha];
            image[index] = result.red;
            image[index + 1] = result.green;
            image[index + 2] = result.blue;
        }
        
        // Query neighbours...
        node *new;
        
        // North
        if ([FloodFill compareColorForPointX:current.x Y:current.y-1 image:image width:w height:h targetColor:target] != (int)0x00) {
            new = (node*) malloc(sizeof(struct node_st));
            (*new).x = current.x;
            (*new).y = current.y-1;
            (*new).next = list;
            list = new;
        }
        
        // South
        if ([FloodFill compareColorForPointX:current.x Y:current.y+1 image:image width:w height:h targetColor:target] != (int)0x00) {
            new = (node*) malloc(sizeof(struct node_st));
            (*new).x = current.x;
            (*new).y = current.y+1;
            (*new).next = list;
            list = new;
        }
        
        // West
        if ([FloodFill compareColorForPointX:current.x-1 Y:current.y image:image width:w height:h targetColor:target] != (int)0x00) {
            new = (node*) malloc(sizeof(struct node_st));
            (*new).x = current.x-1;
            (*new).y = current.y;
            (*new).next = list;
            list = new;
        }
        
        // East
        if ([FloodFill compareColorForPointX:current.x+1 Y:current.y image:image width:w height:h targetColor:target] != (int)0x00) {
            new = (node*) malloc(sizeof(struct node_st));
            (*new).x = current.x+1;
            (*new).y = current.y;
            (*new).next = list;
            list = new;
        }
        
        free(pointer_to_free);
        iterations ++; if (iterations == w*h*COLOR_DEPTH*5) break;
    }
    NSLog(@"Iterations: %d", iterations);
    return 0;
}

// Scanline flood fill algorythm (based on C implementation here: http://www.academictutorials.com/graphics/graphics-flood-fill.asp )
// WARNING: DOESN'T WORK!!! Critical bug here...
+(int)scanlineFloodfillX:(int)x Y:(int)y image:(unsigned char*)image width:(int)w height:(int)h origIntColor:(int)iOrigColor replacementIntColor:(int)iColor {
    // Replacement color
    color replacement = [FloodFill imkcolor:iColor];
    // Current color of the point where tap was received
    color target = [FloodFill imkcolor:iOrigColor];
    
    if ([FloodFill compareColor:target withTargetColor:replacement]) // if colors identical we don't need to fill
        return 0;
    
    // Creating the list/stack
    node *list = (node*) malloc(sizeof(struct node_st));
    (*list).x = x;
    (*list).y = y;
    (*list).next = NULL;
    
    // The algorithm itself
    int y1; 
    BOOL spanLeft, spanRight;
    
    while (list != NULL) {
        node *pointer_to_free = list;
        node current = *list;
        list = current.next;
        
        y1 = current.y;
        
        color current_color = [FloodFill getColorForX:current.x Y:y1 fromImage:image imageWidth:w];
        while(y1 >= 0 && [FloodFill compareColor:current_color withTargetColor:target]!=0) {
            y1--;   
            current_color = [FloodFill getColorForX:current.x Y:y1 fromImage:image imageWidth:w];
        }
        y1++;
        
        spanLeft = NO;
        spanRight = NO;
        
        current_color = [FloodFill getColorForX:current.x Y:y1 fromImage:image imageWidth:w];
        int blending_alpha = [FloodFill compareColor:current_color withTargetColor:target];
        while(y1 < h && blending_alpha != 0)
        {
            int index = [FloodFill getIndexX:current.x Y:y1 W:w];
            color result = [FloodFill blendColor:current_color withColor:replacement alpha:blending_alpha];
            image[index] = result.red;
            image[index + 1] = result.green;
            image[index + 2] = result.blue;

            color rightColor = [FloodFill getColorForX:(current.x+1) Y:y1 fromImage:image imageWidth:w];
            color leftColor = [FloodFill getColorForX:(current.x-1) Y:y1 fromImage:image imageWidth:w];
            int blendRight = [FloodFill compareColor:rightColor withTargetColor:target];
            int blendLeft = [FloodFill compareColor:leftColor withTargetColor:target];
            
            if(!spanLeft && current.x > 0 && blendLeft != (int)0) // pixel on left same or similar
            {
                node *new = (node*) malloc(sizeof(struct node_st));
                (*new).x = current.x-1;
                (*new).y = y1;
                (*new).next = list;
                list = new;
                
                spanLeft = 1;
            }
            else if(spanLeft && current.x > 0 && blendLeft == (int)0) // pixel on left is different color
            {
                spanLeft = 0;
            }
            if(!spanRight && current.x < w - 1 && blendRight != (int)0) // pixel on right same or similar
            {
                node *new = (node*) malloc(sizeof(struct node_st));
                (*new).x = current.x+1;
                (*new).y = y1;
                (*new).next = list;
                list = new;
                
                spanRight = 1;
            }
            else if(spanRight && current.x < w - 1 && blendRight == (int)0)// pixel on right is different color
            {
                spanRight = 0;
            } 
            
            free(pointer_to_free);
            y1++;
            current_color = [FloodFill getColorForX:current.x Y:y1 fromImage:image imageWidth:w];
            blending_alpha = [FloodFill compareColor:current_color withTargetColor:target];
        }
        
    }
    return 0;
}


// creates color struct from int
+(color)imkcolor:(int)thecolor {
    color result;
    
    result.red = (thecolor & 0xff000000) >> 24;
    result.green = (thecolor & 0x00ff0000) >> 16;
    result.blue = (thecolor & 0x0000ff00) >> 8;
    result.alpha = (thecolor & 0x000000ff);
    
    return result;
}

// creates color struct from RGBA
+(color)mkcolorR:(int)red G:(char)green B:(char)blue A:(char)alpha {
    int x = 0;
    x |= (red & 0xff) << 24;
    x |= (green & 0xff) << 16;
    x |= (blue & 0xff) << 8;
    x |= (alpha & 0xff);
    return [FloodFill imkcolor:x];
}

+(int)getIndexX:(int)x Y:(int)y W:(int)w {
    return y*w*COLOR_DEPTH + x*COLOR_DEPTH;
}


+(color)getColorForINDEX:(int)index fromImage:(unsigned char*)image {
    int red, green, blue, alpha;
    red = image[index];
    green = image[index + 1];
    blue = image[index + 2];
    if (COLOR_DEPTH == 4) alpha = image[index + 3];
    
    return [FloodFill mkcolorR:red G:green B:blue A:alpha];
}

+(color)getColorForX:(int)x Y:(int)y fromImage:(unsigned char*)image imageWidth:(int)w {
    int red, green, blue, alpha;
    int index= y*w*COLOR_DEPTH + x*COLOR_DEPTH;
    red = image[index];
    green = image[index + 1];
    blue = image[index + 2];
    if (COLOR_DEPTH == 4) alpha = image[index + 3];
    
    return [FloodFill mkcolorR:red G:green B:blue A:alpha];
}


+(int)compareColorForPointX:(int)x Y:(int)y image:(unsigned char*)image width:(int)w height:(int)h targetColor:(color)target {
    if (x<0 || x>=w) return NO;
    if (y<0 || y>=h) return NO;
    
    int index = [FloodFill getIndexX:x Y:y W:w];
    color current = [FloodFill getColorForINDEX:index fromImage:image];//getColor(getIndex(x, y, w, bpc), image, bpc);
    
    return [FloodFill compareColor:current withTargetColor:target];
}

// checks are colors same/similar or not. 
// Returns current color alpha if colors are same/similar OR if current color is very transperent (alpha <= 100)
// returns 0 if colors aren't similar and current color has alpha > 100.
+(int)compareColor:(color)current withTargetColor:(color) target {
    if (current.red == target.red &&
        current.green == target.green &&
        current.blue == target.blue)
        return current.alpha;
    else if([FloodFill isColorsSimilar:current withColor:target])
        return current.alpha;
    else if(current.alpha > 100)
            return (int)0x00;
    
    return current.alpha;
}

// Checks are colors similar or not.
+ (BOOL) isColorsSimilar:(color)color1 withColor:(color)color2
{
	int da = abs(color1.alpha - color2.alpha);
	int dr = abs(color1.red - color2.red);
	int dg = abs(color1.green - color2.green);
	int db = abs(color1.blue - color2.blue);
	
	
	if (((double)(da + dr + dg + db) / 4.0) <= THRESHOULD)
	{
		//NSLog(@"YES");
		return YES;
	}
	
	//NSLog(@"diff: %i, currentColor: %i, color: %i", (currentColor - color), currentColor, color);
	return NO;
}

// blend colors. If current color is "solid", then replace it, if it is transperent, then blend colors
+(color)blendColor:(color)current withColor:(color)replacement alpha:(int) alpha {
    
    color result;
    
    float falpha;
    if (alpha == 255) falpha = 1.;
    else falpha = alpha/255.;
    
    if (alpha > 100) {
        return replacement;
    }
    
    result.red = (int)(current.red*falpha) + (int)(replacement.red*(1-falpha));
    result.green = (int)(current.green*falpha) + (int)(replacement.green*(1-falpha));
    result.blue = (int)(current.blue*falpha) + (int)(replacement.blue*(1-falpha));
    if (current.alpha == 0)
        result.alpha = replacement.alpha;
    
    return result;
}


@end
