#!/usr/bin/perl
#
# Copyright 2009 Jesse Weaver and the Koha Dev Team
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

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Context;
use C4::Koha;
use C4::Languages qw(getTranslatedLanguages);
use C4::ClassSource;
use C4::Log;
use C4::Output;
use C4::Templates;
use C4::Budgets qw(GetCurrency);
use File::Spec;
use IO::File;
use YAML::Syck qw();
use List::MoreUtils qw(any);
$YAML::Syck::ImplicitTyping = 1;
$YAML::Syck::ImplicitUnicode = 1;
our $lang;

# use Smart::Comments;
#

sub GetTab {
    my ( $input, $tab ) = @_;

    my $tab_template = C4::Templates::gettemplate( 'admin/preferences/' . $tab . '.pref', 'intranet', $input );

    my $active_currency = GetCurrency();
    my $local_currency;
    if ($active_currency) {
        $local_currency = $active_currency->{currency};
    }
    $tab_template->param(
        local_currency => $local_currency, # currency code is used, because we do not know how a given currency is formatted.
    );

    return YAML::Syck::Load( $tab_template->output() );
}

sub _get_chunk {
    my ( $value, %options ) = @_;

    my $name = $options{'pref'};
    my $chunk = { name => $name, value => $value, type => $options{'type'} || 'input', class => $options{'class'} };

    if ( $options{'class'} && $options{'class'} eq 'password' ) {
        $chunk->{'input_type'} = 'password';
    } elsif ( $options{'class'} && $options{'class'} eq 'date' ) {
        $chunk->{'dateinput'} = 1;
    } elsif ( $options{'type'} && ( $options{'type'} eq 'opac-languages' || $options{'type'} eq 'staff-languages' ) ) {
        my $current_languages = { map { +$_, 1 } split( /\s*,\s*/, $value ) };

        my $theme;
        my $interface;
        if ( $options{'type'} eq 'opac-languages' ) {
            # this is the OPAC
            $interface = 'opac';
            $theme     = C4::Context->preference('opacthemes');
        } else {
            # this is the staff client
            $interface = 'intranet';
            $theme     = C4::Context->preference('template');
        }
        $chunk->{'languages'} = getTranslatedLanguages( $interface, $theme, $lang, $current_languages );
        $chunk->{'type'} = 'languages';
    } elsif ( $options{ 'choices' } ) {
        if ( $options{'choices'} && ref( $options{ 'choices' } ) eq '' ) {
            if ( $options{'choices'} eq 'class-sources' ) {
                my $sources = GetClassSources();
                $options{'choices'} = { map { $_ => $sources->{$_}->{'description'} } keys %$sources };
            } elsif ( $options{'choices'} eq 'opac-templates' ) {
                $options{'choices'} = { map { $_ => $_ } getallthemes( 'opac' ) }
            } elsif ( $options{'choices'} eq 'staff-templates' ) {
                $options{'choices'} = { map { $_ => $_ } getallthemes( 'intranet' ) }
            } else {
                die 'Unrecognized source of preference values: ' . $options{'choices'};
            }
        }

        $value ||= 0;

        $chunk->{'type'} = 'select';
        $chunk->{'CHOICES'} = [
            sort { $a->{'text'} cmp $b->{'text'} }
            map { { text => $options{'choices'}->{$_}, value => $_, selected => ( $_ eq $value || ( $_ eq '' && ( $value eq '0' || !$value ) ) ) } }
            keys %{ $options{'choices'} }
        ];
    } elsif ( $options{'multiple'} ) {
        my @values;
        @values = split /,/, $value if defined($value);
        $chunk->{type}    = 'multiple';
        $chunk->{CHOICES} = [
            sort { $a->{'text'} cmp $b->{'text'} }
              map {
                my $option_value = $_;
                {
                    text     => $options{multiple}->{$option_value},
                    value    => $option_value,
                    selected => (grep /^$option_value$/, @values) ? 1 : 0,
                }
              }
              keys %{ $options{multiple} }
        ];
    }

    $chunk->{ 'type_' . $chunk->{'type'} } = 1;

    return $chunk;
}

sub TransformPrefsToHTML {
    my ( $data, $searchfield ) = @_;

    my @lines;
    my $dbh = C4::Context->dbh;
    my $title = ( keys( %$data ) )[0];
    my $tab = $data->{ $title };
    $tab = { '' => $tab } if ( ref( $tab ) eq 'ARRAY' );

    my @override_syspref_names;
    if ( exists($ENV{OVERRIDE_SYSPREF_NAMES}) &&
         defined($ENV{OVERRIDE_SYSPREF_NAMES})
       ) {
        @override_syspref_names = split /,/, $ENV{OVERRIDE_SYSPREF_NAMES};
    }

    foreach my $group ( sort keys %$tab ) {
        if ( $group ) {
            push @lines, { is_group_title => 1, title => $group };
        }

        foreach my $line ( @{ $tab->{ $group } } ) {
            my @chunks;
            my @names;

            foreach my $piece ( @$line ) {
                if ( ref ( $piece ) eq 'HASH' ) {
                    my $name = $piece->{'pref'};

                    if ( $name ) {
                        my $row = $dbh->selectrow_hashref( "SELECT value, type FROM systempreferences WHERE variable = ?", {}, $name );
                        my $value;
                        if ( ( !defined( $row ) || ( !defined( $row->{'value'} ) && $row->{'type'} ne 'YesNo' ) ) && defined( $piece->{'default'} ) ) {
                            $value = $piece->{'default'};
                        } else {
                            $value = $row->{'value'};
                        }
                        my $chunk = _get_chunk( $value, %$piece );

                        # No highlighting of inputs yet, but would be useful
                        $chunk->{'highlighted'} = 1 if ( $searchfield && $name =~ /^$searchfield$/i );

                        push @chunks, $chunk;

                        my $name_entry = { name => $name };
                        if ( $searchfield ) {
                            if ( $name =~ /^$searchfield$/i ) {
                                $name_entry->{'jumped'} = 1;
                            } elsif ( $name =~ /$searchfield/i ) {
                                $name_entry->{'highlighted'} = 1;
                            }
                        }
                        $name_entry->{'overridden'} = 1 if ( any { $name eq $_ } @override_syspref_names );
                        push @names, $name_entry;
                    } else {
                        push @chunks, $piece;
                    }
                } else {
                    push @chunks, { type_text => 1, contents => $piece };
                }
            }
            push @lines, { CHUNKS => \@chunks, NAMES => \@names, is_group_title => 0 };
        }
    }

    return $title, \@lines;
}

sub _get_pref_files {
    my ( $input, $open_files ) = @_;

    my ( $htdocs, $theme, $lang, undef ) = C4::Templates::_get_template_file( 'admin/preferences/admin.pref', 'intranet', $input );

    my %results;

    foreach my $file ( glob( "$htdocs/$theme/$lang/modules/admin/preferences/*.pref" ) ) {
        my ( $tab ) = ( $file =~ /([a-z0-9_-]+)\.pref$/ );

        $results{$tab} = $open_files ? new IO::File( $file, 'r' ) : '';
    }

    return %results;
}

sub SearchPrefs {
    my ( $input, $searchfield ) = @_;
    my @tabs;

    my %tab_files = _get_pref_files( $input );
    our @terms = split( /\s+/, $searchfield );

    foreach my $tab_name ( keys %tab_files ) {
        my $data = GetTab( $input, $tab_name );
        my $title = ( keys( %$data ) )[0];
        my $tab = $data->{ $title };
        $tab = { '' => $tab } if ( ref( $tab ) eq 'ARRAY' );

        my $matched_groups;

        while ( my ( $group_title, $contents ) = each %$tab ) {
            if ( matches( $group_title, \@terms ) ) {
                $matched_groups->{$group_title} = $contents;
                next;
            }

            my @new_contents;

            foreach my $line ( @$contents ) {
                my $matched;

                foreach my $piece ( @$line ) {
                    if ( ref( $piece ) eq 'HASH' ) {
                        if ( !$piece->{'pref'} ){
                            next;
                        }
                        if ( matches( $piece->{'pref'}, \@terms) ) {
                            $matched = 1;
                        } elsif ( ref( $piece->{'choices'} ) eq 'HASH' && grep( { $_ && matches( $_, \@terms ) } values( %{ $piece->{'choices'} } ) ) ) {
                            $matched = 1;
                        }
                    } elsif ( matches( $piece, \@terms ) ) {
                        $matched = 1;
                    }
                    last if ( $matched );
                }

                push @new_contents, $line if ( $matched );
            }

            $matched_groups->{$group_title} = \@new_contents if ( @new_contents );
        }

        if ( $matched_groups ) {
            my ( $title, $LINES ) = TransformPrefsToHTML( { $title => $matched_groups }, $searchfield );

            push @tabs, { tab => $tab, tab_title => $title, LINES => $LINES, tab_id => $tab_name };
        }
    }

    return @tabs;
}

sub matches {
    my ( $text, $terms ) = @_;
    if ( $text ) {
        return !grep(
            {
                my $re = eval{qr|$_|i};
                $re = qr|\Q$_\E| if $@;
                $text !~ m|$re|;
            } @$terms
        )
    }
}

my $dbh = C4::Context->dbh;
our $input = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/preferences.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

$lang = $template->param( 'lang' );
my $op = $input->param( 'op' ) || '';
my $tab = $input->param( 'tab' );
$tab ||= 'acquisitions'; # Ideally this should be "local-use" but preferences.pl
                         # does not presently support local use preferences

my $highlighted;

if ( $op eq 'save' ) {
    unless ( C4::Context->config( 'demo' ) ) {
        foreach my $param ( $input->param() ) {
            my ( $pref ) = ( $param =~ /pref_(.*)/ );

            next if ( !defined( $pref ) );

            my $value = join( ',', $input->param( $param ) );

            C4::Context->set_preference( $pref, $value );
        }
    }

    print $input->redirect( '/cgi-bin/koha/admin/preferences.pl?tab=' . $tab );
    exit;
}

my @TABS;

if ( $op eq 'search' ) {
    my $searchfield = $input->param( 'searchfield' );

    $searchfield =~ s/\p{IsC}//g;
    $searchfield =~ s/\s+/ /;
    $searchfield =~ s/^\s+//;
    $searchfield =~ s/\s+$//;

    $template->param( searchfield => $searchfield );

    @TABS = SearchPrefs( $input, $searchfield );

    foreach my $tabh ( @TABS ) {
        $template->param(
            $tabh->{'tab'} => 1
        );
    }

    if ( @TABS ) {
        $tab = ''; # No need to load a particular tab, as we found results
        $template->param( search_jumped => 1 ) if ( $TABS[0]->{'search_jumped'} );
    } else {
        $template->param(
            search_not_found => 1,
        );
    }
}

if ( $tab ) {
    my ( $tab_title, $LINES ) = TransformPrefsToHTML( GetTab( $input, $tab ), $highlighted );

    push @TABS, { tab_title => $tab_title, LINES => $LINES, tab_id => $tab };
    $template->param(
        $tab => 1,
        tab => $tab,
    );
}

$template->param( TABS => \@TABS );

output_html_with_http_headers $input, $cookie, $template->output;
