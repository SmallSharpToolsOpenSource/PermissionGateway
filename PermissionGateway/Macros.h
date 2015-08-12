//
//  Macros.h
//  PermissionGateway
//
//  Created by Brennan Stehling on 8/11/15.
//  Copyright (c) 2015 Brennan Stehling. All rights reserved.
//

#ifndef PermissionGateway_Macros_h
#define PermissionGateway_Macros_h

// Make sure NDEBUG is defined on Release
#ifndef NDEBUG
#define DebugLog(message, ...) NSLog(@"%s: " message, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define DebugLog(message, ...)
#endif

#ifndef NDEBUG
#define EnvVarIsTrue(key) [[[[NSProcessInfo processInfo] environment] objectForKey:key] boolValue]
#else
#define EnvVarIsTrue(key)
#endif

#ifndef NDEBUG
#define EnvVarString(key) [[[NSProcessInfo processInfo] environment] objectForKey:key]
#else
#define EnvVarString(key)
#endif

#endif
