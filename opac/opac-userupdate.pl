#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use Mail::Sendmail;

use C4::Auth;         # checkauth, getborrowernumber.
use C4::Koha;
use C4::Circulation::Circ2;
use HTML::Template;


my $query = new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-userupdate.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);


# handle the new information....
# collect the form values and send an email.
my @fields = ('title', 'surname', 'firstname', 'phone', 'faxnumber', 'streetaddress', 'emailaddress', 'city');
my $update;
my $updateemailaddress = "finlay\@katipo.co.nz";      #Will have to change this! !!!!!!!!!!!!!!!!!!!
if ($query->{'title'}) {
    # get all the fields:
    my $message = <<"EOF";
Borrower $borr->{'cardnumber'} http://intradev.katipo.co.nz/cgi-bin/koha/moremember.pl?bornum=$borrowernumber

has requested to change their personal details. Please check these new details and make the changes:
EOF
    foreach my $field (@fields){
	my $newfield = $query->param($field);
	$message .= "$field : $borr->{$field}  -->  $newfield\n";
    }
    $message .= "\n\nThanks,\nKoha\n\n";
    my %mail = ( To      => $updateemailaddress ,
		 From    => $updateemailaddress ,
		 Subject => "User Request for update of Record.",
		 Message => $message );
    if (sendmail %mail) {
# do something if it works....
	warn "Mail sent ok\n";
	print $query->redirect('/cgi-bin/koha/opac-user.pl');
    } else {
# do something if it doesnt work....
        warn "Error sending mail: $Mail::Sendmail::error \n";
    }
}


$borr->{'dateenrolled'} = slashifyDate($borr->{'dateenrolled'});
$borr->{'expiry'}       = slashifyDate($borr->{'expiry'});
$borr->{'dateofbirth'}  = slashifyDate($borr->{'dateofbirth'});
$borr->{'ethnicity'}    = fixEthnicity($borr->{'ethnicity'});


my @bordat;
$bordat[0] = $borr;

$template->param(BORROWER_INFO => \@bordat);

print $query->header(-cookie => $cookie), $template->output;
