package Koha::Cron;

# Copyright PTFS Europe 2019
# Copyright 2019 Koha Development Team
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

=head1 NAME

Koha::Cron - Koha Cron scripts base class

=head1 SYNOPSIS

    use Koha::Cron;

=head1 DESCRIPTION

This class should be used in all cronscripts. It sets the interface and userenv appropriately.

=cut

use C4::Context;

# Set userenv
C4::Context->_new_userenv(1);
C4::Context->set_userenv(
    undef, undef, undef, 'CRON', 'CRON', undef,
    undef, undef, undef, undef,  undef
);

# Set interface
C4::Context->interface('cron');

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
