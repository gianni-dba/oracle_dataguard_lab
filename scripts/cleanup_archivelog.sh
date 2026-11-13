#!/bin/bash
# /home/oracle/cleanup_archivelog.sh
# Script per cancellare gli archivelog già applicati sulla standby
# Nota: richiede CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY;
# Da schedulare su entrambi i nodi (utile in caso di switchover/failover)

# Passa il sid da comando oppure usa orcl
export ORACLE_SID=${1:-orcl}
export ORACLE_HOME=/u01/app/oracle/product/26.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

# Cancella gli archivelog applicati sulla standby e più vecchi di 2 giorni
rman target / <<EOF
CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
DELETE NOPROMPT ARCHIVELOG ALL COMPLETED BEFORE 'SYSDATE-2';
-- DELETE NOPROMPT ARCHIVELOG ALL;
EXIT;
EOF

echo "Archivelog cleanup completato: $(date)"
