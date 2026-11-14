#!/bin/bash
# /home/oracle/cleanup_archivelog.sh
# Script per cancellare gli archivelog già applicati sulla standby
# Nota: richiede CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;
# Da schedulare su entrambi i nodi (utile in caso di switchover/failover)

#passa il sid da comando oppure usa orcl
export ORACLE_SID=${1:-orcl}
export ORACLE_HOME=/u01/app/oracle/product/26.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

mkdir -p /home/oracle/logs
LOG_DIR="/home/oracle/logs"
LOG="$LOG_DIR/cleanup_${ORACLE_SID}_$(date +%F).log"

# cancella gli archivelog applicati sulla standby e più vecchi di 2 giorni
rman target / >> "$LOG" 2>&1 <<EOF
CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
DELETE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
EXIT;
EOF

echo "Archivelog cleanup completato: $(date)" >> "$LOG"

#rimuove i file di log più vecchi di 30 giorni
find "$LOG_DIR" -name "cleanup_${ORACLE_SID}_*.log" -mtime +30 -delete
