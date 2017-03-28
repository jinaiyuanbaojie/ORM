//
//  OMRSQLiteHelper.m
//  JSPatchDemoProject
//
//  Created by 晋爱元 on 2017/3/22.
//  Copyright © 2017年 jinaiyuan. All rights reserved.
//

#import "OMRSQLiteHelper.h"

static NSString *const kZXBDbFileName = @"zxb.db";

@interface OMRSQLiteHelper()
@property (nonatomic,strong) FMDatabaseQueue    *dbQueue;
@end

@implementation OMRSQLiteHelper

+(instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    
    static OMRSQLiteHelper *helper = nil;
    dispatch_once(&onceToken, ^{
        helper = [[OMRSQLiteHelper alloc] init];
    });
    
    return helper;
}

- (instancetype) init{
    self = [super init];
    if (self) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[self class] pathForZXBDataBase]];
    }
    
    return self;
}

- (BOOL) executeStatements:(NSString*) sql{
    __block BOOL ret = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ret = [db executeStatements:sql];
    }];
    return ret;
}

- (FMResultSet*) executeQuery:(NSString*) sql{
    __block FMResultSet *set = nil;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        set = [db executeQuery:sql];
    }];
    return set;
}

- (BOOL) executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments{
    __block BOOL ret = NO;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:sql withArgumentsInArray:arguments];
    }];
    return ret;
}

+(NSString*) pathForZXBDataBase{
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES).firstObject;
    NSString *dataBaseName = [documents stringByAppendingPathComponent:kZXBDbFileName];
    return dataBaseName;
}

@end
