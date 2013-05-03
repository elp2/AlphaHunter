//
//  AHDictionarySingleton.m
//  AlphaHunterIpad
//
//  Created by Ed Palmer on 16/12/2010.
//  Copyright 2010 chichai.com. All rights reserved.
//

#import "AHDictionarySingleton.h"
#import <sqlite3.h>

static AHDictionarySingleton *sharedInstance = nil;

static sqlite3 *database = nil;

@implementation AHDictionarySingleton

@synthesize seenInstructions = seenInstructions_;
		 
-(int) isAWord:(NSString *) wordString
{
	if( [wordString length] <3 )
		return NO;
	
	NSLog( @"checkForWordiness: [%@]", wordString );
	
	const char *sql = [[[NSString stringWithFormat:@"select * from words where word ='%@'", wordString] lowercaseString] cStringUsingEncoding:NSASCIIStringEncoding ];
	NSLog( @"%s", sql );
	sqlite3_stmt *selectstmt;
	assert(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK);
	
	NSLog( @"prepared" );
	
	return( sqlite3_step(selectstmt) == SQLITE_ROW );
}
			 
			 
#pragma mark -
#pragma mark Database Functions
			 
-(NSString *) getDBPath 
{
	 
	 //Search for standard documents using NSSearchPathForDirectoriesInDomains
	 //First Param = Searching the documents directory
	 //Second Param = Searching the Users directory and not the System
	 //Expand any tildes and identify home directories.
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	 NSString *documentsDir = [paths objectAtIndex:0];
	 return [documentsDir stringByAppendingPathComponent:@"dict.db"];
 }
 
 // The database needs to live somewhere we can write it
 -(void) copyDatabaseIfNeeded {
	 NSFileManager *fileManager = [NSFileManager defaultManager];
	 NSError *error;
	 NSString *dbPath = [self getDBPath];
	 BOOL success = [fileManager fileExistsAtPath:dbPath]; 
	 
	 if(!success) {
		 NSLog( @"Copying over DB" );
		 NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dict.db"];
		 NSLog( @"Coping from %@", defaultDBPath );
		 success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		 
		 if (!success) 
			 NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		 
		 NSLog( @"DB Copied" );
	 }	
 }
 
 -(void)setupWordsDB
{
	[self copyDatabaseIfNeeded];
	
	// Do one fake query to get things going with the database		
	if (sqlite3_open([[self getDBPath] UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "select word from words where word ='abacus'";
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				NSLog( @"found something!" );
			}
		} else { NSLog( @"Found nothing!" ); }
	}
	else {
		NSLog( @"NO DB!!!!!!!!!!!!!!!" );
		sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory
	}
}

-(NSMutableArray *) getXRandomWords:(int) numWords
{
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	const char *sql = [[[NSString stringWithFormat:@"SELECT word FROM words ORDER BY RANDOM() LIMIT %d;", numWords] lowercaseString] cStringUsingEncoding:NSASCIIStringEncoding ];
	NSLog( @"%s", sql );
	sqlite3_stmt *selectstmt;
	assert(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK);
	
	NSLog( @"prepared" );
	
	while ( sqlite3_step(selectstmt) == SQLITE_ROW ) {		
		char *cStringWord = (char *) sqlite3_column_text(selectstmt, 0);
		NSString *word = [NSString stringWithUTF8String:cStringWord];
		[ret addObject:word];
        NSLog(@"%@", word);
	}

	return ret;
}


+(AHDictionarySingleton*)sharedInstance
{
	@synchronized(self)
	{
		if( nil == sharedInstance )
		{
			sharedInstance = [[AHDictionarySingleton alloc] init];
			[sharedInstance setupWordsDB];
            sharedInstance.seenInstructions = NO;
		}
	}
	
    return sharedInstance;
}
			 

@end
