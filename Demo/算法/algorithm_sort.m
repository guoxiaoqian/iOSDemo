//
//  algorithm_sort.c
//  Demo
//
//  Created by 郭晓倩 on 2017/5/23.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#include "algorithm_sort.h"

typedef struct{
    int array[10];
    int length;
}ArrayStruct;


ArrayStruct generateArray(){
    ArrayStruct arrayS = {{1,3,90,11,33,55,21,0,33,38},10};
    return arrayS;
}

void printArray(ArrayStruct array,const char* sortName){
    printf("%s:",sortName);
    for (int i=0; i<array.length; ++i) {
        printf(" %d",array.array[i]);
    }
    printf("\n");
}



#pragma mark - 冒泡排序

void bubble_sort(){
    ArrayStruct arrayS = generateArray();
    int* array = arrayS.array;
    int count = arrayS.length;
    for (int i=0; i<count; ++i) {
        for (int j=count-1; j>i; --j) {
            if (array[j] < array[j-1]) {
                int tmp = array[j];
                array[j] = array[j-1];
                array[j-1] = tmp;
            }
        }
    }
    printArray(arrayS, __func__);
}

#pragma mark - 选择排序

void select_sort(){
    ArrayStruct arrayS = generateArray();
    int* array = arrayS.array;
    int count = arrayS.length;
    for (int i=0; i<count; ++i) {
        int index = i;
        for (int j=i+1; j < count; ++j) {
            if (array[j] < array[index]) {
                index = j;
            }
        }
        if (index != i) {
            int tmp = array[i];
            array[i] = array[index];
            array[index] = tmp;
        }
    }
    printArray(arrayS, __func__);
}

#pragma mark - 插入排序

void insert_sort(){
    ArrayStruct arrayS = generateArray();
    int* array = arrayS.array;
    int count = arrayS.length;
    for (int i=1; i<count; ++i) {
        int k = array[i];
        int j = i - 1;
        while (j > -1 && array[j] > k) {
            array[j+1] = array[j];
            --j;
        }
        array[j+1] = k;
    }
    printArray(arrayS, __func__);
}

#pragma mark - 快速排序

void quik_sort_recursive(ArrayStruct* arrayS,int left,int right){
    if (left < right) {
        int i = left,j = right;
        int* array = arrayS->array;
        int target = array[left];
        while (i < j) {
            while (i < j && array[j] > target) {
                --j;
            }
            if (i < j) {
                array[i] = array[j];
                ++i;
            }
            while (i < j && array[i] < target) {
                ++i;
            }
            if (i < j) {
                array[j] = array[i];
            }
        }
        
        array[i] = target;
        quik_sort_recursive(arrayS, left, i-1);
        quik_sort_recursive(arrayS, i+1, right);
    }
}

void quik_sort(){
    ArrayStruct arrayS = generateArray();
    quik_sort_recursive(&arrayS, 0, arrayS.length-1);
    printArray(arrayS, __func__);
}

#pragma mark - Test

void testSort(){
    bubble_sort();
    select_sort();
    insert_sort();
    quik_sort();
}
