package KohaTest::Message;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Message;
sub testing_class { 'C4::Message' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( 
                    new
                    find
                    find_last_message
                    enqueue
                    update
                    metadata
                    render_metadata
                    append
                );
    
    can_ok( $self->testing_class, @methods );    
}

sub test_metadata : Test( 1 ) {
    my $self = shift;
    my $message = C4::Message->new;
    $message->metadata({
        header => "Header",
        body   => [],
        footer => "Footer",
    });
    like($message->{metadata}, qr{^---}, "The metadata attribute should be serialized as YAML.");
}

sub test_append : Test( 1 ) {
    my $self = shift;
    my $message = C4::Message->new;
    $message->metadata({
        header => "Header",
        body   => [],
        footer => "Footer",
    });
    $message->append("foo");
    is($message->metadata->{body}->[0], "foo", "Appending a string should add an element to metadata.body.");
}

1;
