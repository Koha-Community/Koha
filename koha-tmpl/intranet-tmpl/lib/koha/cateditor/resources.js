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

define( [ 'module' ], function( module ) {
    var _allResources = [];

    var Resources = {
        GetAll: function() {
            return $.when.call( null, _allResources );
        }
    };

    function _res( name, deferred ) {
        Resources[name] = deferred;
        _allResources.push(deferred);
    }

    switch ( module.config().marcflavour ) {
        case 'MARC21':
            _res( 'marc21/xml/006', $.get( module.config().themelang + '/data/marc21_field_006.xml' ) );
            _res( 'marc21/xml/008', $.get( module.config().themelang + '/data/marc21_field_008.xml' ) );
            break;
    }

    return Resources;
} );
