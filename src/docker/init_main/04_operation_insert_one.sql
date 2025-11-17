CREATE OR REPLACE PROCEDURE operation_insert_one()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO operations (
        operation_date,
        operation_id,
        amount,
        status,
        message
    )
    VALUES (
        current_date,
        gen_random_uuid(),
        round((random() * 1000)::numeric, 2),
        0,
        jsonb_build_object(
            'account_number', substring(md5(random()::text), 1, 10),
            'client_id', (random() * 5000)::int,
            'operation_type', CASE round(random())::int
                                    WHEN 0 THEN 'offline'::operation_type_enum
                                    ELSE 'online'::operation_type_enum
                                END
        )
    );
END;
$$;
