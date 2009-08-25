#! /usr/bin/perl
# vim: enc=utf-8 fdm=marker fdn=1 sw=4
use utf8;
use strict;
use warnings;
use Devel::SimpleTrace;
use Storable qw< freeze thaw >;
use C4::Auth;
use C4::Context;
use C4::Biblio;
use C4::VirtualShelves;
use YAML;
use CGI;

sub debug { print STDERR @_,"\n" }

# Global values {{{
my $query   = CGI->new;
my $sessionID = (checkauth($query))[2];
my $session = C4::Auth::get_session( $sessionID );

my ( $template, $user, $cookie ) = get_template_and_user {
    qw(
    template_name virtualshelves/merge.tmpl
    type intranet
    authnotrequired 0
    )
    , query => $query
    , flagsrequired => {}
};
# }}}
# Functions {{{

sub render {
    use C4::Output;
    $template->param( session => $sessionID ); 
    output_html_with_http_headers $query, $cookie, $template->output;
}

sub maybe_lost {
    $template->param( maybe_lost => 1 );
    render; exit;
}

sub fields_to_merge { $session->param('fields_to_merge') }

# global values ... but only for nextid

my $selection_id = 0;
sub nextid { $selection_id++ }

sub prepare_subfield { { key => $$_[0], value => $$_[1]  } }

sub prepare_field {
    my $ready = {
	field => freeze($_)
	, from => shift
	, tag => $_->tag 
	, id => nextid
    };

    if ( $_->is_control_field ) {
	$$ready{control} = 1;
    } else {
	$$ready{subfields} = [ map prepare_subfield, $_->subfields ]
    };

    $ready;
}

sub fields_by_tag { $$a{tag} cmp $$b{tag} }

sub build_records {
    my $newbiblio = MARC::Record->new;
    my $items = MARC::Record->new;
    my ( $selected_fields ) = @_;
    my $stored_fields = $session->param('fields');
    my $kept_biblio   = $stored_fields->[0]->{id};
    my %biblio_to_delete;

    for ( @$stored_fields  ) {
	my $from = $$_{from};
	$biblio_to_delete{ $from } = 1;

	if ( $$_{tag} eq '995' ) {
	    if ( $from != $kept_biblio ) {
		$items->append_fields( thaw $$_{field} )
	    }
	} else {
	    if ( exists $$selected_fields{ $$_{id} } ) {
		$newbiblio->append_fields( thaw $$_{field} )
	    }
	}
    }
    delete $biblio_to_delete{ $kept_biblio };
    ( $newbiblio, $kept_biblio, $items, [ values %biblio_to_delete ] );
}

sub clear_session { (shift)->clear([qw< fields shelf >]) }

# }}}
# the controller {{{

if ( my %field_selection = map { $_ => 1 } $query->param('selected_field') ) {
    my ($record, $number, $items, $delete ) = build_records( \%field_selection );
    ModBiblio( $record, $number, GetFrameworkCode( $number ));
    AddItems( $items, $number );
    for ( @$delete ) {
	if ( my $error = DelBiblio($_) ) {
	    die $error
	}
    }
} else {
    my $shelf = $query->param('shelf') or maybe_lost;
    if ( my @records = C4::VirtualShelves::each_biblionumbers {
	    { id => $_, record => GetMarcBiblio($_) }
	} $shelf
    ) {
	my @fields = sort {fields_by_tag} map {
	    my ( $id , $record ) = @$_{qw< id record >};
	    map { prepare_field($id) } $record->fields;
	} @records;
	my @store = ( fields => \@fields ); 

	for ($session) {
	    clear_session($_);
	    $_->param(@store, shelf => $shelf );
	}
	$template->param(@store);
    } else {
	die "GET LOST ?";
    }
}

render;

# }}}
