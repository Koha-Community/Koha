/* Copyright 2013 C & P Bibliography Services
 *
 * This file is part of Koha.
 *
 * Koha is free software; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 3 of the License, or (at your option) any later
 * version.
 *
 * Koha is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with Koha; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

(function( kohadb, $, undefined ) {
    kohadb.settings = kohadb.settings || {};
    kohadb.initialize = function (callback) {
        $.indexedDB("koha", {
            "version": 1,
            "schema": {
                "1": function(versionTransaction){
                    var patrons = versionTransaction.createObjectStore("patrons", {
                        "keyPath": "cardnumber"
                    });
                    var items = versionTransaction.createObjectStore("items", {
                        "keyPath": "barcode"
                    });
                    var issues = versionTransaction.createObjectStore("issues", {
                        "keyPath": "barcode"
                    });
                    issues.createIndex("cardnumber", { "multiEntry": true });
                    var transactions = versionTransaction.createObjectStore("transactions", {
                        "keyPath": "timestamp"
                    });
                    var settings = versionTransaction.createObjectStore("offline_settings", {
                        "keyPath": "key"
                    });
                },
            }
        }).done(function(){
            if (typeof callback === 'function') {
                callback();
                kohadb.loadSetting('userid');
                kohadb.loadSetting('branchcode');
            }
        });
    };
    kohadb.loadSetting = function (key, callback) {
        $.indexedDB("koha").transaction(["offline_settings"]).then(function(){
        }, function(err, e){
            if (typeof callback === 'function') {
                callback(key, undefined);
            }
        }, function(transaction){
            var settings = transaction.objectStore("offline_settings");
            settings.get(key).done(function (item, error) {
                if (typeof item !== 'undefined') {
                    kohadb.settings[key] = item.value;
                }
                if (typeof callback === 'function') {
                    callback(key, kohadb.settings[key]);
                }
            });
        });
    };
    kohadb.saveSetting = function (key, value) {
        $.indexedDB("koha").transaction(["offline_settings"]).then(function(){
        }, function(err, e){
        }, function(transaction){
            var settings = transaction.objectStore("offline_settings");
            settings.put({ "key" : key, "value" : value });
            kohadb.settings[key] = value;
        });
    };
    kohadb.recordTransaction = function (newtrans, callback) {
        $.indexedDB("koha").transaction(["transactions"]).then(function(){
            callback(newtrans);
        }, function(err, e){
        }, function(dbtransaction) {
            var transactions = dbtransaction.objectStore("transactions");
            transactions.put(newtrans);
            kohadb.saveSetting('dirty', true);
        });
    };
}( window.kohadb = window.kohadb || {}, jQuery ));

if ( !Date.prototype.toMySQLString ) {
  ( function() {

    function pad(number) {
      var r = String(number);
      if ( r.length === 1 ) {
        r = '0' + r;
      }
      return r;
    }

    Date.prototype.toMySQLString = function() {
      return this.getFullYear()
        + '-' + pad( this.getMonth() + 1 )
        + '-' + pad( this.getDate() )
        + ' ' + pad( this.getHours() )
        + ':' + pad( this.getMinutes() )
        + ':' + pad( this.getSeconds() )
        + '.' + String( (this.getMilliseconds()/1000).toFixed(3) ).slice( 2, 5 );
    };

  }() );
}
