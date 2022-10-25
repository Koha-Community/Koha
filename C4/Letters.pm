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

use Carp qw( carp croak );
use Template;
use Module::Load::Conditional qw( can_load );

use Try::Tiny;

use C4::Members;
use C4::Log qw( logaction );
use C4::SMS;
use C4::Templates;
use Koha::SMS::Providers;

use Koha::Email;
use Koha::Notice::Messages;
use Koha::Notice::Templates;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Auth::TwoFactorAuth;
use Koha::Patrons;
use Koha::SMTP::Servers;
use Koha::Subscriptions;

use constant SERIALIZED_EMAIL_CONTENT_TYPE => 'message/rfc822';

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
      GetLetters
      GetLettersAvailableForALibrary
      GetLetterTemplates
      DelLetter
      GetPreparedLetter
      GetWrappedLetter
      SendAlerts
      GetPrintMessages
      GetQueuedMessages
      GetMessage
      GetMessageTransportTypes

      EnqueueLetter
      SendQueuedMessages
      ResendMessage
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
    return Koha::Notice::Templates->search(
        {
            module     => $module,
            code       => $code,
            branchcode => $branchcode,
            (
                C4::Context->preference('TranslateNotices')
                ? ()
                : ( lang => 'default' )
            )
        }
    )->unblessed;
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
    my $error;

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

        # find the list of subscribers to notify
        my $subscription = Koha::Subscriptions->find( $subscriptionid );
        my $subscribers = $subscription->subscribers;
        while ( my $patron = $subscribers->next ) {
            my $email = $patron->email or next;

#                    warn "sending issues...";
            my $userenv = C4::Context->userenv;
            my $library = $patron->library;
            my $letter = GetPreparedLetter (
                module => 'serial',
                letter_code => $letter_code,
                branchcode => $userenv->{branch},
                tables => {
                    'branches'    => $library->branchcode,
                    'biblio'      => $biblionumber,
                    'biblioitems' => $biblionumber,
                    'borrowers'   => $patron->unblessed,
                    'subscription' => $subscriptionid,
                    'serial' => $externalid,
                },
                want_librarian => 1,
            ) or return;

            # FIXME: This 'default' behaviour should be moved to Koha::Email
            my $mail = Koha::Email->create(
                {
                    to       => $email,
                    from     => $library->branchemail,
                    reply_to => $library->branchreplyto,
                    sender   => $library->branchreturnpath,
                    subject  => "" . $letter->{title},
                }
            );

            if ( $letter->{is_html} ) {
                $mail->html_body( _wrap_html( $letter->{content}, "" . $letter->{title} ) );
            }
            else {
                $mail->text_body( $letter->{content} );
            }

            my $success = try {
                $mail->send_or_die({ transport => $library->smtp_server->transport });
            }
            catch {
                # We expect ref($_) eq 'Email::Sender::Failure'
                $error = $_->message;

                carp "$_";
                return;
            };

            return { error => $error }
                unless $success;
        }
    }
    elsif ( $type eq 'claimacquisition' or $type eq 'claimissues' or $type eq 'orderacquisition' ) {

        # prepare the letter...
        my $strsth;
        my $sthorders;
        my $dataorders;
        my $action;
        my $basketno;
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
            SELECT serial.*,subscription.*, biblio.*, biblioitems.*, aqbooksellers.*,
            aqbooksellers.id AS booksellerid
            FROM serial
            LEFT JOIN subscription ON serial.subscriptionid=subscription.subscriptionid
            LEFT JOIN biblio ON serial.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON serial.biblionumber = biblioitems.biblionumber
            LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
            WHERE serial.serialid IN (
            };

            if (!@$externalid){
                carp "No issues selected";
                return { error => "no_issues_selected" };
            }

            $strsth .= join( ",", ('?') x @$externalid ) . ")";
            $action = "SERIAL CLAIM";
            $sthorders = $dbh->prepare($strsth);
            $sthorders->execute( @$externalid );
            $dataorders = $sthorders->fetchall_arrayref( {} );
        }

        if ( $type eq 'orderacquisition') {
            $basketno = $externalid;
            $strsth = qq{
            SELECT aqorders.*,aqbasket.*,biblio.*,biblioitems.*
            FROM aqorders
            LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
            LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON aqorders.biblionumber=biblioitems.biblionumber
            WHERE aqbasket.basketno = ?
            AND orderstatus IN ('new','ordered')
            };

            unless ( $basketno ) {
                carp "No basketnumber given";
                return { error => "no_basketno" };
            }
            $action = "ACQUISITION ORDER";
            $sthorders = $dbh->prepare($strsth);
            $sthorders->execute($basketno);
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
                'branches'      => $userenv->{branch},
                'aqbooksellers' => $databookseller,
                'aqcontacts'    => $datacontact,
                'aqbasket'      => $basketno,
            },
            repeat => $dataorders,
            want_librarian => 1,
        ) or return { error => "no_letter" };

        # Remove the order tag
        $letter->{content} =~ s/<order>(.*?)<\/order>/$1/gxms;

        # ... then send mail
        my $library = Koha::Libraries->find( $userenv->{branch} );
        my $mail = Koha::Email->create(
            {
                to => join( ',', @email ),
                cc => join( ',', @cc ),
                (
                    (
                        C4::Context->preference("ClaimsBccCopy")
                          && ( $type eq 'claimacquisition'
                            || $type eq 'claimissues' )
                    )
                    ? ( bcc => $userenv->{emailaddress} )
                    : ()
                ),
                from => $library->branchemail
                  || C4::Context->preference('KohaAdminEmailAddress'),
                subject => "" . $letter->{title},
            }
        );

        if ( $letter->{is_html} ) {
            $mail->html_body( _wrap_html( $letter->{content}, "" . $letter->{title} ) );
        }
        else {
            $mail->text_body( "" . $letter->{content} );
        }

        my $success = try {
            $mail->send_or_die({ transport => $library->smtp_server->transport });
        }
        catch {
            # We expect ref($_) eq 'Email::Sender::Failure'
            $error = $_->message;

            carp "$_";
            return;
        };

        return { error => $error }
            unless $success;

        my $log_object = $action eq 'ACQUISITION ORDER' ? $externalid : undef;
        my $module = $action eq 'ACQUISITION ORDER' ? 'ACQUISITIONS' : 'CLAIMS';
        logaction(
            $module,
            $action,
            $log_object,
            "To="
                . join( ',', @email )
                . " Title="
                . $letter->{title}
                . " Content="
                . $letter->{content}
        ) if C4::Context->preference("ClaimsLog");
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
    my $lang   = $params{lang} || 'default';

    unless ( $letter ) {
        my $module      = $params{module} or croak "No module";
        my $letter_code = $params{letter_code} or croak "No letter_code";
        my $branchcode  = $params{branchcode} || '';
        my $mtt         = $params{message_transport_type} || 'email';

        my $template = Koha::Notice::Templates->find_effective_template(
            {
                module                 => $module,
                code                   => $letter_code,
                branchcode             => $branchcode,
                message_transport_type => $mtt,
                lang                   => $lang
            }
        );

        unless ( $template ) {
            warn( "No $module $letter_code letter transported by " . $mtt );
            return;
        }

        $letter = $template->unblessed;
        $letter->{'content-type'} = 'text/html; charset="UTF-8"' if $letter->{is_html};
    }

    my $objects = $params{objects} || {};
    my $tables = $params{tables} || {};
    my $substitute = $params{substitute} || {};
    my $loops  = $params{loops} || {}; # loops is not supported for historical notices syntax
    my $repeat = $params{repeat};
    %$tables || %$substitute || $repeat || %$loops || %$objects
      or carp( "ERROR: nothing to substitute - all of 'objects', 'tables', 'loops' and 'substitute' are empty" ),
         return;
    my $want_librarian = $params{want_librarian};

    if (%$substitute) {
        while ( my ($token, $val) = each %$substitute ) {
            $val //= q{};
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
            content    => $letter->{content},
            lang       => $lang,
            loops      => $loops,
            objects    => $objects,
            substitute => $substitute,
            tables     => $tables,
        }
    );

    $letter->{title} = _process_tt(
        {
            content    => $letter->{title},
            lang       => $lang,
            loops      => $loops,
            objects    => $objects,
            substitute => $substitute,
            tables     => $tables,
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
    ($table eq 'accountlines' )    ? "SELECT * FROM $table WHERE   accountlines_id = ?"                               :
    ($table eq 'biblio'       )    ? "SELECT * FROM $table WHERE   biblionumber = ?"                                  :
    ($table eq 'biblioitems'  )    ? "SELECT * FROM $table WHERE   biblionumber = ?"                                  :
    ($table eq 'tickets'      )    ? "SELECT * FROM $table WHERE   id = ?"                                            :
    ($table eq 'credits'      )    ? "SELECT * FROM accountlines WHERE   accountlines_id = ?"                         :
    ($table eq 'debits'       )    ? "SELECT * FROM accountlines WHERE   accountlines_id = ?"                         :
    ($table eq 'items'        )    ? "SELECT * FROM $table WHERE     itemnumber = ?"                                  :
    ($table eq 'issues'       )    ? "SELECT * FROM $table WHERE     itemnumber = ?"                                  :
    ($table eq 'old_issues'   )    ? "SELECT * FROM $table WHERE     issue_id = ?"  :
    ($table eq 'reserves'     )    ? "SELECT * FROM $table WHERE borrowernumber = ? and biblionumber = ?"             :
    ($table eq 'borrowers'    )    ? "SELECT * FROM $table WHERE borrowernumber = ?"                                  :
    ($table eq 'branches'     )    ? "SELECT * FROM $table WHERE     branchcode = ?"                                  :
    ($table eq 'suggestions'  )    ? "SELECT * FROM $table WHERE   suggestionid = ?"                                  :
    ($table eq 'aqbooksellers')    ? "SELECT * FROM $table WHERE             id = ?"                                  :
    ($table eq 'aqorders'     )    ? "SELECT * FROM $table WHERE    ordernumber = ?"                                  :
    ($table eq 'aqbasket'     )    ? "SELECT * FROM $table WHERE       basketno = ?"                                  :
    ($table eq 'illrequests'  )    ? "SELECT * FROM $table WHERE  illrequest_id = ?"                                  :
    ($table eq 'article_requests') ? "SELECT * FROM $table WHERE             id = ?"                                  :
    ($table eq 'borrower_modifications') ? "SELECT * FROM $table WHERE verification_token = ?" :
    ($table eq 'subscription') ? "SELECT * FROM $table WHERE subscriptionid = ?" :
    ($table eq 'serial') ? "SELECT * FROM $table WHERE serialid = ?" :
    ($table eq 'problem_reports') ? "SELECT * FROM $table WHERE reportid = ?" :
    ($table eq 'additional_contents' || $table eq 'opac_news') ? "SELECT * FROM additional_contents WHERE idnew = ?" :
    ($table eq 'recalls') ? "SELECT * FROM $table WHERE recall_id = ?" :
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

    # FIXME Dates formatting must be done in notice's templates
    if ( $table eq 'borrowers' && $values->{'dateexpiry'} ){
        $values->{'dateexpiry'} = output_pref({ dt => dt_from_string( $values->{'dateexpiry'} ), dateonly => 1 });
    }

    if ( $table eq 'reserves' && $values->{'waitingdate'} ) {
        $values->{'waitingdate'} = output_pref({ dt => dt_from_string( $values->{'waitingdate'} ), dateonly => 1 });
    }

    if ($letter->{content} && $letter->{content} =~ /<<today>>/) {
        my $todaysdate = output_pref( dt_from_string() );
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
                    output_pref({ dt => scalar dt_from_string( $replacedby ), dateonly => $dateonly });
                };
                $replacedby_date //= q{};

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
        my $patron = Koha::Patrons->find( $values->{borrowernumber} );
        if ( $patron ) {
            my $attributes = $patron->extended_attributes;
            my %attr;
            while ( my $attribute = $attributes->next ) {
                my $code = $attribute->code;
                my $val  = $attribute->description; # FIXME - we always display intranet description here!
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

Places a letter in the message_queue database table, which will
eventually get processed (sent) by the process_message_queue.pl
cronjob when it calls SendQueuedMessages.

Return message_id on success

Parameters
* letter - required; A letter hashref as returned from GetPreparedLetter
* message_transport_type - required; One of the available mtts
* borrowernumber - optional if 'to_address' is passed; The borrowernumber of the patron we enqueuing the notice for
* to_address - optional if 'borrowernumber' is passed; The destination email address for the notice (defaults to patron->notice_email_address)
* from_address - optional; The from address for the notice, defaults to patron->library->from_email_address
* reply_address - optional; The reply address for the notice, defaults to patron->library->reply_to

=cut

sub EnqueueLetter {
    my $params = shift or return;

    return unless exists $params->{'letter'};
#   return unless exists $params->{'borrowernumber'};
    return unless exists $params->{'message_transport_type'};

    my $content = $params->{letter}->{content};
    $content =~ s/\s+//g if(defined $content);
    if ( not defined $content or $content eq '' ) {
        Koha::Logger->get->info("Trying to add an empty message to the message queue");
        return;
    }

    # If we have any attachments we should encode then into the body.
    if ( $params->{'attachments'} ) {
        $params->{'letter'} = _add_attachments(
            {   letter      => $params->{'letter'},
                attachments => $params->{'attachments'},
            }
        );
    }

    my $dbh       = C4::Context->dbh();
    my $statement = << 'ENDSQL';
INSERT INTO message_queue
( letter_id, borrowernumber, subject, content, metadata, letter_code, message_transport_type, status, time_queued, to_address, from_address, reply_address, content_type, failure_code )
VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, CAST(NOW() AS DATETIME), ?, ?, ?, ?, ? )
ENDSQL

    my $sth    = $dbh->prepare($statement);
    my $result = $sth->execute(
        $params->{letter}->{id} || undef,         # letter.id
        $params->{'borrowernumber'},              # borrowernumber
        $params->{'letter'}->{'title'},           # subject
        $params->{'letter'}->{'content'},         # content
        $params->{'letter'}->{'metadata'} || '',  # metadata
        $params->{'letter'}->{'code'}     || '',  # letter_code
        $params->{'message_transport_type'},      # message_transport_type
        'pending',                                # status
        $params->{'to_address'},                  # to_address
        $params->{'from_address'},                # from_address
        $params->{'reply_address'},               # reply_address
        $params->{'letter'}->{'content-type'},    # content_type
        $params->{'failure_code'}        || '',   # failure_code
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

    my $which_unsent_messages = {
        'message_id'             => $params->{'message_id'},
        'limit'                  => $params->{'limit'} // 0,
        'borrowernumber'         => $params->{'borrowernumber'} // q{},
        'letter_code'            => $params->{'letter_code'} // q{},
        'message_transport_type' => $params->{'type'} // q{},
        'where'                  => $params->{'where'} // q{},
    };
    my $unsent_messages = _get_unsent_messages( $which_unsent_messages );
    MESSAGE: foreach my $message ( @$unsent_messages ) {
        my $message_object = Koha::Notice::Messages->find( $message->{message_id} );
        # If this fails the database is unwritable and we won't manage to send a message that continues to be marked 'pending'
        $message_object->make_column_dirty('status');
        return unless $message_object->store;

        # warn Data::Dumper->Dump( [ $message ], [ 'message' ] );
        warn sprintf( 'sending %s message to patron: %s',
                      $message->{'message_transport_type'},
                      $message->{'borrowernumber'} || 'Admin' )
          if $params->{'verbose'};
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
                    warn sprintf( "Patron %s has no sms provider id set!", $message->{'borrowernumber'} ) if $params->{'verbose'};
                    _set_message_status( { message_id => $message->{'message_id'}, status => 'failed' } );
                    next MESSAGE;
                }
                unless ( $patron->smsalertnumber ) {
                    _set_message_status( { message_id => $message->{'message_id'}, status => 'failed' } );
                    warn sprintf( "No smsalertnumber found for patron %s!", $message->{'borrowernumber'} ) if $params->{'verbose'};
                    next MESSAGE;
                }
                $message->{to_address}  = $patron->smsalertnumber; #Sometime this is set to email - sms should always use smsalertnumber
                $message->{to_address} .= '@' . $sms_provider->domain();

                # Check for possible from_address override
                my $from_address = C4::Context->preference('EmailSMSSendDriverFromAddress');
                if ($from_address && $message->{from_address} ne $from_address) {
                    $message->{from_address} = $from_address;
                    _update_message_from_address($message->{'message_id'}, $message->{from_address});
                }

                _update_message_to_address($message->{'message_id'}, $message->{to_address});
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

Fetches a list of messages from the message queue optionally filtered by borrowernumber
and limited to specified limit.

Return is an arrayref of hashes, each has represents a message in the message queue.

=cut

sub GetQueuedMessages {
    my $params = shift;

    my $dbh = C4::Context->dbh();
    my $statement = << 'ENDSQL';
SELECT message_id, borrowernumber, subject, content, message_transport_type, status, time_queued, updated_on, failure_code
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
        SELECT message_id, borrowernumber, subject, content, metadata, letter_code, message_transport_type, status, time_queued, updated_on, to_address, from_address, reply_address, content_type, failure_code
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

  _add_attachments({ letter => $letter, attachments => $attachments });

  named parameters:
  letter - the standard letter hashref
  attachments - listref of attachments. each attachment is a hashref of:
    type - the mime type, like 'text/plain'
    content - the actual attachment
    filename - the name of the attachment.

  returns your letter object, with the content updated.
  This routine picks the I<content> of I<letter> and generates a MIME
  email, attaching the passed I<attachments> using Koha::Email. The
  content is replaced by the string representation of the MIME object,
  and the content-type is updated for later handling.

=cut

sub _add_attachments {
    my $params = shift;

    my $letter = $params->{letter};
    my $attachments = $params->{attachments};
    return $letter unless @$attachments;

    my $message = Koha::Email->new;

    if ( $letter->{is_html} ) {
        $message->html_body( _wrap_html( $letter->{content}, $letter->{title} ) );
    }
    else {
        $message->text_body( $letter->{content} );
    }

    foreach my $attachment ( @$attachments ) {
        $message->attach(
            Encode::encode( "UTF-8", $attachment->{content} ),
            content_type => $attachment->{type} || 'application/octet-stream',
            name         => $attachment->{filename},
            disposition  => 'attachment',
        );
    }

    $letter->{'content-type'} = SERIALIZED_EMAIL_CONTENT_TYPE;
    $letter->{content} = $message->as_string;

    return $letter;

}

=head2 _get_unsent_messages

  This function's parameter hash reference takes the following
  optional named parameters:
   message_transport_type: method of message sending (e.g. email, sms, etc.)
                           Can be a single string, or an arrayref of strings
   borrowernumber        : who the message is to be sent
   letter_code           : type of message being sent (e.g. PASSWORD_RESET)
                           Can be a single string, or an arrayref of strings
   message_id            : the message_id of the message. In that case the sub will return only 1 result
   limit                 : maximum number of messages to send

  This function returns an array of matching hash referenced rows from
  message_queue with some borrower information added.

=cut

sub _get_unsent_messages {
    my $params = shift;

    my $dbh = C4::Context->dbh();
    my $statement = qq{
        SELECT mq.message_id, mq.borrowernumber, mq.subject, mq.content, mq.message_transport_type, mq.status, mq.time_queued, mq.from_address, mq.reply_address, mq.to_address, mq.content_type, b.branchcode, mq.letter_code, mq.failure_code
        FROM message_queue mq
        LEFT JOIN borrowers b ON b.borrowernumber = mq.borrowernumber
        WHERE status = ?
    };

    my @query_params = ('pending');
    if ( ref $params ) {
        if ( $params->{'borrowernumber'} ) {
            $statement .= ' AND mq.borrowernumber = ? ';
            push @query_params, $params->{'borrowernumber'};
        }
        if ( $params->{'letter_code'} ) {
            my @letter_codes = ref $params->{'letter_code'} eq "ARRAY" ? @{$params->{'letter_code'}} : $params->{'letter_code'};
            if ( @letter_codes ) {
                my $q = join( ",", ("?") x @letter_codes );
                $statement .= " AND mq.letter_code IN ( $q ) ";
                push @query_params, @letter_codes;
            }
        }
        if ( $params->{'message_transport_type'} ) {
            my @types = ref $params->{'message_transport_type'} eq "ARRAY" ? @{$params->{'message_transport_type'}} : $params->{'message_transport_type'};
            if ( @types ) {
                my $q = join( ",", ("?") x @types );
                $statement .= " AND message_transport_type IN ( $q ) ";
                push @query_params, @types;
            }
        }
        if ( $params->{message_id} ) {
            $statement .= ' AND message_id = ?';
            push @query_params, $params->{message_id};
        }
        if ( $params->{where} ) {
            $statement .= " AND $params->{where} ";
        }
        if ( $params->{'limit'} ) {
            $statement .= ' limit ? ';
            push @query_params, $params->{'limit'};
        }
    }

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
            _set_message_status(
                {
                    message_id   => $message->{'message_id'},
                    status       => 'failed',
                    failure_code => 'INVALID_BORNUMBER'
                }
            );
            return;
        }
        $to_address = $patron->notice_email_address;
        unless ($to_address) {  
            # warn "FAIL: No 'to_address' and no email for " . ($member->{surname} ||'') . ", borrowernumber ($message->{borrowernumber})";
            # warning too verbose for this more common case?
            _set_message_status(
                {
                    message_id   => $message->{'message_id'},
                    status       => 'failed',
                    failure_code => 'NO_EMAIL'
                }
            );
            return;
        }
    }

    my $subject = $message->{'subject'};

    my $content = $message->{'content'};
    my $content_type = $message->{'content_type'} || 'text/plain; charset="UTF-8"';
    my $is_html = $content_type =~ m/html/io;

    my $branch_email = undef;
    my $branch_replyto = undef;
    my $branch_returnpath = undef;
    my $library;

    if ($patron) {
        $library           = $patron->library;
        $branch_email      = $library->from_email_address;
        $branch_replyto    = $library->branchreplyto;
        $branch_returnpath = $library->branchreturnpath;
    }

    # NOTE: Patron may not be defined above so branch_email may be undefined still
    # so we need to fallback to KohaAdminEmailAddress as a last resort.
    my $from_address =
         $message->{'from_address'}
      || $branch_email
      || C4::Context->preference('KohaAdminEmailAddress');
    if( !$from_address ) {
        _set_message_status(
            {
                message_id   => $message->{'message_id'},
                status       => 'failed',
                failure_code => 'NO_FROM',
            }
        );
        return;
    };
    my $email;

    try {

        my $params = {
            to => $to_address,
            (
                C4::Context->preference('NoticeBcc')
                ? ( bcc => C4::Context->preference('NoticeBcc') )
                : ()
            ),
            from     => $from_address,
            reply_to => $message->{'reply_address'} || $branch_replyto,
            sender   => $branch_returnpath,
            subject  => "" . $message->{subject}
        };

        if ( $message->{'content_type'} && $message->{'content_type'} eq SERIALIZED_EMAIL_CONTENT_TYPE ) {

            # The message has been previously composed as a valid MIME object
            # and serialized as a string on the DB
            $email = Koha::Email->new_from_string($content);
            $email->create($params);
        } else {
            $email = Koha::Email->create($params);
            if ($is_html) {
                $email->html_body( _wrap_html( $content, $subject ) );
            } else {
                $email->text_body($content);
            }
        }
    }
    catch {
        if ( ref($_) eq 'Koha::Exceptions::BadParameter' ) {
            _set_message_status(
                {
                    message_id   => $message->{'message_id'},
                    status       => 'failed',
                    failure_code => "INVALID_EMAIL:".$_->parameter
                }
            );
        } else {
            _set_message_status(
                {
                    message_id   => $message->{'message_id'},
                    status       => 'failed',
                    failure_code => 'UNKNOWN_ERROR'
                }
            );
        }
        return 0;
    };
    return unless $email;

    my $smtp_server;
    if ( $library ) {
        $smtp_server = $library->smtp_server;
    }
    else {
        $smtp_server = Koha::SMTP::Servers->get_default;
    }

    if ( $username ) {
        $smtp_server->set(
            {
                sasl_username => $username,
                sasl_password => $password,
            }
        );
    }

# if initial message address was empty, coming here means that a to address was found and
# queue should be updated; same if to address was overriden by Koha::Email->create
    _update_message_to_address( $message->{'message_id'}, $email->email->header('To') )
      if !$message->{to_address}
      || $message->{to_address} ne $email->email->header('To');

    try {
        $email->send_or_die({ transport => $smtp_server->transport });

        _set_message_status(
            {
                message_id => $message->{'message_id'},
                status     => 'sent',
                failure_code => ''
            }
        );
        return 1;
    }
    catch {
        _set_message_status(
            {
                message_id => $message->{'message_id'},
                status     => 'failed',
                failure_code => 'SENDMAIL'
            }
        );
        carp "$_";
        carp "$Mail::Sendmail::error";
        return;
    };
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
        AND CAST(updated_on AS date) = CAST(NOW() AS date)
        AND status="sent"
        AND content = ?
    |, {}, $message->{message_transport_type}, $message->{borrowernumber}, $message->{letter_code}, $message->{content} );
    return $count;
}

sub _send_message_by_sms {
    my $message = shift or return;
    my $patron = Koha::Patrons->find( $message->{borrowernumber} );
    _update_message_to_address($message->{message_id}, $patron->smsalertnumber) if $patron;

    unless ( $patron and $patron->smsalertnumber ) {
        _set_message_status( { message_id => $message->{'message_id'},
                               status     => 'failed',
                               failure_code => 'MISSING_SMS' } );
        return;
    }

    if ( _is_duplicate( $message ) ) {
        _set_message_status(
            {
                message_id   => $message->{'message_id'},
                status       => 'failed',
                failure_code => 'DUPLICATE_MESSAGE'
            }
        );
        return;
    }

    my $success = C4::SMS->send_sms(
        {
            destination => $patron->smsalertnumber,
            message     => $message->{'content'},
        }
    );

    if ($success) {
        _set_message_status(
            {
                message_id   => $message->{'message_id'},
                status       => 'sent',
                failure_code => ''
            }
        );
    }
    else {
        _set_message_status(
            {
                message_id   => $message->{'message_id'},
                status       => 'failed',
                failure_code => 'NO_NOTES'
            }
        );
    }

    return $success;
}

sub _update_message_to_address {
    my ($id, $to)= @_;
    my $dbh = C4::Context->dbh();
    $dbh->do('UPDATE message_queue SET to_address=? WHERE message_id=?',undef,($to,$id));
}

sub _update_message_from_address {
    my ($message_id, $from_address) = @_;
    my $dbh = C4::Context->dbh();
    $dbh->do('UPDATE message_queue SET from_address = ? WHERE message_id = ?', undef, ($from_address, $message_id));
}

sub _set_message_status {
    my $params = shift or return;

    foreach my $required_parameter ( qw( message_id status ) ) {
        return unless exists $params->{ $required_parameter };
    }

    my $dbh = C4::Context->dbh();
    my $statement = 'UPDATE message_queue SET status= ?, failure_code= ? WHERE message_id = ?';
    my $sth = $dbh->prepare( $statement );
    my $result = $sth->execute( $params->{'status'},
                                $params->{'failure_code'} || '',
                                $params->{'message_id'} );
    return $result;
}

sub _process_tt {
    my ( $params ) = @_;

    my $content    = $params->{content};
    my $tables     = $params->{tables};
    my $loops      = $params->{loops};
    my $objects    = $params->{objects} || {};
    my $substitute = $params->{substitute} || {};
    my $lang = defined($params->{lang}) && $params->{lang} ne 'default' ? $params->{lang} : 'en';
    my ($theme, $availablethemes);

    my $htdocs = C4::Context->config('intrahtdocs');
    ($theme, $lang, $availablethemes)= C4::Templates::availablethemes( $htdocs, 'about.tt', 'intranet', $lang);
    my @includes;
    foreach (@$availablethemes) {
        push @includes, "$htdocs/$_/$lang/includes";
        push @includes, "$htdocs/$_/en/includes" unless $lang eq 'en';
    }

    my $use_template_cache = C4::Context->config('template_cache_dir') && defined $ENV{GATEWAY_INTERFACE};
    my $template           = Template->new(
        {
            EVAL_PERL    => 1,
            ABSOLUTE     => 1,
            PLUGIN_BASE  => 'Koha::Template::Plugin',
            COMPILE_EXT  => $use_template_cache ? '.ttc' : '',
            COMPILE_DIR  => $use_template_cache ? C4::Context->config('template_cache_dir') : '',
            INCLUDE_PATH => \@includes,
            FILTERS      => {},
            ENCODING     => 'UTF-8',
        }
    ) or die Template->error();

    my $tt_params = { %{ _get_tt_params( $tables ) }, %{ _get_tt_params( $loops, 'is_a_loop' ) }, %$substitute, %$objects };

    $content = add_tt_filters( $content );
    $content = qq|[% USE KohaDates %][% USE Remove_MARC_punctuation %][% PROCESS 'html_helpers.inc' %]$content|;

    my $output;
    my $schema = Koha::Database->new->schema;
    $schema->txn_begin;
    my $processed = try {
        $template->process( \$content, $tt_params, \$output );
    }
    finally {
        $schema->txn_rollback;
    };
    croak "ERROR PROCESSING TEMPLATE: " . $template->error() unless $processed;

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
        aqbasket => {
            module   => 'Koha::Acquisition::Baskets',
            singular => 'basket',
            plural   => 'baskets',
            pk       => 'basketno',
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
        credits => {
            module => 'Koha::Account::Lines',
            singular => 'credit',
            plural => 'credits',
            pk => 'accountlines_id',
        },
        debits => {
            module => 'Koha::Account::Lines',
            singular => 'debit',
            plural => 'debits',
            pk => 'accountlines_id',
        },
        items => {
            module   => 'Koha::Items',
            singular => 'item',
            plural   => 'items',
            pk       => 'itemnumber',
        },
        additional_contents => {
            module   => 'Koha::AdditionalContents',
            singular => 'additional_content',
            plural   => 'additional_contents',
            pk       => 'idnew',
        },
        opac_news => {
            module   => 'Koha::AdditionalContents',
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
            pk       => 'reserve_id',
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
        tickets => {
            module   => 'Koha::Tickets',
            singular => 'ticket',
            plural   => 'tickets',
            pk       => 'id',
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
            pk       => 'issue_id',
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
        illrequests => {
            module   => 'Koha::Illrequests',
            singular => 'illrequest',
            plural   => 'illrequests',
            pk       => 'illrequest_id'
        }
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
