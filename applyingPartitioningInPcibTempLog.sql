select * from product_copy_inventory_box where id=2518778;
insert into product_copy_inventory_box_log select * from product_copy_inventory_box where id=2518778;
show create table product_copy_inventory_box_status_change_log_temp;

-- dropping foreign key as partitioning doesn't supported in table which has foreign key restrictions
# ALTER TABLE product_copy_inventory_box_status_change_log_temp DROP FOREIGN KEY product_copy_inventory_box_status_change_log_temp_ibfk_1;

ALTER TABLE product_copy_inventory_box_status_change_log_temp
    PARTITION BY RANGE (id) (
        PARTITION p1 VALUES LESS THAN (10),
        PARTITION p2 VALUES LESS THAN (40),
        PARTITION pRest VALUES LESS THAN MAXVALUE
        );

SELECT * FROM product_copy_inventory_box_status_change_log_temp PARTITION (p2);

ALTER TABLE product_copy_inventory_box_status_change_log_temp REMOVE PARTITIONING;

SELECT pcib_id, previous_status, current_status, recorded_in_ledger, DAYOFMONTH(FROM_UNIXTIME(created_time/1000)) , FROM_UNIXTIME(created_time/1000), FROM_UNIXTIME(updated_time/1000) FROM product_copy_inventory_box_status_change_log_temp;

-- preparing table for applying partition
SHOW CREATE TABLE product_copy_inventory_box_status_change_log_temp;
ALTER TABLE product_copy_inventory_box_status_change_log_temp DROP COLUMN id;
ALTER TABLE product_copy_inventory_box_status_change_log_temp DROP PRIMARY KEY;

-- partition by the date
ALTER TABLE product_copy_inventory_box_status_change_log_temp
    PARTITION BY RANGE (created_time) (
        PARTITION p1 VALUES LESS THAN (UNIX_TIMESTAMP('2021-06-25')),
        PARTITION p2 VALUES LESS THAN (UNIX_TIMESTAMP('2021-07-02')),
        PARTITION pRest VALUES LESS THAN MAXVALUE
        );

-- removing partition
ALTER TABLE product_copy_inventory_box_status_change_log_temp REMOVE PARTITIONING;

-- we can now easily separate recorded in ledger data and non recorded in ledger data
ALTER TABLE product_copy_inventory_box_status_change_log_temp
    PARTITION BY KEY (recorded_in_ledger) PARTITIONS 2;

SELECT * FROM information_schema.PARTITIONS WHERE TABLE_NAME='product_copy_inventory_box_status_change_log_temp';

SELECT * FROM product_copy_inventory_box_status_change_log_temp PARTITION (p1);

-- After finally partitioning by the recorded in ledger key
SHOW CREATE TABLE product_copy_inventory_box_status_change_log_temp;