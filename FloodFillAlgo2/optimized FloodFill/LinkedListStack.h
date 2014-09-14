//
//  LinkedList.h
//  FloodFillAlgo2
//
//  Created by Gaurav Singh on 10/10/13.
//  Copyright (c) 2013 Gaurav Singh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FINAL_NODE_OFFSET -1
#define INVALID_NODE_CONTENT INT_MIN

typedef struct PointNode
{
    int nextNodeOffset;
    
    int point;
    
} PointNode;

@interface LinkedListStack : NSObject
{
    NSMutableData *nodeCache;
    
    int freeNodeOffset;
    int topNodeOffset;
    int _cacheSizeIncrements;
    
    int multiplier;
}

- (id)initWithCapacity:(int)capacity incrementSize:(int)increment andMultiplier:(int)mul;
- (id)initWithCapacity:(int)capacity;

- (void)pushFrontX:(int)x andY:(int)y;
- (int)popFront:(int *)x andY:(int *)y;
@end
