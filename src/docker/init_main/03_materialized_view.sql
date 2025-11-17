CREATE MATERIALIZED VIEW client_type_sum_mv AS
SELECT
    (message->>'client_id')::int AS client_id,
    (message->>'operation_type')::operation_type_enum AS operation_type,
    SUM(amount) AS total_amount
FROM operations
WHERE status = 1
GROUP BY
    (message->>'client_id')::int,
    (message->>'operation_type')::operation_type_enum;
