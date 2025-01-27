use Modern::Perl;

return {
    bug_number  => "21978",
    description => "Add middle_name to borrowers table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        if ( !column_exists( 'borrowers', 'middle_name' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrowers
                ADD COLUMN middle_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's middle name"
                AFTER firstname
            }
            );
            say $out "Added column 'borrowers.middle_name'";
        }
        if ( !column_exists( 'deletedborrowers', 'middle_name' ) ) {
            $dbh->do(
                q{
                ALTER TABLE deletedborrowers
                ADD COLUMN middle_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's middle name"
                AFTER firstname
            }
            );
            say $out "Added column 'deletedborrowers.middle_name'";
        }
        if ( !column_exists( 'borrower_modifications', 'middle_name' ) ) {
            $dbh->do(
                q{
                ALTER TABLE borrower_modifications
                ADD COLUMN middle_name longtext NULL DEFAULT NULL
                COMMENT "patron/borrower's middle name"
                AFTER firstname
            }
            );
            say $out "Added column 'borrower_modifications.middle_name'";
        }

        my ($default_patron_search_fields) = $dbh->selectrow_array(
            q{
            SELECT value FROM systempreferences WHERE variable='DefaultPatronSearchFields';
        }
        );
        my @default_patron_search_fields = split( ',', $default_patron_search_fields );
        unless ( grep /middle_name/, @default_patron_search_fields ) {
            if ( $default_patron_search_fields eq 'firstname,surname,othernames,cardnumber,userid' ) {
                $dbh->do(
                    q{
                    UPDATE systempreferences SET value=? WHERE variable='DefaultPatronSearchFields'
                }, undef, 'firstname,middle_name,surname,othernames,cardnumber,userid'
                );
                say $out "Added middle name to DefaultPatronSearchFields";
            } elsif ( grep /firstname/, @default_patron_search_fields ) {
                push @default_patron_search_fields, 'middle_name';
                my $new_patron_search_fields = join( ',', @default_patron_search_fields );
                $dbh->do(
                    q{
                    UPDATE systempreferences SET value=? WHERE variable='DefaultPatronSearchFields'
                }, undef, $new_patron_search_fields
                );
                say $out "Added middle name to DefaultPatronSearchFields";
            } else {
                say $out "Please add 'middlename' to DefaultPatronSearchFields if you want it searched by default";
            }
        }
    },
    }
