use Modern::Perl;

return {
    bug_number  => 29894,
    description => "Add 2FA (de)enabling notices",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
INSERT IGNORE INTO letter
(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES
('members', '2FA_DISABLE', '', 'Confirmation of disabling two factor authentication', 1, 'Confirmation of disabling two factor authentication', '<p>Dear [% borrower.firstname %] [% borrower.surname %],</p>\r\n<p>This is to confirm that someone disabled two factor authentication on your account.</p>\r\n<p>If you did not do this, someone else may be using your account. Please contact technical support.</p>\r\n<p>Your library</p>', 'email', 'default'),
('members', '2FA_ENABLE', '', 'Confirmation of enabling two factor authentication', 1, 'Confirmation of enabling two factor authentication', '<p>Dear [% borrower.firstname %] [% borrower.surname %],</p>\r\n<p>This is to confirm that someone enabled two factor authentication on your account.</p>\r\n<p>If you did not do this, someone else may be using your account. Please contact technical support.</p>\r\n<p>Your library</p>', 'email', 'default')
        }
        );
    },
};
