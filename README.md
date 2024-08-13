
# Schema Duplicator

This SQL script duplicates a schema without referential integrity. It creates a copy of the schema by iterating over all tables in the source schema and creating and inserting them into the target schema. The copy process does not include foreign key constraints.

## Prerequisites

-   MySQL
-   Administrative privileges

## Usage

To use this script, simply call the `duplicate_schema` stored procedure and pass in the source and target schema names as parameters. For example:

sql

`CALL duplicate_schema('source_schema', 'target_schema');` 

## Procedure Steps

1.  Declare cursor and handler
2.  Create target schema if it doesn't exist
3.  Get a list of tables in the source schema
4.  Loop through the tables and create and insert into corresponding tables in the target schema
5.  Drop any foreign key constraints on the new table
6.  Output to SQL
7.  Close the cursor

## Limitations

This script does not copy foreign key constraints between tables. Therefore, the target schema will not have the same referential integrity as the source schema.

## License

This script is licensed under the MIT License.
