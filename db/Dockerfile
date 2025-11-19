# syntax=docker/dockerfile:1
FROM postgres:16.1-alpine3.19

LABEL maintainer="miningcore" \
      description="PostgreSQL database for Miningcore mining pool server" \
      version="1.0"

# Create directories for SQL scripts
# These will be populated via volume mounts in docker-compose
RUN mkdir -p /miningcore /pools /docker-entrypoint-initdb.d

# Copy SQL scripts from the actual location in the repo
# Build context is project root, so paths are relative to root
COPY src/Miningcore/Persistence/Postgres/Scripts/createdb.sql /miningcore/
COPY src/Miningcore/Persistence/Postgres/Scripts/createdb_postgresql_11_appendix.sql /miningcore/

# Declare data volume
VOLUME /var/lib/postgresql/data

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD pg_isready -U ${POSTGRES_USER:-postgres} || exit 1
