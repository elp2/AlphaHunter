deletewords = ""

split = deletewords.split( "," );

import sqlite3
conn = sqlite3.connect( 'dict.db' )

for str in split:
	str = str.strip().lower()
	sql = "DELETE FROM words WHERE word = '%s'" % str
	print( sql )
	conn.execute( sql )
	conn.commit()



