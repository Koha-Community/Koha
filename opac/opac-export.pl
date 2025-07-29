#!/usr/bin/perl

# Parts Copyright Catalyst IT 2011
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

use C4::Record;
use C4::Auth;
use C4::Output;
use C4::Biblio qw(
    GetFrameworkCode
    GetISBDView
);
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Ris qw( marc2ris );
use Koha::Biblios;
use Koha::RecordProcessor;

use List::MoreUtils qw(none any);

my $query = CGI->new;
my $op=$query->param("op")||''; #op=export is currently the only use
my $format=$query->param("format")||'utf8';
my $biblionumber = $query->param("bib")||0;
$biblionumber = int($biblionumber);
my $error = q{};

my @dc_subtypes   = qw(rdfdc oaidc srwdc);
my @valid_formats = split( ',', C4::Context->preference('OpacExportOptions') // '' );

if ( any { $_ eq 'dc' } @valid_formats ) {
    # DC enabled, add @dc_subtypes to @valid_formats
    @valid_formats = ( @valid_formats, @dc_subtypes );
}

if ( !scalar @valid_formats || none { $format eq $_ } @valid_formats ) {
    # bad request: either the feature is disabled, or requested a format the
    # library hasn't made available
    print $query->redirect("/cgi-bin/koha/errors/400.pl");
    exit;
}

# Determine logged in user's patron category.
# Blank if not logged in.
my $userenv = C4::Context->userenv;
my $patron;
if ($userenv) {
    my $borrowernumber = $userenv->{'number'};
    if ($borrowernumber) {
        $patron = Koha::Patrons->find( $borrowernumber );
    }
}

my $include_items = ($format =~ /bibtex/) ? 0 : 1;
my $biblio = Koha::Biblios->find($biblionumber);
my $marc = $biblio
  ? $biblio->metadata_record(
    {
        embed_items => 1,
        interface   => 'opac',
        patron      => $patron,
    }
  )
  : undef;

if(!$marc) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $metadata_extractor = $biblio->metadata_extractor;

my $file_id = $biblionumber;
my $file_pre = "bib-";
if ( C4::Context->preference('DefaultSaveRecordFileID') eq 'controlnumber' ) {
    my $control_number = $metadata_extractor->get_control_number();
    if ($control_number) {
        $file_id  = $control_number;
        $file_pre = "record-";
    }
}

my $framework = $biblio->frameworkcode;
my $record_processor = Koha::RecordProcessor->new({
    filters => 'ViewPolicy',
    options => {
        interface => 'opac',
        frameworkcode => $framework
    }
});
$record_processor->process($marc);

if ($format =~ /endnote/) {
    $marc = marc2endnote($marc);
    $format = 'endnote';
}
elsif ($format =~ /marcxml/) {
    $marc = marc2marcxml($marc, undef, undef, 1);
    $format = 'marcxml';
}
elsif ($format=~ /mods/) {
    $marc = marc2modsxml($marc);
    $format = 'mods';
}
elsif ($format =~ /ris/) {
    $marc = marc2ris($marc);
    $format = 'ris';
}
elsif ($format =~ /bibtex/) {
    $marc = marc2bibtex($marc,$biblionumber);
    $format = 'bibtex';
}
elsif ($format =~ /^(dc|oaidc|srwdc|rdfdc)$/i ) {
    # TODO: Dublin Core leaks fields marked hidden by framework.
    $marc = marc2dcxml($marc, undef, $biblionumber, $format);
    $format = "dublin-core.xml";
}
elsif ($format =~ /marc8/) {
    ($error,$marc) = changeEncoding($marc,"MARC","MARC21","MARC-8");
    $marc = $marc->as_usmarc() unless $error;
    $format = 'marc8';
}
elsif ($format =~ /utf8/) {
    C4::Charset::SetUTF8Flag($marc,0);
    $marc = $marc->as_usmarc();
    $format = 'utf8';
}
elsif ($format =~ /marcstd/) {
    C4::Charset::SetUTF8Flag($marc,0);
    ($error,$marc) = marc2marc($marc, 'marcstd', C4::Context->preference('marcflavour'));
    $format = 'marcstd';
}
elsif ( $format =~ /isbd/ ) {
    $marc   = GetISBDView({
        'record'    => $marc,
        'template'  => 'opac',
        'framework' => $framework,
    });
    $format = 'isbd';
}
else {
    $error= "Format $format is not supported.";
}

if ($error){
    print $query->header();
    print $query->start_html();
    print "<h1>An error occurred </h1>";
    print $query->escapeHTML("$error");
    print $query->end_html();
}
else {
    if ($format eq 'marc8'){
        print $query->header(
            -type => 'application/marc',
            -charset=>'ISO-2022',
            -attachment=>"$file_pre$file_id.$format");
    }
    elsif ( $format eq 'isbd' ) {
        print $query->header(
            -type       => 'text/plain',
            -charset    => 'utf-8',
            -attachment =>  "$file_pre$file_id.txt"
        );
    }
    elsif ( $format eq 'ris' ) {
        print $query->header(
            -type => 'text/plain',
            -charset => 'utf-8',
            -attachment => "$file_pre$file_id.$format"
        );
    } else {
        binmode STDOUT, ':encoding(UTF-8)';
        print $query->header(
            -type => 'application/octet-stream',
            -charset => 'utf-8',
            -attachment => "$file_pre$file_id.$format"
        );
    }
    print $marc;
}

1;
