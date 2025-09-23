const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send('<h1>¡Bienvenido a la aplicación desplegada en GKE!</h1>');
});

app.listen(port, () => {
  console.log(`La aplicación está escuchando en el puerto ${port}`);
});