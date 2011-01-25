package C4::Templates;

use strict;
use warnings;
use Carp;

# Copyright 2009 Chris Cormack and The Koha Dev Team
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 NAME 

    Koha::Templates - Object for manipulating templates for use with Koha

=cut

use base qw(Class::Accessor);
use Template;
use Template::Constants qw( :debug );

use C4::Context;

__PACKAGE__->mk_accessors(qw( theme lang filename htdocs interface vars));

sub new {
    my $class     = shift;
    my $interface = shift;
    my $filename  = shift;
    my $htdocs;
    if ( $interface ne "intranet" ) {
        $htdocs = C4::Context->config('opachtdocs');
    }
    else {
        $htdocs = C4::Context->config('intrahtdocs');
    }

#    my ( $theme, $lang ) = themelanguage( $htdocs, $tmplbase, $interface, $query );
    my $theme = 'prog';
    my $lang = 'en';
    my $template = Template->new(
        {
            EVAL_PERL    => 1,
            ABSOLUTE     => 1,
            INCLUDE_PATH => "$htdocs/$theme/$lang/includes",
            FILTERS      => {},

        }
    ) or die Template->error();
    my $self = {
        TEMPLATE => $template,
	VARS => {},
    };
    bless $self, $class;
    $self->theme($theme);
    $self->lang($lang);
    $self->filename($filename);
    $self->htdocs($htdocs);
    $self->interface($interface);
    $self->{VARS}->{"test"} = "value";
    return $self;

}

sub output {
    my $self = shift;
    my $vars = shift;
#    my $file = $self->htdocs . '/' . $self->theme .'/'.$self->lang.'/'.$self->filename;
    my $template = $self->{TEMPLATE};
    if ($self->interface eq 'intranet'){
	$vars->{themelang} = '/intranet-tmpl';
    }
    else {
	$vars->{themelang} = '/opac-tmpl';
    }
    $vars->{lang} = $self->lang;
    $vars->{themelang}          .= '/' . $self->theme . '/' . $self->lang;
    $vars->{yuipath}             = (C4::Context->preference("yuipath") eq "local"?$self->{themelang}."/lib/yui":C4::Context->preference("yuipath"));
    $vars->{interface}           = ( $vars->{interface} ne 'intranet' ? '/opac-tmpl' : '/intranet-tmpl' );
    $vars->{theme}               = $self->theme;
    $vars->{opaccolorstylesheet} = C4::Context->preference('opaccolorstylesheet');
    $vars->{opacsmallimage}      = C4::Context->preference('opacsmallimage');
    $vars->{opacstylesheet}      = C4::Context->preference('opacstylesheet');
    #add variables set via param to $vars for processing
    for my $k(keys %{$self->{VARS}}){
	$vars->{$k} = $self->{VARS}->{$k};
    }
    my $data;
    $template->process( $self->filename, $vars, \$data) || die "Template process failed: ", $template->error();; 
    return $data;
}

# wrapper method to allow easier transition from HTML template pro to Template Toolkit
sub param{
    my $self = shift;
    while(@_){
	my $key = shift;
	my $val = shift;
        utf8::decode($val) if utf::is_utf8($val);
	$self->{VARS}->{$key} = $val;
    }
}

1;
