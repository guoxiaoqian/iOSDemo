//
//  algorithm_sort.c
//  Demo
//
//  Created by 郭晓倩 on 2017/5/23.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#include "algorithm_sort.h"

//http://www.jianshu.com/p/036feafa8e95?utm_source=tuicool&utm_medium=referral


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

//调整某个父节点下的子树成为最大堆子树
void adjust_heap(ArrayStruct* arrayS,int parentNodeIndex,int len){
    for (int i=parentNodeIndex;i >= 0 && (i+1)*2 - 1 < len;) {
        int childNodeIndex = (i+1)*2 - 1;  //2k,减一是因为数组从0开始索引，而节点编号是从1开始
        int nextChildNodeIndex = childNodeIndex + 1 ; //2k+1
        //获取最大子节点
        if (nextChildNodeIndex < len) {
            if (arrayS->array[nextChildNodeIndex] > arrayS->array[childNodeIndex]) {
                childNodeIndex = nextChildNodeIndex;
            }
        }
        //如果最大子节点比父节点大，则交换
        if (arrayS->array[parentNodeIndex] < arrayS->array[childNodeIndex]) {
            int tmp = arrayS->array[parentNodeIndex];
            arrayS->array[parentNodeIndex] = arrayS->array[childNodeIndex];
            arrayS->array[childNodeIndex] = tmp;
            
            //继续调整交换过后的子节点
            i = childNodeIndex;
        }else{
            break;
        }
    }
}

#warning TODO-GUO:结果不对
void heap_sort(){
    ArrayStruct arrayS = generateArray();
    
    //构建最大堆(从最后一个父节点到根节点，依次调整成最大堆)
    for (int i=arrayS.length/2 -1; i>=0; --i) {
        adjust_heap(&arrayS, i,arrayS.length);
    }
    
    //不断取最大堆根节点，与最后子节点交换，并重新调整堆
    for (int i=arrayS.length-1; i>0; --i) {
        int tmp = arrayS.array[0];
        arrayS.array[0] = arrayS.array[i];
        arrayS.array[i] = tmp;
        
        adjust_heap(&arrayS, 0, i);
    }

    printArray(arrayS, __func__);
}

#pragma mark - Test

void testSort(){
    bubble_sort();
    select_sort();
    insert_sort();
    quik_sort();
    heap_sort();
}
