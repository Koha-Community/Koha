$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    if ( !TableExists( 'illrequests' ) ) {
        $dbh->do(q{
            CREATE TABLE illrequests (
               illrequest_id serial PRIMARY KEY,           -- ILL request number
               borrowernumber integer DEFAULT NULL,        -- Patron associated with request
               biblio_id integer DEFAULT NULL,             -- Potential bib linked to request
               branchcode varchar(50) NOT NULL,            -- The branch associated with the request
               status varchar(50) DEFAULT NULL,            -- Current Koha status of request
               placed date DEFAULT NULL,                   -- Date the request was placed
               replied date DEFAULT NULL,                  -- Last API response
               updated timestamp DEFAULT CURRENT_TIMESTAMP -- Last modification to request
                 ON UPDATE CURRENT_TIMESTAMP,
               completed date DEFAULT NULL,                -- Date the request was completed
               medium varchar(30) DEFAULT NULL,            -- The Koha request type
               accessurl varchar(500) DEFAULT NULL,        -- Potential URL for accessing item
               cost varchar(20) DEFAULT NULL,              -- Cost of request
               notesopac text DEFAULT NULL,                -- Patron notes attached to request
               notesstaff text DEFAULT NULL,               -- Staff notes attached to request
               orderid varchar(50) DEFAULT NULL,           -- Backend id attached to request
               backend varchar(20) DEFAULT NULL,           -- The backend used to create request
               CONSTRAINT `illrequests_bnfk`
                 FOREIGN KEY (`borrowernumber`)
                 REFERENCES `borrowers` (`borrowernumber`)
                 ON UPDATE CASCADE ON DELETE CASCADE,
               CONSTRAINT `illrequests_bcfk_2`
                 FOREIGN KEY (`branchcode`)
                 REFERENCES `branches` (`branchcode`)
                 ON UPDATE CASCADE ON DELETE CASCADE
           ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });
    }

    if ( !TableExists( 'illrequestattributes' ) ) {
        $dbh->do(q{
            CREATE TABLE illrequestattributes (
                illrequest_id bigint(20) unsigned NOT NULL, -- ILL request number
                type varchar(200) NOT NULL,                 -- API ILL property name
                value text NOT NULL,                        -- API ILL property value
                PRIMARY KEY  (`illrequest_id`,`type`),
                CONSTRAINT `illrequestattributes_ifk`
                  FOREIGN KEY (illrequest_id)
                  REFERENCES `illrequests` (`illrequest_id`)
                  ON UPDATE CASCADE ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        });
    }

    # System preferences
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
            ('ILLModule','0','If ON, enables the interlibrary loans module.','','YesNo');
    });

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES
            ('ILLModuleCopyrightClearance','','70|10','Enter text to enable the copyright clearance stage of request creation. Text will be displayed','Textarea');
    });
    # userflags
    $dbh->do(q{
        INSERT IGNORE INTO userflags (bit,flag,flagdesc,defaulton) VALUES
            (22,'ill','The Interlibrary Loans Module',0);
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 7317 - Add an Interlibrary Loan Module to Circulation and OPAC)\n";
}
