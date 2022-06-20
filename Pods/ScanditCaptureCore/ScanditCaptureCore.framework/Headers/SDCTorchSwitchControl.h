/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCControl.h>
#import <ScanditCaptureCore/SDCBase.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.0.0
 *
 * Control that allows to toggle the torch on and off. The torch switch control hides itself automatically in case the active frame source doesn’t have a torch.
 *
 * You can add this control to a view by calling SDCDataCaptureView.addControl:.
 */
NS_SWIFT_NAME(TorchSwitchControl)
SDC_EXPORTED_SYMBOL
@interface SDCTorchSwitchControl : NSObject <SDCControl>

/**
 * Added in version 6.2.0
 *
 * Sets the image to use for the control button when the torch is off.
 */
@property (nonatomic, strong, nonnull) UIImage *torchOffImage;
/**
 * Added in version 6.2.0
 *
 * Sets the image to use for the control button when the torch is off and the button is pressed.
 */
@property (nonatomic, strong, nonnull) UIImage *torchOffPressedImage;
/**
 * Added in version 6.2.0
 *
 * Sets the image to use for the control button when the torch is on.
 */
@property (nonatomic, strong, nonnull) UIImage *torchOnImage;
/**
 * Added in version 6.2.0
 *
 * Sets the image to use for the control button when the torch is on and the button is pressed.
 */
@property (nonatomic, strong, nonnull) UIImage *torchOnPressedImage;

/**
 * Added in version 6.8.0
 *
 * Constructs a new torch switch control with the provided JSON serialization. See Serialization for details.
 */
+ (nullable instancetype)torchSwitchControlFromJSONString:(nonnull NSString *)JSONString
                                                    error:(NSError *_Nullable *_Nullable)error;

/**
 * Added in version 6.8.0
 *
 * Updates the control according to a JSON serialization. See Serialization for details.
 */
- (BOOL)updateFromJSONString:(nonnull NSString *)JSONString
                       error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
