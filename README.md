# Operations Test Task

Demo environment with PostgreSQL 16, the `pg_cron` extension, a partitioned operations table, a materialized view, and configured streaming replication (primary -> replica). The project is launched via Docker Compose and intended for local runs.

## Components
- PostgreSQL 16 with `pg_cron` preconfigured in the image.
- Services: `postgres_primary` (port `5432`) and `postgres_replica` (port `5433`).
- Database: `operations_db`.
- Default user/password: `postgres`/`postgres`.
- Replication user: `replicator`/`123123` (created on the primary).
- Data is initialized by SQL scripts from `docker/init_main` at the first start of the primary.

## What Gets Provisioned
- Table `operations` (partitioned by `operation_date`) with an index on `(status, id)` and monthly partitions for 2025‑08...2025‑11.
- Enum `operation_type_enum` with values `offline`/`online`.
- Procedures:
  - `operations_test_data(p_start_date, p_end_date, p_rows_total)` — generates test data (called during initialization).
  - `operation_insert_one()` — inserts a single random operation.
  - `change_status()` — updates a subset of rows to status `1` and runs `REFRESH MATERIALIZED VIEW`.
- Materialized view `client_type_sum_mv` — sum of `amount` by `(client_id, operation_type)` for rows with `status = 1` only.
- `pg_cron` jobs:
  - every 5 seconds: `CALL operation_insert_one();`
  - every 3 seconds: `CALL change_status();`
- Streaming replication:
  - The replica performs a base backup from the primary at first start.
  - Config enables `wal_level=replica`, `max_wal_senders`, `replication_slots`, `hot_standby=on`.

## Database Access
- Primary: `localhost:5432`
- Replica: `localhost:5433`
- Database: `operations_db`
- User: `postgres`
- Password: `postgres`

## Notes and Configuration
- Partitions are created for months from 2025‑08 through 2025‑11.
- Replication user and access (`pg_hba`) are defined in `docker/init_main/07_replication_user.sql` and `docker/init_main/08_pg_hba_replication.sh`. In this demo, access is open to `0.0.0.0/0`.
- The image includes `pg_cron` and sets `shared_preload_libraries = 'pg_cron'` and `cron.database_name = 'operations_db'`.
- The replica uses `docker/init_replica/replica-entrypoint.sh` to wait for the primary and run `pg_basebackup`.

## Project Structure
- `docker/Dockerfile` — builds the PostgreSQL image with `pg_cron` and config.
- `docker/init_main/*.sql` — schema/data initialization, materialized view, and pg_cron jobs for the primary.
- `docker/init_main/08_pg_hba_replication.sh` — extends `pg_hba.conf` for replication.
- `docker/init_replica/replica-entrypoint.sh` — replica startup script.
