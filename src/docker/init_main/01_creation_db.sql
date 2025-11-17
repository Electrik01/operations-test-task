CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE TYPE operation_type_enum AS ENUM ('offline', 'online');

CREATE TABLE IF NOT EXISTS operations (
    operation_date date NOT NULL,
    id bigint GENERATED ALWAYS AS IDENTITY,
    operation_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    status int NOT NULL,
    message jsonb NOT NULL,

    CONSTRAINT operations_pk PRIMARY KEY (operation_date, id),
    CONSTRAINT operations_operation_id_uq UNIQUE (operation_date, operation_id)
)
PARTITION BY RANGE (operation_date);

CREATE INDEX operations_status_id_index
    ON operations (status, id);

CREATE TABLE IF NOT EXISTS operations_2025_08
    PARTITION OF operations
    FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

CREATE TABLE IF NOT EXISTS operations_2025_09
    PARTITION OF operations
    FOR VALUES FROM ('2025-09-01') TO ('2025-10-01');

CREATE TABLE IF NOT EXISTS operations_2025_10
    PARTITION OF operations
    FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');

CREATE TABLE IF NOT EXISTS operations_2025_11
    PARTITION OF operations
    FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');