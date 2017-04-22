//
//  ShareViewController.m
//  ShareExtension
//
//  Created by 郭晓倩 on 2017/4/22.
//  Copyright © 2017年 郭晓倩. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

//在Share Extension中是无法直接获取到图片的（因为我们分享的内容可能是图片，也可能是网页、视频等，因此SLComposeServiceViewController也不太可能会直接提供图片访问接口），所有的访问数据包含进在extensionContext的inputItems中，这是一个NSInputItem类型的数组。每个NSInputItem都包含一个attachments集合，它的每个元素都是NSItemProvider类型，每个NSItemProvider就包含了对应的图片、视频、链接、文件等信息，通过它就可以获取到我们需要的图片资源。但是需要注意，通过NSItemProvider进行资源获取的过程较长，同时也会阻塞线程，如果直接在didSelectPost方法中获取图片资源势必造成用户长时间等待，比较好的体验是在presentationAnimationDidFinish方法中就异步调用NSItemProvider的loadItemForTypeIdentifier方法进行图片资源加载，并存储到数组中以便在didSelectPost方法中使用。
//此外，为了获取更好的用户体验，图片的上传过程同样需要放到后台进行，首先想到的就是使用NSURLSession的后台会话模式，值得一提的是在这个过程中必须指定NSURLSessionConfiguration的sharedContainerIdentifier，因为上传的过程中首先会将资源缓存到本地，而扩展是没办法直接访问宿主应用的缓存空间的，配置sharedContainerIdentifier以便利通过App Group使用容器应用的缓存空间。

//charactersRemaining：剩余字符数，显示在分享界面左下方，例如这里设置为最大200。
//isContentValid()：分享内容验证（例如验证分享内容中是否包含特殊字符），此方法再编辑过程中会不断调用，如果此方法返回false则分享按钮不可用，这里可以通过判断输入动态修改charactersRemaining。
//didSelectPost()：发送点击事件，通常在此方法中会上传图片和内容。
//configurationItems()：用于自定义sheet选项，显示在分享界面下方，可以接收点击事件，这里我们会导航到另一个自定义编辑界面用于选择分类

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    NSLog(@"点击了发送");
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    SLComposeSheetConfigurationItem* item = [SLComposeSheetConfigurationItem new];
    item.title = @"配置项";
    item.value = @"配置值";
    item.tapHandler =  ^{
        NSLog(@"点击了配置项");
    };
    return @[item];
}

@end
