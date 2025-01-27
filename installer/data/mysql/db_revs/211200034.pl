use Modern::Perl;

return {
    bug_number  => "30237",
    description => "Replace ACCDETAILS notice with WELCOME notice",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add WELCOME notice
        $dbh->do(
            q{
            INSERT IGNORE INTO letter (module, code, name, is_html, title, content, message_transport_type) VALUES ('members', 'WELCOME', 'Welcome notice', 1, "[% USE Koha %]Welcome to [% IF Koha.Preference('LibraryName') %][% Koha.Preference('LibraryName') %][% ELSE %]the library[% END %]", "[% USE Koha %]\r\nHello [% borrower.title %] [% borrower.firstname %] [% borrower.surname %].\r\n\r\nThank you for joining [% IF Koha.Preference('LibraryName') %][% Koha.Preference('LibraryName') %][% ELSE %]the library[% END %]\r\n\r\nYou can search for all our materials in our <a href='[% Koha.Preference('OPACBaseURL') %]'>catalog</a>.\r\n\r\nYour library card number is [% borrower.cardnumber %]\r\n\r\nIf you have any problems or questions regarding your account, please contact the library.", 'email');
        }
        );

        # Update system preference
        $dbh->do(
            q{
            UPDATE systempreferences SET variable = 'AutoEmailNewUser', explanation = 'Send an email to newly created patrons.' WHERE variable = 'AutoEmailOpacUser'
        }
        );
    },
};
