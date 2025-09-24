const express = require('express');
const axios = require('axios');
const app = express();
const port = process.env.PORT || 8080;

const METADATA_URL = 'http://metadata.google.internal/computeMetadata/v1/instance/zone';
const METADATA_HEADERS = { headers: { 'Metadata-Flavor': 'Google' } };

/**
 * Obtiene la región de GCP desde el servidor de metadatos.
 * @returns {Promise<string>} La región de GCP o un mensaje de error.
 */
async function getRegion() {
  try {
    const response = await axios.get(METADATA_URL, METADATA_HEADERS);
    // El formato de la respuesta es: projects/PROJECT_NUMBER/zones/us-central1-a
    const zone = response.data.split('/').pop();
    // Extraemos la región de la zona (ej: 'us-central1-a' -> 'us-central1')
    const region = zone.slice(0, -2);
    return region;
  } catch (error) {
    console.error('No se pudo obtener la región del servidor de metadatos:', error.message);
    // Este mensaje se mostrará si la app corre localmente o si hay un error.
    return 'Región Desconocida';
  }
}

app.get('/', async (req, res) => {
  const region = await getRegion();
  res.send(`
    <h1>¡Bienvenido a la aplicación desplegada en GKE!</h1>
    <h2>Región de Despliegue: ${region}</h2>
  `);
});

app.listen(port, () => {
  console.log(`La aplicación está escuchando en el puerto ${port}`);
});