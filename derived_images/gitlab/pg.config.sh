#======================================
# Configure PostgreSQL database
#--------------------------------------

DATADIR=~postgres/data

# Handy wrapper to call pg_ctl with the correct user.
pg_ctl () {
  CMD="/usr/bin/pg_ctl $@"
  su - postgres -c "$CMD"
}

psql () {
  CMD="/usr/bin/psql $@"
  su - postgres -c "$CMD"
}

pg_restore () {
  CMD="/usr/bin/pg_restore $@"
  su - postgres -c "$CMD"
}


# Helper function to execute the given sql file.
execute_sql_file() {
  su postgres -c "psql -q -d $2 < $1 2>&1"
}

# Initialize PostgreSQL
echo "## Initializing PostgreSQL databases and tables..."
# Setting /tmp to 777 with sticky bit for initdb to work properly
# Fix for bnc#919520
echo "## Setting /tmp to 777 with sticky bit..."
chmod a+trwx /tmp
LANG_SYSCONFIG=/etc/sysconfig/language
LANG=$(test -f $LANG_SYSCONFIG && . $LANG_SYSCONFIG && echo ${POSTGRES_LANG:-$RC_LANG})
install -d -o postgres -g postgres -m 700 ${DATADIR} && su - postgres -c \
  "/usr/bin/initdb --locale=$LANG --auth='trust' --auth-host='trust' --auth-local='trust' $DATADIR &> initlog"

# Start PostgreSQL without networking
echo "## Starting PostgreSQL..."
pg_ctl start -o "\"-c listen_addresses=''\"" -s -w -D $DATADIR

# Load PostgreSQL data dump, if it exists
pgsql_dump=/tmp/pgsql_dump.sql
if [ -f "$pgsql_dump" ]; then
  echo "## Loading PostgreSQL data dump..."
  execute_sql_file "$pgsql_dump"  "postgres"
else
  echo "## No PostgreSQL data dump found, skipping"
fi


# Load PostgreSQL users and permissions, if setup file exists
pgsql_perms=/tmp/pgsql_config.sql
if [ -f "$pgsql_perms" ]; then
  echo "## Loading PostgreSQL users and perms..."
  execute_sql_file "$pgsql_perms" "postgres"

  # update config file to allow trust login
  #sed -i "s/127.0.0.1\/32/samenet/g" /var/lib/pgsql/data/pg_hba.conf
  #sed -i "s/max_connections \?= \?100/max_connections = 1000/g" /var/lib/pgsql/data/postgresql.conf
  #sed -i "s/#listen_addresses \?= \?'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/data/postgresql.conf
else
  echo "## No PostgreSQL user/perms config found, skipping"
fi


# Stop PostgreSQL service (for uncontained builds)
echo "## Stopping PostgreSQL..."
pg_ctl stop -s -D $DATADIR -m fast

# Clean up temp files (for uncontained builds)
rm -f "$pgsql_perms" "$pgsql_dump"

echo "## PostgreSQL configuration complete"
