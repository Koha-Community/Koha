use Modern::Perl;

return {
    bug_number  => "24010",
    description => "Make subscription.staffdisplaycount and opacdisplaycount integer columns",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE subscription
            SET staffdisplaycount = NULL
            WHERE staffdisplaycount = ""
        }
        );
        $dbh->do(
            q{
            ALTER TABLE subscription
            MODIFY COLUMN staffdisplaycount INT(11) NULL DEFAULT NULL
            COMMENT 'how many issues to show to the staff'
        }
        );

        $dbh->do(
            q{
            UPDATE subscription
            SET opacdisplaycount = NULL
            WHERE opacdisplaycount = ""
        }
        );
        $dbh->do(
            q{
            ALTER TABLE subscription
            MODIFY COLUMN opacdisplaycount INT(11) NULL DEFAULT NULL
            COMMENT 'how many issues to show to the public'
        }
        );
    },
};
