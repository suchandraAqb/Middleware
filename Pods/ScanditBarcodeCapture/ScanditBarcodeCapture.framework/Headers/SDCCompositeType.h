/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2017- Scandit AG. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <ScanditCaptureCore/SDCBase.h>

/**
 * Added in version 6.6.0
 *
 * An enumeration of composite code presets.
 */
typedef NS_OPTIONS(NSUInteger, SDCCompositeType) {
/**
     * Added in version 6.6.0
     *
     * Composite Code A
     */
    SDCCompositeTypeA NS_SWIFT_NAME(a) = 1 << 0,
/**
     * Added in version 6.6.0
     *
     * Composite Code B
     */
    SDCCompositeTypeB NS_SWIFT_NAME(b) = 1 << 1,
/**
     * Added in version 6.6.0
     *
     * Composite Code C
     */
    SDCCompositeTypeC NS_SWIFT_NAME(c) = 1 << 2,
} NS_SWIFT_NAME(CompositeType);

/**
 * Added in version 6.6.0
 *
 * Serialize the composite type in a JSON string.
 */
SDC_EXTERN NSString *_Nonnull NSStringFromCompositeType(SDCCompositeType compositeType)
    NS_SWIFT_NAME(getter:SDCCompositeType.jsonString(self:));
/**
 * Added in version 6.6.0
 *
 * Deserialize the composite type from a JSON string.
 */
SDC_EXTERN BOOL SDCCompositeTypeFromJSONString(NSString *_Nonnull JSONString,
                                               SDCCompositeType *_Nonnull compositeType);

