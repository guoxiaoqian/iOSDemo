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

void printGroupOfSubStr(const char* str,int m,char tmp[],int level){
    int len = strlen(str);

    if (len == 0 || m == 0 || len < m) {
        return;
    }
    
    if (m == 1) {
        for (char *ch=str; *ch!='\0'; ++ch) {
            tmp[level] = *ch;
            tmp[level+1] = '\0';
            printf("%s ",tmp);
        }
        return;
    }

    if(len == m){
        for (int i=0; i<len; ++i,++level) {
            tmp[level] = str[i];
        }
        tmp[level] = '\0';
        printf("%s ",tmp);
    }else{
        printGroupOfSubStr(str+1, m,tmp,level);
        
        tmp[level] = *str;
        printGroupOfSubStr(str+1, m-1,tmp,level+1);
    }
}

void printGroupOfStr(const char* str){
    int len = strlen(str);
    char* tmp = (char*)malloc((len+1)*sizeof(char));
    memset(tmp,'\0', len+1);
    for (int i=1; i<=len; ++i) {
        printGroupOfSubStr(str,i,tmp,0);
    }
    free(tmp);
}

void testDivide(){
    char array[] = "abc";
    arrangeString(array,array);
    
    int array2[] = {1,-2,3,10,-4,7,2,-5};
    maxSumOfSubArray(array2,sizeof(array2)/sizeof(int));
    
    printGroupOfStr("abcd");
}
