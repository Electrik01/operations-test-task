CREATE OR REPLACE PROCEDURE change_status()
LANGUAGE plpgsql
AS $$
DECLARE
    v_even boolean;
    v_parity int;
    v_batch int := 20000;
BEGIN
    v_even := EXTRACT(SECOND FROM clock_timestamp())::int % 2 = 0;
    v_parity := CASE WHEN v_even THEN 0 ELSE 1 END;

    WITH candidates AS (
        SELECT operation_date, id
        FROM operations
        WHERE status = 0
          AND (id % 2) = v_parity
        ORDER BY operation_date, id
        LIMIT v_batch
    )
    UPDATE operations o
    SET status = 1
    FROM candidates c
    WHERE o.operation_date = c.operation_date
      AND o.id = c.id;

    REFRESH MATERIALIZED VIEW client_type_sum_mv;  
END;
$$;
