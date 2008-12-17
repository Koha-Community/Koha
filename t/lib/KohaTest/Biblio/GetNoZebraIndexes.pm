package KohaTest::Biblio::GetNoZebraIndexes;
use base qw( KohaTest::Biblio );

use strict;
use warnings;

use Test::More;

use C4::Biblio;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut


=head2 TEST METHODS

standard test methods

=head3 

=cut
    
sub returns_expected_hashref : Test(2) {
    my $self = shift;

    my %nzi = C4::Biblio::GetNoZebraIndexes();
    ok( scalar keys %nzi, 'got some keys from GetNoZebraIndexes' );

    my %expected = (
        'title'        => '130a,210a,222a,240a,243a,245a,245b,246a,246b,247a,247b,250a,250b,440a,830a',
        'author'       => '100a,100b,100c,100d,110a,111a,111b,111c,111d,245c,700a,710a,711a,800a,810a,811a',
        'isbn'         => '020a',
        'issn'         => '022a',
        'lccn'         => '010a',
        'biblionumber' => '999c',
        'itemtype'     => '942c',
        'publisher'    => '260b',
        'date'         => '260c',
        'note'         => '500a,501a,504a,505a,508a,511a,518a,520a,521a,522a,524a,526a,530a,533a,538a,541a,546a,555a,556a,562a,563a,583a,585a,582a',
        'subject'      => '600*,610*,611*,630*,650*,651*,653*,654*,655*,662*,690*',
        'dewey'        => '082',
        'bc'           => '952p',
        'callnum'      => '952o',
        'an'           => '6009,6109,6119',
        'homebranch'   => '952a,952c'
    );
    is_deeply( \%nzi, \%expected, 'GetNoZebraIndexes returns the expected hashref' );
}

=head2 HELPER METHODS

These methods are used by other test methods, but
are not meant to be called directly.

=cut

=cut


=head2 SHUTDOWN METHODS

These get run once, after the main test methods in this module

=head3 

=cut


1;
