CREATE TABLE `refund_lost_item_fee_rules` (
  `branchcode` varchar(10) NOT NULL default '',
  `refund` tinyint(1) NOT NULL default 0,
  PRIMARY KEY  (`branchcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
VALUES( 'RefundLostOnReturnControl',
        'CheckinLibrary',
        'If a lost item is returned, choose which branch to pick rules for refunding.',
        'CheckinLibrary|PatronLibrary|ItemHomeBranch|ItemHoldingbranch',
        'Choice');

INSERT INTO refund_lost_item_fee_rules (branchcode,refund)
    SELECT '*', COALESCE(value,'1') FROM systempreferences WHERE variable='RefundLostItemFeeOnReturn';

DELETE IGNORE FROM systempreferences;

-- $DBversion = "16.06.00.XXX";
-- if ( CheckVersion($DBversion) ) {
--     $dbh->do(q{
--         CREATE TABLE `refund_lost_item_fee_rules` (
--           `branchcode` varchar(10) NOT NULL default '',
--           `refund` tinyint(1) NOT NULL default 0,
--           PRIMARY KEY  (`branchcode`)
--         ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
--     });
--     $dbh->do(q{
--         INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
--         VALUES( 'RefundLostOnReturnControl',
--                 'CheckinLibrary',
--                 'If a lost item is returned, choose which branch to pick rules for refunding.',
--                 'CheckinLibrary|PatronLibrary|ItemHomeBranch|ItemHoldingbranch',
--                 'Choice')
--     });
--     # Pick the old syspref as the default rule
--     $dbh->do(q{
--         INSERT INTO refund_lost_item_fee_rules (branchcode,refund)
--             SELECT '*', COALESCE(value,'1') FROM systempreferences WHERE variable='RefundLostItemFeeOnReturn'
--     });
--     # Delete the old syspref
--     $dbh->do(q{
--         DELETE IGNORE FROM systempreferences
--         WHERE variable='RefundLostItemFeeOnReturn'
--     });

--     print "Upgrade to $DBversion done (Bug 14048: Change RefundLostItemFeeOnReturn to be branch specific)\n";
--     SetVersion($DBversion);
-- }
