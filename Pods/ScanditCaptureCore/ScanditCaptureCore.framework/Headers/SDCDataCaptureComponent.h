/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#include <Foundation/Foundation.h>

#include <ScanditCaptureCore/SDCBase.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Added in version 6.3.0
 *
 * SDCDataCaptureComponent is the protocol implemented by all data capture components such as the parser.
 */
NS_SWIFT_NAME(DataCaptureComponent)
SDC_EXPORTED_SYMBOL
@protocol SDCDataCaptureComponent <NSObject>

/**
 * Added in version 6.3.0
 *
 * An ID for the component, currently only assignable during deserialization.
 */
@property (nonatomic, readonly) NSString *componentId;

@end

NS_ASSUME_NONNULL_END
