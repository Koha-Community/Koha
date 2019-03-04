--
-- Default keyboard shortcuts
-- for Koha.
--
-- Copyright (C) 2007 LiblimeA
-- Copyright 2018 Koha Development Team
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
INSERT INTO keyboard_shortcuts (shortcut_name, shortcut_keys, shortcut_desc) VALUES
    ("insert_copyright","Alt-C","Insert copyright symbol (©)"),
    ("insert_copyright_sound","Alt-P","Insert copyright symbol (℗) (sound recordings)"),
    ("insert_delimiter","Ctrl-D","Insert delimiter (‡)"),
    ("subfield_help","Ctrl-H","Get help on current subfield"),
    ("link_authorities","Shift-Ctrl-L","Link field to authorities"),
    ("delete_field","Ctrl-X","Delete current field"),
    ("delete_subfield","Shift-Ctrl-X","Delete current subfield"),
    ("new_line","Enter","New field on next line"),
    ("line_break","Shift-Enter","Insert line break"),
    ("next_position","Tab","Move to next position"),
    ("prev_position","Shift-Tab","Move to previous position");
