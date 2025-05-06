use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39835",
    description => "Switch datatype to TINYINT(1) when boolean",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            ALTER TABLE `issues`
            MODIFY COLUMN `onsite_checkout` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'in house use flag',
            MODIFY COLUMN `noteseen` tinyint(1) DEFAULT NULL COMMENT 'describes whether checkout note has been seen 1, not been seen 0 or doesn''t exist null'
        }
        );

        $dbh->do(
            q{
            ALTER TABLE `old_issues`
            MODIFY COLUMN `onsite_checkout` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'in house use flag',
            MODIFY COLUMN `noteseen` tinyint(1) DEFAULT NULL COMMENT 'describes whether checkout note has been seen 1, not been seen 0 or doesn''t exist null'
        }
        );

        $dbh->do(
            q{
            ALTER TABLE `overduerules`
            MODIFY COLUMN `debarred1` tinyint(1) DEFAULT 0 COMMENT 'is the patron restricted when the first notice is sent (1 for yes, 0 for no)',
            MODIFY COLUMN `debarred2` tinyint(1) DEFAULT 0 COMMENT 'is the patron restricted when the second notice is sent (1 for yes, 0 for no)',
            MODIFY COLUMN `debarred3` tinyint(1) DEFAULT 0 COMMENT 'is the patron restricted when the third notice is sent (1 for yes, 0 for no)'
        }
        );

        $dbh->do(
            q{
            ALTER TABLE `columns_settings`
            MODIFY COLUMN `cannot_be_toggled` tinyint(1) NOT NULL DEFAULT 0,
            MODIFY COLUMN `is_hidden` tinyint(1) NOT NULL DEFAULT 0
            }
        );

        say_success(
            $out,
            "Updated 'issues.onsite_checkout', 'issues.noteseen', 'old_issues.onsite_checkout', 'old_issues.noteseen', 'overduerules.debarred1', 'overduerules.debarred2', 'overduerules.debarred3', 'columns_settings.cannot_be_toggled', and 'columns_settings.is_hidden'"
        );

    },
};
