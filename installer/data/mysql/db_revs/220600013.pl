use Modern::Perl;

return {
    bug_number  => "24865",
    description => "Customize the Accountlines Description",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO letter
            (module,code,branchcode,name,is_html,title,content,message_transport_type,lang)
            VALUES ('circulation','OVERDUE_FINE_DESC','','Overdue item fine description',0,'Overdue item fine description','[% item.biblio.title %] [% checkout.date_due | $KohaDates %]','print','default')
        }
        );

        say $out "Added new letter 'OVERDUE_FINE_DESC' (print)";
    },
};
