SELECT cron.schedule(
    'operations_insert',
    '5 seconds',
    $$CALL operation_insert_one();$$
);

SELECT cron.schedule(
    'operations_change_status',
    '3 seconds',
    $$CALL change_status();$$
);

