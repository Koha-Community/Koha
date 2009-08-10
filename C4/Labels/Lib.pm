package C4::Labels::Lib;

# Copyright 2009 Foundations Bible College.
#
# This file is part of Koha.
#       
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;
use Sys::Syslog qw(syslog);
use Data::Dumper;

use C4::Context;
use C4::Debug;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
    use base qw(Exporter);
    our @EXPORT_OK = qw(get_all_templates
                        get_all_layouts
                        get_all_profiles
                        get_batch_summary
                        get_label_summary
                        get_barcode_types
                        get_label_types
                        get_font_types
                        get_text_justification_types
                        get_label_output_formats
                        get_column_names
                        get_table_names
                        get_unit_values
                        html_table
    );
}

#=head2 C4::Labels::Lib::_SELECT()
#
#    This function returns a recordset upon success and 1 upon failure. Errors are logged to the syslog.
#
#    examples:
#
#        my $field_value = _SELECT(field_name, table_name, condition);
#
#=cut

sub _SELECT {
    my @params = @_;
    my $query = "SELECT $params[0] FROM $params[1]";
    $params[2] ? $query .= " WHERE $params[2];" : $query .= ';';
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute();
    if ($sth->err) {
        syslog("LOG_ERR", "C4::Labels::Lib::get_single_field_value : Database returned the following error: %s", $sth->errstr);
        return 1;
    }
    my $record_set = [];
    while (my $row = $sth->fetchrow_hashref()) {
        push(@$record_set, $row);
    }
    return $record_set;
}

my $barcode_types = [
    {type => 'CODE39',          name => 'Code 39',              desc => 'Translates the characters 0-9, A-Z, \'-\', \'*\', \'+\', \'$\', \'%\', \'/\', \'.\' and \' \' to a barcode pattern.',                                  selected => 0},
    {type => 'CODE39MOD',       name => 'Code 39 + Modulo43',   desc => 'Translates the characters 0-9, A-Z, \'-\', \'*\', \'+\', \'$\', \'%\', \'/\', \'.\' and \' \' to a barcode pattern. Encodes Mod 43 checksum.',         selected => 0},
    {type => 'CODE39MOD10',     name => 'Code 39 + Modulo10',   desc => 'Translates the characters 0-9, A-Z, \'-\', \'*\', \'+\', \'$\', \'%\', \'/\', \'.\' and \' \' to a barcode pattern. Encodes Mod 10 checksum.',         selected => 0},
    {type => 'COOP2OF5',        name => 'COOP2of5',             desc => 'Creates COOP2of5 barcodes from a string consisting of the numeric characters 0-9',                                                                     selected => 0},
#    {type => 'EAN13',           name => 'EAN13',                desc => 'Creates EAN13 barcodes from a string of 12 or 13 digits. The check number (the 13:th digit) is calculated if not supplied.',                           selected => 0},
#    {type => 'EAN8',            name => 'EAN8',                 desc => 'Translates a string of 7 or 8 digits to EAN8 barcodes. The check number (the 8:th digit) is calculated if not supplied.',                              selected => 0},
#    {type => 'IATA2of5',        name => 'IATA2of5',             desc => 'Creates IATA2of5 barcodes from a string consisting of the numeric characters 0-9',                                                                     selected => 0},
    {type => 'INDUSTRIAL2OF5',  name => 'Industrial2of5',       desc => 'Creates Industrial2of5 barcodes from a string consisting of the numeric characters 0-9',                                                               selected => 0},
#    {type => 'ITF',             name => 'Interleaved2of5',      desc => 'Translates the characters 0-9 to a barcodes. These barcodes could also be called 'Interleaved2of5'.',                                                  selected => 0},
#    {type => 'MATRIX2OF5',      name => 'Matrix2of5',           desc => 'Creates Matrix2of5 barcodes from a string consisting of the numeric characters 0-9',                                                                   selected => 0},
#    {type => 'NW7',             name => 'NW7',                  desc => 'Creates a NW7 barcodes from a string consisting of the numeric characters 0-9',                                                                        selected => 0},
#    {type => 'UPCA',            name => 'UPCA',                 desc => 'Translates a string of 11 or 12 digits to UPCA barcodes. The check number (the 12:th digit) is calculated if not supplied.',                           selected => 0},
#    {type => 'UPCE',            name => 'UPCE',                 desc => 'Translates a string of 6, 7 or 8 digits to UPCE barcodes. If the string is 6 digits long, '0' is added first in the string. The check number (the 8:th digit) is calculated if not supplied.',                                 selected => 0},
];

my $label_types = [
    {type => 'BIB',     name => 'Biblio',               desc => 'Only the bibliographic data is printed.',                              selected => 0},
    {type => 'BARBIB',  name => 'Barcode/Biblio',       desc => 'Barcode proceeds bibliographic data.',                                 selected => 0},
    {type => 'BIBBAR',  name => 'Biblio/Barcode',       desc => 'Bibliographic data proceeds barcode.',                                 selected => 0},
    {type => 'ALT',     name => 'Alternating',          desc => 'Barcode and bibliographic data are printed on alternating labels.',    selected => 0},
    {type => 'BAR',     name => 'Barcode',              desc => 'Only the barcode is printed.',                                         selected => 0},
];

my $font_types = [
    {type => 'TR',      name => 'Times-Roman',                  selected => 0},
    {type => 'TB',      name => 'Times-Bold',                   selected => 0},
    {type => 'TI',      name => 'Times-Italic',                 selected => 0},
    {type => 'TBI',     name => 'Times-Bold-Italic',            selected => 0},
    {type => 'C',       name => 'Courier',                      selected => 0},
    {type => 'CB',      name => 'Courier-Bold',                 selected => 0},
    {type => 'CO',      name => 'Courier-Oblique',              selected => 0},
    {type => 'CBO',     name => 'Courier-Bold-Oblique',         selected => 0},
    {type => 'H',       name => 'Helvetica',                    selected => 0},
    {type => 'HB',      name => 'Helvetica-Bold',               selected => 0},
    {type => 'HBO',     name => 'Helvetica-Bold-Oblique',       selected => 0},
];

my $text_justification_types = [
    {type => 'L',       name => 'Left',                         selected => 0},
    {type => 'C',       name => 'Center',                       selected => 0},
    {type => 'R',       name => 'Right',                        selected => 0},
#    {type => 'F',       name => 'Full',                         selected => 0},    
];

my $unit_values = [
    {type       => 'POINT',      desc    => 'PostScript Points',  value   => 1,                 selected => 0},
    {type       => 'AGATE',      desc    => 'Adobe Agates',       value   => 5.1428571,         selected => 0},
    {type       => 'INCH',       desc    => 'US Inches',          value   => 72,                selected => 0},
    {type       => 'MM',         desc    => 'SI Millimeters',     value   => 2.83464567,        selected => 0},
    {type       => 'CM',         desc    => 'SI Centimeters',     value   => 28.3464567,        selected => 0},
];

my $label_output_formats = [
    {type       => 'pdf',       desc    => 'PDF File'},
    {type       => 'csv',       desc    => 'CSV File'},
];

=head2 C4::Labels::Lib::get_all_templates()

    This function returns a reference to a hash containing all templates upon success and 1 upon failure. Errors are logged to the syslog.

    examples:

        my $templates = get_all_templates();

=cut

sub get_all_templates {
    my %params = @_;
    my @templates = ();
    my $query = "SELECT " . ($params{'field_list'} ? $params{'field_list'} : '*') . " FROM labels_templates";
    $query .= ($params{'filter'} ? " WHERE $params{'filter'};" : ';');
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute();
    if ($sth->err) {
        syslog("LOG_ERR", "C4::Labels::Lib::get_all_templates : Database returned the following error: %s", $sth->errstr);
        return -1;
    }
    ADD_TEMPLATES:
    while (my $template = $sth->fetchrow_hashref) {
        push(@templates, $template);
    }
    return \@templates;
}

=head2 C4::Labels::Lib::get_all_layouts()

    This function returns a reference to a hash containing all layouts upon success and 1 upon failure. Errors are logged to the syslog.

    examples:

        my $layouts = get_all_layouts();

=cut

sub get_all_layouts {
    my %params = @_;
    my @layouts = ();
    #my $query = "SELECT * FROM labels_layouts;";
    my $query = "SELECT " . ($params{'field_list'} ? $params{'field_list'} : '*') . " FROM labels_layouts";
    $query .= ($params{'filter'} ? " WHERE $params{'filter'};" : ';');
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute();
    if ($sth->err) {
        syslog("LOG_ERR", "C4::Labels::Lib::get_all_layouts : Database returned the following error: %s", $sth->errstr);
        return -1;
    }
    ADD_LAYOUTS:
    while (my $layout = $sth->fetchrow_hashref) {
        push(@layouts, $layout);
    }
    return \@layouts;
}

=head2 C4::Labels::Lib::get_all_profiles()

    This function returns an arrayref whose elements are hashes containing all profiles upon success and 1 upon failure. Errors are logged
    to the syslog. Two parameters are accepted. The first limits the field(s) returned. This parameter should be string of comma separted
    fields. ie. "field_1, field_2, ...field_n" The second limits the records returned based on a string containing a valud SQL 'WHERE' filter.
    NOTE: Do not pass in the keyword 'WHERE.'

    examples:

        my $profiles = get_all_profiles();
        my $profiles = get_all_profiles(field_list => field_list, filter => filter_string);

=cut

sub get_all_profiles {
    my %params = @_;
    my @profiles = ();
    my $query = "SELECT " . ($params{'field_list'} ? $params{'field_list'} : '*') . " FROM printers_profile";
    $query .= ($params{'filter'} ? " WHERE $params{'filter'};" : ';');
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3 if $debug;
    $sth->execute();
    if ($sth->err) {
        syslog("LOG_ERR", "C4::Labels::Lib::get_all_profiles : Database returned the following error: %s", $sth->errstr);
        return -1;
    }
    ADD_PROFILES:
    while (my $profile = $sth->fetchrow_hashref) {
        push(@profiles, $profile);
    }
    return \@profiles;
}

=head2 C4::Labels::Lib::get_batch_summary()

    This function returns an arrayref whose elements are hashes containing the batch_ids of current batches along with the item count
    for each batch upon success and 1 upon failure. Item counts are stored under the key '_item_count' Errors are logged to the syslog.
    One parameter is accepted which limits the records returned based on a string containing a valud SQL 'WHERE' filter.
    
    NOTE: Do not pass in the keyword 'WHERE.'

    examples:

        my $batches = get_batch_summary();
        my $batches = get_batch_summary(filter => filter_string);

=cut

sub get_batch_summary {
    my %params = @_;
    my @batches = ();
    my $query = "SELECT DISTINCT batch_id FROM labels_batches";
    $query .= ($params{'filter'} ? " WHERE $params{'filter'};" : ';');
    my $sth = C4::Context->dbh->prepare($query);
#    $sth->{'TraceLevel'} = 3;
    $sth->execute();
    if ($sth->err) {
        syslog("LOG_ERR", "C4::Labels::Lib::get_batch_summary : Database returned the following error on attempted SELECT: %s", $sth->errstr);
        return -1;
    }
    ADD_BATCHES:
    while (my $batch = $sth->fetchrow_hashref) {
        my $query = "SELECT count(item_number) FROM labels_batches WHERE batch_id=?;";
        my $sth1 = C4::Context->dbh->prepare($query);
        $sth1->execute($batch->{'batch_id'});
        if ($sth1->err) {
            syslog("LOG_ERR", "C4::Labels::Lib::get_batch_summary : Database returned the following error on attempted SELECT count: %s", $sth1->errstr);
            return -1;
        }
        my $count = $sth1->fetchrow_arrayref;
        $batch->{'_item_count'} = @$count[0];
        push(@batches, $batch);
    }
    return \@batches;
}

=head2 C4::Labels::Lib::get_label_summary()

    This function returns an arrayref whose elements are hashes containing the label_ids of current labels along with the item count
    for each label upon success and 1 upon failure. Item counts are stored under the key '_item_count' Errors are logged to the syslog.
    One parameter is accepted which limits the records returned based on a string containing a valud SQL 'WHERE' filter.
    
    NOTE: Do not pass in the keyword 'WHERE.'

    examples:

        my $labels = get_label_summary();
        my $labels = get_label_summary(items => @item_list);

=cut

sub get_label_summary {
    my %params = @_;
    my $label_number = 0;
    my @label_summaries = ();
    my $query = "SELECT b.title, b.author, bi.itemtype, i.barcode, i.biblionumber FROM biblio AS b, biblioitems AS bi ,items AS i, labels_batches AS l WHERE itemnumber=? AND l.item_number=i.itemnumber AND i.biblioitemnumber=bi.biblioitemnumber AND bi.biblionumber=b.biblionumber AND l.batch_id=?;";
    my $sth = C4::Context->dbh->prepare($query);
    foreach my $item (@{$params{'items'}}) {
        $label_number++;
        $sth->execute($item->{'item_number'}, $params{'batch_id'});
        if ($sth->err) {
            syslog("LOG_ERR", "C4::Labels::Lib::get_label_summary : Database returned the following error on attempted SELECT: %s", $sth->errstr);
            return -1;
        }
        my $record = $sth->fetchrow_hashref;
        my $label_summary->{'_label_number'} = $label_number;
        $record->{'author'} =~ s/[^\.|\w]$// if $record->{'author'};  # strip off ugly trailing chars... but not periods or word chars
        $record->{'title'} =~ s/\W*$//;  # strip off ugly trailing chars
        $record->{'title'} = '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' . $record->{'biblionumber'} . '"> ' . $record->{'title'} . '</a>';
        $label_summary->{'_summary'} = $record->{'title'} . " | " . ($record->{'author'} ? $record->{'author'} : 'N/A');
        $label_summary->{'_item_type'} = $record->{'itemtype'};
        $label_summary->{'_barcode'} = $record->{'barcode'};
        $label_summary->{'_item_number'} = $item->{'item_number'};
        $label_summary->{'_label_id'} = $item->{'label_id'};
        push (@label_summaries, $label_summary);
    }
    return \@label_summaries;
}

=head2 C4::Labels::Lib::get_barcode_types()

    This function returns a reference to an array of hashes containing all barcode types along with their name and description.

    examples:

        my $barcode_types = get_barcode_types();

=cut

sub get_barcode_types {
    return $barcode_types;
}

=head2 C4::Labels::Lib::get_label_types()

    This function returns a reference to an array of hashes containing all label types along with their name and description.

    examples:

        my $label_types = get_label_types();

=cut

sub get_label_types {
    return $label_types;
}

=head2 C4::Labels::Lib::get_font_types()

    This function returns a reference to an array of hashes containing all font types along with their name and description.

    examples:

        my $font_types = get_font_types();

=cut

sub get_font_types {
    return $font_types;
}

=head2 C4::Labels::Lib::get_text_justification_types()

    This function returns a reference to an array of hashes containing all text justification types along with their name and description.

    examples:

        my $text_justification_types = get_text_justification_types();

=cut

sub get_text_justification_types {
    return $text_justification_types;
}

=head2 C4::Labels::Lib::get_unit_values()

    This function returns a reference to an array of  hashes containing all unit types along with their description and multiplier. NOTE: All units are relative to a PostScript Point.
    There are 72 PS points to the inch.

    examples:

        my $unit_values = get_unit_values();

=cut

sub get_unit_values {
    return $unit_values;
}

=head2 C4::Labels::Lib::get_label_output_formats()

    This function returns a reference to an array of hashes containing all label output formats along with their description.

    examples:

        my $label_output_formats = get_label_output_formats();

=cut

sub get_label_output_formats {
    return $label_output_formats;
}

=head2 C4::Labels::Lib::get_column_names($table_name)

Return an arrayref of an array containing the column names of the supplied table.

=cut

sub get_column_names {
    my $table = shift;
    my $dbh = C4::Context->dbh();
    my $column_names = [];
    my $sth = $dbh->column_info(undef,undef,$table,'%');
    while (my $info = $sth->fetchrow_hashref()){
        $$column_names[$info->{'ORDINAL_POSITION'}] = $info->{'COLUMN_NAME'};
    }
    return $column_names;
}

=head2 C4::Labels::Lib::get_table_names($search_term)

Return an arrayref of an array containing the table names which contain the supplied search term.

=cut

sub get_table_names {
    my $search_term = shift;
    my $dbh = C4::Context->dbh();
    my $table_names = [];
    my $sth = $dbh->table_info(undef,undef,"%$search_term%");
    while (my $info = $sth->fetchrow_hashref()){
        push (@$table_names, $info->{'TABLE_NAME'});
    }
    return $table_names;
}

=head2 C4::Labels::Lib::html_table()

    This function returns an arrayref of an array of hashes contianing the supplied data formatted suitably to
    be passed off as a T::P template parameter and used to build an html table.

    examples:

        my $table = html_table(header_fields, array_of_row_data);

=cut

sub html_table {
    my $headers = shift;
    my $data = shift;
    my $table = [];
    my $fields = [];
    my @headers = ();
    my @table_columns = ();
    my ($row_index, $col_index) = (0,0);
    my $cols = 0;       # number of columns to wrap on
    my $field_count = 0;
    my $select_value = undef;
    my $link_field = undef;
    POPULATE_HEADER:
    foreach my $header (@$headers) {
        my @key = keys %$header;
        if ($key[0] eq 'select' ) {
            push (@table_columns, $key[0]);
            $$fields[$col_index] = {hidden => 0, select_field => 0, field_name => ($key[0]), field_label => $header->{$key[0]}{'label'}};
            # do special formatting stuff....
            $select_value = $header->{$key[0]}{'value'};
        }
        else {
            # do special formatting stuff....
            $link_field->{$key[0]} = ($header->{$key[0]}{'link_field'} == 1 ? 1 : 0);
            push (@table_columns, $key[0]);
            $$fields[$col_index] = {hidden => 0, select_field => 0, field_name => ($key[0]), field_label => $header->{$key[0]}{'label'}};
        }
        $field_count++;
        $col_index++;
    }
    $$table[$row_index] = {header_fields => $fields};
    $cols = $col_index;
    $field_count *= scalar(@$data);     # total fields to be displayed in the table
    $col_index = 0;
    $row_index++;
    $fields = [];
    POPULATE_TABLE:
    foreach my $db_row (@$data) {
        POPULATE_ROW:
        foreach my $table_column (@table_columns) {
            if (grep {$table_column eq $_} keys %$db_row) {
                $$fields[$col_index] = {hidden => 0, link_field => $link_field->{$table_column}, select_field => 0, field_name => ($table_column . "_tbl"), field_value => $db_row->{$table_column}};
                $col_index++;
                next POPULATE_ROW;
            }
            elsif ($table_column =~ m/^_((.*)_(.*$))/) {   # this a special case
                my $table_name = get_table_names($2);
                my $record_set = _SELECT($1, @$table_name[0], $2 . "_id = " . $db_row->{$2 . "_id"});
                $$fields[$col_index] = {hidden => 0, link_field => $link_field->{$table_column}, select_field => 0, field_name => ($table_column . "_tbl"), field_value => $$record_set[0]{$1}};
                $col_index++;
                next POPULATE_ROW;
            }
            elsif ($table_column eq 'select' ) {
                $$fields[$col_index] = {hidden => 0, select_field => 1, field_name => 'select', field_value => $db_row->{$select_value}};
            }
        }
        $$table[$row_index] = {text_fields => $fields};
        $col_index = 0;
        $row_index++;
        $fields = [];
    }
    return $table;
}

1;
__END__

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut
