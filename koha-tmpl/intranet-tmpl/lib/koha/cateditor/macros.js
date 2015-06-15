/**
 * Copyright 2015 ByWater Solutions
 *
 * This file is part of Koha.
 *
 * Koha is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Koha is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Koha; if not, see <http://www.gnu.org/licenses>.
 */

define( [ 'macros/its', 'macros/rancor' ], function( ITSMacro, RancorMacro ) {
    var Macros = {
        formats: {
            its: {
                description: 'TLC® ITS',
                Run: ITSMacro.Run,
            },
            rancor: {
                description: 'Rancor',
                Run: RancorMacro.Run,
            },
        },
        Run: function( editor, format, macro ) {
            return Macros.formats[format].Run( editor, macro );
        },
    };

    return Macros;
} );
