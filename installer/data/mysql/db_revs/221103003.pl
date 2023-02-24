use Modern::Perl;

return {
    bug_number => "32967",
    description => "Recalls notices are using the wrong database columns",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{ UPDATE letter SET content=REPLACE(content,'recalls.branchcode','recalls.pickup_library_id') WHERE code='PICKUP_RECALLED_ITEM' });
        $dbh->do(q{ UPDATE letter SET content=REPLACE(content,'recalls.expirationdate','recalls.expiration_date') WHERE code='PICKUP_RECALLED_ITEM' });

        say $out "Fix column names in PICKUP_RECALLED_ITEM notice";

        $dbh->do(q{ UPDATE letter SET content=REPLACE(content,'recalls.waitingdate','recalls.waiting_date') WHERE code='RECALL_REQUESTER_DET' });
        $dbh->do(q{ UPDATE letter SET content=REPLACE(content,'recalls.recallnotes','recalls.notes') WHERE code='RECALL_REQUESTER_DET' });

        say $out "Fix column names in RECALL_REQUESTER_DET notice";
    },
};
