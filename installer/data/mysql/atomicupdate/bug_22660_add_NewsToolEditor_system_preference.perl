$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES('NewsToolEditor','tinymce', 'Choose tool for editing News','tinymce|codemirror','Choice')" );

    NewVersion( $DBversion, 22660, "Adds NewsToolEditor system preference");
}
