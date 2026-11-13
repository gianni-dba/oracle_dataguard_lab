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
* Ottimizzazione del sistema operativo (rimozione pacchetti grafici superflui e configurazione di qemu-guest-agent per l'interazione con Proxmox).
* Configurazione delle regole di rete (apertura porta 1521/tcp) e impostazione di SELinux in modalità permissive per evitare blocchi durante l'installazione, mantenendo comunque il logging degli audit.
* Installazione dei prerequisiti di kernel e creazione utenti/gruppi (oracle:oinstall, dba, dgba) tramite il pacchetto ufficiale oracle-database-preinstall.
* Configurazone delle variabili d'ambiente in .bash_profile e integrazione di rlwrap per migliorare l'usabilità e la cronologia dei client a riga di comando (sqlplus, rman, dgmgrl) .

### 2. Configurazione del database primario
* Abilitazione della modalità **ARCHIVELOG** per garantire la tracciabilità completa delle transazioni.
* Attivazione del **FORCE LOGGING** a livello database per assicurare che tutte le modifiche, incluse le **NOLOGGING** vengano replicate sullo standby.
* Configurazione dei file di rete (listener.ora e tnsnames.ora) con registrazione statica dei servizi (SID_LIST_LISTENER) per consentire le connessioni da remoto anche ad istanza spenta (nomount), requisito fondamentale per RMAM.
