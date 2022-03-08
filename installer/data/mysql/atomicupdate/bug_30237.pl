use Modern::Perl;

return {
    bug_number => "30237",
    description => "Replace ACCDETAILS notice with WELCOME notice",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Add WELCOME notice
        $dbh->do( q{
            INSERT IGNORE INTO letter (module, code, name, is_html, title, content, message_transport_type) VALUES ('members', 'WELCOME', 'Welcome notice', 1, '[% USE Koha %]Welcome to [% Koha.Preference('LibraryName') %]', "[% USE Koha %]\r\nHello [% borrower.title %] [% borrower.firstname %] [% borrower.surname %].\r\n\r\nThankyou for joining [% Koha.Preference('LibraryName') %]\r\n\r\nThe library's catalog can be found <a href='[% Koha.Preference('OPACBaseURL') %]'>here</a>.\r\n\r\nYour library card number is [% borrower.cardnumber %]\r\n\r\nIf you have any problems or questions regarding your account, please contact your Koha Administrator.", 'email');});
    },
};
