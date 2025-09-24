--
-- Default keyboard shortcuts
-- for Koha.
--
-- Copyright 2019 Koha Development Team
--
-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- Koha is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Koha; if not, see <https://www.gnu.org/licenses>.

-- keyboard shortcuts
INSERT INTO keyboard_shortcuts (shortcut_name, shortcut_keys) VALUES
    ("insert_copyright","Alt-C"),
    ("insert_copyright_sound","Alt-P"),
    ("insert_delimiter","Ctrl-D"),
    ("subfield_help","Ctrl-H"),
    ("link_authorities","Shift-Ctrl-L"),
    ("delete_field","Ctrl-X"),
    ("delete_subfield","Shift-Ctrl-X"),
    ("new_line","Enter"),
    ("line_break","Shift-Enter"),
    ("next_position","Tab"),
    ("prev_position","Shift-Tab"),
    ("toggle_keyboard", "Shift-Ctrl-K"),
    ("copy_line","Ctrl-Alt-C"),
    ("copy_subfield","Shift-Ctrl-C"),
    ("paste_line","Ctrl-P"),
    ("insert_line","Ctrl-I");
