//
//  MachExceptionVC.m
//  Demo
//
//  Created by 郭晓倩 on 2019/7/28.
//  Copyright © 2019 郭晓倩. All rights reserved.
//

#import "MachExceptionVC.h"
#import <mach/mach.h>
#import <signal.h>
#import <pthread/pthread.h>

#import <unistd.h>


static mach_port_name_t myExceptionPort;

static void *exc_handler(void *ignored) {
    // Exception handler – runs a message loop. Refactored into a standalone function
    // so as to allow easy insertion into a thread (can be in same program or different)
    mach_msg_return_t rc;
    fprintf(stderr, "Exc handler listening\\\\\\\\n");
    // The exception message, straight from mach/exc.defs (following MIG processing) // copied here for ease of reference.
    typedef struct {
        mach_msg_header_t Head;
        /* start of the kernel processed data */
        mach_msg_body_t msgh_body;
        mach_msg_port_descriptor_t thread;
        mach_msg_port_descriptor_t task;
        /* end of the kernel processed data */
        NDR_record_t NDR;
        exception_type_t exception;
        mach_msg_type_number_t codeCnt;
        integer_t code[2];
        int flavor;
        mach_msg_type_number_t old_stateCnt;
        natural_t old_state[144];
    } Request;
    
    Request exc;
    
    
    struct rep_msg {
        mach_msg_header_t Head;
        NDR_record_t NDR;
        kern_return_t RetCode;
    } rep_msg;
    
    
    for(;;) {
        // Message Loop: Block indefinitely until we get a message, which has to be
        // 这里会阻塞，直到接收到exception message，或者线程被中断。
        // an exception message (nothing else arrives on an exception port)
        rc = mach_msg( &exc.Head,
                      MACH_RCV_MSG|MACH_RCV_LARGE,
                      0,
                      sizeof(Request),
                      myExceptionPort, // Remember this was global – that's why.
                      MACH_MSG_TIMEOUT_NONE,
                      MACH_PORT_NULL);
        
        if(rc != MACH_MSG_SUCCESS) {
            /*... */
            break ;
        };
        
        
        // Normally we would call exc_server or other. In this example, however, we wish
        // to demonstrate the message contents:
        // <mach/exception_types.h>
        printf("Got message %d. Exception : %d Flavor: %d. Code %lld/%lld. State count is %d\\\\\\\\n" ,
               exc.Head.msgh_id, exc.exception, exc.flavor,
               exc.code[0], exc.code[1], // can also print as 64-bit quantity
               exc.old_stateCnt);
        
        rep_msg.Head = exc.Head;
        rep_msg.NDR = exc.NDR;
        rep_msg.RetCode = KERN_FAILURE;
        
        kern_return_t result;
        if (rc == MACH_MSG_SUCCESS) {
            result = mach_msg(&rep_msg.Head,
                              MACH_SEND_MSG,
                              sizeof (rep_msg),
                              0,
                              MACH_PORT_NULL,
                              MACH_MSG_TIMEOUT_NONE,
                              MACH_PORT_NULL);
        }
    }
    
    return  NULL;
    
} // end exc_handler


static void catchMACHExceptions() {
    
    kern_return_t rc = 0;
    exception_mask_t excMask = EXC_MASK_BAD_ACCESS |
    EXC_MASK_BAD_INSTRUCTION |
    EXC_MASK_ARITHMETIC |
    EXC_MASK_SOFTWARE |
    EXC_MASK_BREAKPOINT;
    
    rc = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &myExceptionPort);
    if (rc != KERN_SUCCESS) {
        fprintf(stderr, "------->Fail to allocate exception port\\\\\\\\n");
        return;
    }
    
    rc = mach_port_insert_right(mach_task_self(), myExceptionPort, myExceptionPort, MACH_MSG_TYPE_MAKE_SEND);
    if (rc != KERN_SUCCESS) {
        fprintf(stderr, "-------->Fail to insert right");
        return;
    }
    
    rc = thread_set_exception_ports(mach_thread_self(), excMask, myExceptionPort, EXCEPTION_DEFAULT, MACHINE_THREAD_STATE);
    if (rc != KERN_SUCCESS) {
        fprintf(stderr, "-------->Fail to  set exception\\\\\\\\n");
        return;
    }
    
    // at the end of catchMachExceptions, spawn the exception handling thread
    pthread_t thread;
    pthread_create(&thread, NULL, exc_handler, NULL);
} // end catchMACHExceptions

static void testBadAccess() {
    int *pi = (int*)0x00001111;
    *pi = 17;
}

static void testCallSelf() {
    testCallSelf();
}

static void testKill() {
    pthread_kill(pthread_self(),0);
    //    kill(getpid(),0);
}

static void testAbort() {
    abort();
}


@interface MachExceptionVC ()

@end

@implementation MachExceptionVC

- (void)viewDidLoad {
    [super viewDidLoad];

    catchMACHExceptions();
    
    testBadAccess();
//
//    testCallSelf();
//
//    testKill();
    
//    testAbort();
}

@end
