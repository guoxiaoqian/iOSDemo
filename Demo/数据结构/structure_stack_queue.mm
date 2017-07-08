//
//  structure_stack_queue.cpp
//  Demo
//
//  Created by 郭晓倩 on 2017/7/8.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#include <vector>

template <typename T>
class Stack {
    std::vector<T> m_array;
    
public:
    bool push(T& value){
        m_array.push_back(value);
        return true;
    }
    
    bool pop(T& value){
        if (!empty()) {
            value = m_array.back();
            m_array.pop_back();
            return true;
        }else{
            return false;
        }
    }
    
    bool empty(){
        return m_array.empty();
    }
    
    void clear(){
        m_array.clear();
    }
};

template <typename T>
class TwoStackQueue {
    Stack<T> stack1; //模拟进队列
    Stack<T> stack2; //模拟出队列
public:
    bool enqueue(T& value){
       return stack1.push(value);
    }
    
    bool dequeue(T& value){
        if (stack2.empty()) {
            T tmp;
            while (stack1.pop(tmp)) {
                stack2.push(tmp);
            }
        }
        return stack2.pop(value);
    }
    
    bool empty(){
        return stack1.empty() && stack2.empty();
    }
};
