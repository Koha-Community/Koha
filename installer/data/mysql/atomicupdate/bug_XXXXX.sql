UPDATE systempreferences SET options="any_time_is_placed|not_always|any_time_is_collected" WHERE variable="HoldFeeMode";
UPDATE systempreferences SET value="any_time_is_placed" WHERE variable="HoldFeeMode" AND value="always";
