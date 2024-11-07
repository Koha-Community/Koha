use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36757",
    description => "Notify assignee when a concern is assigned to them",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, message_transport_type, lang, content) VALUES ("catalogue", "TICKET_ASSIGNED", "", "Concern assigned notification", 1, "Catalog concern assigned", "email", "default", "[%- PROCESS 'html_helpers.inc' -%][%- USE Koha -%]Dear cataloger,<br>[%- INCLUDE 'patron-title.inc' patron => librarian -%] has assigned the following concern with <a href='[%- Koha.Preference('staffClientBaseURL') -%]/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% ticket.biblio.biblionumber %]' >[%- INCLUDE 'biblio-title.inc' biblio=ticket.biblio link = 0 -%]</a> to you<br><br>[%- ticket.body -%]<br><br>You can action this concern from the <a href='[%- Koha.Preference('staffClientBaseURL') -%]/cgi-bin/koha/cataloguing/concerns.pl'>concern management page</a>.")}
        );

        say_success( $out, "Added notice 'TICKET_ASSIGNED'" );
    },
};
