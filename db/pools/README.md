# Pool Partition Scripts

This directory is for custom PostgreSQL partition scripts for multi-pool clusters.

## Purpose

When running a high-performance multi-pool cluster with PostgreSQL 11+, you can create partitioned tables for better performance. Each pool gets its own partition of the `shares` table.

## Usage

Create a file `createdb_shares.sql` in this directory with partition definitions for your pools:

```sql
-- Example: Create partitions for your pools
-- Replace 'mypool1', 'mypool2' with your actual pool IDs from config.json

CREATE TABLE IF NOT EXISTS shares_mypool1 PARTITION OF shares FOR VALUES IN ('mypool1');
CREATE TABLE IF NOT EXISTS shares_mypool2 PARTITION OF shares FOR VALUES IN ('mypool2');
CREATE TABLE IF NOT EXISTS shares_mypool3 PARTITION OF shares FOR VALUES IN ('mypool3');

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS shares_mypool1_created_idx ON shares_mypool1 (created);
CREATE INDEX IF NOT EXISTS shares_mypool2_created_idx ON shares_mypool2 (created);
CREATE INDEX IF NOT EXISTS shares_mypool3_created_idx ON shares_mypool3 (created);
```

## Mounting in Docker

The `createdb_shares.sql` file will be automatically loaded during database initialization if you uncomment the volume mount in `docker-compose.dev.yml`:

```yaml
volumes:
  - ./db/pools:/pools:ro
```

## Important Notes

1. **Pool ID must match**: The partition values (`'mypool1'`) must exactly match the pool IDs in your `config.json`

2. **Only for new databases**: These scripts only run during initial database creation. To add partitions to an existing database, connect manually:
   ```bash
   docker-compose -f docker-compose.dev.yml exec db psql -U miningcore -d miningcore
   ```
   Then run your CREATE TABLE commands.

3. **Performance**: Partitioning is recommended for high-volume pools (>1000 shares/second) running multiple pools on the same database.

4. **PostgreSQL 11+ required**: Table partitioning requires PostgreSQL 11 or higher (this image uses PostgreSQL 16).

## References

- See `src/Miningcore/Persistence/Postgres/Scripts/createdb_postgresql_11_appendix.sql` for the base partitioned table setup
- Miningcore documentation: [CLAUDE.md](../../CLAUDE.md#database-setup)
