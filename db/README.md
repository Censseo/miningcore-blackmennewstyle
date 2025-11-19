# Database Configuration

This directory contains PostgreSQL database configuration files for Miningcore.

## Files

- **[init-user-db.sh](init-user-db.sh)** - Database initialization script (mounted as Docker config)
- **[Dockerfile](Dockerfile)** - PostgreSQL 16.1 image with Miningcore SQL schemas
- **[pools/](pools/)** - Pool partition scripts for multi-pool clusters

## Architecture

The database initialization uses **Docker configs** instead of baked-in scripts. This provides:

- ✅ **Immutable configs** - Perfect for production deployments
- ✅ **No rebuild required** - Modify scripts without rebuilding images
- ✅ **Version control** - Track configuration changes in git
- ✅ **Environment-specific** - Different configs for dev/staging/prod
- ✅ **Docker Swarm compatible** - Works seamlessly in orchestrated environments

## How It Works

### 1. Docker Config Declaration

In [docker-compose.dev.yml](../docker-compose.dev.yml):

```yaml
services:
  db:
    build:
      context: .              # Build context is project root
      dockerfile: ./db/Dockerfile
    configs:
      - source: db-init-script
        target: /docker-entrypoint-initdb.d/init-user-db.sh
        mode: 0555

configs:
  db-init-script:
    file: ./db/init-user-db.sh
```

**Important:** The build context is the project root (`.`), not `./db`, to allow copying SQL scripts from `src/Miningcore/Persistence/Postgres/Scripts/`.

### 2. PostgreSQL Initialization

When the database container starts for the first time:

1. PostgreSQL runs all scripts in `/docker-entrypoint-initdb.d/`
2. Our `init-user-db.sh` script:
   - Creates the `miningcore` user and database
   - Loads the schema from `/miningcore/createdb.sql`
   - Sets up table partitioning (PostgreSQL 11+)
   - Optionally loads pool partitions from `/pools/createdb_shares.sql`

### 3. SQL Schemas

The base SQL schemas are copied into the image during build:

```dockerfile
COPY ../src/Miningcore/Persistence/Postgres/Scripts/createdb.sql /miningcore/
COPY ../src/Miningcore/Persistence/Postgres/Scripts/createdb_postgresql_11_appendix.sql /miningcore/
```

## Usage

### Development

```bash
# Start database with default configuration
docker-compose -f docker-compose.dev.yml up -d db

# Check initialization logs
docker-compose -f docker-compose.dev.yml logs db
```

### Modifying Initialization Script

```bash
# 1. Edit the script
nano db/init-user-db.sh

# 2. Recreate the container (configs are immutable)
docker-compose -f docker-compose.dev.yml up -d --force-recreate db
```

**Note:** Changes only apply to NEW databases. To reset:

```bash
docker-compose -f docker-compose.dev.yml down
docker volume rm miningcore-blackmennewstyle_miningcore-data
docker-compose -f docker-compose.dev.yml up -d db
```

### Adding Pool Partitions

For high-volume multi-pool clusters:

```bash
# 1. Create pool partition script
cp db/pools/createdb_shares.sql.example db/pools/createdb_shares.sql

# 2. Edit with your pool IDs
nano db/pools/createdb_shares.sql

# 3. Uncomment the config in docker-compose.dev.yml
nano docker-compose.dev.yml
# Uncomment:
# configs:
#   - source: db-pool-partitions
#     target: /pools/createdb_shares.sql
#     mode: 0444

# Also uncomment in the configs section:
# db-pool-partitions:
#   file: ./db/pools/createdb_shares.sql

# 4. Recreate database
docker-compose -f docker-compose.dev.yml down
docker volume rm miningcore-blackmennewstyle_miningcore-data
docker-compose -f docker-compose.dev.yml up -d db
```

### Production Deployment

For production, create separate config files:

```bash
# Create production-specific init script
cp db/init-user-db.sh db/init-user-db.prod.sh
nano db/init-user-db.prod.sh

# Create docker-compose.prod.yml
cat > docker-compose.prod.yml <<'EOF'
version: '3.9'
services:
  db:
    image: miningcore-db:1.0
    configs:
      - source: db-init-script
        target: /docker-entrypoint-initdb.d/init-user-db.sh
        mode: 0555

configs:
  db-init-script:
    file: ./db/init-user-db.prod.sh
EOF
```

### Docker Swarm Deployment

For orchestrated production environments:

```bash
# Initialize swarm
docker swarm init

# Create Docker configs
docker config create db-init-script db/init-user-db.sh
docker config create db-pool-partitions db/pools/createdb_shares.sql

# Create secrets
echo "your-secure-password" | docker secret create postgres_password -

# Deploy stack
docker stack deploy -c docker-compose.swarm.yml miningcore
```

In `docker-compose.swarm.yml`:

```yaml
services:
  db:
    configs:
      - source: db-init-script
        target: /docker-entrypoint-initdb.d/init-user-db.sh
    secrets:
      - postgres_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/postgres_password

configs:
  db-init-script:
    external: true

secrets:
  postgres_password:
    external: true
```

## Troubleshooting

### Config Not Applied

```bash
# Check if config is mounted
docker-compose -f docker-compose.dev.yml exec db ls -la /docker-entrypoint-initdb.d/

# View config content
docker-compose -f docker-compose.dev.yml exec db cat /docker-entrypoint-initdb.d/init-user-db.sh

# Check Docker config
docker config ls
docker config inspect db-init-script
```

### Init Script Errors

```bash
# View database initialization logs
docker-compose -f docker-compose.dev.yml logs db | grep -A 20 "PostgreSQL init process"

# Check script syntax locally
bash -n db/init-user-db.sh

# Run script manually for debugging
docker-compose -f docker-compose.dev.yml exec db /bin/bash
# Inside container:
bash -x /docker-entrypoint-initdb.d/init-user-db.sh
```

### Database Already Exists

The init script only runs on an empty database. If database exists:

```bash
# Option 1: Delete volume and recreate
docker-compose -f docker-compose.dev.yml down
docker volume rm miningcore-blackmennewstyle_miningcore-data
docker-compose -f docker-compose.dev.yml up -d db

# Option 2: Run SQL manually
docker-compose -f docker-compose.dev.yml exec db psql -U miningcore -d miningcore
```

## Security Notes

- ✅ Config files are mounted **read-only** (mode 0555 or 0444)
- ✅ No sensitive data in configs (use secrets for passwords)
- ✅ Database runs as `postgres` user (not root)
- ✅ Network isolated (no exposed ports by default)
- ⚠️ Don't commit `db/pools/createdb_shares.sql` (gitignored)
- ⚠️ Use Docker secrets for production passwords

## References

- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Docker Configs Documentation](https://docs.docker.com/engine/swarm/configs/)
- [PostgreSQL Partitioning](https://www.postgresql.org/docs/current/ddl-partitioning.html)
- [Miningcore Database Setup](../CLAUDE.md#database-setup)
