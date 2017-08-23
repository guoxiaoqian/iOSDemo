//
//  algorithm_divide.m
//  Demo
//
//  Created by 郭晓倩 on 2017/7/15.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "algorithm_divide.h"

void arrangeString(char* str,char* begin){
    
    if (str == NULL) {
        return;
    }
    
    if (*begin == '\0') {
        printf("%s ",str);
    }
    
    for (char* pc=begin;*pc != '\0';++pc) {
        
        char tmp = *begin;
        *begin = *pc;
        *pc = tmp;
        
        arrangeString(str,begin+1);

        tmp = *begin;
        *begin = *pc;
        *pc = tmp;
    }
}

void maxSumOfSubArray(int array[],int len){
    if (array==NULL || len <= 0) {
        return;
    }
    int max = array[0];
    int adder = 0;
    int startIndex = 0;
    int endIndex = 0;
    for (int i=0; i<len; ++i) {
        adder += array[i];
        if (adder > max) {
            max = adder;
            endIndex = i;
        }
        if (adder < 0) {
            adder = 0;
            if (i<len-1) {
                startIndex = i+1;
            }
        }
    }
    
    printf("\n");
    for (int i=startIndex; i<=endIndex; ++i) {
        printf("%d ",array[i]);
    }
    printf("\n");
    printf("max = %d\n",max);
}

int oneCount(int num){
    //取总位数和最高位的数
    int decCount = 0;
    int highNum = 0;
    int tmp = num;
    while (tmp > 0) {
        decCount ++;
        highNum = tmp % 10;
        tmp = tmp / 10;
    }
    
    if (num < 10) {
        if (num < 1) {
            return 0;
        }else{
            return 1;
        }
    }else{
        int tail = num / pow(10,decCount-1);
        int count = pow(10,decCount-1)-pow(9, decCount-1);
        return highNum*count+oneCount(tail);
    }
    
    
}


void testDivide(){
    char array[] = "abc";
    arrangeString(array,array);
    
    int array2[] = {1,-2,3,10,-4,7,2,-5};
    maxSumOfSubArray(array2,sizeof(array2)/sizeof(int));
}
