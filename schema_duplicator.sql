DELIMITER //
DROP PROCEDURE IF EXISTS duplicate_schema//
CREATE PROCEDURE duplicate_schema(IN source_schema VARCHAR(64), IN target_schema VARCHAR(64))
BEGIN
    -- Declare cursor and handler
    DECLARE done INT DEFAULT FALSE;
    DECLARE tbl VARCHAR(64);
    DECLARE tables CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema = source_schema AND table_type = 'BASE TABLE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Create target schema if it doesn't exist
    SET @create_target_schema = CONCAT('CREATE SCHEMA IF NOT EXISTS ', target_schema);
    PREPARE stmt FROM @create_target_schema;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Get a list of tables in the source schema
    SET @get_tables = CONCAT('SELECT table_name FROM information_schema.tables WHERE table_schema = \'', source_schema, '\' AND table_type = \'BASE TABLE\'');
    PREPARE stmt FROM @get_tables;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Loop through the tables and create and insert into corresponding tables in the target schema
    OPEN tables;
    REPEAT
        -- Get the next table
        FETCH tables INTO tbl;
        IF NOT done THEN
            SET FOREIGN_KEY_CHECKS = 0;
            -- Create the new table
            SET @create_table = CONCAT('CREATE TABLE ', target_schema, '.', tbl, ' LIKE ', source_schema, '.', tbl);
            PREPARE stmt FROM @create_table;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            -- Copy the data to the new table
            SET @insert_into = CONCAT('INSERT INTO ', target_schema, '.', tbl, ' SELECT * FROM ', source_schema, '.', tbl);
            PREPARE stmt FROM @insert_into;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            -- Drop any foreign key constraints on the new table
	    SET @drop_constraints = CONCAT('SELECT CONCAT(\'ALTER TABLE ', target_schema, '.', tbl, ' DROP FOREIGN KEY \', constraint_name, \';\') FROM information_schema.table_constraints WHERE constraint_type=\'FOREIGN KEY\' AND table_schema=\'', target_schema, '\' AND table_name=\'', tbl, '\' AND constraint_name LIKE \'', tbl, '_ibfk_%\'');
	    PREPARE stmt FROM @drop_constraints;
	    EXECUTE stmt;
	    DEALLOCATE PREPARE stmt;
        SET FOREIGN_KEY_CHECKS = 1;
        END IF;
    UNTIL done END REPEAT;
    -- Output to SQL
	SELECT "Schema Copy Completed!" as "Status" FROM DUAL;
    -- Close the cursor
    CLOSE tables;
END//
DELIMITER ;

-- Then just call the procedure pass in source and target schema names
CALL duplicate_schema('source', 'target');
