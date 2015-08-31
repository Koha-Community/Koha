package C4::Search::History;

use Modern::Perl;

use C4::Auth qw( get_session );
use C4::Context;
use Koha::DateUtils;

use JSON qw( encode_json decode_json );
use URI::Escape;
use Encode;

sub add {
    my ($params)   = @_;
    my $userid     = $params->{userid};
    my $sessionid  = $params->{sessionid};
    my $query_desc = $params->{query_desc};
    my $query_cgi  = $params->{query_cgi};
    my $total      = $params->{total} // 0;
    my $type       = $params->{type} || 'biblio';
    my $time       = $params->{time};

    my $dbh = C4::Context->dbh;

    # Add the request the user just made
    my $query = q{
        INSERT INTO search_history(
            userid, sessionid, query_desc, query_cgi, type, total, time
        ) VALUES(
            ?, ?, ?, ?, ?, ?, ?
        )
    };
    my $sth = $dbh->prepare($query);
    $sth->execute( $userid, $sessionid, $query_desc, $query_cgi, $type,
        $total, $time );
}

sub add_to_session {
    my ($params) = @_;
    my $cgi = $params->{cgi};
    my $query_desc = $params->{query_desc} || "unknown";
    my $query_cgi  = $params->{query_cgi} || "unknown";
    my $total      = $params->{total};
    my $type       = $params->{type}                              || 'biblio';

    # To a cookie (the user is not logged in)
    my $now = dt_from_string;
    my $id = $now->year . $now->month . $now->day . $now->hour . $now->minute . $now->second . int(rand(100));
    my @recent_searches = get_from_session( { cgi => $cgi } );
    push @recent_searches, {
        query_desc => $query_desc,
        query_cgi  => $query_cgi,
        total      => "$total",
        type       => $type,
        time       => output_pref( { dt => $now, dateformat => 'iso', timeformat => '24hr' } ),
        id         => $id,
    };

    shift @recent_searches if ( @recent_searches > 15 );
    set_to_session( { cgi => $cgi, search_history => \@recent_searches } );
}

sub delete {
    my ($params)  = @_;
    my $id        = $params->{id};
    my $userid    = $params->{userid};
    my $sessionid = $params->{sessionid};
    my $type      = $params->{type}     || q{};
    my $previous  = $params->{previous} || 0;
    my $interval  = $params->{interval} || 0;

    unless ( ref( $id ) ) {
        $id = $id ? [ $id ] : [];
    }

    unless ( $userid or @$id or $interval ) {
        warn "ERROR: userid, id or interval is required for history deletion";
        return;
    }

    my $dbh   = C4::Context->dbh;
    my $query = q{
        DELETE FROM search_history
        WHERE 1
    };

    $query .= q{ AND id IN ( } . join( q{,}, (q{?}) x @$id ) . q{ )}
        if @$id;

    $query .= q{
        AND userid = ?
    } if $userid;

    if ($sessionid) {
        $query .=
          $previous
          ? q{ AND sessionid != ?}
          : q{ AND sessionid = ?};
    }

    $query .= q{ AND type = ?}
      if $type;

    # FIXME DATE_SUB is a Mysql-ism. Postgres uses: datefield - INTERVAL '6 months'
    $query .= q{ AND time < DATE_SUB( NOW(), INTERVAL ? DAY )}
        if $interval;

    $dbh->do(
        $query, {},
        ( @$id ? ( @$id ) : () ),
        ( $userid ? $userid : () ),
        ( $sessionid ? $sessionid : () ),
        ( $type      ? $type      : () ),
        ( $interval  ? $interval  : () ),
    );
}

sub delete_from_cookie {
    my ($params) = @_;
    my $cookie   = $params->{cookie};
    my $id       = $params->{id};

    return unless $cookie;

    unless ( ref( $id ) ) {
        $id = $id ? [ $id ] : [];
    }
    return unless @$id;

    my @searches;
    if ( $cookie ){
        $cookie = uri_unescape( $cookie );
        if (decode_json( $cookie )) {
            @searches = @{decode_json( $cookie )}
        }
    }

    @searches = map {
        my $search = $_;
        ( grep { $_ != $search->{id} } @$id ) ? $search : ()
    } @searches;

    return uri_escape( encode_json( \@searches ) );

}

sub get {
    my ($params)  = @_;
    my $id        = $params->{id};
    my $userid    = $params->{userid};
    my $sessionid = $params->{sessionid};
    my $type      = $params->{type};
    my $previous  = $params->{previous};

    unless ( ref( $id ) ) {
        $id = $id ? [ $id ] : [];
    }

    unless ( $userid or @$id ) {
        warn "ERROR: userid is required for history search";
        return;
    }

    my $query = q{
        SELECT *
        FROM search_history
        WHERE 1
    };

    $query .= q{ AND id IN ( } . join( q{,}, (q{?}) x @$id ) . q{ )}
        if @$id;

    $query .= q{
        AND userid = ?
    } if $userid;

    if ($sessionid) {
        $query .=
          $previous
          ? q{ AND sessionid != ?}
          : q{ AND sessionid = ?};
    }

    $query .= q{ AND type = ?}
      if $type;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        ( @$id ? ( @$id ) : () ),
        ( $userid ? $userid : () ),
        ( $sessionid ? $sessionid : () ),
        ( $type      ? $type      : () )
    );
    return $sth->fetchall_arrayref( {} );
}

sub get_from_session {
    my ($params)  = @_;
    my $cgi       = $params->{cgi};
    my $sessionID = $cgi->cookie('CGISESSID');
    return () unless $sessionID;
    my $session = C4::Auth::get_session($sessionID);
    return () unless $session and $session->param('search_history');
    my $obj =
      eval { decode_json( uri_unescape( $session->param('search_history') ) ) };
    return () unless defined $obj;
    return () unless ref $obj eq 'ARRAY';
    return @{$obj};
}

sub set_to_session {
    my ($params)       = @_;
    my $cgi            = $params->{cgi};
    my $search_history = $params->{search_history};
    my $sessionID      = $cgi->cookie('CGISESSID');
    return () unless $sessionID;
    my $session = C4::Auth::get_session($sessionID);
    return () unless $session;
    $session->param( 'search_history',
        uri_escape( encode_json($search_history) ) );
}

1;

__END__

=pod

=head1 NAME

C4::Search::History - Manage search history

=head1 DESCRIPTION

This module provides some routines for the search history management.
It deals with session or database.

=head1 ROUTINES

=head2 add

    C4::Search::History::add({
        userid => $userid,
        sessionid => $cgi->cookie("CGIESSID"),
        query_desc => $query_desc,
        query_cgi => $query_cgi,
        total => $total,
        type => $type,
    });

type is "biblio" or "authority".

Add a new search to the user's history.

=head2 add_to_session

    my $value = C4::Search::History::add_to_session({
        cgi => $cgi,
        query_desc => $query_desc,
        query_cgi => $query_cgi,
        total => $total,
        type => $type,
    });

Add a search to the session. The number of searches to keep is hardcoded to 15.

=head2 delete

    C4::Search::History::delete({
        userid => $loggedinuser,
        sessionid => $sessionid,
        type => $type,
        previous => $previous
    });

Delete searches in the database.
If the sessionid is missing all searches for all sessions will be deleted.
It is possible to delete searches for current session or all previous sessions using the previous flag.
If the type ("biblio" or "authority") is missing, all type will be deleted.
To delete *all* searches for a given userid, just pass a userid.

=head2 get

    my $searches C4::Search::History::get({
        userid => $userid,
        sessionsid => $sessionid,
        type => $type,
        previous => $previous
    });

Return a list of searches for a given userid.
If a sessionid is given, searches are limited to the matching session.
type and previous follow the same behavior as the delete routine.

=head2 get_from_session

    my $searches = C4::Search::History::get_from_session({
        cgi => $cgi
    });

Return all searches present for the given session.

=head2 set_to_session

    C4::Search::History::set_to_session({
        cgi => $cgi,
        search_history => $search_history
    });

Store searches into the session.

=head1 AUTHORS

Jonathan Druart <jonathan.druart@biblibre.com>

=head1 LICENSE

This file is part of Koha.

Copyright 2013 BibLibre SARL

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.
