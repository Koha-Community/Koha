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
            <li><<borrower_modifications.firstname>> <<borrower_modifications.surname>></li>
            <li>Physical address: <<borrower_modifications.streetnumber>> <<borrower_modifications.streettype>> <<borrower_modifications.address>> <<borrower_modifications.address2>>, <<borrower_modifications.city>>, <<borrower_modifications.state>> <<borrower_modifications.zipcode>>, <<borrower_modifications.country>></li>
            <li>Email: <<borrower_modifications.email>></li>
            <li>Phone: <<borrower_modifications.phone>></li>
            <li>Mobile: <<borrower_modifications.mobile>></li>
            <li>Fax: <<borrower_modifications.fax>></li>
            <li>Secondary email: <<borrower_modifications.emailpro>></li>
            <li>Secondary phone:<<borrower_modifications.phonepro>></li>
            <li>Home library: <<borrower_modifications.branchcode>></li>
            <li>Temporary patron category: <<borrower_modifications.categorycode>></li>
            </ul>
            </p>', 'email', 'default') });
    },
};
