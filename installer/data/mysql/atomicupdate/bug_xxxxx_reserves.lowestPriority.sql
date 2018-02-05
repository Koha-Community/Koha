ALTER TABLE reserves MODIFY lowestPriority tinyint(1) NOT NULL DEFAULT 0;
ALTER TABLE old_reserves MODIFY lowestPriority tinyint(1) NOT NULL DEFAULT 0;
