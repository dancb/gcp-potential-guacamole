# Usa una imagen base oficial de Node.js 22
FROM node:22-alpine

# Crea y define el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Copia los archivos de dependencias
COPY package*.json ./

# Instala las dependencias de producción
RUN npm install --only=production

# Copia el resto del código fuente de la aplicación
COPY . .

# Expone el puerto en el que corre la aplicación
EXPOSE 8080

# Comando para iniciar la aplicación
CMD [ "node", "index.js" ]