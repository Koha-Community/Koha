# This file is part of Koha.
#
# Copyright (C) 2013 Tamil s.a.r.l.
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

package Koha::Indexer::Daemon;

use Moose;

use Modern::Perl;
use utf8;
use AnyEvent;
use Koha::Indexer::Indexing;
use C4::Context;

with 'MooseX::Getopt';


has name => ( is => 'rw', isa => 'Str' );

has directory => ( is => 'rw', isa => 'Str' );

has timeout => (
    is      => 'rw',
    isa     => 'Int',
    default => 60,
);

has verbose => ( is => 'rw', isa => 'Bool', default => 0 );


sub BUILD {
    my $self = shift;

    say "Starting Koha Indexer Daemon";

    $self->name( C4::Context->config('database') );

    my $idle = AnyEvent->timer(
        after    => $self->timeout,
        interval => $self->timeout,
        cb       => sub { $self->index_zebraqueue(); }
    );
    AnyEvent->condvar->recv;
}


sub index_zebraqueue {
    my $self = shift;

    my $dbh = C4::Context->dbh();
    my $sql = " SELECT COUNT(*), server
                FROM zebraqueue
                WHERE done = 0
                GROUP BY server ";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my %count = ( biblio => 0, authority => 0 );
    while ( my ($count, $server) = $sth->fetchrow ) {
        $server =~ s/server//g;
        $count{$server} = $count;
    }

    say "[", $self->name, "] Index biblio (", $count{biblio}, ") authority (",
        $count{authority}, ")";

    for my $source (qw/biblio authority/) {
        next unless $count{$source};
        my $indexer = Koha::Indexer::Indexing->new(
            source      => $source,
            select      => 'queue',
            blocking    => 1,
            keep        => 1,
            verbose     => $self->verbose,
        );
        $indexer->directory($self->directory) if $self->directory;
        $indexer->run();
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__
=pod

=head1 SYNOPSIS

 # Index Koha queued biblio/authority records every minute.
 # KOHA_CONF environment variable is used to find which Koha
 # instance to use.
 # Records are exported from Koha DB into files located in
 # the current directory
 my $daemon = Koha::Indexer::Daemon->new();

 my $daemon = Koha::Indexer::Daemon->new(
    timeout   => 20,
    directory => '/home/koha/mylib/tmp',
    verbose   => 1 );

=head1 Attributes

=over

=item directory($directory_name)

Location of the directory where to export biblio/authority records before
sending them to Zebra indexer.

=item timeout($seconds)

Number of seconds between indexing.

=item verbose(0|1)

Task verbosity.

=back

=cut
