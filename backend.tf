 # Configuración del backend remoto en Google Cloud Storage.
 # Esto le dice a OpenTofu/Terraform que almacene el archivo de estado
 # de forma segura en un bucket de GCS en lugar de localmente.
 terraform {
   backend "gcs" {
     bucket = "elite-buttress-472417-g3-tfstate" # El nombre del bucket que acabas de crear.
     prefix = "terraform/state"                  # Una "carpeta" dentro del bucket para organizar el estado.
   }
 }