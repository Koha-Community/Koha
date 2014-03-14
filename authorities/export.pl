#!/usr/bin/perl
use strict;
use warnings;

use C4::Record;
use C4::Auth;
use C4::Output;
use C4::AuthoritiesMarc;
use CGI qw ( -utf8 );

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/export.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op     = $query->param("op");
my $format = $query->param("format");
my $error  = '';
if ( $op eq "export" ) {
    my $authid = $query->param("authid");
    if ($authid) {

        my $marc = GetAuthority($authid);

        if ( $format =~ /marcxml/ ) {
            $marc = marc2marcxml($marc, 'UTF-8', C4::Context->preference("marcflavour") eq 'UNIMARC' ? 'UNIMARCAUTH' : 'MARC21' );
        }
        elsif ($format=~ /mads/) {
            $marc = marc2madsxml($marc);
        }
        elsif ( $format =~ /marc8/ ) {
            $marc = changeEncoding( $marc, "MARC", "MARC21", "MARC-8" );
            $marc = $marc->as_usmarc();
        }
        elsif ( $format =~ /utf8/ ) {
            C4::Charset::SetUTF8Flag( $marc, 1 );
            $marc = $marc->as_usmarc();
        }
        print $query->header(
            -type       => 'application/octet-stream',
            -attachment => "auth-$authid.$format"
        );
        print $marc;
    }
}
