````markdown


# Modulo Terraform: BTP Print Server Creation

Questo modulo Terraform abilita le entitlements, crea la subscription e le istanze di servizio necessarie per SAP Print Server su un subaccount e uno space Cloud Foundry.


## Provider richiesti

```hcl
terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~>1.12.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.9.0"
    }
  }
}
```



### Configurazione dei provider

Esempio di configurazione dei provider con placeholder:

```hcl
provider "btp" {
  globalaccount = "<GLOBALACCOUNT_ID>" # ID dell'account globale BTP
  username      = "<USERNAME>"          # Username per autenticazione
  password      = "<PASSWORD>"          # Password per autenticazione
}

provider "cloudfoundry" {
  api_url  = "<CF_API_URL>" # URL dell'API Cloud Foundry
  user     = "<USERNAME>"   # Username per autenticazione
  password = "<PASSWORD>"   # Password per autenticazione
}
```

#### Spiegazione parametri
**Provider BTP**
- `globalaccount`: ID dell'account globale BTP.
- `username`: username per autenticazione.
- `password`: password per autenticazione.

**Provider Cloud Foundry**
- `api_url`: URL dell'API Cloud Foundry.
- `user`: username per autenticazione.
- `password`: password per autenticazione.



## Guida all'utilizzo

```hcl
module "print_server" {
  source = "git::https://github.com/RegestaItalia/regesta.devops.terraform.modules.btp-print-server-creation.git?ref=main"

  subaccountid       = "your_subaccount_id"
  spaceid            = "your_space_id"
  print-server-plan  = "default" # oppure altro piano disponibile
}
```


## Variabili di input

- **subaccountid** (string): ID del subaccount BTP.
- **spaceid** (string): ID dello space Cloud Foundry.
- **print-server-plan** (string, default: "default"): Piano da utilizzare per il servizio Print Server.




## Output

- **service-key**: Oggetto della chiave di servizio generata per Print Server. Contiene le credenziali necessarie per accedere al servizio.


## Risorse create

- **Entitlements** per il servizio: `print-server`
- **Istanza gestita** di servizio Cloud Foundry per `print-server`
- **Service key** per `print-server` (usata per ottenere le credenziali)

````
