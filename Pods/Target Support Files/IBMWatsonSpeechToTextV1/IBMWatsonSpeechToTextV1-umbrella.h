#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ogg.h"
#import "opus.h"
#import "opus_defines.h"
#import "opus_multistream.h"
#import "opus_types.h"
#import "os_types.h"

FOUNDATION_EXPORT double SpeechToTextVersionNumber;
FOUNDATION_EXPORT const unsigned char SpeechToTextVersionString[];

