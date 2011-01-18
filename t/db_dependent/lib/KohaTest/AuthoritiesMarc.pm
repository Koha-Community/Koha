package KohaTest::AuthoritiesMarc;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::AuthoritiesMarc;
sub testing_class { 'C4::AuthoritiesMarc' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( GetAuthMARCFromKohaField 
                      SearchAuthorities 
                      CountUsage 
                      CountUsageChildren 
                      GetAuthTypeCode 
                      GetTagsLabels 
                      AddAuthority 
                      DelAuthority 
                      ModAuthority 
                      GetAuthorityXML 
                      GetAuthority 
                      GetAuthType 
                      AUTHhtml2marc 
                      FindDuplicateAuthority 
                      BuildSummary
                      BuildUnimarcHierarchies
                      BuildUnimarcHierarchy
                      GetHeaderAuthority
                      AddAuthorityTrees
                      merge 
                      get_auth_type_location 
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;
