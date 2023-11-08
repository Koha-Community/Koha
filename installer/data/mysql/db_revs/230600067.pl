use Modern::Perl;

return {
    bug_number  => "17617",
    description => "Notify patron when their hold has been placed",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('EmailPatronWhenHoldIsPlaced', '0', NULL, 'Email patron when a hold has been placed for them', 'YesNo') }
        );

        say $out "Added new system preference 'EmailPatronWhenHoldIsPlaced'";

        $dbh->do(
            q{INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, message_transport_type, lang, content) VALUES ("reserves", "HOLDPLACED_PATRON", "", "Hold is confirmed", 0, "Your hold on [% hold.biblio.title %] is confirmed", "email", "default", "Hello [% borrower.firstname %] [% borrower.surname %] ([% borrower.cardnumber %]),
Your hold on [% hold.biblio.title %] ([% hold.biblio.id %]) has been confirmed.
You will be notified by the library when your item is available for pickup.
Thank you!")}
        );

        say $out "Added new letter 'HOLDPLACED_PATRON' (email)";
    },
};
