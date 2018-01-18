#!/usr/bin/perl
use Modern::Perl;

use C4::Record;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use CGI qw ( -utf8 );
use C4::Ris;



my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
    template_name   => "tools/export.tt",
    query           => $query,
    type            => "intranet",
    authnotrequired => 0,
    flagsrequired   => { catalogue => 1 },
    debug           => 1,
    });

my $op=$query->param("op");
my $format=$query->param("format");
my $error = '';
if ($op eq "export") {
    my $biblionumber = $query->param("bib");
        if ($biblionumber){

            my $marc = GetMarcBiblio({
                biblionumber => $biblionumber,
                embed_items  => 1 });

            if ($format =~ /endnote/) {
                $marc = marc2endnote($marc);
                $format = 'endnote';
            }
            elsif ($format =~ /marcxml/) {
                $marc = marc2marcxml($marc);
                $format = "marcxml";
            }
            elsif ($format=~ /mods/) {
                $marc = marc2modsxml($marc);
                $format = "mods";
            }
            elsif ($format =~ /ris/) {
                $marc = marc2ris($marc);
                $format = "ris";
            }
            elsif ($format =~ /bibtex/) {
                $marc = marc2bibtex($marc);
                $format = "bibtex";
            }
            elsif ($format =~ /dc$/) {
                $marc = marc2dcxml(undef, undef, $biblionumber, $format);
                $format = "dublin-core.xml";
            }
            elsif ($format =~ /marc8/) {
                $marc = changeEncoding($marc,"MARC","MARC21","MARC-8");
                $marc = $marc->as_usmarc();
                $format = "marc8";
            }
            elsif ($format =~ /utf8/) {
                C4::Charset::SetUTF8Flag($marc, 1);
                $marc = $marc->as_usmarc();
                $format = "utf8";
            }
            elsif ($format =~ /marcstd/) {
                C4::Charset::SetUTF8Flag($marc,1);
                ($error, $marc) = marc2marc($marc, 'marcstd', C4::Context->preference('marcflavour'));
                $format = "marcstd";
            }
            if ( $format =~ /utf8/ or $format =~ /marcstd/ ) {
                binmode STDOUT, ':encoding(UTF-8)';
            }
            print $query->header(
                -type => 'application/octet-stream',
                -attachment=>"bib-$biblionumber.$format");
            print $marc;
        }
}
