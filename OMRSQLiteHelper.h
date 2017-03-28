//
//  OMRSQLiteHelper.h
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/22.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface OMRSQLiteHelper : NSObject
+ (instancetype) sharedInstance;
- (FMResultSet*) executeQuery:(NSString*) sql;
- (BOOL) executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL) executeStatements:(NSString*) sql;
@end
