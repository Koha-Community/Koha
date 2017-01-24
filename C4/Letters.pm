package C4::Letters;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use MIME::Lite;
use Mail::Sendmail;
use Date::Calc qw( Add_Delta_Days );
use Encode;
use Carp;
use Template;
use Module::Load::Conditional qw(can_load);

use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use C4::Log;
use C4::SMS;
use C4::Debug;
use Koha::DateUtils;
use Koha::SMS::Providers;

use Koha::Email;
use Koha::DateUtils qw( format_sqldatetime dt_from_string );
use Koha::Patrons;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    require Exporter;
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

  DEPRECATED - You must use Koha::Notice::Templates instead
  The group by clause is confusing and can lead to issues

=cut

sub GetLetters {
    my ($filters) = @_;
    my $module    = $filters->{module};
    my $code      = $filters->{code};
    my $branchcode = $filters->{branchcode};
    my $dbh       = C4::Context->dbh;
    my $letters   = $dbh->selectall_arrayref(
        q|
            SELECT code, module, name
            FROM letter
            WHERE 1
        |
          . ( $module ? q| AND module = ?| : q|| )
          . ( $code   ? q| AND code = ?|   : q|| )
          . ( defined $branchcode   ? q| AND branchcode = ?|   : q|| )
          . q| GROUP BY code, module, name ORDER BY name|, { Slice => {} }
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

=cut

sub GetLetterTemplates {
    my ( $params ) = @_;

    my $module    = $params->{module};
    my $code      = $params->{code};
    my $branchcode = $params->{branchcode} // '';
    my $dbh       = C4::Context->dbh;
    my $letters   = $dbh->selectall_arrayref(
        q|
            SELECT module, code, branchcode, name, is_html, title, content, message_transport_type, lang
            FROM letter
            WHERE module = ?
            AND code = ?
            and branchcode = ?
        |
        , { Slice => {} }
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

sub getletter {
    my ( $module, $code, $branchcode, $message_transport_type, $lang) = @_;
    $message_transport_type //= '%';
    $lang = 'default' unless( $lang && C4::Context->preference('TranslateNotices') );


    my $only_my_library = C4::Context->only_my_library;
    if ( $only_my_library and $branchcode ) {
        $branchcode = C4::Context::mybranch();
    }
    $branchcode //= '';

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(q{
        SELECT *
        FROM letter
        WHERE module=? AND code=? AND (branchcode = ? OR branchcode = '')
        AND message_transport_type LIKE ?
        AND lang =?
        ORDER BY branchcode DESC LIMIT 1
    });
    $sth->execute( $module, $code, $branchcode, $message_transport_type, $lang );
    my $line = $sth->fetchrow_hashref
      or return;
    $line->{'content-type'} = 'text/html; charset="UTF-8"' if $line->{is_html};
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
    my $lang       = $params->{lang};
    my $dbh        = C4::Context->dbh;
    $dbh->do(q|
        DELETE FROM letter
        WHERE branchcode = ?
          AND module = ?
          AND code = ?
    |
    . ( $mtt ? q| AND message_transport_type = ?| : q|| )
    . ( $lang? q| AND lang = ?| : q|| )
    , undef, $branchcode, $module, $code, ( $mtt ? $mtt : () ), ( $lang ? $lang : () ) );
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
    my $query = "SELECT a.*, b.branchcode FROM alert a JOIN borrowers b USING(borrowernumber) WHERE 1";
    my @bind;
    if ($borrowernumber and $borrowernumber =~ /^\d+$/) {
        $query .= " AND borrowernumber=?";
        push @bind, $borrowernumber;
    }
    if ($type) {
        $query .= " AND type=?";
        push @bind, $type;
    }
    if ($externalid) {
        $query .= " AND externalid=?";
        push @bind, $externalid;
    }
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

    my $err = &SendAlerts($type, $externalid, $letter_code);

    Parameters:
      - $type : the type of alert
      - $externalid : the id of the "object" to query
      - $letter_code : the notice template to use

    C<&SendAlerts> sends an email notice directly to a patron or a vendor.

    Currently it supports ($type):
      - claim serial issues (claimissues)
      - claim acquisition orders (claimacquisition)
      - send acquisition orders to the vendor (orderacquisition)
      - notify patrons about newly received serial issues (issue)
      - notify patrons when their account is created (members)

    Returns undef or { error => 'message } on failure.
    Returns true on success.

=cut

sub SendAlerts {
    my ( $type, $externalid, $letter_code ) = @_;
    my $dbh = C4::Context->dbh;
    if ( $type eq 'issue' ) {

        # prepare the letter...
        # search the subscriptionid
        my $sth =
          $dbh->prepare(
            "SELECT subscriptionid FROM serial WHERE serialid=?");
        $sth->execute($externalid);
        my ($subscriptionid) = $sth->fetchrow
          or warn( "No subscription for '$externalid'" ),
             return;

        # search the biblionumber
        $sth =
          $dbh->prepare(
            "SELECT biblionumber FROM subscription WHERE subscriptionid=?");
        $sth->execute($subscriptionid);
        my ($biblionumber) = $sth->fetchrow
          or warn( "No biblionumber for '$subscriptionid'" ),
             return;

        my %letter;
        # find the list of borrowers to alert
        my $alerts = getalert( '', 'issue', $subscriptionid );
        foreach (@$alerts) {
            my $patron = Koha::Patrons->find( $_->{borrowernumber} );
            next unless $patron; # Just in case
            my $email = $patron->email or next;

#                    warn "sending issues...";
            my $userenv = C4::Context->userenv;
            my $library = Koha::Libraries->find( $_->{branchcode} );
            my $letter = GetPreparedLetter (
                module => 'serial',
                letter_code => $letter_code,
                branchcode => $userenv->{branch},
                tables => {
                    'branches'    => $_->{branchcode},
                    'biblio'      => $biblionumber,
                    'biblioitems' => $biblionumber,
                    'borrowers'   => $patron->unblessed,
                    'subscription' => $subscriptionid,
                    'serial' => $externalid,
                },
                want_librarian => 1,
            ) or return;

            # ... then send mail
            my $message = Koha::Email->new();
            my %mail = $message->create_message_headers(
                {
                    to      => $email,
                    from    => $library->branchemail,
                    replyto => $library->branchreplyto,
                    sender  => $library->branchreturnpath,
                    subject => Encode::encode( "UTF-8", "" . $letter->{title} ),
                    message => $letter->{'is_html'}
                                ? _wrap_html( Encode::encode( "UTF-8", $letter->{'content'} ),
                                              Encode::encode( "UTF-8", "" . $letter->{'title'} ))
                                : Encode::encode( "UTF-8", "" . $letter->{'content'} ),
                    contenttype => $letter->{'is_html'}
                                    ? 'text/html; charset="utf-8"'
                                    : 'text/plain; charset="utf-8"',
                }
            );
            unless( Mail::Sendmail::sendmail(%mail) ) {
                carp $Mail::Sendmail::error;
                return { error => $Mail::Sendmail::error };
            }
        }
    }
    elsif ( $type eq 'claimacquisition' or $type eq 'claimissues' or $type eq 'orderacquisition' ) {

        # prepare the letter...
        my $strsth;
        my $sthorders;
        my $dataorders;
        my $action;
        if ( $type eq 'claimacquisition') {
            $strsth = qq{
            SELECT aqorders.*,aqbasket.*,biblio.*,biblioitems.*
            FROM aqorders
            LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
            LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON aqorders.biblionumber=biblioitems.biblionumber
            WHERE aqorders.ordernumber IN (
            };

            if (!@$externalid){
                carp "No order selected";
                return { error => "no_order_selected" };
            }
            $strsth .= join( ",", ('?') x @$externalid ) . ")";
            $action = "ACQUISITION CLAIM";
            $sthorders = $dbh->prepare($strsth);
            $sthorders->execute( @$externalid );
            $dataorders = $sthorders->fetchall_arrayref( {} );
        }

        if ($type eq 'claimissues') {
            $strsth = qq{
            SELECT serial.*,subscription.*, biblio.*, aqbooksellers.*,
            aqbooksellers.id AS booksellerid
            FROM serial
            LEFT JOIN subscription ON serial.subscriptionid=subscription.subscriptionid
            LEFT JOIN biblio ON serial.biblionumber=biblio.biblionumber
            LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
            WHERE serial.serialid IN (
            };

            if (!@$externalid){
                carp "No Order selected";
                return { error => "no_order_selected" };
            }

            $strsth .= join( ",", ('?') x @$externalid ) . ")";
            $action = "CLAIM ISSUE";
            $sthorders = $dbh->prepare($strsth);
            $sthorders->execute( @$externalid );
            $dataorders = $sthorders->fetchall_arrayref( {} );
        }

        if ( $type eq 'orderacquisition') {
            $strsth = qq{
            SELECT aqorders.*,aqbasket.*,biblio.*,biblioitems.*
            FROM aqorders
            LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
            LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON aqorders.biblionumber=biblioitems.biblionumber
            WHERE aqbasket.basketno = ?
            AND orderstatus IN ('new','ordered')
            };

            if (!$externalid){
                carp "No basketnumber given";
                return { error => "no_basketno" };
            }
            $action = "ACQUISITION ORDER";
            $sthorders = $dbh->prepare($strsth);
            $sthorders->execute($externalid);
            $dataorders = $sthorders->fetchall_arrayref( {} );
        }

        my $sthbookseller =
          $dbh->prepare("select * from aqbooksellers where id=?");
        $sthbookseller->execute( $dataorders->[0]->{booksellerid} );
        my $databookseller = $sthbookseller->fetchrow_hashref;

        my $addressee =  $type eq 'claimacquisition' || $type eq 'orderacquisition' ? 'acqprimary' : 'serialsprimary';

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
        ) or return { error => "no_letter" };

        # Remove the order tag
        $letter->{content} =~ s/<order>(.*?)<\/order>/$1/gxms;

        # ... then send mail
        my $library = Koha::Libraries->find( $userenv->{branch} );
        my %mail = (
            To => join( ',', @email),
            Cc             => join( ',', @cc),
            From           => $library->branchemail || C4::Context->preference('KohaAdminEmailAddress'),
            Subject        => Encode::encode( "UTF-8", "" . $letter->{title} ),
            Message => $letter->{'is_html'}
                            ? _wrap_html( Encode::encode( "UTF-8", $letter->{'content'} ),
                                          Encode::encode( "UTF-8", "" . $letter->{'title'} ))
                            : Encode::encode( "UTF-8", "" . $letter->{'content'} ),
            'Content-Type' => $letter->{'is_html'}
                                ? 'text/html; charset="utf-8"'
                                : 'text/plain; charset="utf-8"',
        );

        if ($type eq 'claimacquisition' || $type eq 'claimissues' ) {
            $mail{'Reply-to'} = C4::Context->preference('ReplytoDefault')
              if C4::Context->preference('ReplytoDefault');
            $mail{'Sender'} = C4::Context->preference('ReturnpathDefault')
              if C4::Context->preference('ReturnpathDefault');
            $mail{'Bcc'} = $userenv->{emailaddress}
              if C4::Context->preference("ClaimsBccCopy");
        }

        unless ( Mail::Sendmail::sendmail(%mail) ) {
            carp $Mail::Sendmail::error;
            return { error => $Mail::Sendmail::error };
        }

        logaction(
            "ACQUISITION",
            $action,
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
        my $library = Koha::Libraries->find( $externalid->{branchcode} )->unblessed;
        my $letter = GetPreparedLetter (
            module => 'members',
            letter_code => $letter_code,
            branchcode => $externalid->{'branchcode'},
            tables => {
                'branches'    => $library,
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
                from    => $library->{branchemail},
                replyto => $library->{branchreplyto},
                sender  => $library->{branchreturnpath},
                subject => Encode::encode( "UTF-8", "" . $letter->{'title'} ),
                message => $letter->{'is_html'}
                            ? _wrap_html( Encode::encode( "UTF-8", $letter->{'content'} ),
                                          Encode::encode( "UTF-8", "" . $letter->{'title'}  ) )
                            : Encode::encode( "UTF-8", "" . $letter->{'content'} ),
                contenttype => $letter->{'is_html'}
                                ? 'text/html; charset="utf-8"'
                                : 'text/plain; charset="utf-8"',
            }
        );
        unless( Mail::Sendmail::sendmail(%mail) ) {
            carp $Mail::Sendmail::error;
            return { error => $Mail::Sendmail::error };
        }
    }

    # If we come here, return an OK status
    return 1;
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

    my $letter = $params{letter};

    unless ( $letter ) {
        my $module      = $params{module} or croak "No module";
        my $letter_code = $params{letter_code} or croak "No letter_code";
        my $branchcode  = $params{branchcode} || '';
        my $mtt         = $params{message_transport_type} || 'email';
        my $lang        = $params{lang} || 'default';

        $letter = getletter( $module, $letter_code, $branchcode, $mtt, $lang );

        unless ( $letter ) {
            $letter = getletter( $module, $letter_code, $branchcode, $mtt, 'default' )
                or warn( "No $module $letter_code letter transported by " . $mtt ),
                    return;
        }
    }

    my $tables = $params{tables} || {};
    my $substitute = $params{substitute} || {};
    my $loops  = $params{loops} || {}; # loops is not supported for historical notices syntax
    my $repeat = $params{repeat};
    %$tables || %$substitute || $repeat || %$loops
      or carp( "ERROR: nothing to substitute - both 'tables', 'loops' and 'substitute' are empty" ),
         return;
    my $want_librarian = $params{want_librarian};

    if (%$substitute) {
        while ( my ($token, $val) = each %$substitute ) {
            if ( $token eq 'items.content' ) {
                $val =~ s|\n|<br/>|g if $letter->{is_html};
            }

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

    if (%$tables) {
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

    $letter->{content} = _process_tt(
        {
            content => $letter->{content},
            tables  => $tables,
            loops  => $loops,
            substitute => $substitute,
        }
    );

    $letter->{content} =~ s/<<\S*>>//go; #remove any stragglers

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
    ($table eq 'biblio'       )    ? "SELECT * FROM $table WHERE   biblionumber = ?"                                  :
    ($table eq 'biblioitems'  )    ? "SELECT * FROM $table WHERE   biblionumber = ?"                                  :
    ($table eq 'items'        )    ? "SELECT * FROM $table WHERE     itemnumber = ?"                                  :
    ($table eq 'issues'       )    ? "SELECT * FROM $table WHERE     itemnumber = ?"                                  :
    ($table eq 'old_issues'   )    ? "SELECT * FROM $table WHERE     itemnumber = ? ORDER BY timestamp DESC LIMIT 1"  :
    ($table eq 'reserves'     )    ? "SELECT * FROM $table WHERE borrowernumber = ? and biblionumber = ?"             :
    ($table eq 'borrowers'    )    ? "SELECT * FROM $table WHERE borrowernumber = ?"                                  :
    ($table eq 'branches'     )    ? "SELECT * FROM $table WHERE     branchcode = ?"                                  :
    ($table eq 'suggestions'  )    ? "SELECT * FROM $table WHERE   suggestionid = ?"                                  :
    ($table eq 'aqbooksellers')    ? "SELECT * FROM $table WHERE             id = ?"                                  :
    ($table eq 'aqorders'     )    ? "SELECT * FROM $table WHERE    ordernumber = ?"                                  :
    ($table eq 'opac_news'    )    ? "SELECT * FROM $table WHERE          idnew = ?"                                  :
    ($table eq 'article_requests') ? "SELECT * FROM $table WHERE             id = ?"                                  :
    ($table eq 'borrower_modifications') ? "SELECT * FROM $table WHERE verification_token = ?" :
    ($table eq 'subscription') ? "SELECT * FROM $table WHERE subscriptionid = ?" :
    ($table eq 'serial') ? "SELECT * FROM $table WHERE serialid = ?" :
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
    - $values_in : table record hashref
    parse all fields from a table, and replace values in title & content with the appropriate value
    (not exported sub, used only internally)

=cut

sub _parseletter {
    my ( $letter, $table, $values_in ) = @_;

    # Work on a local copy of $values_in (passed by reference) to avoid side effects
    # in callers ( by changing / formatting values )
    my $values = $values_in ? { %$values_in } : {};

    if ( $table eq 'borrowers' && $values->{'dateexpiry'} ){
        $values->{'dateexpiry'} = format_sqldatetime( $values->{'dateexpiry'} );
    }

    if ( $table eq 'reserves' && $values->{'waitingdate'} ) {
        $values->{'waitingdate'} = output_pref({ dt => dt_from_string( $values->{'waitingdate'} ), dateonly => 1 });
    }

    if ($letter->{content} && $letter->{content} =~ /<<today>>/) {
        my $todaysdate = output_pref( DateTime->now() );
        $letter->{content} =~ s/<<today>>/$todaysdate/go;
    }

    while ( my ($field, $val) = each %$values ) {
        $val =~ s/\p{P}$// if $val && $table=~/biblio/;
            #BZ 9886: Assuming that we want to eliminate ISBD punctuation here
            #Therefore adding the test on biblio. This includes biblioitems,
            #but excludes items. Removed unneeded global and lookahead.

        if ( $table=~/^borrowers$/ && $field=~/^streettype$/ ) {
            my $av = Koha::AuthorisedValues->search({ category => 'ROADTYPE', authorised_value => $val });
            $val = $av->count ? $av->next->lib : '';
        }

        # Dates replacement
        my $replacedby   = defined ($val) ? $val : '';
        if (    $replacedby
            and not $replacedby =~ m|0000-00-00|
            and not $replacedby =~ m|9999-12-31|
            and $replacedby =~ m|^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$| )
        {
            # If the value is XXXX-YY-ZZ[ AA:BB:CC] we assume it is a date
            my $dateonly = defined $1 ? 0 : 1; #$1 refers to the capture group wrapped in parentheses. In this case, that's the hours, minutes, seconds.
            my $re_dateonly_filter = qr{ $field( \s* \| \s* dateonly\s*)?>> }xms;

            for my $letter_field ( qw( title content ) ) {
                my $filter_string_used = q{};
                if ( $letter->{ $letter_field } =~ $re_dateonly_filter ) {
                    # We overwrite $dateonly if the filter exists and we have a time in the datetime
                    $filter_string_used = $1 || q{};
                    $dateonly = $1 unless $dateonly;
                }
                my $replacedby_date = eval {
                    output_pref({ dt => dt_from_string( $replacedby ), dateonly => $dateonly });
                };

                if ( $letter->{ $letter_field } ) {
                    $letter->{ $letter_field } =~ s/\Q<<$table.$field$filter_string_used>>\E/$replacedby_date/g;
                    $letter->{ $letter_field } =~ s/\Q<<$field$filter_string_used>>\E/$replacedby_date/g;
                }
            }
        }
        # Other fields replacement
        else {
            for my $letter_field ( qw( title content ) ) {
                if ( $letter->{ $letter_field } ) {
                    $letter->{ $letter_field }   =~ s/<<$table.$field>>/$replacedby/g;
                    $letter->{ $letter_field }   =~ s/<<$field>>/$replacedby/g;
                }
            }
        }
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

    my $sent = SendQueuedMessages({
        letter_code => $letter_code,
        borrowernumber => $who_letter_is_for,
        limit => 50,
        verbose => 1,
        type => 'sms',
    });

Sends all of the 'pending' items in the message queue, unless
parameters are passed.

The letter_code, borrowernumber and limit parameters are used
to build a parameter set for _get_unsent_messages, thus limiting
which pending messages will be processed. They are all optional.

The verbose parameter can be used to generate debugging output.
It is also optional.

Returns number of messages sent.

=cut

sub SendQueuedMessages {
    my $params = shift;

    my $which_unsent_messages  = {
        'limit'          => $params->{'limit'} // 0,
        'borrowernumber' => $params->{'borrowernumber'} // q{},
        'letter_code'    => $params->{'letter_code'} // q{},
        'type'           => $params->{'type'} // q{},
    };
    my $unsent_messages = _get_unsent_messages( $which_unsent_messages );
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
            if ( C4::Context->preference('SMSSendDriver') eq 'Email' ) {
                my $patron = Koha::Patrons->find( $message->{borrowernumber} );
                my $sms_provider = Koha::SMS::Providers->find( $patron->sms_provider_id );
                unless ( $sms_provider ) {
                    warn sprintf( "Patron %s has no sms provider id set!", $message->{'borrowernumber'} ) if $params->{'verbose'} or $debug;
                    _set_message_status( { message_id => $message->{'message_id'}, status => 'failed' } );
                    next MESSAGE;
                }
                unless ( $patron->smsalertnumber ) {
                    _set_message_status( { message_id => $message->{'message_id'}, status => 'failed' } );
                    warn sprintf( "No smsalertnumber found for patron %s!", $message->{'borrowernumber'} ) if $params->{'verbose'} or $debug;
                    next MESSAGE;
                }
                $message->{to_address}  = $patron->smsalertnumber; #Sometime this is set to email - sms should always use smsalertnumber
                $message->{to_address} .= '@' . $sms_provider->domain();
                _update_message_to_address($message->{'message_id'},$message->{to_address});
                _send_message_by_email( $message, $params->{'username'}, $params->{'password'}, $params->{'method'} );
            } else {
                _send_message_by_sms( $message );
            }
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

=head2 GetMessage

    my $message = C4::Letters::Message($message_id);

=cut

sub GetMessage {
    my ( $message_id ) = @_;
    return unless $message_id;
    my $dbh = C4::Context->dbh;
    return $dbh->selectrow_hashref(q|
        SELECT message_id, borrowernumber, subject, content, metadata, letter_code, message_transport_type, status, time_queued, to_address, from_address, content_type
        FROM message_queue
        WHERE message_id = ?
    |, {}, $message_id );
}

=head2 ResendMessage

  Attempt to resend a message which has failed previously.

  my $has_been_resent = C4::Letters::ResendMessage($message_id);

  Updates the message to 'pending' status so that
  it will be resent later on.

  returns 1 on success, 0 on failure, undef if no message was found

=cut

sub ResendMessage {
    my $message_id = shift;
    return unless $message_id;

    my $message = GetMessage( $message_id );
    return unless $message;
    my $rv = 0;
    if ( $message->{status} ne 'pending' ) {
        $rv = C4::Letters::_set_message_status({
            message_id => $message_id,
            status => 'pending',
        });
        $rv = $rv > 0? 1: 0;
        # Clear destination email address to force address update
        _update_message_to_address( $message_id, undef ) if $rv &&
            $message->{message_transport_type} eq 'email';
    }
    return $rv;
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

=head2 _get_unsent_messages

  This function's parameter hash reference takes the following
  optional named parameters:
   message_transport_type: method of message sending (e.g. email, sms, etc.)
   borrowernumber        : who the message is to be sent
   letter_code           : type of message being sent (e.g. PASSWORD_RESET)
   limit                 : maximum number of messages to send

  This function returns an array of matching hash referenced rows from
  message_queue with some borrower information added.

=cut

sub _get_unsent_messages {
    my $params = shift;

    my $dbh = C4::Context->dbh();
    my $statement = qq{
        SELECT mq.message_id, mq.borrowernumber, mq.subject, mq.content, mq.message_transport_type, mq.status, mq.time_queued, mq.from_address, mq.to_address, mq.content_type, b.branchcode, mq.letter_code
        FROM message_queue mq
        LEFT JOIN borrowers b ON b.borrowernumber = mq.borrowernumber
        WHERE status = ?
    };

    my @query_params = ('pending');
    if ( ref $params ) {
        if ( $params->{'message_transport_type'} ) {
            $statement .= ' AND mq.message_transport_type = ? ';
            push @query_params, $params->{'message_transport_type'};
        }
        if ( $params->{'borrowernumber'} ) {
            $statement .= ' AND mq.borrowernumber = ? ';
            push @query_params, $params->{'borrowernumber'};
        }
        if ( $params->{'letter_code'} ) {
            $statement .= ' AND mq.letter_code = ? ';
            push @query_params, $params->{'letter_code'};
        }
        if ( $params->{'type'} ) {
            $statement .= ' AND message_transport_type = ? ';
            push @query_params, $params->{'type'};
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

    my $patron = Koha::Patrons->find( $message->{borrowernumber} );
    my $to_address = $message->{'to_address'};
    unless ($to_address) {
        unless ($patron) {
            warn "FAIL: No 'to_address' and INVALID borrowernumber ($message->{borrowernumber})";
            _set_message_status( { message_id => $message->{'message_id'},
                                   status     => 'failed' } );
            return;
        }
        $to_address = $patron->notice_email_address;
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
    my $subject = encode('UTF-8', $message->{'subject'});
    my $content = encode('UTF-8', $message->{'content'});
    my $content_type = $message->{'content_type'} || 'text/plain; charset="UTF-8"';
    my $is_html = $content_type =~ m/html/io;
    my $branch_email = undef;
    my $branch_replyto = undef;
    my $branch_returnpath = undef;
    if ($patron) {
        my $library = $patron->library;
        $branch_email      = $library->branchemail;
        $branch_replyto    = $library->branchreplyto;
        $branch_returnpath = $library->branchreturnpath;
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
    if ( my $bcc = C4::Context->preference('NoticeBcc') ) {
       $sendmail_params{ Bcc } = $bcc;
    }

    _update_message_to_address($message->{'message_id'},$to_address) unless $message->{to_address}; #if initial message address was empty, coming here means that a to address was found and queue should be updated

    if ( Mail::Sendmail::sendmail( %sendmail_params ) ) {
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
    my $patron = Koha::Patrons->find( $message->{borrowernumber} );

    unless ( $patron and $patron->smsalertnumber ) {
        _set_message_status( { message_id => $message->{'message_id'},
                               status     => 'failed' } );
        return;
    }

    if ( _is_duplicate( $message ) ) {
        _set_message_status( { message_id => $message->{'message_id'},
                               status     => 'failed' } );
        return;
    }

    my $success = C4::SMS->send_sms( { destination => $patron->smsalertnumber,
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

sub _process_tt {
    my ( $params ) = @_;

    my $content = $params->{content};
    my $tables = $params->{tables};
    my $loops = $params->{loops};
    my $substitute = $params->{substitute} || {};

    my $use_template_cache = C4::Context->config('template_cache_dir') && defined $ENV{GATEWAY_INTERFACE};
    my $template           = Template->new(
        {
            EVAL_PERL    => 1,
            ABSOLUTE     => 1,
            PLUGIN_BASE  => 'Koha::Template::Plugin',
            COMPILE_EXT  => $use_template_cache ? '.ttc' : '',
            COMPILE_DIR  => $use_template_cache ? C4::Context->config('template_cache_dir') : '',
            FILTERS      => {},
            ENCODING     => 'UTF-8',
        }
    ) or die Template->error();

    my $tt_params = { %{ _get_tt_params( $tables ) }, %{ _get_tt_params( $loops, 'is_a_loop' ) }, %$substitute };

    $content = add_tt_filters( $content );
    $content = qq|[% USE KohaDates %][% USE Remove_MARC_punctuation %]$content|;

    my $output;
    $template->process( \$content, $tt_params, \$output ) || croak "ERROR PROCESSING TEMPLATE: " . $template->error();

    return $output;
}

sub _get_tt_params {
    my ($tables, $is_a_loop) = @_;

    my $params;
    $is_a_loop ||= 0;

    my $config = {
        article_requests => {
            module   => 'Koha::ArticleRequests',
            singular => 'article_request',
            plural   => 'article_requests',
            pk       => 'id',
          },
        biblio => {
            module   => 'Koha::Biblios',
            singular => 'biblio',
            plural   => 'biblios',
            pk       => 'biblionumber',
        },
        biblioitems => {
            module   => 'Koha::Biblioitems',
            singular => 'biblioitem',
            plural   => 'biblioitems',
            pk       => 'biblioitemnumber',
        },
        borrowers => {
            module   => 'Koha::Patrons',
            singular => 'borrower',
            plural   => 'borrowers',
            pk       => 'borrowernumber',
        },
        branches => {
            module   => 'Koha::Libraries',
            singular => 'branch',
            plural   => 'branches',
            pk       => 'branchcode',
        },
        items => {
            module   => 'Koha::Items',
            singular => 'item',
            plural   => 'items',
            pk       => 'itemnumber',
        },
        opac_news => {
            module   => 'Koha::News',
            singular => 'news',
            plural   => 'news',
            pk       => 'idnew',
        },
        aqorders => {
            module   => 'Koha::Acquisition::Orders',
            singular => 'order',
            plural   => 'orders',
            pk       => 'ordernumber',
        },
        reserves => {
            module   => 'Koha::Holds',
            singular => 'hold',
            plural   => 'holds',
            fk       => [ 'borrowernumber', 'biblionumber' ],
        },
        serial => {
            module   => 'Koha::Serials',
            singular => 'serial',
            plural   => 'serials',
            pk       => 'serialid',
        },
        subscription => {
            module   => 'Koha::Subscriptions',
            singular => 'subscription',
            plural   => 'subscriptions',
            pk       => 'subscriptionid',
        },
        suggestions => {
            module   => 'Koha::Suggestions',
            singular => 'suggestion',
            plural   => 'suggestions',
            pk       => 'suggestionid',
        },
        issues => {
            module   => 'Koha::Checkouts',
            singular => 'checkout',
            plural   => 'checkouts',
            fk       => 'itemnumber',
        },
        old_issues => {
            module   => 'Koha::Old::Checkouts',
            singular => 'old_checkout',
            plural   => 'old_checkouts',
            fk       => 'itemnumber',
        },
        overdues => {
            module   => 'Koha::Checkouts',
            singular => 'overdue',
            plural   => 'overdues',
            fk       => 'itemnumber',
        },
        borrower_modifications => {
            module   => 'Koha::Patron::Modifications',
            singular => 'patron_modification',
            plural   => 'patron_modifications',
            fk       => 'verification_token',
        },
    };

    foreach my $table ( keys %$tables ) {
        next unless $config->{$table};

        my $ref = ref( $tables->{$table} ) || q{};
        my $module = $config->{$table}->{module};

        if ( can_load( modules => { $module => undef } ) ) {
            my $pk = $config->{$table}->{pk};
            my $fk = $config->{$table}->{fk};

            if ( $is_a_loop ) {
                my $values = $tables->{$table} || [];
                unless ( ref( $values ) eq 'ARRAY' ) {
                    croak "ERROR processing table $table. Wrong API call.";
                }
                my $key = $pk ? $pk : $fk;
                # $key does not come from user input
                my $objects = $module->search(
                    { $key => $values },
                    {
                            # We want to retrieve the data in the same order
                            # FIXME MySQLism
                            # field is a MySQLism, but they are no other way to do it
                            # To be generic we could do it in perl, but we will need to fetch
                            # all the data then order them
                        @$values ? ( order_by => \[ "field($key, " . join( ', ', @$values ) . ")" ] ) : ()
                    }
                );
                $params->{ $config->{$table}->{plural} } = $objects;
            }
            elsif ( $ref eq q{} || $ref eq 'HASH' ) {
                my $id = ref $ref eq 'HASH' ? $tables->{$table}->{$pk} : $tables->{$table};
                my $object;
                if ( $fk ) { # Using a foreign key for lookup
                    if ( ref( $fk ) eq 'ARRAY' ) { # Foreign key is multi-column
                        my $search;
                        foreach my $key ( @$fk ) {
                            $search->{$key} = $id->{$key};
                        }
                        $object = $module->search( $search )->last();
                    } else { # Foreign key is single column
                        $object = $module->search( { $fk => $id } )->last();
                    }
                } else { # using the table's primary key for lookup
                    $object = $module->find($id);
                }
                $params->{ $config->{$table}->{singular} } = $object;
            }
            else {    # $ref eq 'ARRAY'
                my $object;
                if ( @{ $tables->{$table} } == 1 ) {    # Param is a single key
                    $object = $module->search( { $pk => $tables->{$table} } )->last();
                }
                else {                                  # Params are mutliple foreign keys
                    croak "Multiple foreign keys (table $table) should be passed using an hashref";
                }
                $params->{ $config->{$table}->{singular} } = $object;
            }
        }
        else {
            croak "ERROR LOADING MODULE $module: $Module::Load::Conditional::ERROR";
        }
    }

    $params->{today} = output_pref({ dt => dt_from_string, dateformat => 'iso' });

    return $params;
}

=head3 add_tt_filters

$content = add_tt_filters( $content );

Add TT filters to some specific fields if needed.

For now we only add the Remove_MARC_punctuation TT filter to biblio and biblioitem fields

=cut

sub add_tt_filters {
    my ( $content ) = @_;
    $content =~ s|\[%\s*biblio\.(.*?)\s*%\]|[% biblio.$1 \| \$Remove_MARC_punctuation %]|gxms;
    $content =~ s|\[%\s*biblioitem\.(.*?)\s*%\]|[% biblioitem.$1 \| \$Remove_MARC_punctuation %]|gxms;
    return $content;
}

=head2 get_item_content

    my $item = Koha::Items->find(...)->unblessed;
    my @item_content_fields = qw( date_due title barcode author itemnumber );
    my $item_content = C4::Letters::get_item_content({
                             item => $item,
                             item_content_fields => \@item_content_fields
                       });

This function generates a tab-separated list of values for the passed item. Dates
are formatted following the current setup.

=cut

sub get_item_content {
    my ( $params ) = @_;
    my $item = $params->{item};
    my $dateonly = $params->{dateonly} || 0;
    my $item_content_fields = $params->{item_content_fields} || [];

    return unless $item;

    my @item_info = map {
        $_ =~ /^date|date$/
          ? eval {
            output_pref(
                { dt => dt_from_string( $item->{$_} ), dateonly => $dateonly } );
          }
          : $item->{$_}
          || ''
    } @$item_content_fields;
    return join( "\t", @item_info ) . "\n";
}

1;
__END__
