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

use C4::Members;
use C4::Members::Attributes qw(GetBorrowerAttributes);
use C4::Branch;
use C4::Log;
use C4::SMS;
use C4::Debug;
use Date::Calc qw( Add_Delta_Days );
use Encode;
use Unicode::Normalize;
use Carp;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	require Exporter;
	# set the version for version checking
    $VERSION = 3.07.00.049;
	@ISA = qw(Exporter);
	@EXPORT = qw(
	&GetLetters &GetPreparedLetter &GetWrappedLetter &addalert &getalert &delalert &findrelatedto &SendAlerts &GetPrintMessages
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

=head2 GetLetters([$category])

  $letters = &GetLetters($category);
  returns informations about letters.
  if needed, $category filters for letters given category
  Create a letter selector with the following code

=head3 in PERL SCRIPT

my $letters = GetLetters($cat);
my @letterloop;
foreach my $thisletter (keys %$letters) {
    my $selected = 1 if $thisletter eq $letter;
    my %row =(
        value => $thisletter,
        selected => $selected,
        lettername => $letters->{$thisletter},
    );
    push @letterloop, \%row;
}
$template->param(LETTERLOOP => \@letterloop);

=head3 in TEMPLATE

    <select name="letter">
        <option value="">Default</option>
    <!-- TMPL_LOOP name="LETTERLOOP" -->
        <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="lettername" --></option>
    <!-- /TMPL_LOOP -->
    </select>

=cut

sub GetLetters {

    # returns a reference to a hash of references to ALL letters...
    my $cat = shift;
    my %letters;
    my $dbh = C4::Context->dbh;
    my $sth;
    if (defined $cat) {
        my $query = "SELECT * FROM letter WHERE module = ? ORDER BY name";
        $sth = $dbh->prepare($query);
        $sth->execute($cat);
    }
    else {
        my $query = "SELECT * FROM letter ORDER BY name";
        $sth = $dbh->prepare($query);
        $sth->execute;
    }
    while ( my $letter = $sth->fetchrow_hashref ) {
        $letters{ $letter->{'code'} } = $letter->{'name'};
    }
    return \%letters;
}

=head2 GetLetter( %params )

    retrieves the letter template

    %params hash:
      module => letter module, mandatory
      letter_code => letter code, mandatory
      branchcode => for letter selection, if missing default system letter taken
    Return value:
      letter fields hashref (title & content useful)

=cut

sub GetLetter {
    my %params = @_;

    my $module      = $params{module} or croak "No module";
    my $letter_code = $params{letter_code} or croak "No letter_code";
    my $branchcode  = $params{branchcode} || '';

    my $letter = getletter( $module, $letter_code, $branchcode )
        or warn( "No $module $letter_code letter"),
            return;

    return $letter;
}

my %letter;
sub getletter {
    my ( $module, $code, $branchcode ) = @_;

    $branchcode ||= '';

    if ( C4::Context->preference('IndependantBranches')
            and $branchcode
            and C4::Context->userenv ) {

        $branchcode = C4::Context->userenv->{'branch'};
    }

    if ( my $l = $letter{$module}{$code}{$branchcode} ) {
        return { %$l }; # deep copy
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select * from letter where module=? and code=? and (branchcode = ? or branchcode = '') order by branchcode desc limit 1");
    $sth->execute( $module, $code, $branchcode );
    my $line = $sth->fetchrow_hashref
      or return;
    $line->{'content-type'} = 'text/html; charset="UTF-8"' if $line->{is_html};
    $letter{$module}{$code}{$branchcode} = $line;
    return { %$line };
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

            # 		warn "sending issues...";
            my $userenv = C4::Context->userenv;
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
            my %mail = (
                To      => $email,
                From    => $email,
                Subject => Encode::encode( "utf8", "" . $letter->{title} ),
                Message => Encode::encode( "utf8", "" . $letter->{content} ),
                'Content-Type' => 'text/plain; charset="utf8"',
                );
            sendmail(%mail) or carp $Mail::Sendmail::error;
        }
    }
    elsif ( $type eq 'claimacquisition' or $type eq 'claimissues' ) {

        # prepare the letter...
        # search the biblionumber
        my $strsth =  $type eq 'claimacquisition'
            ? qq{
            SELECT aqorders.*,aqbasket.*,biblio.*,biblioitems.*,aqbooksellers.*,
            aqbooksellers.id AS booksellerid
            FROM aqorders
            LEFT JOIN aqbasket ON aqbasket.basketno=aqorders.basketno
            LEFT JOIN biblio ON aqorders.biblionumber=biblio.biblionumber
            LEFT JOIN biblioitems ON aqorders.biblioitemnumber=biblioitems.biblioitemnumber
            LEFT JOIN aqbooksellers ON aqbasket.booksellerid=aqbooksellers.id
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
        $strsth .= join( ",", @$externalid ) . ")";
        my $sthorders = $dbh->prepare($strsth);
        $sthorders->execute;
        my $dataorders = $sthorders->fetchall_arrayref( {} );

        my $sthbookseller =
          $dbh->prepare("select * from aqbooksellers where id=?");
        $sthbookseller->execute( $dataorders->[0]->{booksellerid} );
        my $databookseller = $sthbookseller->fetchrow_hashref;

        my @email;
        push @email, $databookseller->{bookselleremail} if $databookseller->{bookselleremail};
        push @email, $databookseller->{contemail}       if $databookseller->{contemail};
        unless (@email) {
            warn "Bookseller $dataorders->[0]->{booksellerid} without emails";
            return { error => "no_email" };
        }

        my $userenv = C4::Context->userenv;
        my $letter = GetPreparedLetter (
            module => $type,
            letter_code => $letter_code,
            branchcode => $userenv->{branch},
            tables => {
                'branches'    => $userenv->{branch},
                'aqbooksellers' => $databookseller,
            },
            repeat => $dataorders,
            want_librarian => 1,
        ) or return;

        # ... then send mail
        my %mail = (
            To => join( ',', @email),
            From           => $userenv->{emailaddress},
            Subject        => Encode::encode( "utf8", "" . $letter->{title} ),
            Message        => Encode::encode( "utf8", "" . $letter->{content} ),
            'Content-Type' => 'text/plain; charset="utf8"',
        );
        sendmail(%mail) or carp $Mail::Sendmail::error;

        logaction(
            "ACQUISITION",
            $type eq 'claimissues' ? "CLAIM ISSUE" : "ACQUISITION CLAIM",
            undef,
            "To="
                . $databookseller->{contemail}
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
        my %mail = (
                To      =>     $externalid->{'emailaddr'},
                From    =>  $branchdetails->{'branchemail'} || C4::Context->preference("KohaAdminEmailAddress"),
                Subject => Encode::encode( "utf8", $letter->{'title'} ),
                Message => Encode::encode( "utf8", $letter->{'content'} ),
                'Content-Type' => 'text/plain; charset="utf8"',
        );
        sendmail(%mail) or carp $Mail::Sendmail::error;
    }
}

=head2 GetPreparedLetter( %params )

    retrieves letter template and performs substituion processing

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
    my $tables = $params{tables};
    my $substitute = $params{substitute};
    my $repeat = $params{repeat};

    my $letter = getletter( $module, $letter_code, $branchcode )
        or warn( "No $module $letter_code letter"),
            return;

    my $prepared_letter = GetProcessedLetter(
        module => $module,
        letter_code => $letter_code,
        letter => $letter,
        branchcode => $branchcode,
        tables => $tables,
        substitute => $substitute,
        repeat => $repeat
    );

    return $prepared_letter;
}

=head2 GetProcessedLetter( %params )

    given a letter, with possible pre-processing do standard processing
    allows one to perform letter template processing beforehand

    %params hash:
      module => letter module, mandatory
      letter_code => letter code, mandatory
      letter => letter, mandatory
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

sub GetProcessedLetter {
    my %params = @_;

    my $module      = $params{module} or croak "No module";
    my $letter_code = $params{letter_code} or croak "No letter_code";
    my $letter = $params{letter} or croak "No letter";
    my $branchcode  = $params{branchcode} || '';
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
            my @pk;
            my $sth = _parseletter_sth($table);
            unless ($sth) {
                warn "_parseletter_sth('$table') failed to return a valid sth.  No substitution will be done for that table.";
                return;
            }
            $sth->execute( $ref ? @$param : $param );

            $values = $sth->fetchrow_hashref;
        }

        _parseletter ( $letter, $table, $values );
    }
}

my %handles = ();
sub _parseletter_sth {
    my $table = shift;
    unless ($table) {
        carp "ERROR: _parseletter_sth() called without argument (table)";
        return;
    }
    # check cache first
    (defined $handles{$table}) and return $handles{$table};
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
    ($table eq 'borrower_modifications') ? "SELECT * FROM $table WHERE borrowernumber = ? OR verification_token =?":
    undef ;
    unless ($query) {
        warn "ERROR: No _parseletter_sth query for table '$table'";
        return;     # nothing to get
    }
    unless ($handles{$table} = C4::Context->dbh->prepare($query)) {
        warn "ERROR: Failed to prepare query: '$query'";
        return;
    }
    return $handles{$table};    # now cache is populated for that $table
}

=head2 _parseletter($letter, $table, $values)

    parameters :
    - $letter : a hash to letter fields (title & content useful)
    - $table : the Koha table to parse.
    - $values : table record hashref
    parse all fields from a table, and replace values in title & content with the appropriate value
    (not exported sub, used only internally)

=cut

my %columns = ();
sub _parseletter {
    my ( $letter, $table, $values ) = @_;

    # TEMPORARY hack until the expirationdate column is added to reserves
    if ( $table eq 'reserves' && $values->{'waitingdate'} ) {
        my @waitingdate = split /-/, $values->{'waitingdate'};

        $values->{'expirationdate'} = C4::Dates->new(
            sprintf(
                '%04d-%02d-%02d',
                Add_Delta_Days( @waitingdate, C4::Context->preference( 'ReservesMaxPickUpDelay' ) )
            ),
            'iso'
        )->output();
    }

    if ($letter->{content} && $letter->{content} =~ /<<today>>/) {
        my @da = localtime();
        my $todaysdate = "$da[2]:$da[1]  " . C4::Dates->today();
        $letter->{content} =~ s/<<today>>/$todaysdate/go;
    }

    # and get all fields from the table
#   my $columns = $columns{$table};
#   unless ($columns) {
#       $columns = $columns{$table} =  C4::Context->dbh->selectcol_arrayref("SHOW COLUMNS FROM $table");
#   }
#   foreach my $field (@$columns) {

    while ( my ($field, $val) = each %$values ) {
        my $replacetablefield = "<<$table.$field>>";
        my $replacefield = "<<$field>>";
        $val =~ s/\p{P}(?=$)//g if $val;
        my $replacedby   = defined ($val) ? $val : '';
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

    # It was found that the some utf8 codes, cause the text to be truncated from that point onward when stored,
    # so we normalize utf8 with NFC so that mysql will store 'all' of the content in its TEXT column type
    # Note: It is also done in _add_attachments accordingly.
    $params->{'letter'}->{'title'} = NFC($params->{'letter'}->{'title'});     # subject
    $params->{'letter'}->{'content'} = NFC($params->{'letter'}->{'content'});

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
            ? _wrap_html($letter->{'content'}, NFC($letter->{'title'}))
            : NFC($letter->{'content'}),
    );

    foreach my $attachment ( @$attachments ) {

        if ($attachment->{'content'} =~ m/text/o) { # NFC normailze any "text" related  content-type attachments
            $attachment->{'content'} = NFC($attachment->{'content'});
        }
        $attachment->{'filename'} = NFC($attachment->{'filename'});

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
SELECT mq.message_id, mq.borrowernumber, mq.subject, mq.content, mq.message_transport_type, mq.status, mq.time_queued, mq.from_address, mq.to_address, mq.content_type, b.branchcode
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

    my $to_address = $message->{to_address};
    unless ($to_address) {
        my $member = C4::Members::GetMember( 'borrowernumber' => $message->{'borrowernumber'} );
        unless ($member) {
            warn "FAIL: No 'to_address' and INVALID borrowernumber ($message->{borrowernumber})";
            _set_message_status( { message_id => $message->{'message_id'},
                                   status     => 'failed' } );
            return;
        }
        my $which_address = C4::Context->preference('AutoEmailPrimaryAddress');
        # If the system preference is set to 'first valid' (value == OFF), look up email address
        if ($which_address eq 'OFF') {
            $to_address = GetFirstValidEmailAddress( $message->{'borrowernumber'} );
        } else {
            $to_address = $member->{$which_address};
        }
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
    my %sendmail_params = (
        To   => $to_address,
        From => $message->{'from_address'} || C4::Context->preference('KohaAdminEmailAddress'),
        Subject => $subject,
        charset => 'utf8',
        Message => $is_html ? _wrap_html($content, $subject) : $content,
        'content-type' => $content_type,
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

sub _send_message_by_sms {
    my $message = shift or return;
    my $member = C4::Members::GetMember( 'borrowernumber' => $message->{'borrowernumber'} );
    return unless $member->{'smsalertnumber'};

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
