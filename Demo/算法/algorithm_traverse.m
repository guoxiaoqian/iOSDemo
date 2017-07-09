//
//  algorithm_traverse.m
//  Demo
//
//  Created by 郭晓倩 on 2017/7/9.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "algorithm_traverse.h"

typedef struct {
    int value;
    bool visited;
}VisitItem;

#define TwoDimensionArrayLength 4

void printTwoDimensionArrayByClockWise(VisitItem array[][TwoDimensionArrayLength]){
    int len = TwoDimensionArrayLength;
     //i表示行，j表示列，顺时针，先列加，再行加，再列减，再行减
    for (int i=0,j=0; i<len && j <len; ) {
        VisitItem* item = &array[i][j];
        printf("%d ",item->value);
        item->visited = true;
        
        if (j+1 < len && ((VisitItem)array[i][j+1]).visited == NO) {
            j = j+1;
            continue;
        }
        if (i+1 < len && ((VisitItem)array[i+1][j]).visited == NO) {
            i = i+1;
            continue;
        }
        
        if (j-1 >= 0 && ((VisitItem)array[i][j-1]).visited == NO) {
            j = j-1;
            continue;
        }
        if (i-1 >= 0 && ((VisitItem)array[i-1][j]).visited == NO) {
            i = i-1;
            continue;
        }
       
        break;
    }
}

void generateTwoDimensionArrayAndPrintByClockWise(){
    VisitItem array[TwoDimensionArrayLength][TwoDimensionArrayLength];
    int value = 0;
    for (int i=0; i<TwoDimensionArrayLength; ++i) { //行
        for(int j=0;j<TwoDimensionArrayLength;++j){ //列
            VisitItem* item = &array[i][j];
            item->value = value;
            item->visited = false;
            value ++;
        }
    }
    printTwoDimensionArrayByClockWise(array);
}

void testTraverse(){
    generateTwoDimensionArrayAndPrintByClockWise();
}
