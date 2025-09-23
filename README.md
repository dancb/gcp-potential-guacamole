# Infraestructura en GCP con Terraform para "Potential Guacamole"

Este repositorio contiene el código de Terraform (o OpenTofu) para desplegar una infraestructura base en Google Cloud Platform (GCP). La configuración está diseñada para alojar una aplicación en contenedores, utilizando servicios gestionados para simplificar la operación y el mantenimiento.

## Características de la Infraestructura

La configuración de Terraform desplegará los siguientes recursos en tu proyecto de GCP:

### 1. Gestión de APIs

- **Habilitación Automática de APIs**: El código habilita automáticamente las APIs de GCP necesarias antes de crear los recursos.
  - `container.googleapis.com` (Kubernetes Engine API)
  - `artifactregistry.googleapis.com` (Artifact Registry API)

### 2. Redes (VPC)

- **Red Virtual Personalizada (VPC)**: Se crea una VPC llamada `potential-guacamole-vpc` para aislar los recursos de la red. No se utilizan las subredes automáticas para un mayor control.
- **Subred**: Se provisiona una subred (`potential-guacamole-subnet`) en la región `us-central1` con el rango de IPs `10.10.1.0/24`.

### 3. Orquestación de Contenedores (GKE)

- **Clúster de GKE Autopilot**: Se despliega un clúster de Google Kubernetes Engine llamado `potential-guacamole-cluster` en modo **Autopilot**. Este modo gestiona automáticamente la infraestructura subyacente (nodos, escalado, etc.), permitiendo enfocarse únicamente en los workloads.

### 4. Registro de Artefactos

- **Repositorio de Docker**: Se crea un repositorio en Artifact Registry (`potential-guacamole-repo`) en la región `us-central1` para almacenar y gestionar imágenes de Docker.
- **Permisos de Acceso**: Se configura automáticamente el permiso `roles/artifactregistry.reader` para la cuenta de servicio por defecto de Compute Engine. Esto permite que el clúster de GKE Autopilot se autentique y extraiga imágenes de este repositorio de forma segura.

## Requisitos Previos

1.  **Terraform / OpenTofu**: Tener instalado Terraform o OpenTofu.
2.  **Google Cloud SDK**: Tener `gcloud` CLI instalado y configurado.
3.  **Autenticación**: Estar autenticado en GCP con los permisos necesarios para crear los recursos descritos. Puedes hacerlo ejecutando:
    ```sh
    gcloud auth application-default login
    ```

## Cómo Desplegar la Infraestructura

1.  **Clonar el repositorio**:
    ```sh
    git clone <URL-del-repositorio>
    cd <nombre-del-repositorio>
    ```

2.  **Inicializar Terraform/Tofu**:
    ```sh
    tofu init
    # o terraform init
    ```

3.  **Revisar el Plan**:
    ```sh
    tofu plan
    # o terraform plan
    ```

4.  **Aplicar los cambios**:
    ```sh
    tofu apply
    # o terraform apply
    ```

## Variables de Entrada

Los siguientes parámetros se pueden personalizar en el archivo `variables.tf` o creando un archivo `terraform.tfvars`.

| Nombre           | Descripción                                | Valor por Defecto            |
| ---------------- | ------------------------------------------ | ---------------------------- |
| `gcp_project_id` | El ID único del proyecto de Google Cloud.  | `elite-buttress-472417-g3`   |
| `project_name`   | El prefijo para nombrar todos los recursos. | `potential-guacamole`        |

## Diagrama Simplificado

```
------------------ GCP Project ------------------
|                                               |
|   [VPC: potential-guacamole-vpc]              |
|     |                                         |
|     +-- [Subnet: 10.10.1.0/24]                |
|           |                                   |
|           +-- [GKE Autopilot Cluster] <-----> [Artifact Registry]
|                 (Pulls images)                      (Stores Docker images)
|                                               |
-------------------------------------------------
```