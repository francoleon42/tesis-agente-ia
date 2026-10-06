# 🤖 Proyecto de Tesis: Agente IA con n8n y Base Vectorial

Este repositorio contiene la infraestructura completa y dockerizada para la ejecución de un Agente de Inteligencia Artificial enfocado en la gestión de tesis. Utiliza **n8n** como motor de orquestación, **PostgreSQL** para la memoria persistente, **Qdrant** como base de datos vectorial y la API de **Google Gemini**, todo integrado con una **interfaz web profesional** servida por Nginx.

El entorno está diseñado para ser 100% reproducible y ejecutarse de forma aislada para evitar conflictos con otras instancias locales.

---

## 📁 Estructura del Proyecto

ia-tesis/
├── docker-compose.yml         # Orquestación de contenedores (Nginx + n8n + Postgres)
├── .env.example               # Plantilla de variables de entorno requeridas
├── init-db/
│   └── init.sql               # Script SQL de inicialización
├── frontend/
│   └── index.html             # Interfaz web de usuario (Chat y Sincronización)
└── flujos/
    └── flujos_agente.json     # Exportación de workflows para importar en n8n

---

## 🛠️ Requisitos Previos

Para ejecutar este proyecto, necesitas tener instalado en tu sistema:
* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)

---

## 🚀 Guía de Instalación y Despliegue

### 1. Preparar las Variables de Entorno
Clona este repositorio, navega hasta la carpeta del proyecto y configura tus credenciales locales:
1. Duplica el archivo `.env.example` y renómbralo a `.env`.
2. Completa los datos requeridos (como usuarios, contraseñas de Postgres y tokens de APIs).

### 2. Organizar el Frontend
Asegúrate de que tu archivo de interfaz web esté correctamente ubicado dentro de la carpeta del proyecto:
* La ruta debe ser: `ia-tesis/frontend/index.html`

### 3. Levantar la Infraestructura Completa
Ejecuta el siguiente comando en la terminal para descargar las imágenes y levantar los contenedores en segundo plano (n8n, la base de datos y el servidor web Nginx):

docker-compose up -d

* **Interfaz Web de Usuario:** Disponible en [http://localhost:8080](http://localhost:8080)
* **Panel de n8n (Backend/Orquestador):** Disponible en [http://localhost:5679](http://localhost:5679)
* **Base de Datos Postgres:** Expuesta en el puerto `5433`

---

## ⚙️ Configuración del Entorno (Modo Producción vs. Testeo)

La aplicación web se comunica con los webhooks de n8n. Puedes alternar fácilmente entre el modo de producción (flujos corriendo de forma automática) y el modo de pruebas (ejecución manual en n8n).

Abre el archivo `frontend/index.html` y busca la sección de configuración de JavaScript al final del código:

```javascript
// ==========================================
// CONFIGURACIÓN DE ENTORNO
// ==========================================
const IS_PRODUCTION = true; // Cambiar a false para modo de pruebas

### Opciones de Configuración:

* **Opción A: Modo Producción (`IS_PRODUCTION = true`)** — *Ideal para entregar el producto final o realizar pruebas integrales.*
  1. Ingresa a n8n ([http://localhost:5679](http://localhost:5679)) y abre tus flujos.
  2. Asegúrate de hacer clic en el botón superior **Publish** para dejarlos activos permanentemente escuchando las peticiones del frontend.
  3. La app web enviará las solicitudes automáticamente a la URL de producción (`/webhook/...`) y esperará la respuesta en segundo plano.

* **Opción B: Modo Testeo / Desarrollo (`IS_PRODUCTION = false`)** — *Ideal para depurar errores o modificar nodos.*
  1. Cambia la variable a `const IS_PRODUCTION = false;` en el `index.html`.
  2. En n8n, abre el flujo correspondiente y haz clic en el botón **"Execute Workflow"** (o en el nodo Webhook haz clic en *Listen for test event*).
  3. La app web enviará las solicitudes a la URL de prueba (`/webhook-test/...`) permitiéndote ver el recorrido paso a paso de los datos en tiempo real dentro del panel de n8n.

---

## 📋 Configuración Inicial en n8n (Solo la primera vez)

1. Ingresa a `http://localhost:5679` y crea tu cuenta de usuario administrador local.
2. **Credenciales:** Ve a la sección **Credentials** en el menú lateral e importa tus conexiones:
   * **Postgres:** Host `postgres_tesis`, utilizando las credenciales.
   * **Qdrant API:** Ingresa tu URL de clúster y API Key.
   * **Google Gemini:** Ingresa tu API Key de Google AI Studio.
   * **Google drive** Conseguir datos de google cloud en :https://console.cloud.google.com/.
   
3. **Importar Flujos:**
   * Ve a **Workflows** -> menú superior derecho (`...`) -> **Import from File**.
   * Selecciona el archivo `.json` ubicado en la carpeta `/flujos` y enlázalo con las credenciales creadas.

---

## 🛑 Comandos Útiles

* **Apagar el entorno:** `docker-compose down`
* **Ver logs de n8n:** `docker logs n8n_tesis`
* **Reiniciar el entorno aplicando cambios:** `docker-compose up -d --force-recreate`

---
**Autor:** Franco León Costantini - *Universidad Nacional de General Sarmiento (UNGS)*