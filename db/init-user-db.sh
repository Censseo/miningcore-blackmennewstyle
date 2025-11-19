#!/bin/bash
set -e

# Create miningcore user and database if needed
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE ROLE IF NOT EXISTS miningcore WITH LOGIN PASSWORD '$POSTGRES_PASSWORD';
	ALTER ROLE miningcore WITH PASSWORD '$POSTGRES_PASSWORD';
	CREATE DATABASE IF NOT EXISTS miningcore OWNER miningcore;
	ALTER DATABASE miningcore OWNER TO miningcore;
EOSQL

# Initialize database schema
echo "Creating database schema..."
psql --username miningcore -d miningcore -f /miningcore/createdb.sql

# Add PostgreSQL 11+ partitioning support (for multi-pool clusters)
echo "Setting up table partitioning..."
psql --username miningcore -d miningcore -f /miningcore/createdb_postgresql_11_appendix.sql

# Create table shares partitions for pools (optional, if config exists)
if [ -f /pools/createdb_shares.sql ]; then
    echo "Creating pool-specific share partitions..."
    psql --username miningcore -d miningcore -f /pools/createdb_shares.sql
else
    echo "No pool-specific share partitions configured. Skipping /pools/createdb_shares.sql"
fi

echo "Database initialization completed successfully!"
