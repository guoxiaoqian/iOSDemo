//
//  structure_tree.cpp
//  Demo
//
//  Created by 郭晓倩 on 2017/7/7.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#include <deque>
#include <queue>

struct BinaryTreeNode{
    int value;
    BinaryTreeNode* leftNode;
    BinaryTreeNode* rightNode;
};


//前序排序、中序排序、后序排序指的都是父节点
BinaryTreeNode* rebuildTreeByPreOrderAndMiddleOrderArray(int preOrderArray[],int middleOrderArray[],int nodeCount){
    if (preOrderArray == NULL || middleOrderArray == NULL || nodeCount == 0) {
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

//按值找到节点
BinaryTreeNode* nodeByValue(BinaryTreeNode* tree,int value){
    if (tree == NULL) {
        return NULL;
    }
    
    BinaryTreeNode* nodeInSubTree = nodeByValue(tree->leftNode, value);
    if (nodeInSubTree != NULL) {
        return nodeInSubTree;
    }
    nodeInSubTree = nodeByValue(tree->rightNode, value);
    
    return nodeInSubTree;
}

bool doesTreeAhaveTreeB(BinaryTreeNode* treeA,BinaryTreeNode* treeB){
    if (treeB == NULL) {
        return true;
    }
    if (treeA == NULL) {
        return false;
    }
    
    if (treeA->value != treeB->value) {
        return false;
    }
    
    return doesTreeAhaveTreeB(treeA->leftNode, treeB->leftNode) &&
    doesTreeAhaveTreeB(treeA->rightNode, treeB->rightNode);
}

//判断树B是否是树A的子结构
bool hasSubTree(BinaryTreeNode* treeA,BinaryTreeNode* treeB){
    if (treeA == NULL || treeB == NULL) {
        return false;
    }
    
    bool result = false;
    
    if(treeA->value == treeB->value){
        result = doesTreeAhaveTreeB(treeA, treeB);
    }
    if (result == false) {
        result = hasSubTree(treeA->leftNode, treeB);
    }
    if (result == false) {
        result = hasSubTree(treeA->rightNode, treeB);
    }
    return result;
}

#pragma mark - 广度优先遍历

void breadthFirstTraverse(BinaryTreeNode* tree){
    if (tree == NULL) {
        return;
    }
    std::queue<BinaryTreeNode*> treeQueue;
    treeQueue.push(tree);
    
    while (treeQueue.empty() == NO) {
        BinaryTreeNode* node = treeQueue.back();
        treeQueue.pop();
        printf("%d ",node->value);
        if (node->leftNode != NULL) {
            treeQueue.push(node->leftNode);
        }
        if (node->rightNode != NULL) {
            treeQueue.push(node->rightNode);
        }
    }
}

#pragma mark - 根据后序遍历数组判断是否是搜索二叉树

bool isBinarySearchTreeByPostOrderTraverseArray(int array[],int startIndex,int endIndex){
    if (array == NULL || startIndex < 0 || endIndex < 0 || startIndex > endIndex) {
        return false;
    }
    int rootValue = array[endIndex];
    int index = endIndex-1;
    while (index >= startIndex && array[index] > rootValue) {
        index--;
    }

    //确保根结点大于左子树所有结点
    for (int i=index; i>= startIndex; --i) {
        if (array[i] > rootValue) {
            return NO;
        }
    }
    
    //左右子树都是搜索二叉树，则总体就是
    bool isLeftTreeIsBinarySearchTree = isBinarySearchTreeByPostOrderTraverseArray(array,startIndex,index);
    bool isRightTreeIsBinarySearchTree = isBinarySearchTreeByPostOrderTraverseArray(array,index+1,endIndex);
    
    return isLeftTreeIsBinarySearchTree && isRightTreeIsBinarySearchTree;
}

#pragma mark - 打印和为某值的路径（从根到叶子）

void findPathForSum(BinaryTreeNode* tree,int sum,int array[],unsigned int deep){
    if (tree == NULL) {
        return ;
    }
    
    //保存访问路径
    array[deep] = tree->value;

    //叶子节点
    if (tree->leftNode == NULL && tree->rightNode == NULL) {
        if (tree->value == sum) {

            //打印路径
            for (int i=0; i<= deep; ++i) {
                printf("%d ",array[i]);
            }
        }
    }
    //非叶子节点，继续查找
    else{
        
        if (tree->leftNode) {
            findPathForSum(tree->leftNode, sum-tree->value, array, deep+1);
        }
        if (tree->rightNode) {
            findPathForSum(tree->rightNode, sum-tree->value, array, deep+1);
        }
    }
}
