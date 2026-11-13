#!/bin/bash
# File: /home/oracle/check_dataguard.sh

#passa il sid da comando oppure usa orcl
export ORACLE_SID=${1:-orcl}
export ORACLE_HOME=/u01/app/oracle/product/26.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

# Verifica che sqlplus sia disponibile
if ! command -v sqlplus &> /dev/null; then
    echo "Errore: sqlplus non trovato. Verifica ORACLE_HOME e PATH."
    exit 1
fi

echo "=========================================="
echo " Controllo Data Guard per SID: $ORACLE_SID"
echo " Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo ""
echo "=== Stato del database ==="
sqlplus -s / as sysdba <<EOF
SELECT database_role, open_mode FROM v\$database;
EOF

echo ""
echo "=== Processi Data Guard ==="
sqlplus -s / as sysdba <<EOF
SELECT process, status, sequence# FROM v\$managed_standby WHERE process IN ('MRP0', 'RFS');
EOF

echo ""
echo "=== Gap di archivelog ==="
sqlplus -s / as sysdba <<EOF
SELECT * FROM v\$archive_gap;
EOF

echo ""
echo "=== Ultimo archivelog applicato ==="
sqlplus -s / as sysdba <<EOF
SELECT MAX(sequence#) FROM v\$archived_log WHERE applied='YES';
EOF
