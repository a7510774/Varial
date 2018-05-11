//
//  DBManager.h
//  DatabaseSample
//
//  Created by Shanmuga priya on 4/14/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface DBManager : NSObject
{
    NSString *destinationPath, *sourcePath;
}

+ (DBManager *)sharedInstance;

@property(strong,nonatomic)NSString *oldID;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSString *documentsDirectory;

- (void) createDB;
- (BOOL) saveRecord:(NSString *)query withParams:(NSMutableArray *)params;
- (BOOL) saveRecord:(NSString*)query;
- (NSMutableArray *) findRecord:(NSString*)query;
- (BOOL) updateRecord:(NSString*)query;
- (BOOL) deleteRecord:(NSString *)query;
- (int) recordCount:(NSString*)query;
- (void) convertToJson:(NSMutableArray *)array;

@end
