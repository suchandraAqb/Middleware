/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.0.0
 *
 * A vibration, to be emitted for example when a code has been successfully scanned.
 */
NS_SWIFT_NAME(Vibration)
SDC_EXPORTED_SYMBOL
@interface SDCVibration : NSObject

/**
 * Added in version 6.0.0
 *
 * The default vibration for a successful scan.
 */
@property (class, nonatomic, readonly) SDCVibration *defaultVibration;
/**
 * Added in version 6.7.0
 *
 * It creates haptics to indicate a change in selection. In particular it uses UISelectionFeedbackGenerator.
 * Please note that if the device does not have the Taptic Engine, no vibration will be emitted.
 */
@property (class, nonatomic, readonly) SDCVibration *selectionHapticFeedback;
/**
 * Added in version 6.7.0
 *
 * It creates haptics to communicate successes. This is a notification feedback type, indicating that a task has completed successfully. In particular it uses UINotificationFeedbackGenerator with type UINotificationFeedbackTypeSuccess.
 * Please note that if the device does not have the Taptic Engine, no vibration will be emitted.
 */
@property (class, nonatomic, readonly) SDCVibration *successHapticFeedback;
/**
 * Added in version 6.8.0
 *
 * It creates haptics to communicate impact. In particular it uses UIImpactFeedbackGenerator.
 * Please note that if the device does not have the Taptic Engine, no vibration will be emitted.
 */
@property (class, nonatomic, readonly) SDCVibration *impactHapticFeedback;
/**
 * Added in version 6.9.0
 *
 * Returns the JSON representation of the vibration.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
