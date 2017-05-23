//
//  AlgorithmVC.m
//  Demo
//
//  Created by 郭晓倩 on 2017/5/23.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "AlgorithmVC.h"



#pragma mark - 排序

int* generateArray(){
    int array[] = {1,3,90,11,33,55,21,0,33};
    return array;
}

int getArrayCount(int* array){
    int count = sizeof(array) / sizeof(int);
    return count;
}

void printArray(int* array,char* sortName){
    printf("sortName:%s:",sortName);
    int count = getArrayCount(array);
    for (int i=0; i<count; ++i) {
        printf(" %d",array[i]);
    }
    printf("\n");
}



#pragma mark  冒泡排序

void bubleSort(){
    int* array = generateArray();
    int count = getArrayCount(array);
    for (int i=0; i<count; ++i) {
        for (int j=count-1; j>i; --j) {
            if (array[j] < array[j-1]) {
                int tmp = array[j];
                array[j] = array[j-1];
                array[j-1] = tmp;
            }
        }
    }
    printArray(array, "BubleSort");
}





@interface AlgorithmVC ()

@end

@implementation AlgorithmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)testSort{
    bubleSort();
}

@end


