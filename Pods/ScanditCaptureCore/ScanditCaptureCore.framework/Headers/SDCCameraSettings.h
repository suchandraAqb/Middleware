/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCFocusGestureStrategy.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.0.0
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCVideoResolution) {
/**
     * Added in version 6.0.0
     *
     * Resolution is 1280x720.
     */
    SDCVideoResolutionHD NS_SWIFT_NAME(hd) = 0,
/**
     * Added in version 6.0.0
     *
     * Resolution is 1920x1080.
     */
    SDCVideoResolutionFullHD = 1,
/**
     * Added in version 6.0.0
     *
     * In contrast to SDCVideoResolutionFullHD, and SDCVideoResolutionHD, SDCVideoResolutionAuto will select the resolution based on hardware capabilities and/or scan-performance considerations. The chosen resolution may change in future versions of the software.
     */
    SDCVideoResolutionAuto = 2,
/**
     * Added in version 6.0.0
     *
     * Resolution is 3840x2160. Please note: Usage of this resolution is not part of every license. If you encounter issues, please contact us at support@scandit.com.
     */
    SDCVideoResolutionUHD4K NS_SWIFT_NAME(uhd4k) = 3,
} NS_SWIFT_NAME(VideoResolution);

/**
 * Added in version 6.1.0
 */
SDC_EXTERN NSString *_Nonnull NSStringFromVideoResolution(SDCVideoResolution videoResolution) NS_SWIFT_NAME(getter:SDCVideoResolution.jsonString(self:));
/**
 * Added in version 6.1.0
 */
SDC_EXTERN BOOL SDCVideoResolutionFromJSONString(NSString *_Nonnull JSONString, SDCVideoResolution *_Nonnull videoResolution);

/**
 * Added in version 6.0.0
 *
 * Enumeration of possible focus ranges to use. This can be used to restrict the auto-focus system to only consider objects in a certain range to focus on.
 */
typedef NS_CLOSED_ENUM(NSUInteger, SDCFocusRange) {
/**
     * Added in version 6.0.0
     *
     * Use the full focus range supported by the camera.
     */
    SDCFocusRangeFull,
/**
     * Added in version 6.0.0
     *
     * Only focus on objects that are far from the camera.
     */
    SDCFocusRangeFar,
/**
     * Added in version 6.0.0
     *
     * Only focus on objects that are near to the camera.
     */
    SDCFocusRangeNear,
} NS_SWIFT_NAME(FocusRange);

/**
 * Added in version 6.1.0
 */
SDC_EXTERN NSString *_Nonnull NSStringFromFocusRange(SDCFocusRange focusRange) NS_SWIFT_NAME(getter:SDCFocusRange.jsonString(self:));
/**
 * Added in version 6.1.0
 */
SDC_EXTERN BOOL SDCFocusRangeFromJSONString(NSString *_Nonnull JSONString, SDCFocusRange *_Nonnull focusRange);

SDC_EXTERN const CGFloat SDCCurrentZoomFactor NS_SWIFT_NAME(CurrentZoomFactor);

/**
 * Added in version 6.0.0
 *
 * Holds camera-specific settings such as preferred resolution, maximum frame rate etc. The defaults are chosen such that they work for a wide variety of use cases. You may apply custom settings to further optimize scan performance for your particular use case. There is typically no need to customize the camera settings beyond changing the preferred resolution.
 *
 * For best performance use the camera settings returned by the capture mode you are using, e.g. SDCBarcodeCapture.recommendedCameraSettings, or SDCBarcodeTracking.recommendedCameraSettings etc.
 *
 * @remark This class is not thread safe.
 *
 * Holds camera related settings such as preview resolution and maximum frame rate to use.
 */
NS_SWIFT_NAME(CameraSettings)
SDC_EXPORTED_SYMBOL
@interface SDCCameraSettings : NSObject

/**
 * Added in version 6.0.0
 *
 * Creates new default camera settings. zoomFactor is set to 1 and preferredResolution is set to SDCVideoResolutionAuto.
 */
- (instancetype)init;
/**
 * Added in version 6.0.0
 *
 * Creates a copy of the provided settings.
 */
- (instancetype)initWithSettings:(nonnull SDCCameraSettings *)settings;
/**
 * Added in version 6.2.0
 *
 * Set camera property to the provided value. Use this method to set properties that are not yet part of a stable API. Properties set through this method may or may not be used or change in a future release.
 */
- (void)setValue:(nonnull id)value forProperty:(nonnull NSString *)property;
/**
 * Added in version 6.2.0
 *
 * Retrieves the value of a previously set camera property. In case the property does not exist, nil is returned.
 */
- (nullable id)valueForProperty:(nonnull NSString *)property;

/**
 * Added in version 6.0.0
 *
 * The preferred resolution to use for the camera. The camera will use the resolution that is closests to the resolution preference. For example, if only lower resolutions than the preferred resolution are available, the highest available resolution will be used.
 *
 * The resolution chosen by the camera only takes the preferredResolution into account, it does not consider the resolution limit of your license key. When the device selects a resolution that is larger than what you have licensed, the data capture context will report a license status error.
 *
 * The default value is SDCVideoResolutionAuto.
 */
@property (nonatomic, assign) SDCVideoResolution preferredResolution;
/**
 * Added in version 6.0.0
 *
 * The maximum frame rate to use for the camera. If the value is higher than the maximum available frame rate of the device, it will be set to the device’s maximum.
 *
 * The default value is 30 Hz.
 *
 * Deprecated since version 6.7.0: The frame rate is optimized internally based on the used device. Setting max frame rate may have no effect due to camera or device-specific restrictions.
 */
@property (nonatomic, assign) CGFloat maxFrameRate DEPRECATED_MSG_ATTRIBUTE(
    "The frame rate is optimized internally based on the used device. Setting max frame rate may "
    "have no effect due to camera or device-specific restrictions.");
/**
 * Added in version 6.0.0
 *
 * The zoom factor to use for the camera. This value is a multiplier, a value of 1.0 means no zoom, while a value of 2.0 doubles the size of the image, but halves the field of view.
 *
 * Values less than 1.0 are treated as 1.0. Values greater than the maximum available zoom factor are clamped to the maximum accepted value.
 *
 * The default zoom factor is 1.0.
 */
@property (nonatomic, assign) CGFloat zoomFactor;
/**
 * Added in version 6.0.0
 *
 * The focus range to primarily use, if supported by the device.
 */
@property (nonatomic, assign) SDCFocusRange focusRange;
/**
 * Added in version 6.6.0
 *
 * The focus gesture strategy to use.
 */
@property (nonatomic, assign) SDCFocusGestureStrategy focusGestureStrategy;
/**
 * Added in version 6.4.0
 *
 * Whether to prefer smooth auto-focus. The default settings have this turned off. Enable it to switch to a smoother (but potentially less reliable) auto-focus strategy. For some devices, this property has no effect.
 */
@property (nonatomic, assign) BOOL shouldPreferSmoothAutoFocus;
/**
 * Added in version 6.6.0
 *
 * The zoom factor to move to when the zoom in gesture was performed. This value is a multiplier, a value of 1.0 means no zoom, while a value of 2.0 doubles the size of the image, but halves the field of view. See also zoomFactor.
 *
 * The default zoom factor for the zoom in gesture is 2.0.
 */
@property (nonatomic, assign) CGFloat zoomGestureZoomFactor;
/**
 * Added in version 6.7.0
 *
 * The torch intensity level. This value must be a number between 0.0 and 1.0.
 * If a number outside the range is provided, either 0.0 or 1.0 will be used instead.
 * Setting the torch level to 0.0 is equivalent to having the torch off.
 */
@property (nonatomic, assign) CGFloat torchLevel;

@end

NS_ASSUME_NONNULL_END
