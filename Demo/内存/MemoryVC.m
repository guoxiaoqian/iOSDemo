//
//  MemoryVC.m
//  Demo
//
//  Created by 郭晓倩 on 2021/5/9.
//  Copyright © 2021 郭晓倩. All rights reserved.
//

#import "MemoryVC.h"
#import <mach/mach.h>

@interface MemoryVC ()

@property (strong,nonatomic) UIImageView* imageView;

@end

@implementation MemoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, 500, 500)];
    [self.view addSubview:self.imageView];
    [self testAllocMemory];
    [self testVMAlloc];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testImageFile];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self testImageNamed];
     });
}

- (int64_t)memoryVirtualSize {
    struct task_basic_info info;
    mach_msg_type_number_t size = (sizeof(task_basic_info_data_t) / sizeof(natural_t));
    kern_return_t ret = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (ret != KERN_SUCCESS) {
        return 0;
    }
    return info.virtual_size;
}

- (int64_t)memoryResidentSize {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(task_basic_info_data_t) / sizeof(natural_t);
    kern_return_t ret = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (ret != KERN_SUCCESS) {
        return 0;
    }
    return info.resident_size;
}

- (int64_t)memoryPhysFootprint {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t ret = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count);
    if (ret != KERN_SUCCESS) {
        return 0;
    }
    return vmInfo.phys_footprint;
}

- (void)logMemorySize {
    NSLog(@"[Memory] Vitural:%.2fM Resident:%.2fM Footprint:%.2fM",(double)[self memoryVirtualSize]/1024/1024,(double)[self memoryResidentSize]/1024/1024,(double)[self memoryPhysFootprint]/1024/1024);
}

- (void)testAllocMemory {
    LOG_FUNCTION;
    [self logMemorySize];
    void *memBlock = malloc(10 * 1024 * 1024);
    [self logMemorySize];
    memset(memBlock, 0, 10 * 1024 * 1024);
    [self logMemorySize];
}

- (void)testImageFile {
    LOG_FUNCTION;
    [self logMemorySize];
    NSURL* imageUrl = [[NSBundle mainBundle] URLForResource:@"Demo2@3x" withExtension:@"png"];
    UIImage* image = [UIImage imageWithContentsOfFile:imageUrl.path];
    [self logMemorySize];
    self.imageView.image = image;
    [self logMemorySize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logMemorySize];
    });

}

- (void)testImageNamed {
    LOG_FUNCTION;
    [self logMemorySize];
    UIImage* image = [UIImage imageNamed:@"Demo2"];
    [self logMemorySize];
    self.imageView.image = image;
    [self logMemorySize];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self logMemorySize];
    });

}

- (void)testVMAlloc {
    LOG_FUNCTION;
    [self logMemorySize];

    vm_address_t address;
    vm_size_t size = 100*1024*1024;
    // VM Tracker中显示Memory Tag 200
    vm_allocate((vm_map_t)mach_task_self(), &address, size, VM_MAKE_TAG(200) | VM_FLAGS_ANYWHERE);
    // VM Tracker中显示VM_MEMORY_MALLOC_HUGE
    // vm_allocate((vm_map_t)mach_task_self(), &address, size, VM_MAKE_TAG(VM_MEMORY_MALLOC_HUGE) | VM_FLAGS_ANYWHERE);
    
    [self logMemorySize];
}

@end
