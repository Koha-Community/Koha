use Modern::Perl;

return {
    bug_number => 29894,
    description => "Add 2FA (de)registering notices",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do( q{
INSERT IGNORE INTO letter
(module, code, branchcode, name, is_html, title, content, message_transport_type, lang) VALUES
('members', '2FA_DEREGISTER', '', 'Confirmation of deregistering two factor authentication', 1, 'Confirmation of deregistering two factor authentication', '<p>Dear [% borrower.firstname %] [% borrower.surname %],</p>\r\n<p>This is to confirm that we deregistered two factor authentication for you.</p>\r\n<p>If you did not deregister, someone else may be using your account. Please contact technical support.</p>\r\n<p>Your library</p>', 'email', 'default'),
('members', '2FA_REGISTER', '', 'Confirmation of registering two factor authentication', 1, 'Confirmation of registering two factor authentication', '<p>Dear [% borrower.firstname %] [% borrower.surname %],</p>\r\n<p>This is to confirm that we registered two factor authentication for you.</p>\r\n<p>If you did not register, someone else may be using your account. Please contact technical support.</p>\r\n<p>Your library</p>', 'email', 'default')
        });
    },
};
