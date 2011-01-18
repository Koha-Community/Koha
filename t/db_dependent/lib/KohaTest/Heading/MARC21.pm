package KohaTest::Heading::MARC21;
use base qw( KohaTest::Heading );

use strict;
use warnings;

use Test::More;

use C4::Heading;
use C4::Heading::MARC21;

use MARC::Field;

sub testing_class { 'C4::Heading::MARC21' };

sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( 
                    new
                    valid_bib_heading_tag
                    parse_heading
                    _get_subject_thesaurus
                    _get_search_heading
                    _get_display_heading
                );
    
    can_ok( $self->testing_class, @methods );    
}

sub bug2315 : Test( 1 ) {

    my $subject_heading = MARC::Field->new(650, ' ', '0', 
                                                a   => "Dalziel, Andrew (Fictitious character",
                                                ')' => "Fiction."
                                           );
    my $display_form = C4::Heading::MARC21::_get_display_heading($subject_heading, 'a');
    is($display_form, "Dalziel, Andrew (Fictitious character", "bug 2315: no crash if heading subfield has metacharacter");

}

1;
