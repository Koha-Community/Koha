use Modern::Perl;

return {
    bug_number  => "23538",
    description =>
        "Add new system preferences EmailPatronRegistrations and EmailAddressForPatronRegistrations and new OPAC_REG letter",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('EmailPatronRegistrations', '0', '0|EmailAddressForPatronRegistrations|BranchEmailAddress|KohaAdminEmailAddress', 'Choose email address that new patron registrations will be sent to: ', 'Choice'), ('EmailAddressForPatronRegistrations', '', '', ' If you choose EmailAddressForPatronRegistrations you have to enter a valid email address: ', 'free') }
        );
        say $out "Added new system preference 'EmailPatronRegistrations'";

        $dbh->do(
            q{INSERT IGNORE INTO letter (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES ( 'members', 'OPAC_REG', '', 'New OPAC self-registration submitted', 1, 'New OPAC self-registration',
            '<h3>New OPAC self-registration</h3>
            <p><h4>Self-registration made:</h4>
            <ul>
            <li>[% borrower.firstname %] [% borrower.surname %]</li>
            [% IF borrower.cardnumber %]<li>Cardnumber: [% borrower.cardnumber %]</li>[% END %]
            [% IF borrower.email %]<li>Email: [% borrower.email %]</li>[% END %]
            [% IF borrower.phone %]<li>Phone: [% borrower.phone %]</li>[% END %]
            [% IF borrower.mobile %]<li>Mobile: [% borrower.mobile %]</li>[% END %]
            [% IF borrower.fax %]<li>Fax: [% borrower.fax %]</li>[% END %]
            [% IF borrower.emailpro %]<li>Secondary email: [% borrower.emailpro %]</li>[% END %]
            [% IF borrower.phonepro %]<li>Secondary phone:[% borrower.phonepro %]</li>[% END %]
            [% IF borrower.branchcode %]<li>Home library: [% borrower.branchcode %]</li>[% END %]
            [% IF borrower.categorycode %]<li>Patron category: [% borrower.categorycode %]</li>[% END %]
            </ul>
            </p>', 'email', 'default') }
        );

        say $out "Added new letter 'OPAC_REG' (email)";
    },
};
