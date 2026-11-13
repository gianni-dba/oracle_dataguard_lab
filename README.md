# oracle_dataguard_lab
# Oracle Data Guard lab: alta affidabilità HA e Disaster Recovery


**DISCLAIMER:** Questo repository documenta un ambiente di **laboratorio didattico e di studio personale**. L'installazione e l'uso di Oracle Database Enterprise Edition sono effettuati nel pieno rispetto della licenza OTN (Oracle Technology Network) per soli scopi di sviluppo, test e apprendimento, senza alcun fine di lucro o utilizzo in produzione.

Questo progetto documenta l'architettura, la configurazione e l'automazione di un ambiente di **High Availability (HA)** e **Disaster Recovery** basato su **Oracle Database (23ai)** e **Oracle Data Guard**, interamente virtualizzato su hypervisor **Proxmox VE**.

L'obiettivo del progetto è simulare un ambiente di produzione reale, dimostrando competenze nella gestione dei sistemi linux, nell'amministrazione di database Oracle e nell'automazione delle operazioni di manutenzione.

--

## Architettura dell'Infrastruttura

Il laboratorio è stato costruito partendo da zero su macchine virtuali Linux in modalità "headless" (multi-user.target) per ottimizzare l'uso della ram e simulare un reale ambiente server enterprise. 

* **Hypervisor:** Proxmox VE
* **Sistema Operativo Nodi:** Rocky Linux 9 (Enterprise Linux 9 compatibile)
* **Motore Database:** Oracle Database Enterprise Edition
* **Topologia configurata:**
  * **Primary Database (orcl):** Nodo principale di produzione. 
  * **Physical Standby (orcl_stby2):** Nodo di replica sincronizzato in tempo reale.
* **Modalità di protezione:** Massime performance (trasporto asincrono dei RedoLog).

--

## Fasi principali di implementazione

### 1. Preparazione del sistema operativo e sicurezza
* Ottimizzazione del sistema operativo (rimozione pacchetti grafici superflui e configurazione di `qemu-guest-agent` per l'interazione con Proxmox).
* Configurazione delle regole di rete (apertura porta 1521/tcp) e impostazione di SELinux in modalità permissive per evitare blocchi durante l'installazione, mantenendo comunque il logging degli audit.
* Installazione dei prerequisiti di kernel e creazione utenti/gruppi (oracle:oinstall, dba, dgba) tramite il pacchetto ufficiale oracle-database-preinstall.
* Configurazone delle variabili d'ambiente in .bash_profile e integrazione di rlwrap per migliorare l'usabilità e la cronologia dei client a riga di comando (`sqlplus`, `rman`, `dgmgrl`) .

### 2. Configurazione del database primario
* Abilitazione della modalità **ARCHIVELOG** per garantire la tracciabilità completa delle transazioni.
* Attivazione del **FORCE LOGGING** a livello database per assicurare che tutte le modifiche, incluse le **NOLOGGING** vengano replicate sullo standby.
* Configurazione dei file di rete (`listener.ora` e `tnsnames.ora`) con registrazione statica dei servizi (SID_LIST_LISTENER) per consentire le connessioni da remoto anche ad istanza spenta (nomount), requisito fondamentale per RMAM.

### 3. Creazione dello standby tramite RMAN Active Duplication
Invece di eseguire un backup su disco e trasferirlo manualmente, lo standby è stato inizializzato direttamente via rete, ottimizzando tempi e spazio: 
* Avvio dell'istanza ausiliaria in stato NOMOUNT tramite file di inizializzazione minimale (PFILE).
* Clonazione diretta e configurazione automatica dei parametri di Data Guard (`db_unique_name`, `fal_server`, `fal_client`,  `log_archive_config`, `standby_file_management=AUTO`).
* Creazione degli **Standby Redo Log (SRL)** dimensionati correttamente per ricevere i flussi in ingresso dal primario senza colli di bottiglia.
* Avvio del processo **MRP0 (Managed Recovery Process)** per l'applicazione continua dei Redo Log (`real_time_apply`).

---

Automazione e manutenzione (scripting)

Per simulare le best practice di un DBA in produzione, sono stati sviluppati e schedulati script di automazione: 

1. **Monitoraggio dello stato di Data Guard** Script bash (`check_dataguard_sh`) che verifica automaticamente il ruolo del database, lo stato del processo MRP0, eventuali gap negli archivelog e l'ultima sequenza applicata.
2. **Pulizia automatica degli Archivelog** Script che invoca RMAN per eliminare gli archivelog già applicati sulla standby e più vecchi di un determinato periodo, integrato con `crontab` per l'esecuzione notturna.
3. **Politiche di retenzione RMAN.** Configurazione di `CONFIGURE ARCHIVELOG DELETION POLICY TO APPLIED ON ALL STANDBY` per garantire che i log non vengano cancellati dal primario prima di essere applicati sulla standby, ed, allo stesso tempo, garantirne la cancellazione, mediante script automatizzati, manualmente, od automaticamente quando la FRA si riempe.

---

Sfide tecnologiche risolte 

Durante l'implementazione, sono state affrontate e risolte diverse criticità tipiche degli ambienti reali: 

* **Sincronizzazione sicura delle credenziali:** Invece di combattere con i complessi requisiti di password `orapwd` sulle nuove versioni, il file delle password `orapworcl` è stato clonato in modo sicuro dal primario allo standby tramite `scp`, garantendo la perfetta corrispondenza bit a bit richiesta per l'autenticazione SYSDBA remota.
*  **Gestione dei DB_UNIQUE_NAME:** Durante l'aggiunta di un secondo nodo standby, è stata gestita con attenzione la configurazione di `log_archive_config` e `log_archive_dest_N` sul primario per evitare conflitti di routing dei Redo Log (split-brain), assegnando nomi univoci globali a ogni istanza.
*  **Mapping dei percorsi file:** Prima del lancio di RMAN Duplicate, è stato creato uno script di ricognizione per mappare esattamente i percorsi dei datafile e dei controlfile del primario, ricreando la struttura delle directory sulla standby con i corretti permessi (`chown`/`chmod`) per evitare errori `ORA-27040` durante la creazione dei file.

---

in progress...
