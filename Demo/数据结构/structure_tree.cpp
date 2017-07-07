//
//  structure_tree.cpp
//  Demo
//
//  Created by 郭晓倩 on 2017/7/7.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#include "structure_tree.hpp"

struct BinaryTreeNode{
    int value;
    BinaryTreeNode* leftNode;
    BinaryTreeNode* rightNode;
};

BinaryTreeNode* rebuildTreeByPreOrderAndMiddleOrderArray(int preOrderArray[],int middleOrderArray[],int nodeCount){
    if (nodeCount == 0) {
        return NULL;
    }
    if (nodeCount == 1) {
        BinaryTreeNode* node = new BinaryTreeNode();
        node->value = preOrderArray[0];
        node->leftNode = NULL;
        node->rightNode = NULL;
        return node;
    }
    int rootValue = preOrderArray[0];
    int rootIndexAtMiddleOrderArray = 0;
    for (int index =0; index<nodeCount; ++index) {
        if (middleOrderArray[index] == rootValue) {
            rootIndexAtMiddleOrderArray = index;
            break;
        }
    }
    int leftTreeNodeCount = rootIndexAtMiddleOrderArray;
    int rightTreeNodeCount = nodeCount-1-leftTreeNodeCount;
    
    BinaryTreeNode* node = new BinaryTreeNode();
    node->value = rootValue;
    node->leftNode = rebuildTreeByPreOrderAndMiddleOrderArray(preOrderArray+1,middleOrderArray,leftTreeNodeCount);
    node->rightNode = rebuildTreeByPreOrderAndMiddleOrderArray(preOrderArray+1+leftTreeNodeCount,middleOrderArray+leftTreeNodeCount+1,rightTreeNodeCount);
    return node;
}
