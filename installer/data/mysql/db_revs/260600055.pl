use Modern::Perl;

return {
    bug_number  => "44011",
    description => "Add record source to MARC modification templates",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'marc_modification_templates', 'record_source_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE marc_modification_templates
                    ADD COLUMN `record_source_id` int(11) DEFAULT NULL COMMENT 'record source to set on bibliographic records modified with this template'
                    AFTER name,
                    ADD KEY `marc_modification_templates_ibfk_1` (`record_source_id`),
                    ADD CONSTRAINT `marc_modification_templates_ibfk_1` FOREIGN KEY (`record_source_id`) REFERENCES `record_sources` (`record_source_id`) ON DELETE SET NULL ON UPDATE CASCADE
                    }
            );

            say $out "Added column 'marc_modification_templates.record_source_id'";
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value)
            VALUES ('MarcModificationTemplatesLog', '0')
        }
        );

        say $out "Added new system preference 'MarcModificationTemplatesLog'";
    },
};
