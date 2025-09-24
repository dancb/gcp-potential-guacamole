# Aplicación de Bienvenida para GKE

Esta es una aplicación simple de Node.js y Express que sirve como ejemplo para ser desplegada en Google Kubernetes Engine (GKE).

Este documento contiene las instrucciones para dos escenarios:
1.  **Ejecución Local**: Para probar la aplicación en tu propia máquina usando Docker.
2.  **Despliegue en GKE**: Para desplegar la aplicación en el clúster de Kubernetes en Google Cloud.

---

## 1. Ejecución Local con Docker

Sigue estos pasos para construir y ejecutar la aplicación en tu entorno local.

### Requisitos

-   Tener Docker instalado.

### Pasos

1.  **Asegúrate de estar en este directorio** (`application`).

2.  **Construye la imagen de Docker**:
    ```bash
    docker build -t welcome-app:local .
    ```

3.  **Ejecuta el contenedor**:
    ```bash
    docker run -p 8080:8080 --name mi-app-local welcome-app:local
    ```

4.  **Verifica que funciona**:
    Abre tu navegador y visita `http://localhost:8080`. Deberías ver el mensaje de bienvenida.

---

## 2. Despliegue en Google Kubernetes Engine (GKE)

Sigue estos pasos para desplegar la aplicación en el clúster de GKE.

### Paso A: Construir y Subir la Imagen a Artifact Registry

1.  **Configura las variables de entorno**:
    ```bash
    export GCP_PROJECT_ID="elite-buttress-472417-g3"
    export GCP_REGION="us-central1"
    export IMAGE_TAG="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/potential-guacamole-repo/welcome-app:1.0.2"
    ```

2.  **Autentica Docker con Artifact Registry**:
    ```bash
    gcloud auth configure-docker ${GCP_REGION}-docker.pkg.dev
    ```

3.  **Construye la imagen para la arquitectura correcta (¡Importante!)**:
    Los nodos de GKE usan arquitectura `amd64`. Si estás en una Mac con Apple Silicon (M1/M2/M3, arquitectura `arm64`), debes construir la imagen para la plataforma correcta. De lo contrario, los pods fallarán con el error `ImagePullBackOff` y un mensaje de `no match for platform in manifest`.

    Usa `docker buildx` para construir y subir la imagen multi-plataforma. Asegúrate de estar en este directorio (`application`):
    ```bash
    docker buildx build --platform linux/amd64 -t $IMAGE_TAG --push .
    ```
    El flag `--push` sube la imagen directamente al registro después de construirla.

### Paso B: Aplicar los Manifiestos en Kubernetes

1.  **Actualiza el manifiesto de despliegue**:
    Asegúrate de que el archivo `kubernetes/deployment.yaml` use la nueva etiqueta de imagen (`1.0.1` en nuestro ejemplo).

2.  **Instala el plugin de autenticación de GKE (si es necesario)**:
    Si es la primera vez que te conectas o si recibes un error sobre `gke-gcloud-auth-plugin`, ejecuta:
    ```bash
    gcloud components install gke-gcloud-auth-plugin
    ```

3.  **Conéctate al clúster de GKE**:
    ```bash
    gcloud container clusters get-credentials potential-guacamole-cluster --region $GCP_REGION
    ```

4.  **Aplica los manifiestos**:
    Desde este directorio (`application`), ejecuta:
    ```bash
    kubectl apply -f kubernetes/
    ```
    Kubernetes detectará el cambio en la etiqueta de la imagen y creará nuevos pods.

### Paso C: Verificar el Despliegue

1.  **Revisa el estado de los pods**:
    Observa cómo los nuevos pods se inician y los antiguos se terminan.
    ```bash
    kubectl get pods -l app=welcome-app -w
    ```
    Espera a que los nuevos pods muestren el estado `Running` y `1/1` en la columna `READY`.

2.  **Obtén la IP externa del servicio**:
    El balanceador de carga puede tardar uno o dos minutos en provisionar una IP pública.
    ```bash
    kubectl get service welcome-app-service
    ```
    Copia la dirección IP de la columna `EXTERNAL-IP`.

3.  **Prueba la aplicación**:
    Pega la `EXTERNAL-IP` en tu navegador. ¡Deberías ver tu aplicación funcionando en GKE!
    ```
    http://<EXTERNAL-IP>
    ```