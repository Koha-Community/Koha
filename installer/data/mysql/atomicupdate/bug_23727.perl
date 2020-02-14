$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if ( !column_exists( 'course_items', 'itype_enabled' ) ) {
        $dbh->do(q{
            ALTER TABLE course_items
            ADD COLUMN itype_enabled tinyint(1) NOT NULL DEFAULT 0 AFTER itype,
            ADD COLUMN ccode_enabled tinyint(1) NOT NULL DEFAULT 0 AFTER ccode,
            ADD COLUMN holdingbranch_enabled tinyint(1) NOT NULL DEFAULT 0 AFTER holdingbranch,
            ADD COLUMN location_enabled tinyint(1) NOT NULL DEFAULT 0 AFTER location,
            ADD COLUMN itype_storage varchar(10) DEFAULT NULL AFTER itype_enabled,
            ADD COLUMN ccode_storage varchar(80) DEFAULT NULL AFTER ccode_enabled,
            ADD COLUMN holdingbranch_storage varchar(10) DEFAULT NULL AFTER ccode_enabled,
            ADD COLUMN location_storage varchar(80) DEFAULT NULL AFTER location_enabled
        });

        my $item_level_items = C4::Context->preference('item-level_itypes');
        my $itype_field = $item_level_items ? 'i.itype' : 'bi.itemtype';
        $dbh->do(qq{
            UPDATE course_items ci
            LEFT JOIN items i USING ( itemnumber )
            LEFT JOIN biblioitems bi USING ( biblioitemnumber )
            SET

            -- Assume the column is enabled if the course item is active and i.itype/bi.itemtype is set,
            -- or if the course item is not enabled and ci.itype is set
            ci.itype_enabled = IF( ci.enabled = 'yes', IF( $itype_field IS NULL, 0, 1 ), IF(  ci.itype IS NULL, 0, 1  ) ),
            ci.ccode_enabled = IF( ci.enabled = 'yes', IF( i.ccode IS NULL, 0, 1 ), IF(  ci.ccode IS NULL, 0, 1  ) ),
            ci.holdingbranch_enabled = IF( ci.enabled = 'yes', IF( i.holdingbranch IS NULL, 0, 1 ), IF(  ci.holdingbranch IS NULL, 0, 1  ) ),
            ci.location_enabled = IF( ci.enabled = 'yes', IF( i.location IS NULL, 0, 1 ), IF(  ci.location IS NULL, 0, 1  ) ),

            -- If the course item is enabled, copy the value from the item.
            -- If the course item is not enabled, keep the existing value
            ci.itype = IF( ci.enabled = 'yes', $itype_field, ci.itype ),
            ci.ccode = IF( ci.enabled = 'yes', i.ccode, ci.ccode ),
            ci.holdingbranch = IF( ci.enabled = 'yes', i.holdingbranch, ci.holdingbranch ),
            ci.location = IF( ci.enabled = 'yes', i.location, ci.location ),

            -- If the course is enabled, copy the value from the item to storage.
            -- If it is not enabled, copy the value from the course item to storage
            ci.itype_storage = IF( ci.enabled = 'no', $itype_field, ci.itype ),
            ci.ccode_storage = IF( ci.enabled = 'no', i.ccode, ci.ccode ),
            ci.holdingbranch_storage = IF( ci.enabled = 'no', i.holdingbranch, ci.holdingbranch ),
            ci.location_storage = IF( ci.enabled = 'no', i.location, ci.location );
        });

        # Clean up the storage columns
        $dbh->do(q{
            UPDATE course_items SET
                itype_storage = NULL,
                ccode_storage = NULL,
                holdingbranch_storage = NULL,
                location_storage = NULL
            WHERE enabled = 'no';
        });

        # Clean up the course enabled value columns
        $dbh->do(q{
            UPDATE course_items SET
                itype = IF( itype_enabled = 'no', NULL, itype ),
                ccode = IF( ccode_enabled = 'no', NULL, ccode ),
                holdingbranch = IF( holdingbranch_enabled = 'no', NULL, holdingbranch ),
                location = IF( location_enabled = 'no', NULL, location )
            WHERE enabled = 'no';
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23727 - Editing course reserve items is broken)\n";
}
