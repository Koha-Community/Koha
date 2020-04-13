$DBversion = '19.12.00.XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do( q{
            INSERT IGNORE INTO systempreferences (variable,value,explanation,type) VALUES
                ('MaxTotalSuggestions','','Number of total suggestions used for time limit with NumberOfSuggestionDays','Free'),
                ('NumberOfSuggestionDays','','Number of days that will be used to determine the MaxTotalSuggestions limit','Free')
            });

    NewVersion( $DBversion, 22774, "Limit purchase suggestion in a specified time period");
}
