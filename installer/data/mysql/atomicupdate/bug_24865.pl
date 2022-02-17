use Modern::Perl;

return {
    bug_number => "24865",
    description => "Customize the Accountlines Description",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE INTO letter
            (module,code,branchcode,name,is_html,title,content,message_transport_type,lang)
            VALUES ('circulation','OVERDUE_FINE_DESC','','Overdue Item Fine Description',0,'Overdue Item Fine Description','[% item.biblio.title %] [% checkout.date_due | $KohaDates %]','print','default')
        });
    },
};
