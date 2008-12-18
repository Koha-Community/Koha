#!/usr/bin/perl

#
# Copyright 2008 Tamil s.a.r.l.
#
# This software is placed under the gnu General Public License, v2 
# (http://www.gnu.org/licenses/gpl.html)
#

use strict;
use warnings;
use diagnostics;
use Carp;
use YAML::Syck;
use Pod::Usage;
use Getopt::Long;
use C4::Context;


my $verbose     = 0;
my $help        = 0;
my $conf        = '';
GetOptions( 
    'verbose'   => \$verbose,
    'help'      => \$help,
    'conf=s'    => \$conf,
);

sub usage {
    pod2usage( -verbose => 2 );
    exit;
} 

usage() if $help || !$conf;          


my @clouds;
print "Reading configuration file: $conf\n" if $verbose;
eval {
    @clouds = LoadFile( $conf );
};
croak "Unable to read configuration file: $conf\n" if $@;

for my $cloud ( @clouds ) {
    print "Create a cloud\n",
          "  Koha conf file:  ", $cloud->{KohaConf}, "\n",
          "  Zebra Index:     ", $cloud->{ZebraIndex}, "\n",
          "  Koha Keyword:    ", $cloud->{KohaIndex}, "\n",
          "  Count:           ", $cloud->{Count}, "\n",
          "  Withcss:         ", $cloud->{Withcss}, "\n",
          "  Output:          ", $cloud->{Output}, "\n",
      if $verbose;  

    # Set Koha context
    my $context = new C4::Context( $cloud->{KohaConf} );
    $context->set_context();

    my $index = new ZebraIndex( $cloud->{ZebraIndex} );
    $index->scan( $cloud->{Count} );

    open my $fh, ">", $cloud->{Output}
        or croak "Unable to create file ", $cloud->{Output};

    my $withcss = $cloud->{Withcss};
    $withcss =~ /^y/i;
    print $fh $index->html_cloud( $cloud->{KohaIndex}, $withcss );
    close $fh;
}



package ZebraIndex;


sub new {
    my $self = {};
    my $class = shift;
    $self->{ zebra_index  } = shift;
    $self->{ top_terms    } = undef;
    $self->{ levels_cloud } = 24;
    bless $self, $class;
    return $self;
}


#
# scan
#   Scan zebra index and populate an array of top terms
#
# PARAMETERS:
#   $max_terms    Max number of top terms
#
# RETURN:
#   A 4-dimensionnal array in $self->{top_terms}
#   [0] term
#   [1] term number of occurences
#   [2] term proportional relative weight in terms set E[0-1]
#   [3] term logarithmic relative weight E [0-levels_cloud]
#   
#   This array is sorted alphabetically by terms ([0])
#   It can be easily sorted by occurences:
#     @t = sort { $a[1] <=> $a[1] } @{$self->{top_terms}};
#
sub scan {
    my $self       = shift;
    my $index_name = $self->{ zebra_index };
    my $max_terms  = shift;
    
    my $MAX_OCCURENCE = 1000000000;
    
    my $zbiblio = C4::Context->Zconn( "biblioserver" );
    my $number_of_terms = 0; 
    my @terms;      # 2 dimensions array
    my $min_occurence_index = -1;
    my $min_occurence;
    my $from = '0';
    while (1) {
        my $ss;
        eval {
            print "$from\n" if $verbose;
            $from =~ s/\"/\\\"/g;
            my $query = '@attr 1=' . $index_name . ' @attr 4=1 @attr 6=3 "'
                        . $from . 'a"';
            $ss = $zbiblio->scan_pqf( $query );
        };
        if ($@) {
            chop $from;
            next;
        }
        $ss->option( rpnCharset => 'UTF-8' );
        last if $ss->size() == 0;
        my $term = '';
        my $occ = 0;
        for my $index ( 0..$ss->size()-1 ) {
            ($term, $occ) = $ss->display_term($index);
            #print "$term:$occ\n";
            if ( $number_of_terms < $max_terms ) {
                push( @terms, [ $term, $occ ] ); 
                ++$number_of_terms;
                if ( $number_of_terms == $max_terms ) {
                    $min_occurence = $MAX_OCCURENCE;
                    for (0..$number_of_terms-1) {
                        my @term = @{ $terms[$_] };
                        if ( $term[1] <= $min_occurence ) {
                            $min_occurence       = $term[1];
                            $min_occurence_index = $_;
                        }
                    }
                }
            }
            else {
                if ( $occ > $min_occurence) {
                    @{ $terms[$min_occurence_index] }[0] = $term;
                    @{ $terms[$min_occurence_index] }[1] = $occ;
                    $min_occurence = $MAX_OCCURENCE;
                    for (0..$max_terms-1) {
                        my @term = @{ $terms[$_] };
                        if ( $term[1] <= $min_occurence ) {
                            $min_occurence       = $term[1];
                            $min_occurence_index = $_;
                        }
                    }
                }
            }
        }
        $from = $term;
    }

    # Sort array of array by terms weight
    @terms = sort { @{$a}[1] <=> @{$b}[1] } @terms;
    
    # A relatif weight to other set terms is added to each term
    my $min     = $terms[0][1];
    my $log_min = log( $min );
    my $max     = $terms[$#terms-1][1];
    my $log_max = log( $max );
    my $delta   = $max - $min;
    my $factor;
    if ($log_max - $log_min == 0) {
        $log_min = $log_min - $self->{levels_cloud};
        $factor = 1;
    } 
    else {
        $factor = $self->{levels_cloud} / ($log_max - $log_min);
    }

    foreach (0..$#terms-1) {
        my $count = @{ $terms[$_] }[1];
        my $weight = ( $count - $min ) / $delta;
        my $log_weight = int( (log($count) - $log_min) * $factor);
        push( @{ $terms[$_] }, $weight );
        push( @{ $terms[$_] }, $log_weight );
    }
    $self->{ top_terms } = \@terms;

    # Sort array of array by terms alphabetical order
    @terms = sort { @{$a}[0] cmp @{$b}[0] } @terms;
}


#
# Returns a HTML version of index top terms formated
# as a 'tag cloud'.
#
sub html_cloud {
    my $self = shift;
    my $koha_index = shift;
    my $withcss = shift;
    my @terms = @{ $self->{top_terms} };
    my $html = <<EOS;
<style>
.subjectcloud {
    text-align:  center; 
    line-height: 16px; 
    margin: 20px;
    background: #f0f0f0;
    padding: 3%;
}
.subjectcloud a {
    font-weight: lighter;
    text-decoration: none;
}
span.tagcloud0  { font-size: 12px;}
span.tagcloud1  { font-size: 13px;}
span.tagcloud2  { font-size: 14px;}
span.tagcloud3  { font-size: 15px;}
span.tagcloud4  { font-size: 16px;}
span.tagcloud5  { font-size: 17px;}
span.tagcloud6  { font-size: 18px;}
span.tagcloud7  { font-size: 19px;}
span.tagcloud8  { font-size: 20px;}
span.tagcloud9  { font-size: 21px;}
span.tagcloud10 { font-size: 22px;}
span.tagcloud11 { font-size: 23px;}
span.tagcloud12 { font-size: 24px;}
span.tagcloud13 { font-size: 25px;}
span.tagcloud14 { font-size: 26px;}
span.tagcloud15 { font-size: 27px;}
span.tagcloud16 { font-size: 28px;}
span.tagcloud17 { font-size: 29px;}
span.tagcloud18 { font-size: 30px;}
span.tagcloud19 { font-size: 31px;}
span.tagcloud20 { font-size: 32px;}
span.tagcloud21 { font-size: 33px;}
span.tagcloud22 { font-size: 34px;}
span.tagcloud23 { font-size: 35px;}
span.tagcloud24 { font-size: 36px;}
</style>
<div class="subjectcloud">
EOS
    for (0..$#terms-1) {   
        my @term = @{ $terms[$_] };
        my $uri = $term[0];
        $uri =~ s/\(//g;
        $html = $html
            . '<span class="tagcloud'
            . $term[3]
            . '">'
            . '<a href="/cgi-bin/koha/opac-search.pl?q='
            . $koha_index
            . '%3A'
            . $uri
            . '">'
            . $term[0]
            . "</a></span>\n";
    }
    $html .= "</div>\n";
    return $html;
}


=head1 NAME

cloud-kw.pl - Creates HTML keywords clouds from Koha Zebra Indexes

=head1 USAGE

=over

=item cloud-kw.pl [--verbose|--help] --conf=F<cloud.conf> 

Creates multiple HTML files containing kewords cloud.
F<cloud.conf> is a YAML configuration file driving cloud generation
process.

=back

=head1 PARAMETERS

=over

=item B<--conf=configuration file>

Specify configuration file name

=item B<--verbose|-v>

Enable script verbose mode. 

=item B<--help|-h>

Print this help page.

=back

=head1 CONFIGURATION
    
Configuration file looks like that:

 --- 
  # Koha configuration file for a specific installation
  KohaConf: /home/koha/mylibray/etc/koha-conf.xml
  # Zebra index to scan
  ZebraIndex: Author
  # Koha index used to link found kewords with an opac search URL
  KohaIndex: au
  # Number of top keyword to used for the cloud
  Count: 50
  # Include CSS style directives with the cloud
  Withcss: Yes
  # HTML file where to output the cloud
  Output: /home/koha/mylibrary/koharoot/koha-tmpl/cloud-author.html
 --- 
  KohaConf: /home/koha/yourlibray/etc/koha-conf.xml
  ZebraIndex: Subject
  KohaIndex: su
  Count: 200
  Withcss: no
  Output: /home/koha/yourlibrary/koharoot/koha-tmpl/cloud-subject.html

=cut


