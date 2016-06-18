package Koha::MetaSearcher;

# Copyright 2014 ByWater Solutions
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

use base 'Class::Accessor';

use C4::Charset qw( MarcToUTF8Record );
use C4::Search qw(); # Purely for new_record_from_zebra
use DBIx::Class::ResultClass::HashRefInflator;
use IO::Select;
use Koha::Caches;
use Koha::Database;
use Koha::MetadataRecord;
use MARC::File::XML;
use Storable qw( store_fd fd_retrieve );
use Time::HiRes qw( clock_gettime CLOCK_MONOTONIC );
use UUID;
use ZOOM;

use sort 'stable';

__PACKAGE__->mk_accessors( qw( fetch offset on_error resultset ) );

sub new {
    my ( $class, $options ) = @_;

    my ( $uuid, $uuidstring );
    UUID::generate($uuid);
    UUID::unparse( $uuid, $uuidstring );

    return bless {
        offset => 0,
        fetch => 100,
        on_error => sub {},
        results => [],
        resultset => $uuidstring,
        %{ $options || {} }
    }, $class;
}

sub handle_hit {
    my ( $self, $index, $server, $marcrecord ) = @_;

    my $record = Koha::MetadataRecord->new( { schema => 'marc', record => $marcrecord } );

    my %fetch = (
        title => 'biblio.title',
        seriestitle => 'biblio.seriestitle',
        author => 'biblio.author',
        isbn =>'biblioitems.isbn',
        issn =>'biblioitems.issn',
        lccn =>'biblioitems.lccn', #LC control number (not call number)
        edition =>'biblioitems.editionstatement',
        date => 'biblio.copyrightdate', #MARC21
        date2 => 'biblioitems.publicationyear', #UNIMARC
    );

    my $metadata = {};
    while ( my ( $key, $kohafield ) = each %fetch ) {
        $metadata->{$key} = $record->getKohaField($kohafield);
    }
    $metadata->{date} //= $metadata->{date2};

    push @{ $self->{results} }, {
        server => $server,
        index => $index,
        record => $marcrecord,
        metadata => $metadata,
    };
}

sub search {
    my ( $self, $server_ids, $query ) = @_;

    my $resultset_expiry = 300;

    my $cache = Koha::Caches->get_instance();
    my $schema = Koha::Database->new->schema;
    my $stats = {
        num_fetched => {
            map { $_ => 0 } @$server_ids
        },
        num_hits => {
            map { $_ => 0 } @$server_ids
        },
        total_fetched => 0,
        total_hits => 0,
    };
    my $start = clock_gettime( CLOCK_MONOTONIC );
    my $select = IO::Select->new;

    my @cached_sets;
    my @servers;

    foreach my $server_id ( @$server_ids ) {
        if ( $server_id =~ /^\d+$/ ) {
            # Z39.50 server
            my $server = $schema->resultset('Z3950server')->find(
                { id => $server_id },
                { result_class => 'DBIx::Class::ResultClass::HashRefInflator' },
            );
            $server->{type} = 'z3950';

            push @servers, $server;
        } elsif ( $server_id =~ /(\w+)(?::(\w+))?/ ) {
            # Special server
            push @servers, {
                type => $1,
                extra => $2,
                id => $server_id,
                host => $server_id,
                name => $server_id,
            };
        }
    }

    # HashRefInflator is used so that the information will survive into the fork
    foreach my $server ( @servers ) {
        if ( $cache ) {
            my $set = $cache->get_from_cache( 'z3950-resultset-' . $self->resultset . '-' . $server->{id} );
            if ( ref($set) eq 'HASH' ) {
                $set->{server} = $server;
                push @cached_sets, $set;
                next;
            }
        }

        $select->add( $self->_start_worker( $server, $query ) );
    }

    # Handle these while the servers are searching
    foreach my $set ( @cached_sets ) {
        $self->_handle_hits( $stats, $set );
    }

    while ( $select->count ) {
        foreach my $readfh ( $select->can_read() ) {
            my $result = fd_retrieve( $readfh );

            $select->remove( $readfh );
            close $readfh;
            wait;

            next if ( ref $result ne 'HASH' );

            if ( $result->{error} ) {
                $self->{on_error}->( $result->{server}, $result->{error} );
                next;
            }

            $self->_handle_hits( $stats, $result );

            if ( $cache ) {
                $cache->set_in_cache( 'z3950-resultset-' . $self->resultset . '-' . $result->{server}->{id}, {
                    hits => $result->{hits},
                    num_fetched => $result->{num_fetched},
                    num_hits => $result->{num_hits},
                }, { expiry => $resultset_expiry } );
            }
        }
    }

    $stats->{time} = clock_gettime( CLOCK_MONOTONIC ) - $start;

    return $stats;
}

sub _start_worker {
    my ( $self, $server, $query ) = @_;
    pipe my $readfh, my $writefh;

    # Accessing the cache or Koha database after the fork is risky, so get any resources we need
    # here.
    my $pid;
    my $marcflavour = C4::Context->preference('marcflavour');

    if ( ( $pid = fork ) ) {
        # Parent process
        close $writefh;

        return $readfh;
    } elsif ( !defined $pid ) {
        # Error

        $self->{on_error}->( $server, 'Failed to fork' );
        return;
    }

    close $readfh;
    my $connection;
    my ( $num_hits, $num_fetched, $hits, $results );

    eval {
        if ( $server->{type} eq 'z3950' ) {
            my $zoptions = ZOOM::Options->new();
            $zoptions->option( 'elementSetName', 'F' );
            $zoptions->option( 'databaseName',   $server->{db} );
            $zoptions->option( 'user', $server->{userid} ) if $server->{userid};
            $zoptions->option( 'password', $server->{password} ) if $server->{password};
            $zoptions->option( 'preferredRecordSyntax', $server->{syntax} );
            $zoptions->option( 'timeout', $server->{timeout} ) if $server->{timeout};

            $connection = ZOOM::Connection->create($zoptions);

            $connection->connect( $server->{host}, $server->{port} );
            $results = $connection->search_pqf( $query ); # Starts the search
        } elsif ( $server->{type} eq 'koha' ) {
            $connection = C4::Context->Zconn( $server->{extra} );
            $results = $connection->search_pqf( $query ); # Starts the search
        } elsif ( $server->{type} eq 'batch' )  {
            $server->{encoding} = 'utf-8';
        }
    };
    if ($@) {
        store_fd {
            error => $connection ? $connection->exception() : $@,
            server => $server,
        }, $writefh;
        exit;
    }

    if ( $server->{type} eq 'batch' ) {
        # TODO: actually handle PQF
        $query =~ s/@\w+ (?:\d+=\d+ )?//g;
        $query =~ s/"//g;

        my $schema = Koha::Database->new->schema;
        $schema->storage->debug(1);
        my $match_condition = [ map +{ -like => '%' . $_ . '%' }, split( /\s+/, $query ) ];
        $hits = [ $schema->resultset('ImportRecord')->search(
            {
                import_batch_id => $server->{extra},
                -or => [
                    { 'import_biblios.title' => $match_condition },
                    { 'import_biblios.author' => $match_condition },
                    { 'import_biblios.isbn' => $match_condition },
                    { 'import_biblios.issn' => $match_condition },
                ],
            },
            {
                join => [ qw( import_biblios ) ],
                rows => $self->{fetch},
            }
        )->get_column( 'marc' )->all ];

        $num_hits = $num_fetched = scalar @$hits;
    } else {
        $num_hits = $results->size;
        $num_fetched = ( $self->{offset} + $self->{fetch} ) < $num_hits ? $self->{fetch} : $num_hits;

        $hits = [ map { $_->raw() } @{ $results->records( $self->{offset}, $num_fetched, 1 ) } ];
    }

    if ( !@$hits && $connection && $connection->exception() ) {
        store_fd {
            error => $connection->exception(),
            server => $server,
        }, $writefh;
        exit;
    }

    if ( $server->{type} eq 'koha' ) {
        $hits = [ map { C4::Search::new_record_from_zebra( $server->{extra}, $_ ) } @$hits ];
    } else {
        $hits = [ map { $self->_import_record( $_, $marcflavour, $server->{encoding} ? $server->{encoding} : "iso-5426" ) } @$hits ];
    }

    store_fd {
        hits => $hits,
        num_fetched => $num_fetched,
        num_hits => $num_hits,
        server => $server,
    }, $writefh;

    exit;
}

sub _import_record {
    my ( $self, $raw, $marcflavour, $encoding ) = @_;

    my ( $marcrecord ) = MarcToUTF8Record( $raw, $marcflavour, $encoding ); #ignores charset return values

    return $marcrecord;
}

sub _handle_hits {
    my ( $self, $stats, $set ) = @_;

    my $server = $set->{server};

    my $num_hits = $stats->{num_hits}->{ $server->{id} } = $set->{num_hits};
    my $num_fetched = $stats->{num_fetched}->{ $server->{id} } = $set->{num_fetched};

    $stats->{total_hits} += $num_hits;
    $stats->{total_fetched} += $num_fetched;

    foreach my $j ( 0..$#{ $set->{hits} } ) {
        $self->handle_hit( $self->{offset} + $j, $server, $set->{hits}->[$j] );
    }
}

sub sort {
    my ( $self, $key, $direction ) = @_;

    my $empty_flip = -1; # Determines the flip of ordering for records with empty sort keys.

    foreach my $hit ( @{ $self->{results} } ) {
        ( $hit->{sort_key} = $hit->{metadata}->{$key} || '' ) =~ s/\W//g;
    }

    $self->{results} = [ sort {
        # Sort empty records at the end
        return -$empty_flip unless $a->{sort_key};
        return $empty_flip unless $b->{sort_key};

        $direction * ( $a->{sort_key} cmp $b->{sort_key} );
    } @{ $self->{results} } ];
}

sub results {
    my ( $self, $offset, $length ) = @_;

    my @subset;

    foreach my $i ( $offset..( $offset + $length - 1 ) ) {
        push @subset, $self->{results}->[$i] if $self->{results}->[$i];
    }

    return @subset;
}

1;
