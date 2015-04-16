UPDATE aqorders SET orderstatus='cancelled'
                WHERE (datecancellationprinted IS NOT NULL OR
                       datecancellationprinted<>'0000-00-00');
