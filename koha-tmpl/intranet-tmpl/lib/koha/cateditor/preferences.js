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

define( function() {
    var Preferences = {
        Load: function( borrowernumber ) {
            if ( borrowernumber == null ) return;

            var saved_prefs;
            try {
                saved_prefs = JSON.parse( localStorage[ 'cateditor_preferences_' + borrowernumber ] );
            } catch (e) {}

            Preferences.user = $.extend( {
                // Preference defaults
                fieldWidgets: true,
                font: 'monospace',
                fontSize: '1em',
                macros: {},
                selected_search_targets: {},
            }, saved_prefs );
        },

        Save: function( borrowernumber ) {
            if ( !borrowernumber ) return;
            if ( !Preferences.user ) Preferences.Load(borrowernumber);

            localStorage[ 'cateditor_preferences_' + borrowernumber ] = JSON.stringify(Preferences.user);
        },
    };

    return Preferences;
} );
