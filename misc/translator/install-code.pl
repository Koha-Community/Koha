#!/usr/bin/perl

use strict;

=head1 NAME

install-code.pl 

=head1 USAGE

Install templates for given language codes.

For example:

   ./install-code fr-FR en-ES

creates templates for languages: fr-FR and en-ES

=cut



sub install_code {
    my $code = shift;
    opendir(PO_DIR, "po") or die "Unable to open po directory";
    my @po_files = grep { /^$code-i-opac|^$code-i-staff/ } readdir PO_DIR;
    closedir PO_DIR;
    
    foreach ( @po_files ) {
        my ($interface) = /(staff|opac)/;
        $interface =~ s/staff/intranet/;        
        mkdir "../../koha-tmpl/$interface-tmpl/prog/$code";
        print $_, " : ", $interface, "\n";
        my $cmd = "./tmpl_process3.pl install -r " . 
                  "-i ../../koha-tmpl/$interface-tmpl/prog/en/ " .
                  "-o ../../koha-tmpl/$interface-tmpl/prog/$code/ " .
                  "-s po/$_";
        system $cmd;
    }
}


# Main

install_code ( $_ ) foreach ( @ARGV );

