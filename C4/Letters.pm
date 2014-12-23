package C4::Letters;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use MIME::Lite;
use Mail::Sendmail;

use C4::Koha qw(GetAuthorisedValueByCode);
use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use C4::Branch;
use C4::Log;
use C4::SMS;
use C4::Debug;
use Koha::DateUtils;
use Date::Calc qw( Add_Delta_Days );
use Encode;
use Carp;
use Koha::Email;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    require Exporter;
    # set the version for version checking
    $VERSION = 3.07.00.049;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &GetLetters &GetLettersAvailableForALibrary &GetLetterTemplates &DelLetter &GetPreparedLetter &GetWrappedLetter &addalert &getalert &delalert &findrelatedto &SendAlerts &GetPrintMessages &GetMessageTransportTypes
    );
}

=head1 NAME

C4::Letters - Give functions for Letters management

=head1 SYNOPSIS

  use C4::Letters;

=head1 DESCRIPTION

  "Letters" is the tool used in Koha to manage informations sent to the patrons and/or the library. This include some cron jobs like
  late issues, as well as other tasks like sending a mail to users that have subscribed to a "serial issue alert" (= being warned every time a new issue has arrived at the library)

  Letters are managed through "alerts" sent by Koha on some events. All "alert" related functions are in this module too.

=head2 GetLetters([$module])

  $letters = &GetLetters($module);
  returns informations about letters.
  if needed, $module filters for letters given module

=cut

sub GetLetters {
    my ($filters) = @_;
    my $module    = $filters->{module};
    my $code      = $filters->{code};
    my $branchcode = $filters->{branchcode};
    my $dbh       = C4::Context->dbh;
    my $letters   = $dbh->selectall_arrayref(
        q|
            SELECT module, code, branchcode, name
            FROM letter
            WHERE 1
        |
          . ( $module ? q| AND module = ?| : q|| )
          . ( $code   ? q| AND code = ?|   : q|| )
          . ( defined $branchcode   ? q| AND branchcode = ?|   : q|| )
          . q| GROUP BY code ORDER BY name|, { Slice => {} }
        , ( $module ? $module : () )
        , ( $code ? $code : () )
        , ( defined $branchcode ? $branchcode : () )
    );

    return $letters;
}

=head2 GetLetterTemplates

    my $letter_templates = GetLetterTemplates(
        {
            module => 'circulation',
            code => 'my code',
            branchcode => 'CPL', # '' for default,
        }
    );

    Return a hashref of letter templates.
    The key will be the message transport type.

=cut

sub GetLetterTemplates {
    my ( $params ) = @_;

    my $module    = $params->{module};
    my $code      = $params->{code};
    my $branchcode = $params->{branchcode} // '';
    my $dbh       = C4::Context->dbh;
    my $letters   = $dbh->selectall_hashref(
        q|
            SELECT module, code, branchcode, name, is_html, title, content, message_transport_type
            FROM letter
            WHERE module = ?
            AND code = ?
            and branchcode = ?
        |
        , 'message_transport_type'
        , undef
        , $module, $code, $branchcode
    );

    return $letters;
}

=head2 GetLettersAvailableForALibrary

    my $letters = GetLettersAvailableForALibrary(
        {
            branchcode => 'CPL', # '' for default
            module => 'circulation',
        }
    );

    Return an arrayref of letters, sorted by name.
    If a specific letter exist for the given branchcode, it will be retrieve.
    Otherwise the default letter will be.

=cut

sub GetLettersAvailableForALibrary {
    my ($filters)  = @_;
    my $branchcode = $filters->{branchcode};
    my $module     = $filters->{module};

    croak "module should be provided" unless $module;

    my $dbh             = C4::Context->dbh;
    my $default_letters = $dbh->selectall_arrayref(
        q|
            SELECT module, code, branchcode, name
            FROM letter
            WHERE 1
        |
          . q| AND branchcode = ''|
          . ( $module ? q| AND module = ?| : q|| )
          . q| ORDER BY name|, { Slice => {} }
        , ( $module ? $module : () )
    );

    my $specific_letters;
    if ($branchcode) {
        $specific_letters = $dbh->selectall_arrayref(
            q|
                SELECT module, code, branchcode, name
                FROM letter
                WHERE 1
            |
              . q| AND branchcode = ?|
              . ( $module ? q| AND module = ?| : q|| )
              . q| ORDER BY name|, { Slice => {} }
            , $branchcode
            , ( $module ? $module : () )
        );
    }

    my %letters;
    for my $l (@$default_letters) {
        $letters{ $l->{code} } = $l;
    }
    for my $l (@$specific_letters) {
        # Overwrite the default letter with the specific one.
        $letters{ $l->{code} } = $l;
    }

    return [ map { $letters{$_} }
          sort { $letters{$a}->{name} cmp $letters{$b}->{name} }
          keys %letters ];

}

# FIXME: using our here means that a Plack server will need to be
#        restarted fairly regularly when working with this routine.
#        A better option would be to use Koha::Cache and use a cache
#        that actually works in a persistent environment, but as a
#        short-term fix, our will work.
our %letter;
sub getletter {
    my ( $module, $code, $branchcode, $message_transport_type ) = @_;
    $message_transport_type ||= 'email';


    if ( C4::Context->preference('IndependentBranches')
            and $branchcode
            and C4::Context->userenv ) {

        $branchcode = C4::Context->userenv->{'branch'};
    }
    $branchcode //= '';

    if ( my $l = $letter{$module}{$code}{$branchcode}{$message_transport_type} ) {
        return { %$l }; # deep copy
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(q{
        SELECT *
        FROM letter
        WHERE module=? AND code=? AND (branchcode = ? OR branchcode = '') AND message_transport_type = ?
        ORDER BY branchcode DESC LIMIT 1
    });
    $sth->execute( $module, $code, $branchcode, $message_transport_type );
    my $line = $sth->fetchrow_hashref
      or return;
    $line->{'content-type'} = 'text/html; charset="UTF-8"' if $line->{is_html};
    $letter{$module}{$code}{$branchcode}{$message_transport_type} = $line;
    return { %$line };
}

=head2 DelLetter

    DelLetter(
        {
            branchcode => 'CPL',
            module => 'circulation',
            code => 'my code',
            [ mtt => 'email', ]
        }
    );

    Delete the letter. The mtt parameter is facultative.
    If not given, all templates mathing the other parameters will be removed.

=cut

sub DelLetter {
    my ($params)   = @_;
    my $branchcode = $params->{branchcode};
    my $module     = $params->{module};
    my $code       = $params->{code};
    my $mtt        = $params->{mtt};
    my $dbh        = C4::Context->dbh;
    $dbh->do(q|
        DELETE FROM letter
        WHERE branchcode = ?
          AND module = ?
          AND code = ?
    | . ( $mtt ? q| AND message_transport_type = ?| : q|| )
    , undef, $branchcode, $module, $code, ( $mtt ? $mtt : () ) );
}

=head2 addalert ($borrowernumber, $type, $externalid)

    parameters : 
    - $borrowernumber : the number of the borrower subscribing to the alert
    - $type : the type of alert.
    - $externalid : the primary key of the object to put alert on. For issues, the alert is made on subscriptionid.
    
    create an alert and return the alertid (primary key)

=cut

sub addalert {
    my ( $borrowernumber, $type, $externalid ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
        "insert into alert (borrowernumber, type, externalid) values (?,?,?)");
    $sth->execute( $borrowernumber, $type, $externalid );

    # get the alert number newly created and return it
    my $alertid = $dbh->{'mysql_insertid'};
    return $alertid;
}

=head2 delalert ($alertid)

    parameters :
    - alertid : the alert id
    deletes the alert

=cut

sub delalert {
    my $alertid = shift or die "delalert() called without valid argument (alertid)";    # it's gonna die anyway.
    $debug and warn "delalert: deleting alertid $alertid";
    my $sth = C4::Context->dbh->prepare("delete from alert where alertid=?");
    $sth->execute($alertid);
}

=head2 getalert ([$borrowernumber], [$type], [$externalid])

    parameters :
    - $borrowernumber : the number of the borrower subscribing to the alert
    - $type : the type of alert.
    - $externalid : the primary key of the object to put alert on. For issues, the alert is made on subscriptionid.
    all parameters NON mandatory. If a parameter is omitted, the query is done without the corresponding parameter. For example, without $externalid, returns all alerts for a borrower on a topic.

=cut

sub getalert {
    my ( $borrowernumber, $type, $externalid ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT a.*, b.branchcode FROM alert a JOIN borrowers b USING(borrowernumber) WHERE";
    my @bind;
    if ($borrowernumber and $borrowernumber =~ /^\d+$/) {
        $query .= " borrowernumber=? AND ";
        push @bind, $borrowernumber;
    }
    if ($type) {
        $query .= " type=? AND ";
        push @bind, $type;
    }
    if ($externalid) {
        $query .= " externalid=? AND ";
        push @bind, $externalid;
    }
    $query =~ s/ AND $//;
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    return $sth->fetchall_arrayref({});
}

=head2 findrelatedto($type, $externalid)

    parameters :
    - $type : the type of alert
    - $externalid : the id of the "object" to query

    In the table alert, a "id" is stored in the externalid field. This "id" is related to another table, depending on the type of the alert.
    When type=issue, the id is related to a subscriptionid and this sub returns the name of the biblio.

=cut
    
# outmoded POD:
# When type=virtual, the id is related to a virtual shelf and this sub returns the name of the sub

sub findrelatedto {
    my $type       = shift or return;
    my $externalid = shift or return;
    my $q = ($type eq 'issue'   ) ?
"select title as result from subscription left join biblio on subscription.biblionumber=biblio.biblionumber where subscriptionid=?" :
            ($type eq 'borrower') ?
"select concat(firstname,' ',surname) from borrowers where borrowernumber=?" : undef;
    unless ($q) {
        warn "findrelatedto(): Illegal type '$type'";
        return;
    }
    my $sth = C4::Context->dbh->prepare($q);
    $sth->execute($externalid);
    my ($result) = $sth->fetchrow;
    return $result;
}

=head2 SendAlerts

    parameters :
    - $type : the type of alert
    - $externalid : the id of the "object" to query
    - $letter_code : the letter to send.

    send an alert to all borrowers having put an alert on a given subject.

=cut

sub SendAlerts {
    my ( $type, $externalid, $letter_code ) = @_;
    my $dbh = C4::Context->dbh;
    if ( $type eq 'issue' ) {

        # prepare the letter...
        # search the biblionumber
        my $sth =
          $dbh->prepare(
            "SELECT biblionumber FROM subscription WHERE subscriptionid=?");
        $sth->execute($externalid);
        my ($biblionumber) = $sth->fetchrow
          or warn( "No subscription for '$externalid'" ),
             return;

        my %letter;
        # find the list of borrowers to alert
        my $alerts = getalert( '', 'issue', $externalid );
        foreach (@$alerts) {
            my $borinfo = C4::Members::GetMember('borrowernumber' => $_->{'borrowernumber'});
            my $email = $borinfo->{email} or next;

#                    warn "sending issues...";
            my $userenv = C4::Context->userenv;
            my $branchdetails = GetBranchDetail($_->{'branchcode'});
            my $letter = GetPreparedLetter (
                module => 'serial',
                letter_code => $letter_code,
                branchcode => $userenv->{branch},
                tables => {
                    'branches'    => $_->{branchcode},
                    'biblio'      => $biblionumber,
                    'biblioitems' => $biblionumber,
                    'borrowers'   => $borinfo,
                },
                want_librarian => 1,
            ) or return;

            # ... then send mail
            my $message = Koha::Email->new();
            my %mail = $message->create_message_headers(
                {
                    to      => $email,
                    from    => $branchdetails->{'branchemail'},
                    replyto => $branchdetails->{'branchreplyto'},
                    sender  => $branchdetails->{'branchreturnpath'},
                    subject => Encode::encode( "utf8", "" . $letter->{title} ),
                    message => $letter->{'is_html'} ? _wrap_html( Encode::encode( "utf8", $letter->{'content'} ), Encode::encode( "utf8", "" . $letter->{'title'}  ) ) : Encode::encode( "utf8", "" . $letter->{'content'} ),
                    contenttype => $letter->{'is_html'} ? 'text/html; charset="utf-8"' : 'text/plain; charset="utf-8"',
                }
            );
            sendmail(%mail) or carp $Mail::Sendmail::error;
        }
    }
    elsif ( $type eq 'claimacquisition' or $type eq 'claimissues' ) {

        # prepare the letter...
        # search the biblionumber
        my $strsth =  $type eq 'claimacquisition'
            ? qq{
            SELECT aqorders.*,aqbasket.*,biblio.*,biblioitems.*
            FROM aqorders
            LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
            LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON aqorders.biblionumber=biblioitems.biblionumber
            WHERE aqorders.ordernumber IN (
            }
            : qq{
            SELECT serial.*,subscription.*, biblio.*, aqbooksellers.*,
            aqbooksellers.id AS booksellerid
            FROM serial
            LEFT JOIN subscription ON serial.subscriptionid=subscription.subscriptionid
            LEFT JOIN biblio ON serial.biblionumber=biblio.biblionumber
            LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
            WHERE serial.serialid IN (
            };

        if (!@$externalid){
            carp "No Order seleted";
            return { error => "no_order_seleted" };
        }

        $strsth .= join( ",", @$externalid ) . ")";
        my $sthorders = $dbh->prepare($strsth);
        $sthorders->execute;
        my $dataorders = $sthorders->fetchall_arrayref( {} );

        my $sthbookseller =
          $dbh->prepare("select * from aqbooksellers where id=?");
        $sthbookseller->execute( $dataorders->[0]->{booksellerid} );
        my $databookseller = $sthbookseller->fetchrow_hashref;
        my $addressee =  $type eq 'claimacquisition' ? 'acqprimary' : 'serialsprimary';
        my $sthcontact =
          $dbh->prepare("SELECT * FROM aqcontacts WHERE booksellerid=? AND $type=1 ORDER BY $addressee DESC");
        $sthcontact->execute( $dataorders->[0]->{booksellerid} );
        my $datacontact = $sthcontact->fetchrow_hashref;

        my @email;
        my @cc;
        push @email, $databookseller->{bookselleremail} if $databookseller->{bookselleremail};
        push @email, $datacontact->{email}           if ( $datacontact && $datacontact->{email} );
        unless (@email) {
            warn "Bookseller $dataorders->[0]->{booksellerid} without emails";
            return { error => "no_email" };
        }
        my $addlcontact;
        while ($addlcontact = $sthcontact->fetchrow_hashref) {
            push @cc, $addlcontact->{email} if ( $addlcontact && $addlcontact->{email} );
        }

        my $userenv = C4::Context->userenv;
        my $letter = GetPreparedLetter (
            module => $type,
            letter_code => $letter_code,
            branchcode => $userenv->{branch},
            tables => {
                'branches'    => $userenv->{branch},
                'aqbooksellers' => $databookseller,
                'aqcontacts'    => $datacontact,
            },
            repeat => $dataorders,
            want_librarian => 1,
        ) or return;

        # Remove the order tag
        $letter->{content} =~ s/<order>(.*?)<\/order>/$1/gxms;

        # ... then send mail
        my %mail = (
            To => join( ',', @email),
            Cc             => join( ',', @cc),
            From           => $userenv->{emailaddress},
            Subject        => Encode::encode( "utf8", "" . $letter->{title} ),
            Message => $letter->{'is_html'} ? _wrap_html( Encode::encode( "utf8", $letter->{'content'} ), Encode::encode( "utf8", "" . $letter->{'title'}  ) ) : Encode::encode( "utf8", "" . $letter->{'content'} ),
            'Content-Type' => $letter->{'is_html'} ? 'text/html; charset="utf-8"' : 'text/plain; charset="utf-8"',
        );

        $mail{'Reply-to'} = C4::Context->preference('ReplytoDefault')
          if C4::Context->preference('ReplytoDefault');
        $mail{'Sender'} = C4::Context->preference('ReturnpathDefault')
          if C4::Context->preference('ReturnpathDefault');

        unless ( sendmail(%mail) ) {
            carp $Mail::Sendmail::error;
            return { error => $Mail::Sendmail::error };
        }

        logaction(
            "ACQUISITION",
            $type eq 'claimissues' ? "CLAIM ISSUE" : "ACQUISITION CLAIM",
            undef,
            "To="
                . join( ',', @email )
                . " Title="
                . $letter->{title}
                . " Content="
                . $letter->{content}
        ) if C4::Context->preference("LetterLog");
    }
   # send an "account details" notice to a newly created user
    elsif ( $type eq 'members' ) {
        my $branchdetails = GetBranchDetail($externalid->{'branchcode'});
        my $letter = GetPreparedLetter (
            module => 'members',
            letter_code => $letter_code,
            branchcode => $externalid->{'branchcode'},
            tables => {
                'branches'    => $branchdetails,
                'borrowers' => $externalid->{'borrowernumber'},
            },
            substitute => { 'borrowers.password' => $externalid->{'password'} },
            want_librarian => 1,
        ) or return;
        return { error => "no_email" } unless $externalid->{'emailaddr'};
        my $email = Koha::Email->new();
        my %mail  = $email->create_message_headers(
            {
                to      => $externalid->{'emailaddr'},
                from    => $branchdetails->{'branchemail'},
                replyto => $branchdetails->{'branchreplyto'},
                sender  => $branchdetails->{'branchreturnpath'},
                subject => Encode::encode( "utf8", "" . $letter->{'title'} ),
                message => $letter->{'is_html'} ? _wrap_html( Encode::encode( "utf8", $letter->{'content'} ), Encode::encode( "utf8", "" . $letter->{'title'}  ) ) : Encode::encode( "utf8", "" . $letter->{'content'} ),
                contenttype => $letter->{'is_html'} ? 'text/html; charset="utf-8"' : 'text/plain; charset="utf-8"',
            }
        );
        sendmail(%mail) or carp $Mail::Sendmail::error;
    }
}

=head2 GetPreparedLetter( %params )

    %params hash:
      module => letter module, mandatory
      letter_code => letter code, mandatory
      branchcode => for letter selection, if missing default system letter taken
      tables => a hashref with table names as keys. Values are either:
        - a scalar - primary key value
        - an arrayref - primary key values
        - a hashref - full record
      substitute => custom substitution key/value pairs
      repeat => records to be substituted on consecutive lines:
        - an arrayref - tries to guess what needs substituting by
          taking remaining << >> tokensr; not recommended
        - a hashref token => @tables - replaces <token> << >> << >> </token>
          subtemplate for each @tables row; table is a hashref as above
      want_librarian => boolean,  if set to true triggers librarian details
        substitution from the userenv
    Return value:
      letter fields hashref (title & content useful)

=cut

sub GetPreparedLetter {
    my %params = @_;

    my $module      = $params{module} or croak "No module";
    my $letter_code = $params{letter_code} or croak "No letter_code";
    my $branchcode  = $params{branchcode} || '';
    my $mtt         = $params{message_transport_type} || 'email';

    my $letter = getletter( $module, $letter_code, $branchcode, $mtt )
        or warn( "No $module $letter_code letter transported by " . $mtt ),
            return;

    my $tables = $params{tables};
    my $substitute = $params{substitute};
    my $repeat = $params{repeat};
    $tables || $substitute || $repeat
      or carp( "ERROR: nothing to substitute - both 'tables' and 'substitute' are empty" ),
         return;
    my $want_librarian = $params{want_librarian};

    if ($substitute) {
        while ( my ($token, $val) = each %$substitute ) {
            $letter->{title} =~ s/<<$token>>/$val/g;
            $letter->{content} =~ s/<<$token>>/$val/g;
       }
    }

    my $OPACBaseURL = C4::Context->preference('OPACBaseURL');
    $letter->{content} =~ s/<<OPACBaseURL>>/$OPACBaseURL/go;

    if ($want_librarian) {
        # parsing librarian name
        my $userenv = C4::Context->userenv;
        $letter->{content} =~ s/<<LibrarianFirstname>>/$userenv->{firstname}/go;
        $letter->{content} =~ s/<<LibrarianSurname>>/$userenv->{surname}/go;
        $letter->{content} =~ s/<<LibrarianEmailaddress>>/$userenv->{emailaddress}/go;
    }

    my ($repeat_no_enclosing_tags, $repeat_enclosing_tags);

    if ($repeat) {
        if (ref ($repeat) eq 'ARRAY' ) {
            $repeat_no_enclosing_tags = $repeat;
        } else {
            $repeat_enclosing_tags = $repeat;
        }
    }

    if ($repeat_enclosing_tags) {
        while ( my ($tag, $tag_tables) = each %$repeat_enclosing_tags ) {
            if ( $letter->{content} =~ m!<$tag>(.*)</$tag>!s ) {
                my $subcontent = $1;
                my @lines = map {
                    my %subletter = ( title => '', content => $subcontent );
                    _substitute_tables( \%subletter, $_ );
                    $subletter{content};
                } @$tag_tables;
                $letter->{content} =~ s!<$tag>.*</$tag>!join( "\n", @lines )!se;
            }
        }
    }

    if ($tables) {
        _substitute_tables( $letter, $tables );
    }

    if ($repeat_no_enclosing_tags) {
        if ( $letter->{content} =~ m/[^\n]*<<.*>>[^\n]*/so ) {
            my $line = $&;
            my $i = 1;
            my @lines = map {
                my $c = $line;
                $c =~ s/<<count>>/$i/go;
                foreach my $field ( keys %{$_} ) {
                    $c =~ s/(<<[^\.]+.$field>>)/$_->{$field}/;
                }
                $i++;
                $c;
            } @$repeat_no_enclosing_tags;

            my $replaceby = join( "\n", @lines );
            $letter->{content} =~ s/\Q$line\E/$replaceby/s;
        }
    }

    $letter->{content} =~ s/<<\S*>>//go; #remove any stragglers
#   $letter->{content} =~ s/<<[^>]*>>//go;

    return $letter;
}

sub _substitute_tables {
    my ( $letter, $tables ) = @_;
    while ( my ($table, $param) = each %$tables ) {
        next unless $param;

        my $ref = ref $param;

        my $values;
        if ($ref && $ref eq 'HASH') {
            $values = $param;
        }
        else {
            my $sth = _parseletter_sth($table);
            unless ($sth) {
                warn "_parseletter_sth('$table') failed to return a valid sth.  No substitution will be done for that table.";
                return;
            }
            $sth->execute( $ref ? @$param : $param );

            $values = $sth->fetchrow_hashref;
            $sth->finish();
        }

        _parseletter ( $letter, $table, $values );
    }
}

sub _parseletter_sth {
    my $table = shift;
    my $sth;
    unless ($table) {
        carp "ERROR: _parseletter_sth() called without argument (table)";
        return;
    }
    # NOTE: we used to check whether we had a statement handle cached in
    #       a %handles module-level variable. This was a dumb move and
    #       broke things for the rest of us. prepare_cached is a better
    #       way to cache statement handles anyway.
    my $query = 
    ($table eq 'biblio'       ) ? "SELECT * FROM $table WHERE   biblionumber = ?"                                  :
    ($table eq 'biblioitems'  ) ? "SELECT * FROM $table WHERE   biblionumber = ?"                                  :
    ($table eq 'items'        ) ? "SELECT * FROM $table WHERE     itemnumber = ?"                                  :
    ($table eq 'issues'       ) ? "SELECT * FROM $table WHERE     itemnumber = ?"                                  :
    ($table eq 'old_issues'   ) ? "SELECT * FROM $table WHERE     itemnumber = ? ORDER BY timestamp DESC LIMIT 1"  :
    ($table eq 'reserves'     ) ? "SELECT * FROM $table WHERE borrowernumber = ? and biblionumber = ?"             :
    ($table eq 'borrowers'    ) ? "SELECT * FROM $table WHERE borrowernumber = ?"                                  :
    ($table eq 'branches'     ) ? "SELECT * FROM $table WHERE     branchcode = ?"                                  :
    ($table eq 'suggestions'  ) ? "SELECT * FROM $table WHERE   suggestionid = ?"                                  :
    ($table eq 'aqbooksellers') ? "SELECT * FROM $table WHERE             id = ?"                                  :
    ($table eq 'aqorders'     ) ? "SELECT * FROM $table WHERE    ordernumber = ?"                                  :
    ($table eq 'opac_news'    ) ? "SELECT * FROM $table WHERE          idnew = ?"                                  :
    ($table eq 'borrower_modifications') ? "SELECT * FROM $table WHERE verification_token = ?" :
    undef ;
    unless ($query) {
        warn "ERROR: No _parseletter_sth query for table '$table'";
        return;     # nothing to get
    }
    unless ($sth = C4::Context->dbh->prepare_cached($query)) {
        warn "ERROR: Failed to prepare query: '$query'";
        return;
    }
    return $sth;    # now cache is populated for that $table
}

=head2 _parseletter($letter, $table, $values)

    parameters :
    - $letter : a hash to letter fields (title & content useful)
    - $table : the Koha table to parse.
    - $values : table record hashref
    parse all fields from a table, and replace values in title & content with the appropriate value
    (not exported sub, used only internally)

=cut

sub _parseletter {
    my ( $letter, $table, $values ) = @_;

    if ( $table eq 'reserves' && $values->{'waitingdate'} ) {
        my @waitingdate = split /-/, $values->{'waitingdate'};

        $values->{'expirationdate'} = '';
        if( C4::Context->preference('ExpireReservesMaxPickUpDelay') &&
        C4::Context->preference('ReservesMaxPickUpDelay') ) {
            my $dt = dt_from_string();
            $dt->add( days => C4::Context->preference('ReservesMaxPickUpDelay') );
            $values->{'expirationdate'} = output_pref({ dt => $dt, dateonly => 1 });
        }

        $values->{'waitingdate'} = output_pref({ dt => dt_from_string( $values->{'waitingdate'} ), dateonly => 1 });

    }

    if ($letter->{content} && $letter->{content} =~ /<<today>>/) {
        my $todaysdate = output_pref( DateTime->now() );
        $letter->{content} =~ s/<<today>>/$todaysdate/go;
    }

    while ( my ($field, $val) = each %$values ) {
        my $replacetablefield = "<<$table.$field>>";
        my $replacefield = "<<$field>>";
        $val =~ s/\p{P}$// if $val && $table=~/biblio/;
            #BZ 9886: Assuming that we want to eliminate ISBD punctuation here
            #Therefore adding the test on biblio. This includes biblioitems,
            #but excludes items. Removed unneeded global and lookahead.

        $val = GetAuthorisedValueByCode ('ROADTYPE', $val, 0) if $table=~/^borrowers$/ && $field=~/^streettype$/;
        my $replacedby   = defined ($val) ? $val : '';
        if (    $replacedby
            and not $replacedby =~ m|0000-00-00|
            and not $replacedby =~ m|9999-12-31|
            and $replacedby =~ m|^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$| )
        {
            # If the value is XXXX-YY-ZZ[ AA:BB:CC] we assume it is a date
            my $dateonly = defined $1 ? 0 : 1; #$1 refers to the capture group wrapped in parentheses. In this case, that's the hours, minutes, seconds.
            eval {
                $replacedby = output_pref({ dt => dt_from_string( $replacedby ), dateonly => $dateonly });
            };
            warn "$replacedby seems to be a date but an error occurs on generating it ($@)" if $@;
        }
        ($letter->{title}  ) and do {
            $letter->{title}   =~ s/$replacetablefield/$replacedby/g;
            $letter->{title}   =~ s/$replacefield/$replacedby/g;
        };
        ($letter->{content}) and do {
            $letter->{content} =~ s/$replacetablefield/$replacedby/g;
            $letter->{content} =~ s/$replacefield/$replacedby/g;
        };
    }

    if ($table eq 'borrowers' && $letter->{content}) {
        if ( my $attributes = GetBorrowerAttributes($values->{borrowernumber}) ) {
            my %attr;
            foreach (@$attributes) {
                my $code = $_->{code};
                my $val  = $_->{value_description} || $_->{value};
                $val =~ s/\p{P}(?=$)//g if $val;
                next unless $val gt '';
                $attr{$code} ||= [];
                push @{ $attr{$code} }, $val;
            }
            while ( my ($code, $val_ar) = each %attr ) {
                my $replacefield = "<<borrower-attribute:$code>>";
                my $replacedby   = join ',', @$val_ar;
                $letter->{content} =~ s/$replacefield/$replacedby/g;
            }
        }
    }
    return $letter;
}

=head2 EnqueueLetter

  my $success = EnqueueLetter( { letter => $letter, 
        borrowernumber => '12', message_transport_type => 'email' } )

places a letter in the message_queue database table, which will
eventually get processed (sent) by the process_message_queue.pl
cronjob when it calls SendQueuedMessages.

return message_id on success

=cut

sub EnqueueLetter {
    my $params = shift or return;

    return unless exists $params->{'letter'};
#   return unless exists $params->{'borrowernumber'};
    return unless exists $params->{'message_transport_type'};

    my $content = $params->{letter}->{content};
    $content =~ s/\s+//g if(defined $content);
    if ( not defined $content or $content eq '' ) {
        warn "Trying to add an empty message to the message queue" if $debug;
        return;
    }

    # If we have any attachments we should encode then into the body.
    if ( $params->{'attachments'} ) {
        $params->{'letter'} = _add_attachments(
            {   letter      => $params->{'letter'},
                attachments => $params->{'attachments'},
                message     => MIME::Lite->new( Type => 'multipart/mixed' ),
            }
        );
    }

    my $dbh       = C4::Context->dbh();
    my $statement = << 'ENDSQL';
INSERT INTO message_queue
( borrowernumber, subject, content, metadata, letter_code, message_transport_type, status, time_queued, to_address, from_address, content_type )
VALUES
( ?,              ?,       ?,       ?,        ?,           ?,                      ?,      NOW(),       ?,          ?,            ? )
ENDSQL

    my $sth    = $dbh->prepare($statement);
    my $result = $sth->execute(
        $params->{'borrowernumber'},              # borrowernumber
        $params->{'letter'}->{'title'},           # subject
        $params->{'letter'}->{'content'},         # content
        $params->{'letter'}->{'metadata'} || '',  # metadata
        $params->{'letter'}->{'code'}     || '',  # letter_code
        $params->{'message_transport_type'},      # message_transport_type
        'pending',                                # status
        $params->{'to_address'},                  # to_address
        $params->{'from_address'},                # from_address
        $params->{'letter'}->{'content-type'},    # content_type
    );
    return $dbh->last_insert_id(undef,undef,'message_queue', undef);
}

=head2 SendQueuedMessages ([$hashref]) 

  my $sent = SendQueuedMessages( { verbose => 1 } );

sends all of the 'pending' items in the message queue.

returns number of messages sent.

=cut

sub SendQueuedMessages {
    my $params = shift;

    my $unsent_messages = _get_unsent_messages();
    MESSAGE: foreach my $message ( @$unsent_messages ) {
        # warn Data::Dumper->Dump( [ $message ], [ 'message' ] );
        warn sprintf( 'sending %s message to patron: %s',
                      $message->{'message_transport_type'},
                      $message->{'borrowernumber'} || 'Admin' )
          if $params->{'verbose'} or $debug;
        # This is just begging for subclassing
        next MESSAGE if ( lc($message->{'message_transport_type'}) eq 'rss' );
        if ( lc( $message->{'message_transport_type'} ) eq 'email' ) {
            _send_message_by_email( $message, $params->{'username'}, $params->{'password'}, $params->{'method'} );
        }
        elsif ( lc( $message->{'message_transport_type'} ) eq 'sms' ) {
            _send_message_by_sms( $message );
        }
    }
    return scalar( @$unsent_messages );
}

=head2 GetRSSMessages

  my $message_list = GetRSSMessages( { limit => 10, borrowernumber => '14' } )

returns a listref of all queued RSS messages for a particular person.

=cut

sub GetRSSMessages {
    my $params = shift;

    return unless $params;
    return unless ref $params;
    return unless $params->{'borrowernumber'};
    
    return _get_unsent_messages( { message_transport_type => 'rss',
                                   limit                  => $params->{'limit'},
                                   borrowernumber         => $params->{'borrowernumber'}, } );
}

=head2 GetPrintMessages

  my $message_list = GetPrintMessages( { borrowernumber => $borrowernumber } )

Returns a arrayref of all queued print messages (optionally, for a particular
person).

=cut

sub GetPrintMessages {
    my $params = shift || {};
    
    return _get_unsent_messages( { message_transport_type => 'print',
                                   borrowernumber         => $params->{'borrowernumber'},
                                 } );
}

=head2 GetQueuedMessages ([$hashref])

  my $messages = GetQueuedMessage( { borrowernumber => '123', limit => 20 } );

fetches messages out of the message queue.

returns:
list of hashes, each has represents a message in the message queue.

=cut

sub GetQueuedMessages {
    my $params = shift;

    my $dbh = C4::Context->dbh();
    my $statement = << 'ENDSQL';
SELECT message_id, borrowernumber, subject, content, message_transport_type, status, time_queued
FROM message_queue
ENDSQL

    my @query_params;
    my @whereclauses;
    if ( exists $params->{'borrowernumber'} ) {
        push @whereclauses, ' borrowernumber = ? ';
        push @query_params, $params->{'borrowernumber'};
    }

    if ( @whereclauses ) {
        $statement .= ' WHERE ' . join( 'AND', @whereclauses );
    }

    if ( defined $params->{'limit'} ) {
        $statement .= ' LIMIT ? ';
        push @query_params, $params->{'limit'};
    }

    my $sth = $dbh->prepare( $statement );
    my $result = $sth->execute( @query_params );
    return $sth->fetchall_arrayref({});
}

=head2 GetMessageTransportTypes

  my @mtt = GetMessageTransportTypes();

  returns an arrayref of transport types

=cut

sub GetMessageTransportTypes {
    my $dbh = C4::Context->dbh();
    my $mtts = $dbh->selectcol_arrayref("
        SELECT message_transport_type
        FROM message_transport_types
        ORDER BY message_transport_type
    ");
    return $mtts;
}

=head2 _add_attachements

named parameters:
letter - the standard letter hashref
attachments - listref of attachments. each attachment is a hashref of:
  type - the mime type, like 'text/plain'
  content - the actual attachment
  filename - the name of the attachment.
message - a MIME::Lite object to attach these to.

returns your letter object, with the content updated.

=cut

sub _add_attachments {
    my $params = shift;

    my $letter = $params->{'letter'};
    my $attachments = $params->{'attachments'};
    return $letter unless @$attachments;
    my $message = $params->{'message'};

    # First, we have to put the body in as the first attachment
    $message->attach(
        Type => $letter->{'content-type'} || 'TEXT',
        Data => $letter->{'is_html'}
            ? _wrap_html($letter->{'content'}, $letter->{'title'})
            : $letter->{'content'},
    );

    foreach my $attachment ( @$attachments ) {
        $message->attach(
            Type     => $attachment->{'type'},
            Data     => $attachment->{'content'},
            Filename => $attachment->{'filename'},
        );
    }
    # we're forcing list context here to get the header, not the count back from grep.
    ( $letter->{'content-type'} ) = grep( /^Content-Type:/, split( /\n/, $params->{'message'}->header_as_string ) );
    $letter->{'content-type'} =~ s/^Content-Type:\s+//;
    $letter->{'content'} = $message->body_as_string;

    return $letter;

}

sub _get_unsent_messages {
    my $params = shift;

    my $dbh = C4::Context->dbh();
    my $statement = << 'ENDSQL';
SELECT mq.message_id, mq.borrowernumber, mq.subject, mq.content, mq.message_transport_type, mq.status, mq.time_queued, mq.from_address, mq.to_address, mq.content_type, b.branchcode, mq.letter_code
  FROM message_queue mq
  LEFT JOIN borrowers b ON b.borrowernumber = mq.borrowernumber
 WHERE status = ?
ENDSQL

    my @query_params = ('pending');
    if ( ref $params ) {
        if ( $params->{'message_transport_type'} ) {
            $statement .= ' AND message_transport_type = ? ';
            push @query_params, $params->{'message_transport_type'};
        }
        if ( $params->{'borrowernumber'} ) {
            $statement .= ' AND borrowernumber = ? ';
            push @query_params, $params->{'borrowernumber'};
        }
        if ( $params->{'limit'} ) {
            $statement .= ' limit ? ';
            push @query_params, $params->{'limit'};
        }
    }

    $debug and warn "_get_unsent_messages SQL: $statement";
    $debug and warn "_get_unsent_messages params: " . join(',',@query_params);
    my $sth = $dbh->prepare( $statement );
    my $result = $sth->execute( @query_params );
    return $sth->fetchall_arrayref({});
}

sub _send_message_by_email {
    my $message = shift or return;
    my ($username, $password, $method) = @_;

    my $member = C4::Members::GetMember( 'borrowernumber' => $message->{'borrowernumber'} );
    my $to_address = $message->{'to_address'};
    unless ($to_address) {
        unless ($member) {
            warn "FAIL: No 'to_address' and INVALID borrowernumber ($message->{borrowernumber})";
            _set_message_status( { message_id => $message->{'message_id'},
                                   status     => 'failed' } );
            return;
        }
        $to_address = C4::Members::GetNoticeEmailAddress( $message->{'borrowernumber'} );
        unless ($to_address) {  
            # warn "FAIL: No 'to_address' and no email for " . ($member->{surname} ||'') . ", borrowernumber ($message->{borrowernumber})";
            # warning too verbose for this more common case?
            _set_message_status( { message_id => $message->{'message_id'},
                                   status     => 'failed' } );
            return;
        }
    }

    my $utf8   = decode('MIME-Header', $message->{'subject'} );
    $message->{subject}= encode('MIME-Header', $utf8);
    my $subject = encode('utf8', $message->{'subject'});
    my $content = encode('utf8', $message->{'content'});
    my $content_type = $message->{'content_type'} || 'text/plain; charset="UTF-8"';
    my $is_html = $content_type =~ m/html/io;
    my $branch_email = undef;
    my $branch_replyto = undef;
    my $branch_returnpath = undef;
    if ($member){
        my $branchdetail = GetBranchDetail( $member->{'branchcode'} );
        $branch_email = $branchdetail->{'branchemail'};
        $branch_replyto = $branchdetail->{'branchreplyto'};
        $branch_returnpath = $branchdetail->{'branchreturnpath'};
    }
    my $email = Koha::Email->new();
    my %sendmail_params = $email->create_message_headers(
        {
            to      => $to_address,
            from    => $message->{'from_address'} || $branch_email,
            replyto => $branch_replyto,
            sender  => $branch_returnpath,
            subject => $subject,
            message => $is_html ? _wrap_html( $content, $subject ) : $content,
            contenttype => $content_type
        }
    );

    $sendmail_params{'Auth'} = {user => $username, pass => $password, method => $method} if $username;
    if ( my $bcc = C4::Context->preference('OverdueNoticeBcc') ) {
       $sendmail_params{ Bcc } = $bcc;
    }

    _update_message_to_address($message->{'message_id'},$to_address) unless $message->{to_address}; #if initial message address was empty, coming here means that a to address was found and queue should be updated
    if ( sendmail( %sendmail_params ) ) {
        _set_message_status( { message_id => $message->{'message_id'},
                status     => 'sent' } );
        return 1;
    } else {
        _set_message_status( { message_id => $message->{'message_id'},
                status     => 'failed' } );
        carp $Mail::Sendmail::error;
        return;
    }
}

sub _wrap_html {
    my ($content, $title) = @_;

    my $css = C4::Context->preference("NoticeCSS") || '';
    $css = qq{<link rel="stylesheet" type="text/css" href="$css">} if $css;
    return <<EOS;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$title</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
$css
</head>
<body>
$content
</body>
</html>
EOS
}

sub _is_duplicate {
    my ( $message ) = @_;
    my $dbh = C4::Context->dbh;
    my $count = $dbh->selectrow_array(q|
        SELECT COUNT(*)
        FROM message_queue
        WHERE message_transport_type = ?
        AND borrowernumber = ?
        AND letter_code = ?
        AND CAST(time_queued AS date) = CAST(NOW() AS date)
        AND status="sent"
        AND content = ?
    |, {}, $message->{message_transport_type}, $message->{borrowernumber}, $message->{letter_code}, $message->{content} );
    return $count;
}

sub _send_message_by_sms {
    my $message = shift or return;
    my $member = C4::Members::GetMember( 'borrowernumber' => $message->{'borrowernumber'} );

    unless ( $member->{smsalertnumber} ) {
        _set_message_status( { message_id => $message->{'message_id'},
                               status     => 'failed' } );
        return;
    }

    if ( _is_duplicate( $message ) ) {
        _set_message_status( { message_id => $message->{'message_id'},
                               status     => 'failed' } );
        return;
    }

    my $success = C4::SMS->send_sms( { destination => $member->{'smsalertnumber'},
                                       message     => $message->{'content'},
                                     } );
    _set_message_status( { message_id => $message->{'message_id'},
                           status     => ($success ? 'sent' : 'failed') } );
    return $success;
}

sub _update_message_to_address {
    my ($id, $to)= @_;
    my $dbh = C4::Context->dbh();
    $dbh->do('UPDATE message_queue SET to_address=? WHERE message_id=?',undef,($to,$id));
}

sub _set_message_status {
    my $params = shift or return;

    foreach my $required_parameter ( qw( message_id status ) ) {
        return unless exists $params->{ $required_parameter };
    }

    my $dbh = C4::Context->dbh();
    my $statement = 'UPDATE message_queue SET status= ? WHERE message_id = ?';
    my $sth = $dbh->prepare( $statement );
    my $result = $sth->execute( $params->{'status'},
                                $params->{'message_id'} );
    return $result;
}


1;
__END__
