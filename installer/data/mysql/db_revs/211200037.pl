use Modern::Perl;

return {
    bug_number  => "27253",
    description => "Fix definition of borrowers.updated_on and deletedborrowers.updated_on",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $rv = $dbh->do(
            q{
            UPDATE borrowers
            SET updated_on = GREATEST(
                COALESCE(date_renewed, FROM_UNIXTIME(1)),
                COALESCE(dateenrolled, FROM_UNIXTIME(1)),
                COALESCE(lastseen, FROM_UNIXTIME(1))
            )
            WHERE updated_on IS NULL
        }
        );
        say $out sprintf(
            'Updated all NULL values of borrowers.updated_on to GREATEST(date_renewed, dateenrolled, lastseen): %d rows updated',
            $rv
        );

        $rv = $dbh->do(
            q{
            UPDATE deletedborrowers
            SET updated_on = GREATEST(
                COALESCE(date_renewed, FROM_UNIXTIME(1)),
                COALESCE(dateenrolled, FROM_UNIXTIME(1)),
                COALESCE(lastseen, FROM_UNIXTIME(1))
            )
            WHERE updated_on IS NULL
        }
        );
        say $out sprintf(
            'Updated all NULL values of borrowers.updated_on to GREATEST(date_renewed, dateenrolled, lastseen): %d rows updated',
            $rv
        );

        $dbh->do(
            q{
            ALTER TABLE borrowers
            MODIFY updated_on timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
            COMMENT 'time of last change could be useful for synchronization with external systems (among others)'
        }
        );
        say $out 'Fixed definition of borrowers.updated_on';

        $dbh->do(
            q{
            ALTER TABLE deletedborrowers
            MODIFY updated_on timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
            COMMENT 'time of last change could be useful for synchronization with external systems (among others)'
        }
        );
        say $out 'Fixed definition of deletedborrowers.updated_on';
    },
};
