//
//  Log.h
//  Less2Do
//
//  Created by BlackandCold on 24.11.09.
//  Copyright 2009 TU Wien. All rights reserved.
//

#import <UIKit/UIKit.h>

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

// same game, but extra verbose output (accept both VLog and VLOG [as in TTLOG])
#ifdef DEBUG//VERBOSE
#	define VLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#	define VLOG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define VLog(...)
#	define VLOG(...)
#endif

// extreme verbose!
#ifdef DEBUG_VERBOSE
#	define VVLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#	define VVLOG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define VVLog(...)
#	define VVLOG(...)
#endif


// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define __FUNC_NAME__ NSLog(NSStringFromSelector(_cmd)); 

