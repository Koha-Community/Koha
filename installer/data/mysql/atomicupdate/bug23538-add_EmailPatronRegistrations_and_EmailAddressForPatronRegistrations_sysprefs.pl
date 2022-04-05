use Modern::Perl;

return {
    bug_number => "23538",
    description => "Add new system preferences EmailPatronRegistrations and EmailAddressForPatronRegistrations and new OPAC_REG letter",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('EmailPatronRegistrations', '0', '0|EmailAddressForPatronRegistrations|BranchEmailAddress|KohaAdminEmailAddress', 'Choose email address that new patron registrations will be sent to: ', 'Choice'), ('EmailAddressForPatronRegistrations', '', '', ' If you choose EmailAddressForPatronRegistrations you have to enter a valid email address: ', 'free') });

        $dbh->do(q{INSERT IGNORE INTO letter (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES ( 'members', 'OPAC_REG', '', 'New OPAC self-registration submitted', 1, 'New OPAC self-registration',
            '<h3>New OPAC self-registration</h3>
            <p><h4>Self-registration made by</h4>
            <ul>
            <li><<borrowers.firstname>> <<borrowers.surname>></li>
            <li>Email: <<borrowers.email>></li>
            <li>Phone: <<borrowers.phone>></li>
            <li>Mobile: <<borrowers.mobile>></li>
            <li>Fax: <<borrowers.fax>></li>
            <li>Secondary email: <<borrowers.emailpro>></li>
            <li>Secondary phone:<<borrowers.phonepro>></li>
            <li>Home library: <<borrowers.branchcode>></li>
            <li>Patron category: <<borrowers.categorycode>></li>
            </ul>
            </p>', 'email', 'default') });
    },
};
