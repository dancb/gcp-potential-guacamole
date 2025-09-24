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
    export IMAGE_TAG="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/potential-guacamole-repo/welcome-app:1.0.4" # Usar una nueva etiqueta para cada actualización
    ```

2.  **Autentica Docker con Artifact Registry**:
    ```bash
    gcloud auth configure-docker ${GCP_REGION}-docker.pkg.dev
    ```

3.  **Construye la imagen para la arquitectura correcta (¡Importante!)**:
    Los nodos de GKE usan arquitectura `amd64`. Si estás en una Mac con Apple Silicon (M1/M2/M3, arquitectura `arm64`), debes construir la imagen para la plataforma correcta. De lo contrario, los pods fallarán con el error `ImagePullBackOff` y un mensaje de `no match for platform in manifest`.

    Usa `docker buildx` para construir y subir la imagen multi-plataforma. Asegúrate de estar en este directorio (`application`):
    **¡Importante!** Verifica que la salida del comando `docker buildx` muestre la etiqueta completa (`:1.0.4` en este ejemplo) en la línea `naming to...` para asegurar que la imagen se sube correctamente.
    ```bash
    docker buildx build --platform linux/amd64 -t $IMAGE_TAG --push .
    ```
    El flag `--push` sube la imagen directamente al registro después de construirla.
    Puedes verificar que la imagen con la etiqueta correcta existe en Artifact Registry con: `gcloud artifacts docker images list $IMAGE_TAG --include-tags`

### Paso B: Aplicar los Manifiestos en Kubernetes

1.  **Actualiza el manifiesto de despliegue**:
    Asegúrate de que el archivo `kubernetes/deployment.yaml` use la nueva etiqueta de imagen (`1.0.3` en nuestro ejemplo).

2.  **Instala el plugin de autenticación de GKE (si es necesario)**:
    Si es la primera vez que te conectas o si recibes un error `CRITICAL: ACTION REQUIRED: gke-gcloud-auth-plugin...`, ejecuta:
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

---

## 3. Troubleshooting Común

Aquí se listan algunos problemas comunes que pueden surgir durante el despliegue y cómo resolverlos.

### Problema: `ImagePullBackOff` o `ErrImagePull`

Este error indica que Kubernetes no pudo descargar la imagen de Docker especificada para tus pods.

**Posibles causas y soluciones:**

1.  **Imagen no encontrada en Artifact Registry:**
    *   **Causa:** La imagen con la etiqueta especificada (`ej. :1.0.4`) no existe en el repositorio, o la URL en `deployment.yaml` es incorrecta. Esto puede ocurrir si la imagen no se construyó y subió correctamente, o si la etiqueta en el comando `docker buildx` no coincidió con la del `deployment.yaml`.
    *   **Solución:**
        *   Verifica la URL de la imagen en `kubernetes/deployment.yaml`.
        *   Asegúrate de que la variable `$IMAGE_TAG` esté configurada correctamente (ej. `welcome-app:1.0.4`).
        *   Vuelve a ejecutar el comando `docker buildx build --platform linux/amd64 -t $IMAGE_TAG --push .` y verifica cuidadosamente su salida para asegurar que la imagen se sube con la etiqueta correcta.
        *   Confirma la existencia de la imagen y su etiqueta en Artifact Registry con `gcloud artifacts docker images list $IMAGE_TAG --include-tags`.

2.  **Problema de arquitectura (`no match for platform in manifest`):**
    *   **Causa:** La imagen fue construida para una arquitectura diferente (ej. `arm64` en una Mac M1/M2) y los nodos de GKE (`amd64`) no encuentran una versión compatible.
    *   **Solución:** Asegúrate de usar `docker buildx build --platform linux/amd64 ...` al construir la imagen. Este problema se resuelve al seguir el "Paso A.3" de este documento.

3.  **Permisos insuficientes:**
    *   **Causa:** La cuenta de servicio de GKE no tiene permisos para leer imágenes de Artifact Registry.
    *   **Solución:** Asegúrate de que la cuenta de servicio por defecto de Compute Engine (`<PROJECT_NUMBER>-compute@developer.gserviceaccount.com`) tenga el rol `roles/artifactregistry.reader` en tu repositorio. Puedes añadirlo con:
        ```bash
        # Obtén el número de tu proyecto
        gcloud projects describe elite-buttress-472417-g3 --format="value(projectNumber)"
        # Añade el permiso
        gcloud artifacts repositories add-iam-policy-binding potential-guacamole-repo \
            --location=us-central1 \
            --member="serviceAccount:<PROJECT_NUMBER>-compute@developer.gserviceaccount.com" \
            --role="roles/artifactregistry.reader"
        ```

### Problema: `CrashLoopBackOff`

Este error indica que el contenedor se inicia, pero la aplicación dentro de él falla y se cierra repetidamente.

**Posibles causas y soluciones:**

1.  **Error en el código de la aplicación:**
    *   **Causa:** La aplicación Node.js tiene un error que provoca su cierre inesperado al inicio (ej. dependencia faltante, error de configuración, puerto incorrecto, etc.).
    *   **Solución:**
        *   Revisa los logs del pod para ver el mensaje de error exacto: `kubectl logs <nombre-del-pod>`.
        *   Asegúrate de que todas las dependencias necesarias (como `axios`) estén en la sección `dependencies` de `package.json`, no en `devDependencies`.
        *   Reconstruye y sube la imagen con una nueva etiqueta después de corregir el código.

### Problema: `gke-gcloud-auth-plugin` no encontrado

**Causa:** `kubectl` necesita un plugin para autenticarse con GKE, y este no está instalado o no es accesible.
**Solución:** Instala el plugin con `gcloud components install gke-gcloud-auth-plugin` y luego vuelve a obtener las credenciales del clúster con `gcloud container clusters get-credentials ...`.