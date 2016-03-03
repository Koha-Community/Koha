#!/usr/bin/perl

# Copyright 2008 Liblime
# Copyright 2010 BibLibre
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

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use Getopt::Long;
use Pod::Usage;
use Text::CSV_XS;
use DateTime;
use DateTime::Duration;

use C4::Context;
use C4::Letters;
use C4::Overdues qw(GetFine GetOverdueMessageTransportTypes parse_overdues_letter);
use C4::Log;
use Koha::Borrower::Debarments qw(AddUniqueDebarment);
use Koha::DateUtils;
use Koha::Calendar;

=head1 NAME

overdue_notices.pl - prepare messages to be sent to patrons for overdue items

=head1 SYNOPSIS

overdue_notices.pl
  [ -n ][ -library <branchcode> ][ -library <branchcode> ... ]
  [ -max <number of days> ][ -csv [<filename>] ][ -itemscontent <field list> ]
  [ -email <email_type> ... ]

 Options:
   -help                          brief help message
   -man                           full documentation
   -v                             verbose
   -n                             No email will be sent
   -max          <days>           maximum days overdue to deal with
   -library      <branchname>     only deal with overdues from this library (repeatable : several libraries can be given)
   -csv          <filename>       populate CSV file
   -html         <directory>      Output html to a file in the given directory
   -text         <directory>      Output plain text to a file in the given directory
   -itemscontent <list of fields> item information in templates
   -borcat       <categorycode>   category code that must be included
   -borcatout    <categorycode>   category code that must be excluded
   -t                             only include triggered overdues
   -list-all                      list all overdues
   -date         <yyyy-mm-dd>     emulate overdues run for this date
   -email        <email_type>     type of email that will be used. Can be 'email', 'emailpro' or 'B_email'. Repeatable.

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<-n>

Do not send any email. Overdue notices that would have been sent to
the patrons or to the admin are printed to standard out. CSV data (if
the -csv flag is set) is written to standard out or to any csv
filename given.

=item B<-max>

Items older than max days are assumed to be handled somewhere else,
probably the F<longoverdues.pl> script. They are therefore ignored by
this program. No notices are sent for them, and they are not added to
any CSV files. Defaults to 90 to match F<longoverdues.pl>.

=item B<-library>

select overdues for one specific library. Use the value in the
branches.branchcode table. This option can be repeated in order 
to select overdues for a group of libraries.

=item B<-csv>

Produces CSV data. if -n (no mail) flag is set, then this CSV data is
sent to standard out or to a filename if provided. Otherwise, only
overdues that could not be emailed are sent in CSV format to the admin.

=item B<-html>

Produces html data. If patron does not have an email address or
-n (no mail) flag is set, an HTML file is generated in the specified
directory. This can be downloaded or further processed by library staff.
The file will be called notices-YYYY-MM-DD.html and placed in the directory
specified.

=item B<-text>

Produces plain text data. If patron does not have an email address or
-n (no mail) flag is set, a text file is generated in the specified
directory. This can be downloaded or further processed by library staff.
The file will be called notices-YYYY-MM-DD.txt and placed in the directory
specified.

=item B<-itemscontent>

comma separated list of fields that get substituted into templates in
places of the E<lt>E<lt>items.contentE<gt>E<gt> placeholder. This
defaults to due date,title,barcode,author

Other possible values come from fields in the biblios, items and
issues tables.

=item B<-borcat>

Repeatable field, that permits to select only some patron categories.

=item B<-borcatout>

Repeatable field, that permits to exclude some patron categories.

=item B<-t> | B<--triggered>

This option causes a notice to be generated if and only if 
an item is overdue by the number of days defined in a notice trigger.

By default, a notice is sent each time the script runs, which is suitable for 
less frequent run cron script, but requires syncing notice triggers with 
the  cron schedule to ensure proper behavior.
Add the --triggered option for daily cron, at the risk of no notice 
being generated if the cron fails to run on time.

=item B<-list-all>

Default items.content lists only those items that fall in the 
range of the currently processing notice.
Choose list-all to include all overdue items in the list (limited by B<-max> setting).

=item B<-date>

use it in order to send overdues on a specific date and not Now. Format: YYYY-MM-DD.

=item B<-email>

Allows to specify which type of email will be used. Can be email, emailpro or B_email. Repeatable.

=back

=head1 DESCRIPTION

This script is designed to alert patrons and administrators of overdue
items.

=head2 Configuration

This script pays attention to the overdue notice configuration
performed in the "Overdue notice/status triggers" section of the
"Tools" area of the staff interface to Koha. There, you can choose
which letter templates are sent out after a configurable number of
days to patrons of each library. More information about the use of this
section of Koha is available in the Koha manual.

The templates used to craft the emails are defined in the "Tools:
Notices" section of the staff interface to Koha.

=head2 Outgoing emails

Typically, messages are prepared for each patron with overdue
items. Messages for whom there is no email address on file are
collected and sent as attachments in a single email to each library
administrator, or if that is not set, then to the email address in the
C<KohaAdminEmailAddress> system preference.

These emails are staged in the outgoing message queue, as are messages
produced by other features of Koha. This message queue must be
processed regularly by the
F<misc/cronjobs/process_message_queue.pl> program.

In the event that the C<-n> flag is passed to this program, no emails
are sent. Instead, messages are sent on standard output from this
program. They may be redirected to a file if desired.

=head2 Templates

Templates can contain variables enclosed in double angle brackets like
E<lt>E<lt>thisE<gt>E<gt>. Those variables will be replaced with values
specific to the overdue items or relevant patron. Available variables
are:

=over

=item E<lt>E<lt>bibE<gt>E<gt>

the name of the library

=item E<lt>E<lt>items.contentE<gt>E<gt>

one line for each item, each line containing a tab separated list of
title, author, barcode, issuedate

=item E<lt>E<lt>borrowers.*E<gt>E<gt>

any field from the borrowers table

=item E<lt>E<lt>branches.*E<gt>E<gt>

any field from the branches table

=back

=head2 CSV output

The C<-csv> command line option lets you specify a file to which
overdues data should be output in CSV format.

With the C<-n> flag set, data about all overdues is written to the
file. Without that flag, only information about overdues that were
unable to be sent directly to the patrons will be written. In other
words, this CSV file replaces the data that is typically sent to the
administrator email address.

=head1 USAGE EXAMPLES

C<overdue_notices.pl> - In this most basic usage, with no command line
arguments, all libraries are processed individually, and notices are
prepared for all patrons with overdue items for whom we have email
addresses. Messages for those patrons for whom we have no email
address are sent in a single attachment to the library administrator's
email address, or to the address in the KohaAdminEmailAddress system
preference.

C<overdue_notices.pl -n -csv /tmp/overdues.csv> - sends no email and
populates F</tmp/overdues.csv> with information about all overdue
items.

C<overdue_notices.pl -library MAIN max 14> - prepare notices of
overdues in the last 2 weeks for the MAIN library.

=head1 SEE ALSO

The F<misc/cronjobs/advance_notices.pl> program allows you to send
messages to patrons in advance of their items becoming due, or to
alert them of items that have just become due.

=cut

# These variables are set by command line options.
# They are initially set to default values.
my $dbh = C4::Context->dbh();
my $help    = 0;
my $man     = 0;
my $verbose = 0;
my $nomail  = 0;
my $MAX     = 90;
my @branchcodes; # Branch(es) passed as parameter
my @emails_to_use;    # Emails to use for messaging
my @emails;           # Emails given in command-line parameters
my $csvfilename;
my $htmlfilename;
my $text_filename;
my $triggered = 0;
my $listall = 0;
my $itemscontent = join( ',', qw( date_due title barcode author itemnumber ) );
my @myborcat;
my @myborcatout;
my ( $date_input, $today );

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'v'              => \$verbose,
    'n'              => \$nomail,
    'max=s'          => \$MAX,
    'library=s'      => \@branchcodes,
    'csv:s'          => \$csvfilename,    # this optional argument gets '' if not supplied.
    'html:s'         => \$htmlfilename,    # this optional argument gets '' if not supplied.
    'text:s'         => \$text_filename,    # this optional argument gets '' if not supplied.
    'itemscontent=s' => \$itemscontent,
    'list-all'       => \$listall,
    't|triggered'    => \$triggered,
    'date=s'         => \$date_input,
    'borcat=s'       => \@myborcat,
    'borcatout=s'    => \@myborcatout,
    'email=s'        => \@emails,
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

cronlogaction();

if ( defined $csvfilename && $csvfilename =~ /^-/ ) {
    warn qq(using "$csvfilename" as filename, that seems odd);
}

my @overduebranches    = C4::Overdues::GetBranchcodesWithOverdueRules();	# Branches with overdue rules
my @branches;									# Branches passed as parameter with overdue rules
my $branchcount = scalar(@overduebranches);

my $overduebranch_word = scalar @overduebranches > 1 ? 'branches' : 'branch';
my $branchcodes_word = scalar @branchcodes > 1 ? 'branches' : 'branch';

my $PrintNoticesMaxLines = C4::Context->preference('PrintNoticesMaxLines');

if ($branchcount) {
    $verbose and warn "Found $branchcount $overduebranch_word with first message enabled: " . join( ', ', map { "'$_'" } @overduebranches ), "\n";
} else {
    die 'No branches with active overduerules';
}

if (@branchcodes) {
    $verbose and warn "$branchcodes_word @branchcodes passed on parameter\n";
    
    # Getting libraries which have overdue rules
    my %seen = map { $_ => 1 } @branchcodes;
    @branches = grep { $seen{$_} } @overduebranches;
    
    
    if (@branches) {

    	my $branch_word = scalar @branches > 1 ? 'branches' : 'branch';
	$verbose and warn "$branch_word @branches have overdue rules\n";

    } else {
    
        $verbose and warn "No active overduerules for $branchcodes_word  '@branchcodes'\n";
        ( scalar grep { '' eq $_ } @branches )
          or die "No active overduerules for DEFAULT either!";
        $verbose and warn "Falling back on default rules for @branchcodes\n";
        @branches = ('');
    }
}
my $date_to_run;
my $date;
if ( $date_input ){
    eval {
        $date_to_run = dt_from_string( $date_input, 'iso' );
    };
    die "$date_input is not a valid date, aborting! Use a date in format YYYY-MM-DD."
        if $@ or not $date_to_run;

    # It's certainly useless to escape $date_input
    # dt_from_string should not return something if $date_input is not correctly set.
    $date = $dbh->quote( $date_input );
}
else {
    $date="NOW()";
    $date_to_run = dt_from_string();
}

# these are the fields that will be substituted into <<item.content>>
my @item_content_fields = split( /,/, $itemscontent );

binmode( STDOUT, ':encoding(UTF-8)' );


our $csv;       # the Text::CSV_XS object
our $csv_fh;    # the filehandle to the CSV file.
if ( defined $csvfilename ) {
    my $sep_char = C4::Context->preference('delimiter') || ';';
    $sep_char = "\t" if ($sep_char eq 'tabulation');
    $csv = Text::CSV_XS->new( { binary => 1 , sep_char => $sep_char } );
    if ( $csvfilename eq '' ) {
        $csv_fh = *STDOUT;
    } else {
        open $csv_fh, ">", $csvfilename or die "unable to open $csvfilename: $!";
    }
    if ( $csv->combine(qw(name surname address1 address2 zipcode city country email phone cardnumber itemcount itemsinfo branchname letternumber)) ) {
        print $csv_fh $csv->string, "\n";
    } else {
        $verbose and warn 'combine failed on argument: ' . $csv->error_input;
    }
}

@branches = @overduebranches unless @branches;
our $fh;
if ( defined $htmlfilename ) {
  if ( $htmlfilename eq '' ) {
    $fh = *STDOUT;
  } else {
    my $today = DateTime->now(time_zone => C4::Context->tz );
    open $fh, ">:encoding(UTF-8)",File::Spec->catdir ($htmlfilename,"notices-".$today->ymd().".html");
  }
  
  print $fh "<html>\n";
  print $fh "<head>\n";
  print $fh "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";
  print $fh "<style type='text/css'>\n";
  print $fh "pre {page-break-after: always;}\n";
  print $fh "pre {white-space: pre-wrap;}\n";
  print $fh "pre {white-space: -moz-pre-wrap;}\n";
  print $fh "pre {white-space: -o-pre-wrap;}\n";
  print $fh "pre {word-wrap: break-work;}\n";
  print $fh "</style>\n";
  print $fh "</head>\n";
  print $fh "<body>\n";
}
elsif ( defined $text_filename ) {
  if ( $text_filename eq '' ) {
    $fh = *STDOUT;
  } else {
    my $today = DateTime->now(time_zone => C4::Context->tz );
    open $fh, ">",File::Spec->catdir ($text_filename,"notices-".$today->ymd().".txt");
  }
}

foreach my $branchcode (@branches) {
    if ( C4::Context->preference('OverdueNoticeCalendar') ) {
        my $calendar = Koha::Calendar->new( branchcode => $branchcode );
        if ( $calendar->is_holiday($date_to_run) ) {
            next;
        }
    }

    my $branch_details      = C4::Branch::GetBranchDetail($branchcode);
    my $admin_email_address = $branch_details->{'branchemail'}
      || C4::Context->preference('KohaAdminEmailAddress');
    my @output_chunks;    # may be sent to mail or stdout or csv file.

    $verbose and warn sprintf "branchcode : '%s' using %s\n", $branchcode, $admin_email_address;

    my $sth2 = $dbh->prepare( <<"END_SQL" );
SELECT biblio.*, items.*, issues.*, biblioitems.itemtype, branchname
  FROM issues,items,biblio, biblioitems, branches b
  WHERE items.itemnumber=issues.itemnumber
    AND biblio.biblionumber   = items.biblionumber
    AND b.branchcode = items.homebranch
    AND biblio.biblionumber   = biblioitems.biblionumber
    AND issues.borrowernumber = ?
    AND TO_DAYS($date)-TO_DAYS(issues.date_due) >= 0
END_SQL

    my $query = "SELECT * FROM overduerules WHERE delay1 IS NOT NULL AND branchcode = ? ";
    $query .= " AND categorycode IN (".join( ',' , ('?') x @myborcat ).") " if (@myborcat);
    $query .= " AND categorycode NOT IN (".join( ',' , ('?') x @myborcatout ).") " if (@myborcatout);
    
    my $rqoverduerules =  $dbh->prepare($query);
    $rqoverduerules->execute($branchcode, @myborcat, @myborcatout);
    
    # We get default rules is there is no rule for this branch
    if($rqoverduerules->rows == 0){
        $query = "SELECT * FROM overduerules WHERE delay1 IS NOT NULL AND branchcode = '' ";
        $query .= " AND categorycode IN (".join( ',' , ('?') x @myborcat ).") " if (@myborcat);
        $query .= " AND categorycode NOT IN (".join( ',' , ('?') x @myborcatout ).") " if (@myborcatout);
        
        $rqoverduerules = $dbh->prepare($query);
        $rqoverduerules->execute(@myborcat, @myborcatout);
    }

    # my $outfile = 'overdues_' . ( $mybranch || $branchcode || 'default' );
    while ( my $overdue_rules = $rqoverduerules->fetchrow_hashref ) {
      PERIOD: foreach my $i ( 1 .. 3 ) {

            $verbose and warn "branch '$branchcode', categorycode = $overdue_rules->{categorycode} pass $i\n";

            my $mindays = $overdue_rules->{"delay$i"};    # the notice will be sent after mindays days (grace period)
            my $maxdays = (
                  $overdue_rules->{ "delay" . ( $i + 1 ) }
                ? $overdue_rules->{ "delay" . ( $i + 1 ) } - 1
                : ($MAX)
            );                                            # issues being more than maxdays late are managed somewhere else. (borrower probably suspended)

            next unless defined $mindays;

            if ( !$overdue_rules->{"letter$i"} ) {
                $verbose and warn "No letter$i code for branch '$branchcode'";
                next PERIOD;
            }

            # $letter->{'content'} is the text of the mail that is sent.
            # this text contains fields that are replaced by their value. Those fields must be written between brackets
            # The following fields are available :
	    # itemcount is interpreted here as the number of items in the overdue range defined by the current notice or all overdues < max if(-list-all).
            # <date> <itemcount> <firstname> <lastname> <address1> <address2> <address3> <city> <postcode> <country>

            my $borrower_sql = <<"END_SQL";
SELECT issues.borrowernumber, firstname, surname, address, address2, city, zipcode, country, email, emailpro, B_email, smsalertnumber, phone, cardnumber, date_due
FROM   issues,borrowers,categories
WHERE  issues.borrowernumber=borrowers.borrowernumber
AND    borrowers.categorycode=categories.categorycode
AND    TO_DAYS($date)-TO_DAYS(issues.date_due) >= 0
END_SQL
            my @borrower_parameters;
            if ($branchcode) {
                $borrower_sql .= ' AND issues.branchcode=? ';
                push @borrower_parameters, $branchcode;
            }
            if ( $overdue_rules->{categorycode} ) {
                $borrower_sql .= ' AND borrowers.categorycode=? ';
                push @borrower_parameters, $overdue_rules->{categorycode};
            }
            $borrower_sql .= '  AND categories.overduenoticerequired=1 ORDER BY issues.borrowernumber';

            # $sth gets borrower info iff at least one overdue item has triggered the overdue action.
	        my $sth = $dbh->prepare($borrower_sql);
            $sth->execute(@borrower_parameters);

            $verbose and warn $borrower_sql . "\n $branchcode | " . $overdue_rules->{'categorycode'} . "\n ($mindays, $maxdays, ".  $date_to_run->datetime() .")\nreturns " . $sth->rows . " rows";
            my $borrowernumber;
            while ( my $data = $sth->fetchrow_hashref ) {

                # check the borrower has at least one item that matches
                my $days_between;
                if ( C4::Context->preference('OverdueNoticeCalendar') )
                {
                    my $calendar =
                      Koha::Calendar->new( branchcode => $branchcode );
                    $days_between =
                      $calendar->days_between( dt_from_string($data->{date_due}),
                        $date_to_run );
                }
                else {
                    $days_between =
                      $date_to_run->delta_days( dt_from_string($data->{date_due}) );
                }
                $days_between = $days_between->in_units('days');
                if ($triggered) {
                    if ( $mindays != $days_between ) {
                        next;
                    }
                }
                else {
                    unless (   $days_between >= $mindays
                        && $days_between <= $maxdays )
                    {
                        next;
                    }
                }
                if (defined $borrowernumber && $borrowernumber eq $data->{'borrowernumber'}){
# we have already dealt with this borrower
                    $verbose and warn "already dealt with this borrower $borrowernumber";
                    next;
                }
                $borrowernumber = $data->{'borrowernumber'};
                my $borr =
                    $data->{'firstname'} . ', '
                  . $data->{'surname'} . ' ('
                  . $borrowernumber . ')';
                $verbose
                  and warn "borrower $borr has items triggering level $i.";

                @emails_to_use = ();
                my $notice_email =
                    C4::Members::GetNoticeEmailAddress($borrowernumber);
                unless ($nomail) {
                    if (@emails) {
                        foreach (@emails) {
                            push @emails_to_use, $data->{$_} if ( $data->{$_} );
                        }
                    }
                    else {
                        push @emails_to_use, $notice_email if ($notice_email);
                    }
                }

                my $letter = C4::Letters::getletter( 'circulation', $overdue_rules->{"letter$i"}, $branchcode );

                unless ($letter) {
                    $verbose and warn qq|Message '$overdue_rules->{"letter$i"}' content not found|;

                    # might as well skip while PERIOD, no other borrowers are going to work.
                    # FIXME : Does this mean a letter must be defined in order to trigger a debar ?
                    next PERIOD;
                }
    
                if ( $overdue_rules->{"debarred$i"} ) {
    
                    #action taken is debarring
                    AddUniqueDebarment(
                        {
                            borrowernumber => $borrowernumber,
                            type           => 'OVERDUES',
                            comment => "Restriction added by overdues process "
                              . output_pref( dt_from_string() ),
                        }
                    );
                    $verbose and warn "debarring $borr\n";
                }
                my @params = ($borrowernumber);
                $verbose and warn "STH2 PARAMS: borrowernumber = $borrowernumber";

                $sth2->execute(@params);
                my $itemcount = 0;
                my $titles = "";
                my @items = ();
                
                my $j = 0;
                my $exceededPrintNoticesMaxLines = 0;
                while ( my $item_info = $sth2->fetchrow_hashref() ) {
                    if ( C4::Context->preference('OverdueNoticeCalendar') ) {
                        my $calendar =
                          Koha::Calendar->new( branchcode => $branchcode );
                        $days_between =
                          $calendar->days_between(
                            dt_from_string( $item_info->{date_due} ), $date_to_run );
                    }
                    else {
                        $days_between =
                          $date_to_run->delta_days(
                            dt_from_string( $item_info->{date_due} ) );
                    }
                    $days_between = $days_between->in_units('days');
                    if ($listall){
                        unless ($days_between >= 1 and $days_between <= $MAX){
                            next;
                        }
                    }
                    else {
                        if ($triggered) {
                            if ( $mindays != $days_between ) {
                                next;
                            }
                        }
                        else {
                            unless ( $days_between >= $mindays
                                && $days_between <= $maxdays )
                            {
                                next;
                            }
                        }
                    }

                    if ( ( scalar(@emails_to_use) == 0 || $nomail ) && $PrintNoticesMaxLines && $j >= $PrintNoticesMaxLines ) {
                      $exceededPrintNoticesMaxLines = 1;
                      last;
                    }
                    $j++;
                    my @item_info = map { $_ =~ /^date|date$/ ?
                                           eval { output_pref( { dt => dt_from_string( $item_info->{$_} ), dateonly => 1 } ); }
                                           :
                                           $item_info->{$_} || '' } @item_content_fields;
                    $titles .= join("\t", @item_info) . "\n";
                    $itemcount++;
                    push @items, $item_info;
                }
                $sth2->finish;

                my @message_transport_types = @{ GetOverdueMessageTransportTypes( $branchcode, $overdue_rules->{categorycode}, $i) };
                @message_transport_types = @{ GetOverdueMessageTransportTypes( q{}, $overdue_rules->{categorycode}, $i) }
                    unless @message_transport_types;


                my $print_sent = 0; # A print notice is not yet sent for this patron
                for my $mtt ( @message_transport_types ) {
                    my $effective_mtt = $mtt;
                    if ( ($mtt eq 'email' and not scalar @emails_to_use) or ($mtt eq 'sms' and not $data->{smsalertnumber}) ) {
                        # email or sms is requested but not exist, do a print.
                        $effective_mtt = 'print';
                    }
                    my $letter = parse_overdues_letter(
                        {   letter_code     => $overdue_rules->{"letter$i"},
                            borrowernumber  => $borrowernumber,
                            branchcode      => $branchcode,
                            items           => \@items,
                            substitute      => {    # this appears to be a hack to overcome incomplete features in this code.
                                                bib             => $branch_details->{'branchname'}, # maybe 'bib' is a typo for 'lib<rary>'?
                                                'items.content' => $titles,
                                                'count'         => $itemcount,
                                               },
                            message_transport_type => $effective_mtt,
                        }
                    );
                    unless ($letter) {
                        $verbose and warn qq|Message '$overdue_rules->{"letter$i"}' content not found|;
                        # this transport doesn't have a configured notice, so try another
                        next;
                    }

                    if ( $exceededPrintNoticesMaxLines ) {
                      $letter->{'content'} .= "List too long for form; please check your account online for a complete list of your overdue items.";
                    }

                    my @misses = grep { /./ } map { /^([^>]*)[>]+/; ( $1 || '' ); } split /\</, $letter->{'content'};
                    if (@misses) {
                        $verbose and warn "The following terms were not matched and replaced: \n\t" . join "\n\t", @misses;
                    }

                    if ($nomail) {
                        push @output_chunks,
                          prepare_letter_for_printing(
                          {   letter         => $letter,
                              borrowernumber => $borrowernumber,
                              firstname      => $data->{'firstname'},
                              lastname       => $data->{'surname'},
                              address1       => $data->{'address'},
                              address2       => $data->{'address2'},
                              city           => $data->{'city'},
                              phone          => $data->{'phone'},
                              cardnumber     => $data->{'cardnumber'},
                              branchname     => $branch_details->{'branchname'},
                              letternumber   => $i,
                              postcode       => $data->{'zipcode'},
                              country        => $data->{'country'},
                              email          => $notice_email,
                              itemcount      => $itemcount,
                              titles         => $titles,
                              outputformat   => defined $csvfilename ? 'csv' : defined $htmlfilename ? 'html' : defined $text_filename ? 'text' : '',
                            }
                          );
                    } else {
                        if ( ($mtt eq 'email' and not scalar @emails_to_use) or ($mtt eq 'sms' and not $data->{smsalertnumber}) ) {
                            push @output_chunks,
                              prepare_letter_for_printing(
                              {   letter         => $letter,
                                  borrowernumber => $borrowernumber,
                                  firstname      => $data->{'firstname'},
                                  lastname       => $data->{'surname'},
                                  address1       => $data->{'address'},
                                  address2       => $data->{'address2'},
                                  city           => $data->{'city'},
                                  postcode       => $data->{'zipcode'},
                                  country        => $data->{'country'},
                                  email          => $notice_email,
                                  itemcount      => $itemcount,
                                  titles         => $titles,
                                  outputformat   => defined $csvfilename ? 'csv' : defined $htmlfilename ? 'html' : defined $text_filename ? 'text' : '',
                                }
                              );
                        }
                        unless ( $effective_mtt eq 'print' and $print_sent == 1 ) {
                            # Just sent a print if not already done.
                            C4::Letters::EnqueueLetter(
                                {   letter                 => $letter,
                                    borrowernumber         => $borrowernumber,
                                    message_transport_type => $effective_mtt,
                                    from_address           => $admin_email_address,
                                    to_address             => join(',', @emails_to_use),
                                }
                            );
                            # A print notice should be sent only once per overdue level.
                            # Without this check, a print could be sent twice or more if the library checks sms and email and print and the patron has no email or sms number.
                            $print_sent = 1 if $effective_mtt eq 'print';
                        }
                    }
                }
            }
            $sth->finish;
        }
    }

    if (@output_chunks) {
        if ( defined $csvfilename ) {
            print $csv_fh @output_chunks;        
        }
        elsif ( defined $htmlfilename ) {
            print $fh @output_chunks;        
        }
        elsif ( defined $text_filename ) {
            print $fh @output_chunks;        
        }
        elsif ($nomail){
                local $, = "\f";    # pagebreak
                print @output_chunks;
        }
        # Generate the content of the csv with headers
        my $content;
        if ( defined $csvfilename ) {
            my $delimiter = C4::Context->preference('delimiter') || ';';
            $content = join($delimiter, qw(title name surname address1 address2 zipcode city country email itemcount itemsinfo due_date issue_date)) . "\n";
        }
        else {
            $content = "";
        }
        $content .= join( "\n", @output_chunks );

        my $attachment = {
            filename => defined $csvfilename ? 'attachment.csv' : 'attachment.txt',
            type => 'text/plain',
            content => $content, 
        };

        my $letter = {
            title   => 'Overdue Notices',
            content => 'These messages were not sent directly to the patrons.',
        };
        C4::Letters::EnqueueLetter(
            {   letter                 => $letter,
                borrowernumber         => undef,
                message_transport_type => 'email',
                attachments            => [$attachment],
                to_address             => $admin_email_address,
            }
        );
    }

}
if ($csvfilename) {
    # note that we're not testing on $csv_fh to prevent closing
    # STDOUT.
    close $csv_fh;
}

if ( defined $htmlfilename ) {
  print $fh "</body>\n";
  print $fh "</html>\n";
  close $fh;
} elsif ( defined $text_filename ) {
  close $fh;
}

=head1 INTERNAL METHODS

These methods are internal to the operation of overdue_notices.pl.

=head2 prepare_letter_for_printing

returns a string of text appropriate for printing in the event that an
overdue notice will not be sent to the patron's email
address. Depending on the desired output format, this may be a CSV
string, or a human-readable representation of the notice.

required parameters:
  letter
  borrowernumber

optional parameters:
  outputformat

=cut

sub prepare_letter_for_printing {
    my $params = shift;

    return unless ref $params eq 'HASH';

    foreach my $required_parameter (qw( letter borrowernumber )) {
        return unless defined $params->{$required_parameter};
    }

    my $return;
    chomp $params->{titles};
    if ( exists $params->{'outputformat'} && $params->{'outputformat'} eq 'csv' ) {
        if ($csv->combine(
                $params->{'firstname'}, $params->{'lastname'}, $params->{'address1'},  $params->{'address2'}, $params->{'postcode'},
                $params->{'city'}, $params->{'country'}, $params->{'email'}, $params->{'phone'}, $params->{'cardnumber'},
                $params->{'itemcount'}, $params->{'titles'}, $params->{'branchname'}, $params->{'letternumber'}
            )
          ) {
            return $csv->string, "\n";
        } else {
            $verbose and warn 'combine failed on argument: ' . $csv->error_input;
        }
    } elsif ( exists $params->{'outputformat'} && $params->{'outputformat'} eq 'html' ) {
      $return = "<pre>\n";
      $return .= "$params->{'letter'}->{'content'}\n";
      $return .= "\n</pre>\n";
    } else {
        $return .= "$params->{'letter'}->{'content'}\n";

        # $return .= Data::Dumper->Dump( [ $params->{'borrowernumber'}, $params->{'letter'} ], [qw( borrowernumber letter )] );
    }
    return $return;
}

