#!/usr/bin/perl -w
use HTML::Template;

my $template = HTML::Template->new(filename => 'searchresults.tmpl', die_on_bad_params => 0);

$template->param(PET => 'Allie');
$template->param(NAME => 'Steve Tonnesen');


$template->param(SEARCH_RESULTS => [ { barcode => '123456789', title => 'Me and My Dog', author => 'Jack London', dewey => '452.32' },
				     { barcode => '153253216', title => 'Dogs in Canada', author => 'Jack London', dewey => '512.3' },
				     { barcode => '163214576', title => 'Howling at the Moon', author => 'Jack London', dewey => '476' }
				     ]
		);


print "Content-Type: text/html\n\n", $template->output;
