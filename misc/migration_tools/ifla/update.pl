#!/usr/bin/env perl

# Copyright 2018 BibLibre
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

use Date::Format   qw( time2str );
use File::Basename qw( basename );
use FindBin        qw( $Bin );
use Getopt::Long   qw( GetOptions );
use Locale::PO;
use YAML::XS;
use utf8;

use Koha::Database;

my $help;
my $po_file;
my $dump_pot;
my $force;
GetOptions(
    'help'      => \$help,
    'po-file=s' => \$po_file,
    'dump-pot'  => \$dump_pot,
    'force'     => \$force,
) or die 'Error in command line arguments';

if ($help) {
    my $basename = basename($0);
    say <<"EOT";
Usage:
    $basename [--po-file FILE] [--force]
    $basename --dump-pot
    $basename --help

This script adds new fields and subfields for biblio and authority, new
authority types and new authorised values, for UNIMARC IFLA update

Options:
    --help
        Display this help

    --po-file FILE
        PO file containing translations

    --dump-pot
        Print a POT file containing all translatable strings and exit

    --force
        Force updating existing data
EOT

    exit 0;
}

my $defaults          = YAML::XS::LoadFile("$Bin/data/defaults.yml");
my $authorised_values = YAML::XS::LoadFile("$Bin/data/authorised_values.yml");
my $authtypes         = YAML::XS::LoadFile("$Bin/data/authtypes.yml");
my @authtags;
my @authsubfields;
for my $authfw (qw(default CLASS CO EXP FAM GENRE_FORM NP NTEXP NTWORK PA PERS PUB SAUTTIT SNC SNG TM TU WORK)) {
    my $file = YAML::XS::LoadFile("$Bin/data/auth/$authfw.yml");
    push @authtags,      @{ $file->{authtags} };
    push @authsubfields, @{ $file->{authsubfields} };
}
my $biblio    = YAML::XS::LoadFile("$Bin/data/biblio/default.yml");
my @tags      = @{ $biblio->{tags} };
my @subfields = @{ $biblio->{subfields} };

my $translations = {};
if ($dump_pot) {
    $translations->{''} = Locale::PO->new(
        -msgid  => '',
        -msgstr => "Project-Id-Version: Koha\n"
            . "POT-Creation-Date: "
            . time2str( '%Y-%m-%d %R%z', time ) . "\n"
            . "MIME-Version: 1.0\n"
            . "Content-Type: text/plain; charset=UTF-8\n"
            . "Content-Transfer-Encoding: 8bit\n",
    );
    while ( my ( $category, $values ) = each %$authorised_values ) {
        foreach my $authorised_value (@$values) {
            $translations->{ $authorised_value->{lib} } = Locale::PO->new(
                -msgid  => $authorised_value->{lib},
                -msgstr => '',
            );
        }
    }
    for my $tag (@tags) {
        $translations->{ $tag->{liblibrarian} } = Locale::PO->new(
            -msgid  => $tag->{liblibrarian},
            -msgstr => '',
        );
    }
    for my $subfield (@subfields) {
        $translations->{ $subfield->{liblibrarian} } = Locale::PO->new(
            -msgid  => $subfield->{liblibrarian},
            -msgstr => '',
        );
    }
    for my $authtype (@$authtypes) {
        $translations->{ $authtype->{authtypetext} } = Locale::PO->new(
            -msgid  => $authtype->{authtypetext},
            -msgstr => '',
        );
    }
    for my $authtag (@authtags) {
        $translations->{ $authtag->{liblibrarian} } = Locale::PO->new(
            -msgid  => $authtag->{liblibrarian},
            -msgstr => '',
        );
    }
    for my $authsubfield (@authsubfields) {
        $translations->{ $authsubfield->{liblibrarian} } = Locale::PO->new(
            -msgid  => $authsubfield->{liblibrarian},
            -msgstr => '',
        );
    }

    Locale::PO->save_file_fromhash( "$Bin/language/template.pot", $translations, 'utf8' );

    exit 0;
}

if ($po_file) {
    $translations = Locale::PO->load_file_ashash( $po_file, 'utf8' );
}

sub t {
    my ($string) = @_;

    my $quoted_string = Locale::PO->quote($string);
    unless ( exists $translations->{$quoted_string} and $translations->{$quoted_string} ) {
        return $string;
    }

    return Locale::PO->dequote( $translations->{$quoted_string}->msgstr );
}

my $schema                       = Koha::Database->new()->schema();
my $authorised_value_rs          = $schema->resultset('AuthorisedValue');
my $authorised_value_category_rs = $schema->resultset('AuthorisedValueCategory');
my $marc_tag_structure_rs        = $schema->resultset('MarcTagStructure');
my $marc_subfield_structure_rs   = $schema->resultset('MarcSubfieldStructure');
my $auth_type_rs                 = $schema->resultset('AuthType');
my $auth_tag_structure_rs        = $schema->resultset('AuthTagStructure');
my $auth_subfield_structure_rs   = $schema->resultset('AuthSubfieldStructure');

my $av_defaults = $defaults->{av};
while ( my ( $category, $values ) = each %$authorised_values ) {
    foreach my $authorised_value (@$values) {
        foreach my $key ( keys %$av_defaults ) {
            unless ( exists $authorised_value->{$key} ) {
                $authorised_value->{$key} = $av_defaults->{$key};
            }
        }
        $authorised_value->{category} = $category;
        $authorised_value->{lib}      = t( $authorised_value->{lib} );

        my $value = $authorised_value->{authorised_value};
        my $av    = $authorised_value_rs->find(
            {
                category         => $category,
                authorised_value => $value,
            }
        );
        if ($av) {
            say "Authorised value already exists ($category, $value)";
            if ($force) {
                say "Force mode is active, updating authorised value ($category, $value)";
                $av->update($authorised_value);
            }
            next;
        }

        my $cat = $authorised_value_category_rs->find($category);
        if ( !$cat ) {
            say "Adding authorised value category $category";
            $authorised_value_category_rs->create(
                {
                    category_name => $category,
                }
            );
        }

        say "Adding authorised value ($category, $value)";
        $authorised_value_rs->create($authorised_value);
    }
}

my $tag_defaults = $defaults->{tag};
for my $tag (@tags) {
    foreach my $key ( keys %$tag_defaults ) {
        unless ( exists $tag->{$key} ) {
            $tag->{$key} = $tag_defaults->{$key};
        }
    }
    $tag->{liblibrarian} = t( $tag->{liblibrarian} );

    my $mts = $marc_tag_structure_rs->find( '', $tag->{tagfield} );
    if ($mts) {
        say "Field already exists: " . $tag->{tagfield};
        if ($force) {
            say "Force mode is active, updating field " . $tag->{tagfield};
            $mts->update($tag);
        }
        next;
    }

    say "Adding field " . $tag->{tagfield};
    $marc_tag_structure_rs->create($tag);
}

my @mss = $marc_subfield_structure_rs->search( { frameworkcode => '' } );
my %tab_for_field;
foreach my $mss (@mss) {
    next if $mss->tab < 0;
    next if exists $tab_for_field{ $mss->tagfield };
    $tab_for_field{ $mss->tagfield } = $mss->tab;
}

my $subfield_defaults = $defaults->{subfield};
for my $subfield (@subfields) {
    foreach my $key ( keys %$subfield_defaults ) {
        unless ( exists $subfield->{$key} ) {
            $subfield->{$key} = $subfield_defaults->{$key};
        }
    }
    $subfield->{liblibrarian} = t( $subfield->{liblibrarian} );

    # If other subfields exist in this field, use the same tab
    if ( exists $tab_for_field{ $subfield->{tagfield} } ) {
        $subfield->{tab} = $tab_for_field{ $subfield->{tagfield} };
    }

    my $mss = $marc_subfield_structure_rs->find( '', $subfield->{tagfield}, $subfield->{tagsubfield} );
    if ($mss) {
        say sprintf( 'Subfield already exists: %s$%s', $subfield->{tagfield}, $subfield->{tagsubfield} );
        if ($force) {
            say sprintf(
                'Force mode is active, updating subfield %s$%s', $subfield->{tagfield},
                $subfield->{tagsubfield}
            );

            # Do not modify the tab of existing subfield
            my %values = %$subfield;
            delete $values{tab};

            $mss->update( \%values );
        }
        next;
    }

    say sprintf( 'Adding subfield %s$%s', $subfield->{tagfield}, $subfield->{tagsubfield} );
    $marc_subfield_structure_rs->create($subfield);
}

for my $authtype (@$authtypes) {
    $authtype->{authtypetext} = t( $authtype->{authtypetext} );

    my $at = $auth_type_rs->find( $authtype->{authtypecode} );
    if ($at) {
        say "Authority type already exists: " . $authtype->{authtypecode};
        if ($force) {
            say "Force mode is active, updating authority type " . $authtype->{authtypecode};
            $at->update($authtype);
        }
        next;
    }

    say "Adding authority type " . $authtype->{authtypecode};
    $auth_type_rs->create($authtype);
}

my $authtag_defaults = $defaults->{authtag};
for my $authtag (@authtags) {
    foreach my $key ( keys %$authtag_defaults ) {
        unless ( exists $authtag->{$key} ) {
            $authtag->{$key} = $authtag_defaults->{$key};
        }
    }
    $authtag->{liblibrarian} = t( $authtag->{liblibrarian} );

    my $ats = $auth_tag_structure_rs->find( $authtag->{authtypecode}, $authtag->{tagfield} );
    if ($ats) {
        say sprintf( 'Auth field already exists: %s (%s)', $authtag->{tagfield}, $authtag->{authtypecode} );
        if ($force) {
            say sprintf(
                'Force mode is active, updating auth field %s (%s)', $authtag->{tagfield},
                $authtag->{authtypecode}
            );
            $ats->update($authtag);
        }
        next;
    }

    say sprintf( 'Adding auth field %s (%s)', $authtag->{tagfield}, $authtag->{authtypecode} );
    $auth_tag_structure_rs->create($authtag);
}

my @ass = $auth_subfield_structure_rs->search();
my %tab_for_authfield;
foreach my $ass (@ass) {
    my $authtypecode = $ass->get_column('authtypecode');
    $tab_for_authfield{$authtypecode} //= {};

    next if $ass->tab < 0;
    next if exists $tab_for_authfield{$authtypecode}->{ $ass->tagfield };

    $tab_for_authfield{$authtypecode}->{ $ass->tagfield } = $ass->tab;
}

my $authsubfield_defaults = $defaults->{authsubfield};
for my $authsubfield (@authsubfields) {
    foreach my $key ( keys %$authsubfield_defaults ) {
        unless ( exists $authsubfield->{$key} ) {
            $authsubfield->{$key} = $authsubfield_defaults->{$key};
        }
    }
    $authsubfield->{liblibrarian} = t( $authsubfield->{liblibrarian} );

    # If other subfields exist in this field, use the same tab
    if ( exists $tab_for_authfield{ $authsubfield->{authtypecode} }->{ $authsubfield->{tagfield} } ) {
        $authsubfield->{tab} = $tab_for_authfield{ $authsubfield->{authtypecode} }->{ $authsubfield->{tagfield} };
    }

    my $ass = $auth_subfield_structure_rs->find(
        $authsubfield->{authtypecode}, $authsubfield->{tagfield},
        $authsubfield->{tagsubfield}
    );
    if ($ass) {
        say sprintf(
            'Auth subfield already exists: %s$%s (%s)', $authsubfield->{tagfield},
            $authsubfield->{tagsubfield},               $authsubfield->{authtypecode}
        );
        if ($force) {
            say sprintf(
                'Force mode is active, updating auth subfield %s$%s (%s)', $authsubfield->{tagfield},
                $authsubfield->{tagsubfield},                              $authsubfield->{authtypecode}
            );

            # Do not modify the tab of existing subfield
            my %values = %$authsubfield;
            delete $values{tab};

            $ass->update( \%values );
        }
        next;
    }

    say sprintf(
        'Adding auth subfield %s$%s (%s)', $authsubfield->{tagfield}, $authsubfield->{tagsubfield},
        $authsubfield->{authtypecode}
    );
    $auth_subfield_structure_rs->create($authsubfield);
}
