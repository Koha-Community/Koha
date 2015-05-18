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

package Koha::Indexer::Indexing;

use Moose;

use Modern::Perl;
use utf8;
use Carp;
use Koha::Indexer::RecordReader;
use Koha::Indexer::RecordWriter;
use AnyEvent::Processor::Conversion;
use File::Path;
use IO::File;
use C4::Context;


with 'MooseX::Getopt';


has source => (
    is      => 'rw',
    isa     => 'Koha::RecordType',
    default => 'biblio'
);

has select => (
    is       => 'rw',
    isa      => 'Koha::RecordSelect',
    required => 1,
    default  => 'all',
);

has directory => (
    is      => 'rw',
    isa     => 'Str',
    default => './koha-index',
);

has keep => ( is => 'rw', isa => 'Bool', default => 0 );

has verbose => ( is => 'rw', isa => 'Bool', default => 0 );

has help => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    traits  => [ 'NoGetopt' ],
);

has blocking => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
    traits  => [ 'NoGetopt' ],
);


sub run {
    my $self = shift;

    # Is it a full indexing of all Koha DB records?
    my $is_full_indexing = $self->select =~ /all/i;

    # Is it biblio indexing (if not it's authority)
    my $is_biblio_indexing = $self->source =~ /biblio/i;

    # STEP 1: All biblio records are exported in a directory

    unless ( -d $self->directory ) {
        mkdir $self->directory
            or die "Unable to create directory: " . $self->directory;
    }
    my $from_dir = $self->directory . "/" . $self->source;
    mkdir $from_dir;
    for my $dir ( ( "$from_dir/update", "$from_dir/delete") ) {
        rmtree( $dir ) if -d $dir;
        mkdir $dir;
    }

    # DOM indexing? otherwise GRS-1
    my $is_dom = $self->source eq 'biblio'
                 ? 'zebra_bib_index_mode'
                 : 'zebra_auth_index_mode';
    $is_dom = C4::Context->config($is_dom) || '';
    $is_dom = $is_dom =~ /dom/i ? 1 : 0;

    # STEP 1.1: Records to update
    say "Exporting records to update" if $self->verbose;
    my $exporter = AnyEvent::Processor::Conversion->new(
        reader => Koha::Indexer::RecordReader->new(
            source => $self->source,
            select => $is_full_indexing ? 'all' : 'queue_update',
            xml    => '1'
        ),
        writer => Koha::Indexer::RecordWriter->new(
            fh => IO::File->new( "$from_dir/update/records", '>:encoding(utf8)' ),
            valid => $is_dom ),
        blocking    => $self->blocking,
        verbose     => $self->verbose,
    );
    $exporter->run();

    # STEP 1.2: Record to delete, if zebraqueue
    if ( ! $is_full_indexing ) {
        say "Exporting records to delete" if $self->verbose;
        $exporter = AnyEvent::Processor::Conversion->new(
            reader => Koha::Indexer::RecordReader->new(
                source => $self->source,
                select => 'queue_delete',
                xml    => '1'
            ),
            writer => Koha::Indexer::RecordWriter->new(
                fh => IO::File->new( "$from_dir/delete/records", '>:encoding(utf8)' ),
                valid => $is_dom ),
            blocking    => $self->blocking,
            verbose     => $self->verbose,
        );
        $exporter->run();
    }

    # STEP 2: Run zebraidx

    my $cmd;
    my $zconfig  = C4::Context->zebraconfig(
       $is_biblio_indexing ? 'biblioserver' : 'authorityserver')->{config};
    my $db_name  = $is_biblio_indexing ? 'biblios' : 'authorities';
    my $cmd_base = "zebraidx -c " . $zconfig;
    $cmd_base   .= " -n" if $is_full_indexing; # No shadow: no indexing daemon
    $cmd_base   .= $self->verbose ? " -v warning,log" : " -v none";
    $cmd_base   .= " -g marcxml";
    $cmd_base   .= " -d $db_name";

    if ( $is_full_indexing ) {
        $cmd = "$cmd_base init";
        say $cmd if $self->verbose;
        system( $cmd );
    }

    $cmd = "$cmd_base update $from_dir/update";
    say $cmd if $self->verbose;
    system( $cmd );

    if ( ! $is_full_indexing ) {
        $cmd = "$cmd_base adelete $from_dir/delete";
        say $cmd if $self->verbose;
        system( $cmd );
        my $cmd = "$cmd_base commit";
        say $cmd if $self->verbose;
        system( $cmd );
    }

    rmtree( $self->directory ) unless $self->keep;
}


no Moose;
__PACKAGE__->meta->make_immutable;

__END__
=pod

=head1 SYNOPSIS

 my $indexer = Koha::Indexer->new(
   source => 'biblio',
   select => 'queue'
 );
 $indexer->run();

 my $indexer = Koha::Indexer->new(
   source    => 'authority',
   select    => 'all',
   directory => '/tmp',
   verbose   => 1,
 );
 $indexer->run();

=head1 DESCRIPTION

Indexes Koha biblio/authority records, full indexing or queued record indexing.


=head1 Methods

=over

=item run

Runs the indexing task.

=back


=cut

1;
