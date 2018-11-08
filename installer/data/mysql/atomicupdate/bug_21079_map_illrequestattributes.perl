$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    # All attributes we're potentially interested in
    my $ff_req = $dbh->selectall_arrayref(
        'SELECT a.illrequest_id, a.type, a.value '.
        'FROM illrequests r, illrequestattributes a '.
        'WHERE r.illrequest_id = a.illrequest_id '.
        'AND r.backend = "FreeForm"',
        { Slice => {} }
    );

    # Before we go any further, identify whether we've done
    # this before, we test for the presence of "container_title"
    # We stop as soon as we find one
    foreach my $req(@{$ff_req}) {
        if ($req->{type} eq 'container_title') {
            warn "Upgrade already carried out";
        }
    }

    # Transform into a hashref with the key of the request ID
    my $requests = {};
    foreach my $request(@{$ff_req}) {
        my $id = $request->{illrequest_id};
        if (!exists $requests->{$id}) {
            $requests->{$id} = {};
        }
        $requests->{$id}->{$request->{type}} = $request->{value};
    }

    # Transform any article requests
    my $transformed = {};
    foreach my $id(keys %{$requests}) {
        if (lc($requests->{$id}->{type}) eq 'article') {
            $transformed->{$id} = $requests->{$id};
            $transformed->{$id}->{type} = 'article';
            $transformed->{$id}->{container_title} = $transformed->{$id}->{title}
                if defined $transformed->{$id}->{title} &&
                    length $transformed->{$id}->{title} > 0;
            $transformed->{$id}->{title} = $transformed->{$id}->{article_title}
                if defined $transformed->{$id}->{article_title} &&
                    length $transformed->{$id}->{article_title} > 0;
            $transformed->{$id}->{author} = $transformed->{$id}->{article_author}
                if defined $transformed->{$id}->{article_author} &&
                    length $transformed->{$id}->{article_author} > 0;
            $transformed->{$id}->{pages} = $transformed->{$id}->{article_pages}
                if defined $transformed->{$id}->{article_pages} &&
                    length $transformed->{$id}->{article_pages} > 0;
        }
    }

    # Now write back the transformed data
    # Rather than selectively replace, we just remove all attributes we've
    # transformed and re-write them
    my @changed = keys %{$transformed};
    my $changed_str = join(',', @changed);

    if (scalar @changed > 0) {
        my ($raise_error) = $dbh->{RaiseError};
        $dbh->{AutoCommit} = 0;
        $dbh->{RaiseError} = 1;
        eval {
            my $del = $dbh->do(
                "DELETE FROM illrequestattributes ".
                "WHERE illrequest_id IN ($changed_str)"
            );
            foreach my $reqid(keys %{$transformed}) {
                my $attr = $transformed->{$reqid};
                foreach my $key(keys %{$attr}) {
                    my $sth = $dbh->prepare(
                        'INSERT INTO illrequestattributes '.
                        '(illrequest_id, type, value) '.
                        'VALUES '.
                        '(?, ?, ?)'
                    );
                    $sth->execute(
                        $reqid,
                        $key,
                        $attr->{$key}
                    );
                }
            }
            $dbh->commit;
        };

        if ($@) {
            warn "Upgrade to $DBversion failed: $@\n";
            eval { $dbh->rollback };
        } else {
            SetVersion( $DBversion );
            print "Upgrade to $DBversion done (Bug 21079 - Unify metadata schema across backends)\n";
        }

        $dbh->{AutoCommit} = 1;
        $dbh->{RaiseError} = $raise_error;
    }

}
