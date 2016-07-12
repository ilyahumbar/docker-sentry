CREATE KEYSPACE IF NOT EXISTS sentry WITH REPLICATION = { 
  'class' : 'SimpleStrategy', 
  'replication_factor' : '2' 
};

CREATE TABLE IF NOT EXISTS sentry.nodestore (
  key text PRIMARY KEY,
  flags int,
  value blob
) WITH
  compaction={'sstable_size_in_mb': '160', 'class': 'LeveledCompactionStrategy'} AND
  compression={'sstable_compression': 'SnappyCompressor'};

