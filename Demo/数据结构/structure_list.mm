//
//  structure_list.cpp
//  Demo
//
//  Created by 郭晓倩 on 2017/7/7.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//


struct ListNode{
    int value;
    ListNode* nextNode;
};

void addNodeAtTail(ListNode** head,int value){
    ListNode* node = new ListNode();
    node->value = value;
    node->nextNode = NULL;
    
    if (*head == NULL) {
        *head = node;
    }else{
        ListNode* tmpNode = *head;
        while (tmpNode->nextNode != NULL) {
            tmpNode = tmpNode->nextNode;
        }
        tmpNode->nextNode = node;
    }
}

void removeNodeForValue(ListNode** head,int value){
    if (head == NULL || *head == NULL) {
        return;
    }
    
    ListNode* nodeToRemove = NULL;
    if ((*head)->value == value) {
        nodeToRemove = (*head);
        *head = (*head)->nextNode;
    }else{
        ListNode* tmpNode = (*head);
        while (tmpNode->nextNode != NULL && tmpNode->nextNode->value != value) {
            tmpNode = tmpNode->nextNode;
        }
        
        //找到要删除结点的前一个结点
        if (tmpNode->nextNode != NULL) {
            nodeToRemove = tmpNode->nextNode;
            tmpNode->nextNode = tmpNode->nextNode->nextNode;
        }
    }
    
    if (nodeToRemove != NULL) {
        delete nodeToRemove;
        nodeToRemove = NULL;
    }

}

void printListReversingly(ListNode* head){
    if (head == NULL) {
        return;
    }
    
    printListReversingly(head->nextNode);

    printf("%d ",head->value);
}
