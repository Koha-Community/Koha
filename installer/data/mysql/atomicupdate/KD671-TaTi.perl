$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('BatchOverlayRules','','Define BatchOverlayRules YAML','70|10','Textarea')");
    $dbh->do("DROP TABLE batch_overlay_rules");

    $dbh->do("
    CREATE TABLE `batch_overlay_reports` ( -- Stores the reports generated during a single batch overlay operation
      `id` int(11) NOT NULL auto_increment,
      `borrowernumber` int(11), -- Borrower who is running this batch overlay operation
      `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP, -- when did the overlaying happen
      PRIMARY KEY (`id`),
      CONSTRAINT `bor_bornum_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

    $dbh->do("
    CREATE TABLE `batch_overlay_diff` ( -- Stores the singular record overlaying report
      `id` int(11) NOT NULL auto_increment,
      `batch_overlay_reports_id` int(11) NOT NULL,
      `biblionumber` int(11), -- Local biblionumber of the original record being overlayed
      `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP, -- when did the overlaying happen
      `operation` varchar(40) NOT NULL, -- name of the operation, 'error', ...
      `ruleName` varchar(20), -- name of the overlaying rule used, found from syspref 'BatchOverlayRules'
      `diff` longtext NOT NULL, -- serialized diff of the given records. Only access it through the internal API.
      PRIMARY KEY `bod_id` (`id`),
      CONSTRAINT `bod_borsid_1` FOREIGN KEY (`batch_overlay_reports_id`) REFERENCES `batch_overlay_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT `bod_bn_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

    $dbh->do("
    CREATE TABLE `batch_overlay_diff_header` ( -- Stores headers of the records participating in the overlaying
      `id` int(11) NOT NULL auto_increment,
      `batch_overlay_diff_id` int(11) NOT NULL,
      `biblionumber` int(11), -- biblionumber of this header record, if available
      `breedingid` int(11), -- breeding id of the incoming remote record
      `title` text, -- title of the record
      `stdid` text, -- standard identifier of the record. One of the standard number, or 'title+author' of none present
      PRIMARY KEY (`id`),
      CONSTRAINT `bodh_bodid_1` FOREIGN KEY (`batch_overlay_diff_id`) REFERENCES `batch_overlay_diff` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
      CONSTRAINT `bodh_bn_1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
      CONSTRAINT `bodh_brid_1` FOREIGN KEY (`breedingid`) REFERENCES `import_records` (`import_record_id`) ON DELETE SET NULL ON UPDATE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;"
    );

    ##Create an example mergeMatcher to show available automerging operations
    my $matchers = t::lib::TestObjects::MatcherFactory->createTestGroup([
                    {
                        code => 'MRGE_XMPLE',
                        description => 'I merge records before MARC modification templates',
                        threshold => 1000,
                        matchpoints => [
                           {
                              index       => '',
                              score       => 0,
                              components => [{
                                   tag         => '020',
                                   subfields   => '',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => ['preserve'],
                              }]
                           },
                        ],
                        required_checks => [{
                                source => [{
                                    tag         => '049',
                                    subfields   => 'c',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['copy'],
                                }],
                                target => [{
                                    tag         => '521',
                                    subfields   => 'a',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['paste'],
                                }],
                            },
                            {
                                source => [{
                                    tag         => '020',
                                    subfields   => 'a',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['move'],
                                }],
                                target => [{
                                    tag         => '024',
                                    subfields   => 'a',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['paste'],
                                }],
                            }
                        ],
                    },
                ], undef, undef);

    Koha::Auth::PermissionManager->addPermission( Koha::Auth::Permission->new({
        module => 'editcatalogue',
        code => 'add_catalogue',
        description => 'Allow adding a new bibliographic record from the REST API.'
    }) );

    $dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('RemoteAPIs','','Define RemoteAPIs YAML','70|10','Textarea')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-671 - TäTi)\n";
}
