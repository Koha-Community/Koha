INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
SELECT 'MaxItemsToProcessForBatchMod', value, NULL, 'Process up to a given number of items in a single item modification batch.', 'Integer' FROM systempreferences WHERE variable='MaxItemsForBatch';
INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type )
SELECT 'MaxItemsToDisplayForBatchDel', value, NULL, 'Display up to a given number of items in a single item deletionbatch.', 'Integer' FROM systempreferences WHERE variable='MaxItemsForBatch';
DELETE FROM systempreferences WHERE variable="MaxItemsForBatch";
