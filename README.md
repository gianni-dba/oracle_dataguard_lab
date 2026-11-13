# oracle_dataguard_lab
# Oracle Data Guard lab: alta affidabilità HA e Disaster Recovery


** DISCLAIMER:** Questo repository documenta un ambiente di **laboratorio didattico e di studio personale**. L'installazione e l'uso di Oracle Database Enterprise Edition sono effettuati nel pieno rispetto della licenza OTN (Oracle Technology Network) per soli scopi di sviluppo, test e apprendimento, senza alcun fine di lucro o utilizzo in produzione.

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
