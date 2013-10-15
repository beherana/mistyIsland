//
//  GlobalFunctions.m
//  
//
//  Created by Radif Sharafullin on 1/31/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import "cdaGlobalFunctions.h"

UIColor* UIColorFromRGBAString(NSString * rgbaString){
	 NSArray *elements=[rgbaString componentsSeparatedByString:@","];
	 float components[4];
	 for (int i=0;i<4;++i) {
		 components[i]=0.0f;
	 }
	 int counter=0;
	 for (NSString *element in elements) {
		 components[counter]= [element floatValue];
		 counter++;
	 }
	 return [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}

@implementation cdaGlobalFunctions
//TODO: this class is yet to be expanded

// Gets the full bundle path of an item
+ (NSString *)getFullPath:(NSString *)inPath
{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:inPath];
}
+(NSString *)documentsPath{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(NSString *)cachesPath{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
			
+(NSString *)pathByResolvingSymlinks:(NSString *)inPath{
	//bundle
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$BUNDLE" withString:[[NSBundle mainBundle] resourcePath]];
	//documents
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$DOCUMENTS" withString:[cdaGlobalFunctions documentsPath] ];
	//cache
	inPath=[inPath stringByReplacingOccurrencesOfString:@"$CACHES" withString:[cdaGlobalFunctions cachesPath]];
	return inPath;
}
			
			
			
// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createDirectories:(BOOL)inCreateDirectories{
	NSString *tmpString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:inPath];
	NSString *directoryPath = [tmpString stringByDeletingLastPathComponent];
	if (inCreateDirectories && ![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpString;
}


// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createItIfDoesntExist:(BOOL)inCreateDirectories{
	NSString *tmpString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:inPath];
	if (inCreateDirectories && ![[NSFileManager defaultManager] fileExistsAtPath:tmpString])
		[[NSFileManager defaultManager] createDirectoryAtPath:tmpString withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpString;
}

+(NSString *)uniqueTimestampID{
	srandom(time(NULL));//ForID
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
	[dateFormatter setDateFormat:@"a-dd-yyyy-MM-hh-ss-mm"];
	NSString *dateString=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
	[dateFormatter release];
	return 	[NSString stringWithFormat:@"%@-%llu-%i%i%i%i",dateString,mach_absolute_time(),random()%10000,random()%10000,random()%10000,random()%10000];
	
}
@end
