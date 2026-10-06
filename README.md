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
2. Abre el archivo `.env` y completa los datos con tus propias credenciales y contraseñas. **Nota:** No utilices comillas para los valores en este archivo.

### 2. Levantar la Infraestructura
Ejecuta el siguiente comando en la terminal para descargar las imágenes y levantar los contenedores en segundo plano:

    docker-compose up -d

*Nota: La base de datos local se expondrá en el puerto 5433 y n8n en el puerto 5679 para evitar conflictos con otras instancias locales existentes.*

### 3. Configuración Inicial de n8n
1. Ingresa a `http://localhost:5679` en tu navegador.
2. Crea tu cuenta de usuario administrador local (puedes usar cualquier correo, es un entorno cerrado).

### 4. Inyección de Credenciales (Paso Crítico)
Por seguridad, las claves reales se inyectan dinámicamente desde el archivo `.env` en tiempo de ejecución. Para que n8n permita esta inyección, debes crear los "cascarones" en la interfaz gráfica:

1. Ve a la sección **Credentials** en el menú lateral izquierdo.
2. Haz clic en **Create credential** y crea exactamente estas tres credenciales, respetando las mayúsculas y espacios:
   * `Postgres account`
   * `Qdrant account`
   * `Google Gemini(PaLM) Api account`
3. Llena los campos obligatorios de cada una con datos falsos (por ejemplo, escribe `1234` en los campos de usuario, contraseña o API Key) y guárdalas. El sistema reemplazará estos datos falsos por los reales de tu `.env` de forma invisible al ejecutar el flujo.

### 5. Importar el Flujo
1. Ve a la sección **Workflows** y haz clic en **Add Workflow**.
2. Abre el menú superior derecho (`...`) y selecciona **Import from File**.
3. Selecciona el archivo `.json` ubicado en la carpeta `/flujos` de este repositorio.

¡Listo! Ya puedes ejecutar el Agente y realizar pruebas en el entorno local.

## 🛑 Comandos Útiles

* **Apagar el entorno:** `docker-compose down`
* **Ver logs de n8n:** `docker logs n8n_tesis`
* **Reiniciar el entorno aplicando cambios:** `docker-compose up -d --force-recreate`

---
**Autor:** Franco León Costantini - *Universidad Nacional de General Sarmiento (UNGS)*