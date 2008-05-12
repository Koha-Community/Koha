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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use Mail::Sendmail;
# use C4::Date;
# use Date::Manip;
# use C4::Suggestions;
use C4::Members;
use C4::Log;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	require Exporter;
	# set the version for version checking
	$VERSION = 3.01;
	@ISA = qw(Exporter);
	@EXPORT = qw(
	&GetLetters &getletter &addalert &getalert &delalert &findrelatedto &SendAlerts
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

=cut

=head2 GetLetters

  $letters = &getletters($category);
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

=head3 in TEMPLATE

    <select name="letter">
        <option value="">Default</option>
    <!-- TMPL_LOOP name="letterloop" -->
        <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="lettername" --></option>
    <!-- /TMPL_LOOP -->
    </select>

=cut

sub GetLetters {

    # returns a reference to a hash of references to ALL letters...
    my $cat = shift;
    my %letters;
    my $dbh = C4::Context->dbh;
    $dbh->quote($cat);
    my $sth;
    if ( $cat ne "" ) {
        my $query = "SELECT * FROM letter WHERE module = ? ORDER BY name";
        $sth = $dbh->prepare($query);
        $sth->execute($cat);
    }
    else {
        my $query = " SELECT * FROM letter ORDER BY name";
        $sth = $dbh->prepare($query);
        $sth->execute;
    }
    while ( my $letter = $sth->fetchrow_hashref ) {
        $letters{ $letter->{'code'} } = $letter->{'name'};
    }
    return \%letters;
}

sub getletter {
    my ( $module, $code ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select * from letter where module=? and code=?");
    $sth->execute( $module, $code );
    my $line = $sth->fetchrow_hashref;
    return $line;
}

=head2 addalert

    parameters : 
    - $borrowernumber : the number of the borrower subscribing to the alert
    - $type : the type of alert.
    - externalid : the primary key of the object to put alert on. For issues, the alert is made on subscriptionid.
    
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

=head2 delalert

    parameters :
    - alertid : the alert id
    deletes the alert
    
=cut

sub delalert {
    my ($alertid) = @_;

    #warn "ALERTID : $alertid";
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("delete from alert where alertid=?");
    $sth->execute($alertid);
}

=head2 getalert

    parameters :
    - $borrowernumber : the number of the borrower subscribing to the alert
    - $type : the type of alert.
    - externalid : the primary key of the object to put alert on. For issues, the alert is made on subscriptionid.
    all parameters NON mandatory. If a parameter is omitted, the query is done without the corresponding parameter. For example, without $externalid, returns all alerts for a borrower on a topic.

=cut

sub getalert {
    my ( $borrowernumber, $type, $externalid ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT * FROM alert WHERE";
    my @bind;
    if ($borrowernumber =~ /^\d+$/) {
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
    my @result;
    while ( my $line = $sth->fetchrow_hashref ) {
        push @result, $line;
    }
    return \@result;
}

=head2 findrelatedto

	parameters :
	- $type : the type of alert
	- $externalid : the id of the "object" to query
	
	In the table alert, a "id" is stored in the externalid field. This "id" is related to another table, depending on the type of the alert.
	When type=issue, the id is related to a subscriptionid and this sub returns the name of the biblio.
	When type=virtual, the id is related to a virtual shelf and this sub returns the name of the sub
=cut

sub findrelatedto {
    my ( $type, $externalid ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ( $type eq 'issue' ) {
        $sth =
          $dbh->prepare(
"select title as result from subscription left join biblio on subscription.biblionumber=biblio.biblionumber where subscriptionid=?"
          );
    }
    if ( $type eq 'borrower' ) {
        $sth =
          $dbh->prepare(
"select concat(firstname,' ',surname) from borrowers where borrowernumber=?"
          );
    }
    $sth->execute($externalid);
    my ($result) = $sth->fetchrow;
    return $result;
}

=head2 SendAlerts

    parameters :
    - $type : the type of alert
    - $externalid : the id of the "object" to query
    - $letter : the letter to send.

    send an alert to all borrowers having put an alert on a given subject.

=cut

sub SendAlerts {
    my ( $type, $externalid, $letter ) = @_;
    my $dbh = C4::Context->dbh;
    if ( $type eq 'issue' ) {

        # 		warn "sending issues...";
        my $letter = getletter( 'serial', $letter );

        # prepare the letter...
        # search the biblionumber
        my $sth =
          $dbh->prepare(
            "SELECT biblionumber FROM subscription WHERE subscriptionid=?");
        $sth->execute($externalid);
        my ($biblionumber) = $sth->fetchrow;

        # parsing branch info
        my $userenv = C4::Context->userenv;
        parseletter( $letter, 'branches', $userenv->{branch} );

        # parsing librarian name
        $letter->{content} =~ s/<<LibrarianFirstname>>/$userenv->{firstname}/g;
        $letter->{content} =~ s/<<LibrarianSurname>>/$userenv->{surname}/g;
        $letter->{content} =~
          s/<<LibrarianEmailaddress>>/$userenv->{emailaddress}/g;

        # parsing biblio information
        parseletter( $letter, 'biblio',      $biblionumber );
        parseletter( $letter, 'biblioitems', $biblionumber );

        # find the list of borrowers to alert
        my $alerts = getalert( '', 'issue', $externalid );
        foreach (@$alerts) {

            # and parse borrower ...
            my $innerletter = $letter;
            my $borinfo = GetMember( $_->{'borrowernumber'}, 'borrowernumber' );
            parseletter( $innerletter, 'borrowers', $_->{'borrowernumber'} );

            # ... then send mail
            if ( $borinfo->{email} ) {
                my %mail = (
                    To      => $borinfo->{email},
                    From    => $borinfo->{email},
                    Subject => "" . $innerletter->{title},
                    Message => "" . $innerletter->{content},
                    'Content-Type' => 'text/plain; charset="utf8"',
                    );
                sendmail(%mail);

# warn "sending to $mail{To} From $mail{From} subj $mail{Subject} Mess $mail{Message}";
            }
        }
    }
    elsif ( $type eq 'claimacquisition' ) {

        # 		warn "sending issues...";
        my $letter = getletter( 'claimacquisition', $letter );

        # prepare the letter...
        # search the biblionumber
        my $strsth =
"select aqorders.*,aqbasket.*,biblio.*,biblioitems.* from aqorders LEFT JOIN aqbasket on aqbasket.basketno=aqorders.basketno LEFT JOIN biblio on aqorders.biblionumber=biblio.biblionumber LEFT JOIN biblioitems on aqorders.biblioitemnumber=biblioitems.biblioitemnumber where aqorders.ordernumber IN ("
          . join( ",", @$externalid ) . ")";
        my $sthorders = $dbh->prepare($strsth);
        $sthorders->execute;
        my $dataorders = $sthorders->fetchall_arrayref( {} );
        parseletter( $letter, 'aqbooksellers',
            $dataorders->[0]->{booksellerid} );
        my $sthbookseller =
          $dbh->prepare("select * from aqbooksellers where id=?");
        $sthbookseller->execute( $dataorders->[0]->{booksellerid} );
        my $databookseller = $sthbookseller->fetchrow_hashref;

        # parsing branch info
        my $userenv = C4::Context->userenv;
        parseletter( $letter, 'branches', $userenv->{branch} );

        # parsing librarian name
        $letter->{content} =~ s/<<LibrarianFirstname>>/$userenv->{firstname}/g;
        $letter->{content} =~ s/<<LibrarianSurname>>/$userenv->{surname}/g;
        $letter->{content} =~
          s/<<LibrarianEmailaddress>>/$userenv->{emailaddress}/g;
        foreach my $data (@$dataorders) {
            my $line = $1 if ( $letter->{content} =~ m/(<<.*>>)/ );
            foreach my $field ( keys %$data ) {
                $line =~ s/(<<[^\.]+.$field>>)/$data->{$field}/;
            }
            $letter->{content} =~ s/(<<.*>>)/$line\n$1/;
        }
        $letter->{content} =~ s/<<[^>]*>>//g;
        my $innerletter = $letter;

        # ... then send mail
        if (   $databookseller->{bookselleremail}
            || $databookseller->{contemail} )
        {
            my %mail = (
                To => $databookseller->{bookselleremail}
                  . (
                    $databookseller->{contemail}
                    ? "," . $databookseller->{contemail}
                    : ""
                  ),
                From           => $userenv->{emailaddress},
                Subject        => "" . $innerletter->{title},
                Message        => "" . $innerletter->{content},
                'Content-Type' => 'text/plain; charset="utf8"',
            );
            sendmail(%mail);
            warn
"sending to $mail{To} From $mail{From} subj $mail{Subject} Mess $mail{Message}";
        }
        if ( C4::Context->preference("LetterLog") ) {
            logaction(
                "ACQUISITION",
                "Send Acquisition claim letter",
                "",
                "order list : "
                  . join( ",", @$externalid )
                  . "\n$innerletter->{title}\n$innerletter->{content}"
            );
        }
    }
    elsif ( $type eq 'claimissues' ) {

        # 		warn "sending issues...";
        my $letter = getletter( 'claimissues', $letter );

        # prepare the letter...
        # search the biblionumber
        my $strsth =
"select serial.*,subscription.*, biblio.* from serial LEFT JOIN subscription on serial.subscriptionid=subscription.subscriptionid LEFT JOIN biblio on serial.biblionumber=biblio.biblionumber where serial.serialid IN ("
          . join( ",", @$externalid ) . ")";
        my $sthorders = $dbh->prepare($strsth);
        $sthorders->execute;
        my $dataorders = $sthorders->fetchall_arrayref( {} );
        parseletter( $letter, 'aqbooksellers',
            $dataorders->[0]->{aqbooksellerid} );
        my $sthbookseller =
          $dbh->prepare("select * from aqbooksellers where id=?");
        $sthbookseller->execute( $dataorders->[0]->{aqbooksellerid} );
        my $databookseller = $sthbookseller->fetchrow_hashref;

        # parsing branch info
        my $userenv = C4::Context->userenv;
        parseletter( $letter, 'branches', $userenv->{branch} );

        # parsing librarian name
        $letter->{content} =~ s/<<LibrarianFirstname>>/$userenv->{firstname}/g;
        $letter->{content} =~ s/<<LibrarianSurname>>/$userenv->{surname}/g;
        $letter->{content} =~
          s/<<LibrarianEmailaddress>>/$userenv->{emailaddress}/g;
        foreach my $data (@$dataorders) {
            my $line = $1 if ( $letter->{content} =~ m/(<<.*>>)/ );
            foreach my $field ( keys %$data ) {
                $line =~ s/(<<[^\.]+.$field>>)/$data->{$field}/;
            }
            $letter->{content} =~ s/(<<.*>>)/$line\n$1/;
        }
        $letter->{content} =~ s/<<[^>]*>>//g;
        my $innerletter = $letter;

        # ... then send mail
        if (   $databookseller->{bookselleremail}
            || $databookseller->{contemail} )
        {
            my %mail = (
                To => $databookseller->{bookselleremail}
                  . (
                    $databookseller->{contemail}
                    ? "," . $databookseller->{contemail}
                    : ""
                  ),
                From    => $userenv->{emailaddress},
                Subject => "" . $innerletter->{title},
                Message => "" . $innerletter->{content},
                'Content-Type' => 'text/plain; charset="utf8"',
            );
            sendmail(%mail);
            logaction(
                "ACQUISITION",
                "CLAIM ISSUE",
                undef,
                "To="
                  . $databookseller->{contemail}
                  . " Title="
                  . $innerletter->{title}
                  . " Content="
                  . $innerletter->{content}
            ) if C4::Context->preference("LetterLog");
        }
        warn
"sending to From $userenv->{emailaddress} subj $innerletter->{title} Mess $innerletter->{content}";
    }
}

=head2 parseletter

    parameters :
    - $letter : a hash to letter fields (title & content useful)
    - $table : the Koha table to parse.
    - $pk : the primary key to query on the $table table
    parse all fields from a table, and replace values in title & content with the appropriate value
    (not exported sub, used only internally)

=cut

sub parseletter {
    my ( $letter, $table, $pk ) = @_;

    # 	warn "Parseletter : ($letter,$table,$pk)";
    my $dbh = C4::Context->dbh;
    my $sth;
    if ( $table eq 'biblio' ) {
        $sth = $dbh->prepare("select * from biblio where biblionumber=?");
    }
    elsif ( $table eq 'biblioitems' ) {
        $sth = $dbh->prepare("select * from biblioitems where biblionumber=?");
    }
    elsif ( $table eq 'borrowers' ) {
        $sth = $dbh->prepare("select * from borrowers where borrowernumber=?");
    }
    elsif ( $table eq 'branches' ) {
        $sth = $dbh->prepare("select * from branches where branchcode=?");
    }
    elsif ( $table eq 'aqbooksellers' ) {
        $sth = $dbh->prepare("select * from aqbooksellers where id=?");
    }
    $sth->execute($pk);

    # store the result in an hash
    my $values = $sth->fetchrow_hashref;

    # and get all fields from the table
    $sth = $dbh->prepare("show columns from $table");
    $sth->execute;
    while ( ( my $field ) = $sth->fetchrow_array ) {
        my $replacefield = "<<$table.$field>>";
        my $replacedby   = $values->{$field};

        # 		warn "REPLACE $replacefield by $replacedby";
        $letter->{title}   =~ s/$replacefield/$replacedby/g;
        $letter->{content} =~ s/$replacefield/$replacedby/g;
    }
}

1;
__END__
