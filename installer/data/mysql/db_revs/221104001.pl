use Modern::Perl;

return {
    bug_number => "32437",
    description => "Add primary key to import_auths tables",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if( !primary_key_exists('import_auths') ){
            $dbh->do(q{ALTER TABLE import_auths ADD PRIMARY KEY (import_record_id);});
            say $out "Added PRIMARY KEY ON import_record_id to import_authd table";
        } elsif( !primary_key_exists('import_auths','import_record_id') ){
            say $out "Found an existing PRIMARY KEY on import_auths table";
            say $out "You must delete this key and replace it with a key on import_record_id";
            say $out "    ALTER TABLE import_auths DROP PRIMARY KEY;";
            say $out "    ALTER TABLE import_auths ADD PRIMARY KEY (import_record_id);";
            die "Interrupting installer process: database revision for bug 32437 fails!";
        } else {
            say $out "PRIMARY KEY import_record_id on import_auths already exists";
        }
    },
};
