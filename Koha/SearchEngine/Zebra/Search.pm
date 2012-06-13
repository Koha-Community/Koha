package Koha::SearchEngine::Zebra::Search;
use Moose::Role;
with 'Koha::SearchEngine::SearchRole';

use Data::SearchEngine::Zebra;
use Data::SearchEngine::Query;
use Koha::SearchEngine::Zebra;
use Data::Dump qw(dump);

has searchengine => (
    is => 'rw',
    isa => 'Koha::SearchEngine::Zebra',
    default => sub { Koha::SearchEngine::Zebra->new },
    lazy => 1
);

sub search {
    my ($self,$query_string) = @_;

     my $query = Data::SearchEngine::Query->new(
       count => 10,
       page => 1,
       query => $query_string,
     );

    warn "search for $query_string";

    my $results = $self->searchengine->search($query);

    foreach my $item (@{ $results->items }) {
        my $title = $item->get_value('ste_title');
        #utf8::encode($title);
        print "$title\n";
                warn dump $title;
    }
}

sub dosmth {'bou' }

1;
