//
//  DBManager.m
//  DatabaseSample
//
//  Created by Shanmuga priya on 4/14/16.
//  Copyright © 2016 Shanmuga priya. All rights reserved.
//

#import "DBManager.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+ (instancetype) sharedInstance{
    static DBManager *dbManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbManager = [[self alloc] init];
        [dbManager createDB];        
    });
    return dbManager;
}


//Set database path to execute query
-(void)createDB{
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    destinationPath =  [[NSString alloc] initWithString:
                     [docsDir stringByAppendingPathComponent:@"VarialChat"]];
    //NSLog(@"Destination path - %@",destinationPath);
    
    sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"VarialChat"];
    //NSLog(@"Source path : %@",sourcePath);
    
    //copy the database from the directory to the bundle
    [self copyDatabaseIntoDocumentsDirectory:destinationPath withpath:sourcePath];
}


//Insert records into the table
-(BOOL) saveRecord:(NSString *)query
{
    //Convert the database path into excutable string format
    const char *dbpath = [destinationPath UTF8String];
    
    //open the connection
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        //Convert the query string into excutable string format
        const char *insert_stmt = [query UTF8String];
        
        //Prepare query statement to excute
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        
        
        //check whether the query statement executes
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            // Finalize and close database.
            sqlite3_reset(statement);
            return YES;
        }
        else
        {
            // Finalize and close database.
            sqlite3_reset(statement);
            return NO;
        }        
    }
    return NO;
}

//Save records with params
-(BOOL) saveRecord:(NSString *)query withParams:(NSMutableArray *)params
{
    //Convert the database path into excutable string format
    const char *dbpath = [destinationPath UTF8String];
    
    //open the connection
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        
        //Convert the query string into excutable string format
        const char *insert_stmt = [query UTF8String];
        //Prepare query statement to excute
        if(sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL) == SQLITE_OK){
            
            //Apply params
            int i = 1;
            for (NSDictionary *param in params) {
                if ([[param valueForKey:@"type"] intValue] == 1) { // Integer
                     sqlite3_bind_int(statement, i++, [[param valueForKey:@"data"] intValue]);
                }
                else if ([[param valueForKey:@"type"] intValue] == 2) { // Text
                    sqlite3_bind_text(statement, i++,[[param valueForKey:@"data"] UTF8String],-1,SQLITE_TRANSIENT);
                }
                else if ([[param valueForKey:@"type"] intValue] == 3) { // Blob
                    sqlite3_bind_text(statement, i++,[[param valueForKey:@"data"] UTF8String],-1,SQLITE_TRANSIENT);
                }
                else if ([[param valueForKey:@"type"] intValue] == 4) { // Integer
                    sqlite3_bind_double(statement, i++, [[param valueForKey:@"data"] doubleValue]);
                }
            }
            
            //check whether the query statement executes
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                // Finalize and close database.
                sqlite3_reset(statement);
                return YES;
            }
            else
            {
                // Finalize and close database.
                sqlite3_reset(statement);
                return NO;
            }
            
        }
        else{
            NSLog(@"Error %s while preparing statement", sqlite3_errmsg(database));
        }
    }
    return NO;
}


//Retrive records from the table
- (NSMutableArray *) findRecord:(NSString*)query
{
    
    //Convert the database path into excutable string format
    const char *dbpath = [destinationPath UTF8String];
    
    //Open the connection
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        //Convert the query string into excutable string format
        NSString *querySQL = query;
        
        //Convert the query string into excutable string format
        const char *query_stmt = [querySQL UTF8String];
        
        //Prepare query statement to excute
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            //Initialize resultArray to store the result array
            NSMutableArray *resultArray = [[NSMutableArray alloc]init];
            
            //check whether row exist in result statement
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                for(int i=0;i<sqlite3_column_count(statement);i++){
                    
                    char *tmp = sqlite3_column_text(statement, i);
                    if (tmp == NULL)
                        //Fetch result values along with the column name
                        [dict setObject:[NSNumber numberWithInt:0] forKey:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_name(statement, i)]];
                    else
                        //Fetch result values along with the column name
                        [dict setObject:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i)] forKey:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_name(statement, i)]];
                }
                
                //Store result array as a collection of dictionary along with the key
                [resultArray addObject:dict];
            }
            //NSLog(@"Result Array:%@",resultArray);
            
            // Finalize and close database.
            sqlite3_reset(statement);
            
            //Convert the result array to json data
            //[self convertToJson:resultArray];
            return resultArray;
        }
        else{
            NSLog(@"Error %s while preparing statement", sqlite3_errmsg(database));
        }
    }
    else{
        NSLog(@"Error %s while preparing statement", sqlite3_errmsg(database));
    }
    return nil;
}

//Update records in the table
- (BOOL)updateRecord:(NSString *)query {
    
    //Convert the database path into excutable string format
    const char *dbpath = [destinationPath UTF8String];
    
    //Open the connection
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        //Convert the query string into excutable string format
        const char *utf8UpdateQuery = [query UTF8String];
        
        //Prepare query statement to excute
        sqlite3_prepare_v2(database, utf8UpdateQuery, -1, &statement, NULL);
        
        //check whether the query statement executes
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            
            // Finalize and close database.
            sqlite3_reset(statement);
            return YES;
        }
        else
        {
            // Finalize and close database.
            sqlite3_reset(statement);
            return NO;
        }
    }
    else
    {
        // Finalize and close database.
        sqlite3_reset(statement);
        return NO;
    }
}

//Delete records in the table
- (BOOL)deleteRecord:(NSString *)query {
    
    //Convert the database path into excutable string format
    const char *dbpath = [destinationPath UTF8String];
    
    //Open the connection
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSString *deleteQuery = query;
        
        //Convert the query string into excutable string format
        const char *utf8DeleteQuery = [deleteQuery UTF8String];
        
        //Prepare query statement to excute
        sqlite3_prepare_v2(database, utf8DeleteQuery, -1, &statement, NULL);
        
        //check whether the query statement executes
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            // Finalize and close database.
            sqlite3_reset(statement);
            return YES;
        }
        else
        {
            // Finalize and close database.
            sqlite3_reset(statement);
            return NO;
        }
    }
    else
    {
        // Finalize and close database.
        sqlite3_reset(statement);
        return NO;
    }
}

//Return number of records in the table
-(int) recordCount:(NSString *)query
{
    int count = 0;
    
    //Convert the database path into excutable string format
    const char *dbpath = [destinationPath UTF8String];
    
    //Open the connection
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //Convert the query string into excutable string format
        const char* sqlStatement = [query UTF8String];
        sqlite3_stmt* statement;
        
        //Prepare query statement to excute
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //check whether row exist in result statement
            if( sqlite3_step(statement) == SQLITE_ROW )
                
                //Fetch the column number
                count  = sqlite3_column_int(statement, 0);
        }
        else
        {
            NSLog( @"Failed to fetch" );
        }
        
        // Finalize and close database.
        sqlite3_reset(statement);
    }
    return count;
}

//Convert the result array to json data
-(void)convertToJson:(NSMutableArray *)array
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"\n\njsonData :\n%@", jsonData);
    NSLog(@"\n\njsonData as string:\n%@", jsonString);
}

//copy the database from the directory to the bundle
-(void)copyDatabaseIntoDocumentsDirectory:(NSString*)destination withpath:(NSString *)source{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destination])
    {
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:source
                                                toPath:destination error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}
@end
