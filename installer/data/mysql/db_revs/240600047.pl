use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35659",
    description => "OAI-PMH harvester",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !TableExists('oai_servers') ) {
            $dbh->do(
                q{
                CREATE TABLE IF NOT EXISTS `oai_servers` (
                `oai_server_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
                `endpoint` varchar(255) NOT NULL COMMENT 'OAI endpoint (host + port + path)',
                `oai_set` varchar(255) DEFAULT NULL COMMENT 'OAI set to harvest',
                `servername` longtext NOT NULL COMMENT 'name given to the target by the library',
                `dataformat` enum('oai_dc','marc-xml', 'marcxml') NOT NULL DEFAULT 'oai_dc' COMMENT 'data format',
                `recordtype` enum('authority','biblio') NOT NULL DEFAULT 'biblio' COMMENT 'server contains bibliographic or authority records',
                `add_xslt` longtext DEFAULT NULL COMMENT 'zero or more paths to XSLT files to be processed on the search results',
                PRIMARY KEY (`oai_server_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say_success( $out, "Added new table 'oai_servers'" );
        }

        if ( !TableExists('import_oai_biblios') ) {
            $dbh->do(
                q{
                CREATE TABLE `import_oai_biblios` (
                `import_oai_biblio_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
                `biblionumber` int(11) NOT NULL COMMENT 'unique identifier assigned to each koha record',
                `identifier` varchar(255) NOT NULL COMMENT 'OAI record identifier',
                `repository` varchar(255) NOT NULL COMMENT 'OAI repository',
                `recordtype` enum('authority','biblio') NOT NULL DEFAULT 'biblio' COMMENT 'is the record bibliographic or authority',
                `datestamp` varchar(255) DEFAULT NULL COMMENT 'OAI set to harvest',
                `last_modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`import_oai_biblio_id`),
                KEY biblionumber (biblionumber),
                CONSTRAINT FK_import_oai_biblios_1 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE NO ACTION
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say_success( $out, "Added new table 'import_oai_biblios'" );
        }

        if ( !TableExists('import_oai_authorities') ) {
            $dbh->do(
                q{
                CREATE TABLE `import_oai_authorities` (
                `import_oai_authority_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier assigned by Koha',
                `authid` bigint(20) unsigned NOT NULL COMMENT 'unique identifier assigned to each koha record',
                `identifier` varchar(255) NOT NULL COMMENT 'OAI record identifier',
                `repository` varchar(255) NOT NULL COMMENT 'OAI repository',
                `recordtype` enum('authority','biblio') NOT NULL DEFAULT 'biblio' COMMENT 'is the record bibliographic or authority',
                `datestamp` varchar(255) DEFAULT NULL COMMENT 'OAI set to harvest',
                `last_modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`import_oai_authority_id`),
                KEY authid (authid),
                CONSTRAINT FK_import_oai_authorities_1 FOREIGN KEY (authid) REFERENCES auth_header (authid) ON DELETE CASCADE ON UPDATE NO ACTION
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say_success( $out, "Added new table 'import_oai_authorities'" );
        }

        $dbh->do(
            q{
            UPDATE `permissions` SET description='Manage Z39.50 and SRU servers, OAI repositories configuration' WHERE code='manage_search_targets';
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
            ('OAI-PMH:HarvestEmailReport','','','After an OAI-PMH harvest, send a report email to the email address','Free');
        }
        );
        say_success( $out, "Added new system preference 'OAI-PMH:HarvestEmailReport'" );

        $dbh->do(
            q{
            INSERT IGNORE INTO letter
            (module, code, branchcode, name, is_html, title, content, message_transport_type, lang)
            VALUES ('catalogue','OAI_HARVEST_REPORT','','OAI harvest report',0,'OAI harvest report for [% servername %]','OAI harvest report for [% servername %]:\n\nEndpoint: [% endpoint %]\nSet: [% set %]\nData format: [% dataformat %]\nRecord type: [% recordtype %]\n\n[% added %] records added\n[% updated %] records updated\n[% deleted %] records deleted\n[% skipped %] records skipped\n[% in_error %] records in error\n[% total %] total','email','default');
        }
        );
        say_success( $out, "Added OAI_HARVEST_REPORT letter" );

    },
};
