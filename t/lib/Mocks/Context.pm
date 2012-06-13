package t::lib::Mocks::Context;
use t::lib::Mocks::Context;
use C4::Context;

sub MockPreference {
    my ( $self, $syspref, $value, $mock_object ) = @_;
    return $value if $syspref eq 'SearchEngine';
    $mock_object->unmock("preference");
    my $r = C4::Context->preference($syspref);
    $mock_object->mock('preference', sub { &t::lib::Mocks::Context::MockPreference( @_, $value, $mock_object ) });
    return $r;
}
1;
