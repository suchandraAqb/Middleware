/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <ScanditCaptureCore/SDCBase.h>
#import <ScanditCaptureCore/SDCDataCaptureMode.h>
#import <ScanditCaptureCore/SDCMeasureUnit.h>

@class SDCDataCaptureContext;
@class SDCCameraSettings;
@class SDCSparkCaptureSettings;
@class SDCSparkCaptureSession;
@class SDCSparkCaptureFeedback;
@class SDCSparkCapture;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.8.0
 *
 * Delegate protocol for traditional spark capture.
 */
NS_SWIFT_NAME(SparkCaptureListener)
@protocol SDCSparkCaptureListener <NSObject>

@required

/**
 * Added in version 6.8.0
 *
 * Invoked whenever a code has been scanned. The newly scanned codes can be retrieved from SDCSparkCaptureSession.newlyRecognizedBarcodes.
 *
 * This method is invoked from a recognition internal thread. To perform UI work, you must dispatch to the main thread first. After receiving this callback, you will typically want to start processing the scanned barcodes. Keep in mind however, that any further recognition is blocked until this method completes. Therefore, if you need to perform a time-consuming operation, like querying a database or opening an URL encoded in the barcode data, consider switching to another thread.
 *
 * Sometimes, after receiving this callback, you may want to pause scanning or to stop scanning completely.
 *
 *   • To pause scanning, but keep the camera (frame source) running, just set the spark capture’s enabled property to NO.
 *
 * captureMode.isEnabled = true
 *
 *   • To stop scanning, you will need to both disable the capture mode and stop the frame source. While it’s possible to only stop the camera and keep the capture mode enabled, this may lead to additional scan events being delivered, which is typically not desired. The following lines of code show how to disable the capture mode and stop the frame source as well:
 *
 * // no more didScan callbacks will be invoked after this call.
 * captureMode.isEnabled = false
 * // asynchronously turn off the camera as quickly as possible.
 * captureMode.context?.frameSource?.switch(toDesiredState: .off, completionHandler: nil)
 *
 * @code
 * captureMode.isEnabled = true
 * @endcode
 *
 * @code
 * // no more didScan callbacks will be invoked after this call.
 * captureMode.isEnabled = false
 * // asynchronously turn off the camera as quickly as possible.
 * captureMode.context?.frameSource?.switch(toDesiredState: .off, completionHandler: nil)
 * @endcode
 */
- (void)sparkCapture:(SDCSparkCapture *)sparkCapture
    didScanInSession:(SDCSparkCaptureSession *)session
           frameData:(id<SDCFrameData>)frameData;

@optional

/**
 * Added in version 6.8.0
 *
 * Invoked after a frame has been processed by spark capture and the session has been updated. In contrast to sparkCapture:didScanInSession:frameData:, this method is invoked, regardless whether a code was scanned or not. If codes were recognized in this frame, this method is invoked after sparkCapture:didScanInSession:frameData:.
 *
 * This method is invoked from a recognition internal thread. To perform UI work, you must dispatch to the main thread first. Further recognition is blocked until this method completes. It is thus recommended to do as little work as possible in this method.
 */
- (void)sparkCapture:(SDCSparkCapture *)sparkCapture
    didUpdateSession:(SDCSparkCaptureSession *)session
           frameData:(id<SDCFrameData>)frameData;

/**
 * Added in version 6.8.0
 *
 * Called when the listener starts observing the spark capture instance.
 */
- (void)didStartObservingSparkCapture:(SDCSparkCapture *)sparkCapture;

/**
 * Added in version 6.8.0
 *
 * Called when the listener stops observing the spark capture instance.
 */
- (void)didStopObservingSparkCapture:(SDCSparkCapture *)sparkCapture;

@end

/**
 * Added in version 6.8.0
 *
 * Capture mode that implements spark capture.
 *
 * This capture mode uses the barcode scanning capability. It cannot be used together with other capture modes that require the same capabilities, e.g. SDCBarcodeCapture.
 */
NS_SWIFT_NAME(SparkCapture)
SDC_EXPORTED_SYMBOL
@interface SDCSparkCapture : NSObject <SDCDataCaptureMode>

/**
 * Added in version 6.8.0
 *
 * Implemented from SDCDataCaptureMode. See SDCDataCaptureMode.context.
 */
@property (nonatomic, nullable, readonly) SDCDataCaptureContext *context;
/**
 * Added in version 6.8.0
 *
 * Implemented from SDCDataCaptureMode. See SDCDataCaptureMode.enabled.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
/**
 * Added in version 6.8.0
 *
 * Instance of SDCSparkCaptureFeedback that is used by spark capture to notify users about a successful scan of a barcode.
 *
 * To change the feedback emitted, the SDCSparkCaptureFeedback can be modified as shown below, or a new one can be assigned.
 *
 * @code
 * let sparkCapture: SparkCapture = ...
 * sparkCapture.feedback.success = Feedback(vibration: Vibration.impactHapticFeedback, sound: Sound.default)
 * @endcode
 */
@property (nonatomic, strong, nonnull) SDCSparkCaptureFeedback *feedback;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.8.0
 *
 * Construct a new spark capture mode with the provided context and settings. When the context is not nil, the capture mode is automatically added to the context.
 */
+ (instancetype)sparkCaptureWithContext:(nullable SDCDataCaptureContext *)context
                               settings:(nonnull SDCSparkCaptureSettings *)settings;

/**
 * Added in version 6.9.0
 *
 * Construct a new spark capture mode with the provided JSON serialization. See Serialization for details. The capture mode is automatically added to the context.
 */
+ (nullable instancetype)sparkCaptureFromJSONString:(nonnull NSString *)JSONString
                                            context:(nonnull SDCDataCaptureContext *)context
                                              error:(NSError *_Nullable *_Nullable)error
    NS_SWIFT_NAME(init(jsonString:context:));

/**
 * Added in version 6.8.0
 *
 * Asynchronously applies the new settings to the barcode scanner. If the scanner is currently running, the task will complete when the next frame is processed, and will use the new settings for that frame. If the scanner is currently not running, the task will complete as soon as the settings have been stored and won’t wait until the next frame is going to be processed.
 */
- (void)applySettings:(nonnull SDCSparkCaptureSettings *)settings
    completionHandler:(nullable void (^)(void))completionHandler;

/**
 * Added in version 6.8.0
 *
 * Adds the listener to this spark capture instance.
 *
 * In case the same listener is already observing this instance, calling this method will not add the listener again. The listener is stored using a weak reference and must thus be retained by the caller for it to not go out of scope.
 */
- (void)addListener:(nonnull id<SDCSparkCaptureListener>)listener NS_SWIFT_NAME(addListener(_:));
/**
 * Added in version 6.8.0
 *
 * Removes a previously added listener from this spark capture instance.
 *
 * In case the listener is not currently observing this instance, calling this method has no effect.
 */
- (void)removeListener:(nonnull id<SDCSparkCaptureListener>)listener
    NS_SWIFT_NAME(removeListener(_:));

/**
 * Added in version 6.9.0
 *
 * Updates the mode according to a JSON serialization. See Serialization for details.
 */
- (BOOL)updateFromJSONString:(nonnull NSString *)JSONString
                       error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
