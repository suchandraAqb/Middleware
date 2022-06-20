/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCFrameSource.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.3.0
 *
 * Emits a frame from the provided UIImage.
 *
 * To emit the frame set this object  as the frame source for the SDCDataCaptureContext and turn it on by changing the desired state to SDCFrameSourceStateOn. This frame source will turn off automatically after the frame is emitted.
 *
 * @remark When using SDCImageFrameSource with SDCTextCapture you should change the SDCTextCaptureSettings.recognitionDirection to SDCDirectionLeftToRight.
 */
NS_SWIFT_NAME(ImageFrameSource)
SDC_EXPORTED_SYMBOL
@interface SDCImageFrameSource : NSObject <SDCFrameSource>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.3.0
 *
 * Constructs a new SDCImageFrameSource from the provided UIImage.
 *
 * The provided UIImage should have one of the following configuration:
 *
 * Gray color space:
 *
 * 8  bits per pixel
 *
 * 8  bits per component
 *
 * kCGImageAlphaNone
 *
 * RGB color space:
 *
 * 32  bits per pixel
 *
 * 8  bits per component
 *
 * kCGImageAlphaNoneSkipFirst
 *
 * 32  bits per pixel
 *
 * 8  bits per component
 *
 * kCGImageAlphaNoneSkipLast
 *
 * 32  bits per pixel
 *
 * 8  bits per component
 *
 * kCGImageAlphaPremultipliedFirst
 *
 * 32  bits per pixel
 *
 * 8  bits per component
 *
 * kCGImageAlphaPremultipliedLast
 */
+ (nonnull instancetype)frameSourceWithImage:(nonnull UIImage *)image;

/**
 * Added in version 6.3.0
 *
 * Convenience method for SDCFrameSource.switchToDesiredState:completionHandler:: it is same as calling SDCFrameSource.switchToDesiredState:completionHandler: with the second argument set to nil.
 */
- (void)switchToDesiredState:(SDCFrameSourceState)state;

@end

NS_ASSUME_NONNULL_END
