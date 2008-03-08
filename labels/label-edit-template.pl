#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Labels;
use HTML::Template::Pro;
use POSIX;

# use Data::Dumper;

my $dbh       = C4::Context->dbh;
my $query     = new CGI;

my $tmpl_id = $query->param('tmpl_id');

my $width      = $query->param('width');
my $height     = $query->param('height');
my $topmargin  = $query->param('topmargin');
my $leftmargin = $query->param('leftmargin');
my $columns    = $query->param('columns');
my $rows       = $query->param('rows');
my $colgap     = $query->param('colgap');
my $rowgap     = $query->param('rowgap');
my $prof_id    = $query->param('prof_id');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-template.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $tmpl = GetSingleLabelTemplate($tmpl_id);
my $curprof = GetAssociatedProfile($tmpl_id);
my @prof = GetAllPrinterProfiles();
my @proflist;

# Generate an array of hashes containing possible profiles for given template and mark the currently associated one...

foreach my $prof (@prof) {
    if ( $prof->{'tmpl_id'} eq $tmpl->{'tmpl_id'} && $prof->{'prof_id'} eq $curprof->{'prof_id'} ) {
        push ( @proflist,  {prof_id         => $prof->{'prof_id'},
                            printername     => $prof->{'printername'},
                            paper_bin       => $prof->{'paper_bin'},
                            selected        => 1} );
    }
    
    elsif ( $prof->{'tmpl_id'} eq $tmpl->{'tmpl_id'} ) {
        push ( @proflist,  {prof_id         => $prof->{'prof_id'},
                            printername     => $prof->{'printername'},
                            paper_bin       => $prof->{'paper_bin'}} );
    }
    
    elsif ( !$prof ) {
        undef @proflist;
    }
}

my @units = (
    { unit => 'INCH',  desc => 'Inches' },
    { unit => 'CM',    desc => 'Centimeters' },
    { unit => 'MM',    desc => 'Millimeters' },
    { unit => 'POINT', desc => 'Postscript Points' },
);

foreach my $unit (@units) {
    if ( $unit->{'unit'} eq $tmpl->{'units'} ) {
        $unit->{'selected'} = 1;
    }
}

my @fonts = (        #FIXME: There is probably a way to discover what additional fonts are installed on a user's system and generate this list dynamically...
    { font => 'TR',     name => 'Times Roman' },
    { font => 'TB',     name => 'Times Bold' },
    { font => 'TI',     name => 'Times Italic' },
    { font => 'TBI',    name => 'Times Bold Italic' },
    { font => 'C',      name => 'Courier' },
    { font => 'CB',     name => 'Courier Bold' },
    { font => 'CO',     name => 'Courier Oblique' },
    { font => 'CBO',    name => 'Courier Bold Oblique' },
    { font => 'H',      name => 'Helvetica' },
    { font => 'HB',     name => 'Helvetica Bold' },
    { font => 'HO',     name => 'Helvetica Oblique' },
    { font => 'HBO',    name => 'Helvetica Bold Oblique' },
);

foreach my $font (@fonts) {
    if ( $font->{'font'} eq $tmpl->{'font'} ) {
        $font->{'selected'} = 1;
    }
}

$template->param(

    proflist     => \@proflist,
    units        => \@units,
    fonts        => \@fonts,

    tmpl_id      => $tmpl->{'tmpl_id'},
    tmpl_code    => $tmpl->{'tmpl_code'},
    tmpl_desc    => $tmpl->{'tmpl_desc'},
    page_width   => $tmpl->{'page_width'},
    page_height  => $tmpl->{'page_height'},
    label_width  => $tmpl->{'label_width'},
    label_height => $tmpl->{'label_height'},
    topmargin    => $tmpl->{'topmargin'},
    leftmargin   => $tmpl->{'leftmargin'},
    cols         => $tmpl->{'cols'},
    rows         => $tmpl->{'rows'},
    colgap       => $tmpl->{'colgap'},
    rowgap       => $tmpl->{'rowgap'},
    fontsize     => $tmpl->{'fontsize'},
    active       => $tmpl->{'active'},
);

output_html_with_http_headers $query, $cookie, $template->output;
