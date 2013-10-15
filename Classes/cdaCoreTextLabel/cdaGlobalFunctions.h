//
//  GlobalFunctions.h
//
//  Created by Radif Sharafullin on 1/31/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import <Foundation/Foundation.h>


#define CDA_RELEASE_SAFELY(__PTR) { if(__PTR){  [__PTR release]; __PTR = nil;} }
#define CDA_AUTORELEASE_SAFELY(__PTR) { [__PTR autorelease]; __PTR = nil; }
#define CDA_INVALIDATE_TIMER(__TMR) { [__TMR invalidate]; __TMR = nil; }
#define CDA_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }



#ifdef DEBUG
#define CDA_LOG_SELECTOR_NAME NSLog(@"%@",NSStringFromSelector(_cmd))
#define CDA_LOG_METHOD_NAME NSLog(@"%s",__FUNCTION__)
#define cdaLog( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define cdaLogMem( s, ... ) NSLog( @"<%s : (%d)[%d]> %@",__FUNCTION__, __LINE__,[dataHandler get_free_memory], [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define cdaLog( s, ... )
#define cdaLogMem( s, ... )
#define NSLog( s, ... )
#define CDA_LOG_SELECTOR_NAME
#define CDA_LOG_METHOD_NAME
#endif

//color rgb 255/char
#define RGBA(a,b,c,d) [UIColor colorWithRed: a /255.0f green: b / 255.0f blue: c / 255.0f alpha: d / 255.0f]
#define RGB(a,b,c) [UIColor colorWithRed: a /255.0f green: b / 255.0f blue: c / 255.0f alpha:1]




/*!
 * Example string: @"1,1,1,1" for white
 */
UIColor* UIColorFromRGBAString(NSString * rgbaString);

@interface cdaGlobalFunctions : NSObject {
}
+(NSString *)pathByResolvingSymlinks:(NSString *)inPath;
+(NSString *)documentsPath;
+(NSString *)cachesPath;
// Gets the full bundle path of an item
+ (NSString *)getFullPath:(NSString *)inPath;	

// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createDirectories:(BOOL)inCreateDirectories;	

// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createItIfDoesntExist:(BOOL)inCreateDirectories;	
+(NSString *)uniqueTimestampID;
@end
