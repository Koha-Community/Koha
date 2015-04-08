package C4::Creators;

# Copyright 2010 Foundations
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

BEGIN {
    use version; our $VERSION = qv('3.07.00.049');
    use vars qw(@EXPORT @ISA);
    @ISA = qw(Exporter);
    our @EXPORT = qw(get_all_templates
                     get_all_layouts
                     get_all_profiles
                     get_all_image_names
                     get_batch_summary
                     get_label_summary
                     get_card_summary
                     get_barcode_types
                     get_label_types
                     get_font_types
                     get_text_justification_types
                     get_output_formats
                     get_column_names
                     get_table_names
                     get_unit_values
                     html_table
    );
    use C4::Creators::Lib;
    use C4::Creators::PDF;
}

1;
