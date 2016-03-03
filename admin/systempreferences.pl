#!/usr/bin/perl

# script to administer the systempref table
# written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

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

=head1 systempreferences.pl

ALSO :
 this script use an $op to know what to do.
 if $op is empty or none of the above values,
    - the default screen is build (with all records, or filtered datas).
    - the   user can clic on add, modify or delete record.
 if $op=add_form
    - if primkey exists, this is a modification,so we read the $primkey record
    - builds the add/modify form
 if $op=add_validate
    - the user has just send datas, so we create/modify the record
 if $op=delete_form
    - we show the record having primkey=$primkey and ask for deletion validation form
 if $op=delete_confirm
    - we delete the record having primkey=$primkey

=cut

use strict;
use warnings;

use CGI qw ( -utf8 );
use MIME::Base64;
use C4::Auth;
use C4::Context;
use C4::Koha;
use C4::Languages qw(getTranslatedLanguages);
use C4::ClassSource;
use C4::Output;
use YAML::Syck qw( Dump LoadFile );

my %tabsysprefs; #we do no longer need to keep track of a tab per pref (yaml)

sub StringSearch {
    my ( $searchstring, $tab ) = @_;
    return (0,[]) if $tab ne 'local_use';

    my $dbh = C4::Context->dbh;
    $searchstring =~ s/\'/\\\'/g;
    my @data = split( ' ', $searchstring );
    my $count = @data;
    my @results;
    my $cnt = 0;
    my $sth;

    my $strsth = "Select variable,value,explanation,type,options from systempreferences where variable in (";
    my $first = 1;
    my @sql_bind;
    for my $name ( get_local_prefs() ) {
                $strsth .= ',' unless $first;
                $strsth .= "?";
                push(@sql_bind,$name);
                $first = 0;
    }
    $strsth .= ") order by variable";
    $sth = $dbh->prepare($strsth);
    $sth->execute(@sql_bind);

    while ( my $data = $sth->fetchrow_hashref ) {
            unless (defined $data->{value}) { $data->{value} = "";}
            $data->{shortvalue} = $data->{value};
            $data->{shortvalue} = substr( $data->{value}, 0, 60 ) . "..." if length( $data->{value} ) > 60;
            push( @results, $data );
            $cnt++;
    }

    return ( $cnt, \@results );
}

sub GetPrefParams {
    my $data   = shift;
    my $params = $data;
    my @options;

    if ( defined $data->{'options'} ) {
        foreach my $option ( split( /\|/, $data->{'options'} ) ) {
            my $selected = '0';
            defined( $data->{'value'} ) and $option eq $data->{'value'} and $selected = 1;
            push @options, { option => $option, selected => $selected };
        }
    }

    $params->{'prefoptions'} = $data->{'options'};

    if ( not defined( $data->{'type'} ) ) {
        $params->{'type_free'} = 1;
        $params->{'fieldlength'} = ( defined( $data->{'options'} ) and $data->{'options'} and $data->{'options'} > 0 );
    } elsif ( $data->{'type'} eq 'Upload' ) {
        $params->{'type_upload'} = 1;
    } elsif ( $data->{'type'} eq 'Choice' ) {
        $params->{'type_choice'} = 1;
    } elsif ( $data->{'type'} eq 'YesNo' ) {
        $params->{'type_yesno'} = 1;
        $data->{'value'}        = C4::Context->boolean_preference( $data->{'variable'} );
        if ( defined( $data->{'value'} ) and $data->{'value'} eq '1' ) {
            $params->{'value_yes'} = 1;
        } else {
            $params->{'value_no'} = 1;
        }
    } elsif ( $data->{'type'} eq 'Integer' || $data->{'type'} eq 'Float' ) {
        $params->{'type_free'} = 1;
        $params->{'fieldlength'} = ( defined( $data->{'options'} ) and $data->{'options'} and $data->{'options'} > 0 ) ? $data->{'options'} : 10;
    } elsif ( $data->{'type'} eq 'Textarea' ) {
        $params->{'type_textarea'} = 1;
        $data->{options} =~ /(.*)\|(.*)/;
        $params->{'cols'} = $1;
        $params->{'rows'} = $2;
    } elsif ( $data->{'type'} eq 'Htmlarea' ) {
        $params->{'type_htmlarea'} = 1;
        $data->{options} =~ /(.*)\|(.*)/;
        $params->{'cols'} = $1;
        $params->{'rows'} = $2;
    } elsif ( $data->{'type'} eq 'Themes' ) {
        $params->{'type_choice'} = 1;
        my $type = '';
        ( $data->{'variable'} =~ m#opac#i ) ? ( $type = 'opac' ) : ( $type = 'intranet' );
        @options = ();
        my $currently_selected_themes;
        my $counter = 0;
        foreach my $theme ( split /\s+/, $data->{'value'} ) {
            push @options, { option => $theme, counter => $counter };
            $currently_selected_themes->{$theme} = 1;
            $counter++;
        }
        foreach my $theme ( getallthemes($type) ) {
            my $selected = '0';
            next if $currently_selected_themes->{$theme};
            push @options, { option => $theme, counter => $counter };
            $counter++;
        }
    } elsif ( $data->{'type'} eq 'ClassSources' ) {
        $params->{'type_choice'} = 1;
        my $type = '';
        @options = ();
        my $sources = GetClassSources();
        my $counter = 0;
        foreach my $cn_source ( sort keys %$sources ) {
            if ( $cn_source eq $data->{'value'} ) {
                push @options, { option => $cn_source, counter => $counter, selected => 1 };
            } else {
                push @options, { option => $cn_source, counter => $counter };
            }
            $counter++;
        }
    } elsif ( $data->{'type'} eq 'Languages' ) {
        my $currently_selected_languages;
        foreach my $language ( split /\s+/, $data->{'value'} ) {
            $currently_selected_languages->{$language} = 1;
        }

        # current language
        my $lang = $params->{'lang'};
        my $theme;
        my $interface;
        if ( $data->{'variable'} =~ /opac/ ) {

            # this is the OPAC
            $interface = 'opac';
            $theme     = C4::Context->preference('opacthemes');
        } else {

            # this is the staff client
            $interface = 'intranet';
            $theme     = C4::Context->preference('template');
        }
        my $languages_loop = getTranslatedLanguages( $interface, $theme, $lang, $currently_selected_languages );

        $params->{'languages_loop'}    = $languages_loop;
        $params->{'type_langselector'} = 1;
    } else {
        $params->{'type_free'} = 1;
        $params->{'fieldlength'} = ( defined( $data->{'options'} ) and $data->{'options'} and $data->{'options'} > 0 ) ? $data->{'options'} : 30;
    }

    if ( $params->{'type_choice'} || $params->{'type_free'} || $params->{'type_yesno'} ) {
        $params->{'oneline'} = 1;
    }

    $params->{'preftype'} = $data->{'type'};
    $params->{'options'}  = \@options;

    return $params;
}

my $input       = new CGI;
my $searchfield = $input->param('searchfield') || '';
my $Tvalue      = $input->param('Tvalue');
my $offset      = $input->param('offset') || 0;
my $script_name = "/cgi-bin/koha/admin/systempreferences.pl";

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/systempreferences.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);
my $pagesize = 100;
my $op = $input->param('op') || '';
$searchfield =~ s/\,//g;

if ($op) {
    $template->param(
        script_name => $script_name,
        $op         => 1
    );    # we show only the TMPL_VAR names $op
} else {
    $template->param(
        script_name => $script_name,
        else        => 1
    );    # we show only the TMPL_VAR names $op
}

if ( $op eq 'update_and_reedit' ) {
    foreach ( $input->param ) {
    }
    my $value = '';
    if ( my $currentorder = $input->param('currentorder') ) {
        my @currentorder = split /\|/, $currentorder;
        my $orderchanged = 0;
        foreach my $param ( $input->param ) {
            if ( $param =~ m#up-(\d+).x# ) {
                my $temp = $currentorder[$1];
                $currentorder[$1]       = $currentorder[ $1 - 1 ];
                $currentorder[ $1 - 1 ] = $temp;
                $orderchanged           = 1;
                last;
            } elsif ( $param =~ m#down-(\d+).x# ) {
                my $temp = $currentorder[$1];
                $currentorder[$1]       = $currentorder[ $1 + 1 ];
                $currentorder[ $1 + 1 ] = $temp;
                $orderchanged           = 1;
                last;
            }
        }
        $value = join ' ', @currentorder;
        if ($orderchanged) {
            $op = 'add_form';
            $template->param(
                script_name => $script_name,
                $op         => 1
            );    # we show only the TMPL_VAR names $op
        } else {
            $op          = '';
            $searchfield = '';
            $template->param(
                script_name => $script_name,
                else        => 1
            );    # we show only the TMPL_VAR names $op
        }
    }
    my $variable = $input->param('variable');
    C4::Context->set_preference($variable, $value) unless C4::Context->config('demo');
}

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record

if ( $op eq 'add_form' ) {

    #---- if primkey exists, it's a modify action, so read values to modify...
    my $data;
    if ($searchfield) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("select variable,value,explanation,type,options from systempreferences where variable=?");
        $sth->execute($searchfield);
        $data = $sth->fetchrow_hashref;
        $template->param( modify => 1 );

        # save tab to return to if user cancels edit
        $template->param( return_tab => $tabsysprefs{$searchfield} );
    }

    $data->{'lang'} = $template->param('lang');
    my $prefparams = GetPrefParams($data);
    $template->param( %$prefparams );
    $template->param( searchfield => $searchfield );

################## ADD_VALIDATE ##################################
    # called by add_form, used to insert/modify data in DB
} elsif ( $op eq 'add_validate' ) {
    # to handle multiple values
    my $value;

    my $variable = $input->param('variable');
    my $expl     = $input->param('explanation');
    my $type     = $input->param('preftype');
    my $options  = $input->param('prefoptions');

    # handle multiple value strings (separated by ',')
    my $params = $input->Vars;
    if ( defined $params->{'value'} ) {
        my @values = ();
        @values = split( "\0", $params->{'value'} ) if defined( $params->{'value'} );
        if (@values) {
            $value = "";
            for my $vl (@values) {
                $value .= "$vl,";
            }
            $value =~ s/,$//;
        } else {
            $value = $params->{'value'};
        }
    }

    if ( $type eq 'Upload' ) {
        my $lgtfh = $input->upload('value');
        $value = join '', <$lgtfh>;
        $value = encode_base64($value);
    }

    C4::Context->set_preference( $variable, $value, $expl, $type, $options )
        unless C4::Context->config('demo');
    print $input->redirect("/cgi-bin/koha/admin/systempreferences.pl?tab=");
    exit;
################## DELETE_CONFIRM ##################################
    # called by default form, used to confirm deletion of data in DB
} elsif ( $op eq 'delete_confirm' ) {
    my $value = C4::Context->preference($searchfield);
    $template->param(
        searchfield => $searchfield,
        Tvalue      => $value,
    );

    # END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
    # called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ( $op eq 'delete_confirmed' ) {
    C4::Context->delete_preference($searchfield);
    # END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else {    # DEFAULT
            #Adding tab management for system preferences
    my $tab = $input->param('tab')||'local_use';
    $template->param( $tab => 1 );
    my ( $count, $results ) = StringSearch( $searchfield, $tab );
    my @loop_data = ();
    for ( my $i = $offset ; $i < ( $offset + $pagesize < $count ? $offset + $pagesize : $count ) ; $i++ ) {
        my $row_data = $results->[$i];
        $row_data->{'lang'} = $template->param('lang');
        $row_data           = GetPrefParams($row_data);                                                         # get a fresh hash for the row data
        $row_data->{edit}   = "$script_name?op=add_form&amp;searchfield=" . $results->[$i]{'variable'};
        $row_data->{delete} = "$script_name?op=delete_confirm&amp;searchfield=" . $results->[$i]{'variable'};
        push( @loop_data, $row_data );
    }
    $template->param( loop => \@loop_data );
    if ( $offset > 0 ) {
        my $prevpage = $offset - $pagesize;
        $template->param( "<a href=$script_name?offset=" . $prevpage . '&lt;&lt; Prev</a>' );
    }
    if ( $offset + $pagesize < $count ) {
        my $nextpage = $offset + $pagesize;
        $template->param( "a href=$script_name?offset=" . $nextpage . 'Next &gt;&gt;</a>' );
    }
    $template->param( tab => $tab, );
}    #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;


# Return an array containing all preferences defined in current Koha instance
# .pref files.

sub get_prefs_from_files {
    my $context       = C4::Context->new();
    my $path_pref_en  = $context->config('intrahtdocs') .
                        '/prog/en/modules/admin/preferences';
    # Get all .pref file names
    opendir ( my $fh, $path_pref_en );
    my @pref_files = grep { /.pref/ } readdir($fh);
    close $fh;

    my @names = ();
    my $append = sub {
        my $prefs = shift;
        for my $pref ( @$prefs ) {
            for my $element ( @$pref ) {
                if ( ref( $element) eq 'HASH' ) {
                    my $name = $element->{pref};
                    next unless $name;
                    push @names, $name;
                    next;
                }
            }
        }
    };
    for my $file (@pref_files) {
        my $pref = LoadFile( "$path_pref_en/$file" );
        for my $tab ( keys %$pref ) {
            my $content = $pref->{$tab};
            if ( ref($content) eq 'ARRAY' ) {
                $append->($content);
                next;
            }
            for my $section ( keys %$content ) {
                my $syspref = $content->{$section};
                $append->($syspref);
            }
        }
    }
    return @names;
}


# Return an array containg all preferences defined in DB

sub get_prefs_from_db {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT variable FROM systempreferences");
    $sth->execute;
    my @names = ();
    while ( (my $name) = $sth->fetchrow_array ) {
        push @names, $name if $name;
    }
    return @names;
}


# Return an array containing all local preferences: those which are defined in
# DB and not defined in Koha .pref files.

sub get_local_prefs {
    my @prefs_file = get_prefs_from_files();
    my @prefs_db = get_prefs_from_db();

    my %prefs_file = map { lc $_ => 1 } @prefs_file;
    my @names = ();
    foreach my $name (@prefs_db) {
        push @names, $name  unless $prefs_file{lc $name};
    }

    return @names;
}

