CREATE OR REPLACE PROCEDURE operations_test_data(
    p_start_date date,
    p_end_date date,
    p_rows_total integer DEFAULT 100000
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_days int;
    v_rows_per_day int;
BEGIN
    IF p_end_date <= p_start_date THEN
        RAISE EXCEPTION 'p_end_date must be > p_start_date';
    END IF;

    v_days := (p_end_date - p_start_date);
    v_rows_per_day := GREATEST(1, p_rows_total / v_days);

    INSERT INTO operations (
        operation_date,
        operation_id,
        amount,
        status,
        message
    )
    SELECT
        (p_start_date + d)::date AS operation_date,
        gen_random_uuid() AS operation_id,
        round((random() * 1000)::numeric, 2) AS amount,
        round(random())::int AS status,
        jsonb_build_object(
            'account_number', substring(md5(random()::text), 1, 10),
            'client_id', (random() * 5000)::int,
            'operation_type', CASE round(random())::int
                                    WHEN 0 THEN 'offline'::operation_type_enum
                                    ELSE 'online'::operation_type_enum
                                END
        ) AS message
    FROM generate_series(0, v_days - 1) AS days_table(d)
    CROSS JOIN LATERAL generate_series(1, v_rows_per_day) AS rows_table(r);
END;
$$;

CALL operations_test_data(
    p_start_date => DATE '2025-08-01',
    p_end_date   => DATE '2025-11-01',
    p_rows_total => 120000
);
