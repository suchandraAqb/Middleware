/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

@class SDCBarcode;
@class SDCLocalizedOnlyBarcode;

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.8.0
 *
 * The spark capture session is responsible for determining the list of relevant barcodes by filtering out duplicates. This filtering of duplicates is completely time-based and does not use any information about the location of the barcode. By default, all the codes scanned in a frame are always reported. It is possible to filter out codes recently scanned by changing SDCSparkCaptureSettings.codeDuplicateFilter.
 *
 * When the spark capture mode is disabled, the session’s duplicate filter is reset.
 *
 * The spark capture session should only be accessed from within sparkCapture:didScanInSession:frameData: or sparkCapture:didUpdateSession:frameData: and from the thread these methods are called from. It is not safe to be accessed from anywhere else since it may be concurrently modified.
 *
 * Specifically no reference to newlyRecognizedBarcodes should be kept and traversed outside of sparkCapture:didScanInSession:frameData: or sparkCapture:didUpdateSession:frameData:. Instead a copy of the lists should be made to avoid concurrent modification. The individual barcodes can be referenced without copying as they are not further modified.
 */
NS_SWIFT_NAME(SparkCaptureSession)
SDC_EXPORTED_SYMBOL
@interface SDCSparkCaptureSession : NSObject

/**
 * Added in version 6.8.0
 *
 * List of codes that were newly recognized in the last processed frame.
 */
@property (nonatomic, nonnull, readonly) NSArray<SDCBarcode *> *newlyRecognizedBarcodes;
/**
 * Added in version 6.8.0
 *
 * The identifier of the current frame sequence.
 *
 * As long as there is no interruption of frames coming from the camera, the frameSequenceId will stay the same.
 */
@property (nonatomic, readonly) NSInteger frameSequenceId;
/**
 * Added in version 6.8.0
 *
 * Returns the JSON representation of the spark capture session.
 */
@property (nonatomic, nonnull, readonly) NSString *JSONString;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 * Added in version 6.8.0
 *
 * Resets the spark capture session, effectively clearing the history of scanned codes. This affects duplicate filtering: when calling reset every frame has the same effect as setting the SDCSparkCaptureSettings.codeDuplicateFilter to 0.
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
