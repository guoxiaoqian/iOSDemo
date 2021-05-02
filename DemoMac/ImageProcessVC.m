//
//  ImageProcessVC.m
//  DemoMac
//
//  Created by gavinxqguo on 2021/5/2.
//  Copyright © 2021 郭晓倩. All rights reserved.
//

#import "ImageProcessVC.h"
#import <CoreImage/CoreImage.h>

@implementation ImageProcessVC

//MARK: - NSImage to CGImageRef

+ (CGImageRef)CGImageFromNSImage:(NSImage*)image
{
    NSData *imageData = [image TIFFRepresentation];
    
    CGImageRef cgImage = NULL;
    if(imageData) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        CFRelease(imageSource);
    }
    return cgImage;
}

+ (CGImageRef)CGImageFromNSImage2:(NSImage*)image
{
    //    API_AVAILABLE(macos(10.6))
    CGImageRef cgImage = [image CGImageForProposedRect:NULL context:nil hints:nil];
    return cgImage;
}

//MARK: - CGImageRef to NSImage

+ (NSImage*)NSImageFromCGImageRef:(CGImageRef)image {

    // Get the image dimensions.
    CGFloat scaleFactor = MAX([NSScreen mainScreen].backingScaleFactor,1);
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    imageRect.size.height = CGImageGetHeight(image) / scaleFactor;
    imageRect.size.width = CGImageGetWidth(image) / scaleFactor;


     // Create a new image to receive the Quartz image data.
    NSImage* newImage = [[NSImage alloc] initWithSize:imageRect.size];
    
    [newImage lockFocus];
     // Get the Quartz context and draw.
    CGContextRef imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    [newImage unlockFocus];

    return newImage;
}

+ (NSImage*)NSImageFromCGImageRef2:(CGImageRef)cgImage {
    CGSize imageSize = CGSizeZero;
    
    // Get the image dimensions.
    CGFloat scaleFactor = MAX([NSScreen mainScreen].backingScaleFactor,1);
    imageSize.height = CGImageGetHeight(cgImage) / scaleFactor;
    imageSize.width = CGImageGetWidth(cgImage) / scaleFactor;
    
    return [[NSImage alloc] initWithCGImage:cgImage size:imageSize];
}

#pragma mark -  NSImage转CIImage

+ (CIImage *)getCIImageWithNSImage:(NSImage *)myImage {

    // convert NSImage to bitmap
    NSData  *tiffData = [myImage TIFFRepresentation];
    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];

    // create CIImage from bitmap
    CIImage * ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];

    // create affine transform to flip CIImage
    NSAffineTransform *affineTransform = [NSAffineTransform transform];
    [affineTransform translateXBy:0 yBy:128];
    [affineTransform scaleXBy:1 yBy:-1];

    // create CIFilter with embedded affine transform
    CIFilter *transform = [CIFilter filterWithName:@"CIAffineTransform"];
    [transform setValue:ciImage forKey:@"inputImage"];
    [transform setValue:affineTransform forKey:@"inputTransform"];

    // get the new CIImage, flipped and ready to serve
    CIImage * result = [transform valueForKey:@"outputImage"];
    return result;
    // draw to view
//    [result drawAtPoint: NSMakePoint ( 0,0 )
//               fromRect: NSMakeRect  ( 0,0,128,128 )
//              operation: NSCompositeSourceOver
//               fraction: 1.0];

    // cleanup
    //    [ciImage release];
}

#pragma mark - NSView 转 NSImage

+ (NSImage *)imageFromView:(NSView *)cview {

    // 从view、data、CGImage获取BitmapImageRep
//    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:data];
//    NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithCGImage:CGImage];
    NSBitmapImageRep *bitmap =  [cview bitmapImageRepForCachingDisplayInRect:[cview visibleRect]];
    [cview cacheDisplayInRect:[cview visibleRect] toBitmapImageRep:bitmap];

    NSImage *image = [[NSImage alloc] initWithSize:cview.frame.size];
    [image addRepresentation:bitmap];


    return image;
}

#pragma mark - 保存图片到本地

+ (BOOL)saveImage:(NSImage *)image fileName:(NSString *)fileName {

    NSData *imageData = [image TIFFRepresentation];

    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];

//    [imageRep setSize:size];  // 只是打开图片时的初始大小，对图片本省没有影响
//    fileName.pathComponents  分割路径
//    fileName.pathExtension   扩展名
    if([fileName.pathExtension isEqualToString:@"jpg"]) {
        ///jpg
        NSDictionary *imageProps = nil;
        NSNumber *quality = [NSNumber numberWithFloat:.85]; // 压缩率
        imageProps = [NSDictionary dictionaryWithObject:quality forKey:NSImageCompressionFactor];

        imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];

    } else {
        ///png
        imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];

    }
    // 写文件 保存到本地需要关闭沙盒  ---- 保存的文件路径一定要是绝对路径，相对路径不行
    return [imageData writeToFile:fileName atomically:YES];
}

#pragma mark - 按照比例压缩大小
//rate 压缩比0.1～1.0之间
+ (NSData *)compressedImageDataWithImg:(NSImage *)img rate:(CGFloat)rate{

    NSData *imgDt = [img TIFFRepresentation];
    if (!imgDt) {
        return nil;
    }

    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgDt];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:rate] forKey:NSImageCompressionFactor];
    imgDt = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];

    return imgDt;
}

#pragma mark - 修改图片尺寸
// 完全填充,变形压缩
+ (NSImage *)resizeImage:(NSImage*)sourceImage forSize:(NSSize)size {
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);

    NSImageRep *sourceImageRep = [sourceImage bestRepresentationForRect:targetFrame context:nil hints:nil];

    NSImage *targetImage = [[NSImage alloc] initWithSize:size];

    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];

    return targetImage;
}

// 将图像居中缩放截取targetsize
+ (NSImage*)resizeImage1:(NSImage*)sourceImage forSize:(CGSize)targetSize {

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;


    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;
    scaleFactor = (widthFactor>heightFactor)?widthFactor:heightFactor;

    CGFloat readHeight = targetHeight/scaleFactor; // 需要读取的源图像的高度或宽度
    CGFloat readWidth = targetWidth/scaleFactor;
    CGPoint readPoint = CGPointMake(
                                    widthFactor>heightFactor?0:(width-readWidth)*0.5,
                                    widthFactor<heightFactor?0:(height-readHeight)*0.5);



    NSImage *newImage = [[NSImage alloc] initWithSize:targetSize];
    CGRect thumbnailRect = {{0.0, 0.0}, targetSize};
    NSRect imageRect = {readPoint, {readWidth, readHeight}};

    [newImage lockFocus];
    [sourceImage drawInRect:thumbnailRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
    [newImage unlockFocus];

    return newImage;
}

#pragma mark - 缩略图(等比缩放)
+ (NSImage*)getThumb:(NSImage*)sourceImage forSize:(CGSize)targetSize {

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        // scale to fit the longer
        scaleFactor = (widthFactor>heightFactor)?widthFactor:heightFactor;
        scaledWidth  = ceil(width * scaleFactor);
        scaledHeight = ceil(height * scaleFactor);

        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(scaledWidth, scaledHeight)];
    CGRect thumbnailRect = {thumbnailPoint, {scaledWidth, scaledHeight}};
    NSRect imageRect = NSMakeRect(0.0, 0.0, width, height);

    [newImage lockFocus];
    [sourceImage drawInRect:thumbnailRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
    [newImage unlockFocus];

//     UIGraphicsBeginImageContext(targetSize); // this will crop
//
//     CGRect thumbnailRect = CGRectZero;
//     thumbnailRect.origin = thumbnailPoint;
//     thumbnailRect.size.width  = scaledWidth;
//     thumbnailRect.size.height = scaledHeight;
//     [sourceImage drawInRect:thumbnailRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
//     //[sourceImage drawInRect:thumbnailRect];
//
//     newImage = UIGraphicsGetImageFromCurrentImageContext();
//     if(newImage == nil)
//     NSLog(@"could not scale image");
//
//     //pop the context to get back to the default
//     UIGraphicsEndImageContext();


    return newImage;
}

+ (NSImage*)getThumb2:(NSData*)imageData forSize:(CGSize)targetSize {
    //利用ImageIO的方案减少内存
    CGFloat scaleFactor = MAX([NSScreen mainScreen].backingScaleFactor,1);
    int thumbnailMaxPixelSize = MAX(targetSize.width,targetSize.height) * scaleFactor; //根据目标尺寸来缩放
    CFDataRef dataRef = (CFDataRef)CFBridgingRetain(imageData);
    CFDictionaryRef dicOptionsRef = (__bridge CFDictionaryRef) @{
        (id)kCGImageSourceCreateThumbnailFromImageIfAbsent : @(YES),
        (id)kCGImageSourceThumbnailMaxPixelSize : @(thumbnailMaxPixelSize),
        (id)kCGImageSourceShouldCache : @(YES),
    };
    CGImageSourceRef src = CGImageSourceCreateWithData(dataRef, nil);
    CGImageRef thumImg = CGImageSourceCreateThumbnailAtIndex(src, 0, dicOptionsRef); //注意：如果设置 kCGImageSourceCreateThumbnailFromImageIfAbsent为 NO，那么 CGImageSourceCreateThumbnailAtIndex 会返回nil
    CFRelease(src); // 注意释放对象，否则会产生内存泄露
    if(thumImg != nil){
        CGSize thumImgSize = CGSizeMake(CGImageGetWidth(thumImg)/scaleFactor, CGImageGetHeight(thumImg)/scaleFactor);
        NSImage* resultImage = [[NSImage alloc] initWithCGImage:thumImg size:thumImgSize];
        CFRelease(thumImg); // 注意释放对象，否则会产生内存泄露
        return resultImage;
    }
    return nil;
}

+ (NSImage*)getThumb3:(NSImage*)sourceImage forSize:(CGSize)size
{
    if(size.width <= 0 || size.height <= 0)
    {
        return nil;
    }
    
//    double memorySizeBefore = usedMemoryInMB();
    
    NSSize sourceSize = [sourceImage size];
    
    CGFloat cropRatio = size.width / size.height;
    CGFloat ratio = sourceSize.width / sourceSize.height;
    
    CGFloat scale = cropRatio >= ratio ? size.width / sourceSize.width : size.height / sourceSize.height;
    
    NSRect cropRect = NSMakeRect(0, 0, sourceSize.width*scale, sourceSize.height*scale);
    cropRect.origin.x = floor((size.width - cropRect.size.width)/2);
    cropRect.origin.y = floor((size.height - cropRect.size.height)/2);
    
    //内存比lockFocus方案可以降一些
    CGSize newSize = cropRect.size;
    CGFloat scaleFactor = MAX([NSScreen mainScreen].backingScaleFactor,1);
    CGSize sizeInPixel = CGSizeMake(newSize.width*scaleFactor, newSize.height*scaleFactor);
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:sizeInPixel.width
                             pixelsHigh:sizeInPixel.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = newSize;
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [sourceImage drawInRect:cropRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0 respectFlipped:YES hints:@{NSImageHintInterpolation:[NSNumber numberWithInt:NSImageInterpolationLow]}];
    [NSGraphicsContext restoreGraphicsState];
    NSImage *targetImage = [[NSImage alloc] initWithSize:newSize];
    [targetImage addRepresentation:rep];
    
    return targetImage;
}

#pragma mark - 将图片压缩到指定大小（KB）

+ (NSData *)compressImgData:(NSData *)imgData toAimKB:(NSInteger)aimKB {
    if (!imgData) {
        return nil;
    }

    CGFloat aimRate = (CGFloat)(aimKB * 1000) / imgData.length;

    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:aimRate] forKey:NSImageCompressionFactor];
    NSData *data = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];

    NSLog(@"数据最终大小：%g， 压缩比率：%g",(CGFloat)data.length/1000, (CGFloat)data.length/imgData.length);

    return data;
}

#pragma mark - 组合图片
+ (NSImage *)jointedImageWithImages:(NSArray *)imgArray {

    CGFloat imgW = 0;
    CGFloat imgH = 0;
    for (NSImage *img in imgArray) {
        if (img) {
            imgW += img.size.width;
            if (imgH < img.size.height) {
                imgH = img.size.height;
            }
        }
    }

    NSLog(@"size : %@",NSStringFromSize(NSMakeSize(imgW, imgH)));

    NSImage *togetherImg = [[NSImage alloc]initWithSize:NSMakeSize(imgW, imgH)];

    [togetherImg lockFocus];

    CGContextRef imgContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

    CGFloat imgX = 0;
    for (NSImage *img in imgArray) {

        CGImageRef imageRef = [self CGImageFromNSImage:img];
        CGContextDrawImage(imgContext, NSMakeRect(imgX, 0, img.size.width, img.size.height), imageRef);

        imgX += img.size.width;

//        NSLog(@"rect : %@",NSStringFromRect(NSMakeRect(imgX, 0, img.size.width, img.size.height)));
    }

    [togetherImg unlockFocus];

    return togetherImg;

}



@end
