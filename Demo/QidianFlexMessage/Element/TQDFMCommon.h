//
//  TQDFMCommon.h
//  QQMSFContact
//
//  Created by 郭晓倩 on 2018/12/3.
//

#ifndef TQDFMCommon_h
#define TQDFMCommon_h

#import "TQDFMPlatformBridge.h"

//*****************************
// 消息解析引擎版本：每次增加新元素或重要属性，则版本加1，用来做向后兼容。
//*****************************
#define TQDFM_VERSION 1

//*****************************
// 端区分：QQ为0,企点为1
//*****************************
#define TQDFM_QIDIAN  1


//调试开关
#if defined(DEBUG)
#define TQDFM_DEBUG  1
#else
#define TQDFM_DEBUG 0
#endif

//日志
#define TQDFM_EVENT(str) [[TQDFMPlatformBridge sharedInstance] log:str]; //QLog_Event("Qidian_Flex", "%s",[str UTF8String]);
#define TQDFM_INFOP(str) [[TQDFMPlatformBridge sharedInstance] log:str];//QLog_InfoP("Qidian_Flex", "%s",[str UTF8String]);
#define TQDFM_INFOP_ASSERT(str) TQDFM_INFOP(str);NSLog(str);//NSAssert(NO,str);

#define TQDFM_ELEMENT_LOGSTR(element, logStr) ([NSString stringWithFormat:@"%@ -- element:%@", logStr, element])
#define TQDFM_EVENT_ELEMENT(element, logStr)  TQDFM_EVENT(TQDFM_ELEMENT_LOGSTR(element, logStr));
#define TQDFM_INFOP_ELEMENT(element, logStr)  TQDFM_INFOP(TQDFM_ELEMENT_LOGSTR(element, logStr));
#define TQDFM_INFOP_ASSERT_ELEMENT(element, logStr)  TQDFM_INFOP_ASSERT(TQDFM_ELEMENT_LOGSTR(element, logStr));

//上报
//#import "QQReportEngine.h"
#define TQDFM_REPORT(actionName, result, targetUin_, kfUin, reserve3_, reserve4_) \
//[CZ_GetReportEngine() report899WithDepartKey:@"Qidian" opUin:CZ_GetSelfUin() targetUin:targetUin_ opType:@"0x800992B" opName:actionName opEntry:2 opCount:1 opResult:result reserved1:(TQDFM_QIDIAN)?@"2":@"1" reserved2:kfUin reserved3:reserve3_ reserved4:reserve4_ immediately:NO];

//性能调试
#define TQDFM_REUSE_LAYOUT       1
#define TQDFM_REUSE_VIEW         1
#define TQDFM_REUSE_TEXT         1
//#if TQDFM_DEBUG
//#import "QQTimeProfile.h"
//#define TQDFM_TIME_BEGIN(name)   [[QQTimeProfile shareInstance] beginMonitor:name];
//#define TQDFM_TIME_END(name)     [[QQTimeProfile shareInstance] endMonitor:name];
//#else
#define TQDFM_TIME_BEGIN(name)
#define TQDFM_TIME_END(name)
//#endif

//浮点数判断
#define TQDFM_FLOAT_EQUALT_ZERO(x)       (-0.01 < x && x < 0.01)
#define TQDFM_FLOAT_LESS_THAN_ZERO(x)    (x <= -0.01)
#define TQDFM_FLOAT_LESS_EQUAL_ZERO(x)   (x < 0.01)

//单位转换
#define TQDFM_WIDTH_FROM_PIXEL(x)        ([[TQDFMPlatformBridge sharedInstance] widthFromPixel:x])
#define TQDFM_HEIGHT_FROM_PIXEL(x)       ([[TQDFMPlatformBridge sharedInstance] heightFromPixel:x])  //确保等比缩放,方便头像圆角
#define TQDFM_FONTSIZE_FROM_PIXEL(x)     ([[TQDFMPlatformBridge sharedInstance] fontSizeFromPixel:x])


#endif /* TQDFMCommon_h */
