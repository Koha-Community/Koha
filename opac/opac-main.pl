#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use HTML::Template;

use C4::Context;
use C4::Auth;       # get_template_and_user
use C4::Interface::CGI::Output;
use C4::BookShelves;
use C4::Koha;
use C4::Members;

my $input = new CGI;
my $kohaVersion = C4::Context->config("kohaversion");
my $dbh = C4::Context->dbh;
my $query="Select itemtype,description from itemtypes order by description";
my $sth=$dbh->prepare($query);
$sth->execute;
my  @itemtypeloop;
my %itemtypes;
while (my ($value,$lib) = $sth->fetchrow_array) {
	my %row =(	value => $value,
				description => $lib,
			);
	push @itemtypeloop, \%row;
}
$sth->finish;

my @branches;
my @select_branch;
my %select_branches;
my $branches = getallbranches();
my @branchloop;
foreach my $thisbranch (keys %$branches) {
        my $selected = 1 if (C4::Context->userenv && ($thisbranch eq C4::Context->userenv->{branch}));
        my %row =(value => $thisbranch,
                                selected => $selected,
                                branchname => $branches->{$thisbranch}->{'branchname'},
                        );
        push @branchloop, \%row;
}

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "opac-main.tmpl",
			     type => "opac",
			     query => $input,
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			 });
my $borrower = getmember('',$borrowernumber);
my @options;
my $counter=0;
foreach my $language (getalllanguages()) {
	next if $language eq 'images';
	next if $language eq 'CVS';
	next if $language=~ /png$/;
	next if $language=~ /css$/;
	my $selected='0';
#                            next if $currently_selected_languages->{$language};
	push @options, { language => $language, counter => $counter };
	$counter++;
}
my $languages_count = @options;
if($languages_count > 1){
		$template->param(languages => \@options);
}

my $branchinfo = getbranchinfo();
my @loop_data =();
foreach my $branch (@$branchinfo) {
        my %row =();
        $row{'branch_name'} = $branch->{'branchname'};
        $row{'branch_hours'} = $branch->{'branchhours'};
        $row{'branch_hours'} =~ s^\n^<br />^g;
        push (@loop_data, \%row);
    }

sub getbranchinfo {
        my $dbh = C4::Context->dbh;
        my $sth;
        $sth = $dbh->prepare("Select * from branches order by branchcode");
        $sth->execute();
    
        my @results;
        while(my $data = $sth->fetchrow_hashref) {
	            push(@results, $data);
	        }
        $sth->finish;
        return \@results;
}


$template->param(		suggestion => C4::Context->preference("suggestion"),
				virtualshelves => C4::Context->preference("virtualshelves"),
				textmessaging => $borrower->{textmessaging},
				opaclargeimage => C4::Context->preference("opaclargeimage"),
				LibraryName => C4::Context->preference("LibraryName"),
				OpacNav => C4::Context->preference("OpacNav"),
				opaccredits => C4::Context->preference("opaccredits"),
				opacreadinghistory => C4::Context->preference("opacreadinghistory"),
				opacsmallimage => C4::Context->preference("opacsmallimage"),
				opaclayoutstylesheet => C4::Context->preference("opaclayoutstylesheet"),
				opaccolorstylesheet => C4::Context->preference("opaccolorstylesheet"),
				opaclanguagesdisplay => C4::Context->preference("opaclanguagesdisplay"),
                                branches => \@loop_data,
);

$template->param('Disable_Dictionary'=>C4::Context->preference("Disable_Dictionary")) if (C4::Context->preference("Disable_Dictionary"));

output_html_with_http_headers $input, $cookie, $template->output;
