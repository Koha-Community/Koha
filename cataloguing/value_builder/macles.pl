#!/usr/bin/perl 


# Copyright 2000-2002 Katipo Communications
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

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;

# use Data::Dumper;
use vars qw( $tagslib);
use vars qw( $authorised_values_sth);
use vars qw( $is_a_modif );
use utf8;

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut

sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= "macles".(int(rand(100000))+1);
my $res="
<script type=\"text/javascript\">
//<![CDATA[

function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(i) {
	newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=macles.pl&index=\"+i,\"MACLES\",',toolbar=false,scrollbars=yes');

}
//]]>
</script>
";

return ($function_name,$res);
}

sub plugin {
my ($input) = @_;
	my %env;

#	my $input = new CGI;
	my $index= $input->param('index');


	my $dbh = C4::Context->dbh;
    my $rq=$dbh->prepare("SELECT authorised_value, lib from authorised_values where category=\"MACLES\" order by authorised_value DESC");
    #tabs
    $rq->execute;
    my @BIGLOOP;
    my @innerloop;
    my (%numbers,%cells,@colhdr,@rowhdr,@multiplelines,@lists,$table);
    while (my $tab = $rq->fetchrow_hashref){
#       if (! utf8::is_utf8($tab->{lib})) {
#         utf8::decode($tab->{lib});
#       }
#       warn $tab->{lib};
      my $number=substr($tab->{authorised_value},0,1);
      if ($tab->{authorised_value}=~/[0-9]XX/){
        $numbers{$number}->{'hdr_tab'}=$tab->{lib};
        $numbers{$number}->{'Table'}=($number=~/[1-7]/);
      } elsif ($tab->{authorised_value}=~/.X./){
        $tab->{authorised_value}=~s/X/\./;
        $table=1;
        unshift @{$numbers{$number}->{"col_hdr"}},{"colvalue"=>$tab->{authorised_value},"collib"=>$tab->{lib}};
      } elsif ($tab->{authorised_value}=~/..X/){
        $tab->{authorised_value}=~s/X/\./;
        unshift @{$numbers{$number}->{"row_hdr"}},{"rowvalue"=>$tab->{authorised_value},"rowlib"=>$tab->{lib}}
      } elsif ($tab->{'authorised_value'}=~/,/){
        my @listval=split /,/,$tab->{'authorised_value'};
#          $tab->{authorised_value}=~s/,/","/g;
#         $tab->{authorised_value}="(".$tab->{authorised_value}.")";
        my %mulrows;
        foreach my $val (@listval){
          unshift @{$numbers{$number}->{$val}},$tab->{'lib'};
          my $mulrow=substr($val,0,2);
          $mulrows{$mulrow}=1;
        }
        foreach my $mulrow (sort keys %mulrows){
          unshift @{$numbers{$number}->{$mulrow}},{'listlib' => $tab->{'lib'},'listvalue' => $tab->{'authorised_value'}};
        }
      } else {
        unshift @{$numbers{$number}->{$tab->{'authorised_value'}}},$tab->{'lib'};
      }
#        use Data::Dumper;warn "BIGLOOP IN".Dumper(@BIGLOOP);
    }
    foreach my $num ( sort keys %numbers ) {
        my @tmpcolhdr;
        my @tmprowhdr;
        @tmpcolhdr = @{ $numbers{$num}->{'col_hdr'} }
          if ( $numbers{$num}->{'col_hdr'} );
        @tmprowhdr = @{ $numbers{$num}->{"row_hdr"} }
          if ( $numbers{$num}->{'row_hdr'} );
        my @lines;
        my @lists;
        my %BIGLOOPcell;
        foreach my $row (@tmprowhdr) {
            my $tmprowvalue = $row->{rowvalue};
            my $rowcode;
            $rowcode = $1 if $tmprowvalue =~ /[0-9]([0-9])\./;
            my @cells;
            if ( scalar(@tmpcolhdr) > 0 ) {

                #cas du tableau bidim
                foreach my $col (@tmpcolhdr) {
                    my $tmpcolvalue = $col->{colvalue};
                    my $colcode;
                    $colcode = $1 if $tmpcolvalue =~ /[0-9]\.([0-9])/;
                    my %cell;
                    $cell{celvalue} = $num . $rowcode . $colcode;
                    $cell{rowvalue} = $tmprowvalue;
                    $cell{colvalue} = $tmpcolvalue;
                    if ( $numbers{$num}->{ $num . $rowcode . $colcode } ) {

                        foreach (
                            @{ $numbers{$num}->{ $num . $rowcode . $colcode } }
                          )
                        {
                            push @{ $cell{libs} }, { 'lib' => $_ };
                        }
                    }
                    else {
                        push @{ $cell{libs} },
                          { 'lib' => $num . $rowcode . $colcode };
                    }
                    push @cells, \%cell;
                }
                if ( $numbers{$num}->{ $num . $rowcode } ) {
                    my @tmpliblist = @{ $numbers{$num}->{ $num . $rowcode } };
                    push @lists,
                      { 'lib' => $row->{rowlib}, 'liblist' => \@tmpliblist };
                }
            }
            else {

                #Cas de la liste simple
                foreach my $key ( sort keys %{ $numbers{$num} } ) {
                    my %cell;
                    if ( $key =~ /$num$rowcode[0-9]/ ) {
                        $cell{celvalue} = $key;
                        foreach my $lib ( @{ $numbers{$num}->{$key} } ) {
                            push @{ $cell{'libs'} }, { 'lib' => $lib };
                        }
                        push @cells, \%cell;
                    }
                }
            }
            push @lines,
              {
                'cells'    => \@cells,
                'rowvalue' => $row->{rowvalue},
                'rowlib'   => $row->{rowlib}
              };
        }
        $BIGLOOPcell{'Lists'}   = \@lists     if ( scalar(@lists) > 0 );
        $BIGLOOPcell{'lines'}   = \@lines     if ( scalar(@lines) > 0 );
        $BIGLOOPcell{'col_hdr'} = \@tmpcolhdr if ( scalar(@tmpcolhdr) > 0 );
        $BIGLOOPcell{'Table'}   = $numbers{$num}->{'Table'};
        $BIGLOOPcell{'hdr_tab'} = $numbers{$num}->{'hdr_tab'};
        $BIGLOOPcell{'number'}  = $num;
        push @BIGLOOP, \%BIGLOOPcell;
    }
#     warn "BIGLOOP OUT".Dumper(@BIGLOOP);
    my ($template, $loggedinuser, $cookie)
        = get_template_and_user({template_name => "cataloguing/value_builder/macles.tt",
                    query => $input,
                    type => "intranet",
                    authnotrequired => 0,
                    flagsrequired => {editcatalogue => '*'},
                    debug => 1,
                    });
    $template->param(BIGLOOP=>\@BIGLOOP);
	$template->param("index"=>$index);
	output_html_with_http_headers $input, $cookie, $template->output;
}
1;


