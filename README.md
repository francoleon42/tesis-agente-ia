# 🤖 Proyecto de Tesis: Agente IA con n8n

Este repositorio contiene la infraestructura completa y dockerizada para la ejecución de un Agente de Inteligencia Artificial basado en flujos. Utiliza **n8n** como motor de orquestación, **PostgreSQL** para el historial de memoria a largo plazo, **Qdrant** como base de datos vectorial y la API de **Google Gemini**.

El entorno está diseñado para ser 100% reproducible y se ejecuta de forma aislada para evitar conflictos con otras instancias locales.

## 📁 Estructura del Proyecto

    ia-tesis/
    │
    ├── docker-compose.yml       # Orquestación de contenedores (n8n + Postgres)
    ├── .env.example             # Plantilla de variables de entorno requeridas
    ├── init-db/
    │   └── init.sql             # Script SQL de inicialización
    └── flujos/
        └── flujos_agente.json   # Exportación del workflow del Agente para importar en n8n

## 🛠️ Requisitos Previos

Para ejecutar este proyecto, necesitas tener instalado en tu sistema:
* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)

## 🚀 Guía de Instalación y Despliegue

### 1. Preparar las Variables de Entorno
Clona este repositorio y navega hasta la carpeta del proyecto. Luego, crea tu archivo de configuración local:

1. Duplica el archivo `.env.example` y renómbralo a `.env`.
2. Abre el archivo `.env` y completa los datos para la base de datos local.

### 2. Levantar la Infraestructura
Ejecuta el siguiente comando en la terminal para descargar las imágenes y levantar los contenedores en segundo plano:

    docker-compose up -d

*Nota: La base de datos local se expondrá en el puerto 5433 y n8n en el puerto 5679 para evitar conflictos con otras instancias locales existentes.*

### 3. Configuración Inicial de n8n
1. Ingresa a `http://localhost:5679` en tu navegador.
2. Crea tu cuenta de usuario administrador local (puedes usar cualquier correo, es un entorno cerrado).

### 4. Configurar Credenciales Manualmente
Para que los flujos puedan comunicarse con los servicios externos, debes configurar las credenciales en la interfaz de n8n:

1. Ve a la sección **Credentials** en el menú lateral izquierdo.
2. Haz clic en **Create credential** y da de alta las siguientes conexiones utilizando tus tokens reales:
   * **Postgres:** Configura el host como `postgres_tesis` y utiliza el usuario, contraseña y base de datos definidos en tu `.env`.
   * **Qdrant API:** Ingresa la URL de tu clúster y tu API Key.
   * **Google Gemini:** Ingresa tu API Key de Google AI Studio.

### 5. Importar el Flujo
1. Ve a la sección **Workflows** y haz clic en **Add Workflow**.
2. Abre el menú superior derecho (`...`) y selecciona **Import from File**.
3. Selecciona el archivo `.json` ubicado en la carpeta `/flujos` de este repositorio.
4. Ingresa al flujo y asegúrate de seleccionar las credenciales que acabas de crear en los nodos correspondientes.

¡Listo! Ya puedes ejecutar el Agente y realizar pruebas en el entorno local.

## 🛑 Comandos Útiles

* **Apagar el entorno:** `docker-compose down`
* **Ver logs de n8n:** `docker logs n8n_tesis`
* **Reiniciar el entorno aplicando cambios:** `docker-compose up -d --force-recreate`

---
**Autor:** Franco León Costantini - *Universidad Nacional de General Sarmiento (UNGS)*