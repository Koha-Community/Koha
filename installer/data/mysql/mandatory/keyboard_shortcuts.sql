--
-- Default keyboard shortcuts
-- for Koha.
--
-- Copyright 2019 Koha Development Team
--
-- This file is part of Koha.
--
-- Koha is free software; you can redistribute it and/or modify it under the
-- terms of the GNU General Public License as published by the Free Software
-- Foundation; either version 2 of the License, or (at your option) any later
-- version.
--
-- Koha is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
-- A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with Koha; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
    ("toggle_keyboard", "Shift-Ctrl-K");
