package WebService::ILS::RecordedBooks::Partner;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::RecordedBooks::Partner - RecordedBooks partner API

=head1 SYNOPSIS

    use WebService::ILS::RecordedBooks::Partner;

=head1 DESCRIPTION

L<WebService::ILS::RecordedBooks::Partner> - services
that use trusted partner credentials

See L<WebService::ILS::RecordedBooks>

=cut

use Carp;

use parent qw(WebService::ILS::RecordedBooks::PartnerBase);

sub circulation_action_base_url {
    my $self = shift;
    my $patron_id = shift or croak "No patron id";

    return $self->library_action_base_url."/patrons/${patron_id}";
}

=head1 DISCOVERY METHODS

=head2 facet_search ($facets)

  See C<native_facet_search()> below for $facets

=head2 named_query_search ($query, $media)

  See C<native_named_query_search()> below for $query, $media

=head1 CIRCULATION METHOD SPECIFICS

Differences to general L<WebService::ILS> interface

=head2 patron_id ($email_or_id)

=head2 holds ($patron_id)

=head2 place_hold ($patron_id, $isbn)

=head2 checkouts ($patron_id)

=head2 checkout ($patron_id, $isbn)

=head2 renew ($patron_id, $isbn)

=head2 return ($patron_id, $isbn)

=cut

foreach my $sub (qw(place_hold remove_hold renew return)) {
    no strict "refs";
    *$sub = sub {
        my $self = shift;
        my $patron_id = shift or croak "No patron id";
        my $isbn = shift or croak "No isbn";
        my $supersub = "SUPER::$sub";
        return $self->$supersub($isbn, $patron_id);
    };
}

sub checkout {
    my $self = shift;
    my $patron_id = shift or croak "No patron id";
    my $isbn = shift or croak "No isbn";
    my $days = shift;
    return $self->SUPER::checkout($isbn, $days, $patron_id);
}


=head1 NATIVE METHODS

=head2 native_quick_search ($query, $category)

  $category can be one of 'all', 'title', 'author', or  'narrator';
    optional, defaults to 'all'

=cut

=head2 native_facet_search ($facets)

  $facets can be either:
  * a hashref of facet => [values],
  * an arrayref of values
  * a single value

=head2 native_named_query_search ($query, $media)

  $query can be one of 'bestsellers', 'most-popular', 'newly-added'
  $media can be 'eaudio' or 'ebook'

=head2 native_patron ($email_or_id)

=cut

1;

__END__

=head1 LICENSE

Copyright (C) Catalyst IT NZ Ltd
Copyright (C) Bywater Solutions

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Srdjan Janković E<lt>srdjan@catalyst.net.nzE<gt>

=cut
