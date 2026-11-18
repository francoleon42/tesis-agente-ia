# 🤖 Proyecto de Tesis: Agente IA con n8n, RAG y LLM Local

Este repositorio contiene la infraestructura completa y dockerizada para desplegar un **Agente de Inteligencia Artificial** orientado a asistir a estudiantes en la preparación de su propuesta de tesis.

La arquitectura integra **n8n** como motor de orquestación, **Ollama** para la ejecución de modelos de lenguaje (LLM) de forma 100% local y privada, **Qdrant** como base de datos vectorial (RAG), **Google Gemini** exclusivamente para la generación de *embeddings*, **PostgreSQL** para la persistencia de sesiones temporales (con purga automática cada 24 hs) y una **interfaz web** servida con **Nginx**.

---

## 📑 Tabla de Contenidos
1. [Arquitectura y Estructura del Proyecto](#1-arquitectura-y-estructura-del-proyecto)
2. [Requisitos Previos](#2-requisitos-previos)
3. [Instalación y Despliegue de Infraestructura](#3-instalación-y-despliegue-de-infraestructura)
4. [Descarga del Modelo de IA Local (Ollama)](#4-descarga-del-modelo-de-ia-local-ollama)
5. [Configuración de la Base de Datos (Memoria 24 hs)](#5-configuración-de-la-base-de-datos-memoria-24-hs)
6. [Importación y Configuración de Flujos en n8n](#6-importación-y-configuración-de-flujos-en-n8n)
7. [Guía de Credenciales y APIs Externas](#7-guía-de-credenciales-y-apis-externas)
8. [Configuración del Frontend (Producción vs. Testeo y Usuarios Temporales)](#8-configuración-del-frontend-producción-vs-testeo-y-usuarios-temporales)
9. [Verificación y Comandos Útiles](#9-verificación-y-comandos-útiles)

---

## 1. Arquitectura y Estructura del Proyecto

```text
ia-tesis/
├── docker-compose.yml              # Orquestación de contenedores (Nginx, n8n, Postgres, Ollama)
├── .env.example                    # Plantilla de variables de entorno
├── init-db/
│   └── init.sql                    # Script SQL de inicialización de PostgreSQL
├── frontend/
│   └── index.html                  # Interfaz web (Chat con ID de usuario temporal y sincronización)
└── flujos-n8n/
    ├── ingesta-drive-qdrant.json   # Flujo 1: Carga de PDFs desde Drive hacia Qdrant (Opcional)
    ├── chat-rag-tesisV2.json       # Flujo 2: Agente RAG principal y gestión de sesiones
    └── limpieza-chats-antiguos.json# Flujo 3: Cron diario para purgar historiales > 24 hs
```

### Mapa de Puertos y Servicios

| Servicio | Contenedor | Acceso desde el Host (Navegador/PC) | Comunicación Interna (Docker DNS) |
| :--- | :--- | :--- | :--- |
| **Frontend (Nginx)** | `web_tesis` | `http://localhost:8080` | `http://web:80` |
| **n8n (Orquestador)** | `n8n_tesis` | `http://localhost:5679` | `http://n8n:5678` |
| **PostgreSQL** | `postgres_tesis` | `localhost:5433` | `postgres_tesis:5432` |
| **Ollama (LLM Local)** | `ollama_tesis` | `http://localhost:11434` | `http://ollama:11434` |

---

## 2. Requisitos Previos

*   **Software:** [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) instalados y en ejecución.
*   **Hardware recomendado:**
    *   Mínimo **8 GB a 16 GB de RAM** para ejecutar `llama3.1` (8B parámetros).
    *   Al menos **16 GB de RAM libres** si se desea utilizar `qwen2.5:14b` (14B parámetros).
    *   Al menos **10 GB de espacio libre en disco** para imágenes y volúmenes de modelos.

---

## 3. Instalación y Despliegue de Infraestructura

### Paso 1: Clonar el repositorio y configurar variables de entorno
1. Duplica el archivo `.env.example` y renómbralo a `.env`.
2. Completa el archivo `.env` con tus credenciales locales (nunca subas este archivo a un repositorio público):

```env
# ==========================================
# Configuración de Base de Datos (PostgreSQL)
# ==========================================
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=tu_password_seguro
POSTGRES_DB=chat_historial

# ==========================================
# Configuración de n8n
# ==========================================
N8N_HOST=localhost
N8N_PORT=5679
N8N_PROTOCOL=http
TIMEZONE=America/Argentina/Buenos_Aires

# ==========================================
# Claves de API Externas (Referencia para n8n)
# ==========================================
HOST_GEMINI=[https://generativelanguage.googleapis.com](https://generativelanguage.googleapis.com)
GEMINI_API_KEY=TU_API_KEY_DE_GEMINI
QDRANT_URL=[https://TU-CLUSTER-ID.aws.cloud.qdrant.io](https://TU-CLUSTER-ID.aws.cloud.qdrant.io)
QDRANT_API_KEY=TU_API_KEY_DE_QDRANT
```

### Paso 2: Verificar el archivo del Frontend
Asegúrate de que la interfaz activa (con soporte para usuarios temporales) se llame `index.html` y esté ubicada en:
`ia-tesis/frontend/index.html` *(si el archivo en el repositorio figura como `indexV2.html`, renómbralo a `index.html` antes de levantar Docker)*.

### Paso 3: Levantar los contenedores
Desde la raíz del proyecto, ejecuta:

```bash
docker compose up -d
```

Verifica que los 4 contenedores estén en estado `Up` (y `postgres_tesis` en estado `healthy`):

```bash
docker compose ps
```

---

## 4. Descarga del Modelo de IA Local (Ollama)

El contenedor de Ollama se inicia sin modelos descargados. Debes descargar el LLM una única vez; los pesos quedarán persistidos en el volumen `ollama_data_tesis`.

### Opción A: Llama 3.1 (Estándar recomendado — 8B parámetros)
Equilibrio ideal entre consumo de RAM y precisión en el uso de herramientas (*Tool Calling*). Pesa aproximadamente **4.7 GB**:

```bash
docker exec -it ollama_tesis ollama run llama3.1
```

### Opción B: Qwen 2.5 14B (Máxima precisión local — 14B parámetros)
Recomendado para máquinas con **16 GB+ de RAM libres**. Ofrece un seguimiento de instrucciones y enrutamiento de herramientas superior. Pesa aproximadamente **9 GB**:

```bash
docker exec -it ollama_tesis ollama run qwen2.5:14b
```

> **Verificación:** Al finalizar la descarga aparecerá el prompt interactivo `>>>`. Escribe `hola` para confirmar que responde y sal escribiendo `/bye`. También puedes verificar que la API responde ingresando a [http://localhost:11434](http://localhost:11434) (debe mostrar `Ollama is running`).

---

## 5. Configuración de la Base de Datos (Memoria 24 hs)

La aplicación no almacena conversaciones a largo plazo: un proceso diario elimina todas las sesiones con más de **24 horas** de antigüedad.

La tabla `n8n_chat_histories` que genera n8n por defecto no incluye una columna de fecha de creación. Para habilitar la purga automática, es necesario agregar la columna `created_at` (asegúrate de ejecutar esto luego de la primera interacción del chat si la tabla aún no existe, o inclúyelo en `init-db/init.sql`):

```sql
ALTER TABLE n8n_chat_histories
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;
```

Puedes ejecutar esta sentencia directamente desde la terminal hacia el contenedor de PostgreSQL:

```bash
docker exec -it postgres_tesis psql -U n8n_user -d chat_historial -c "ALTER TABLE n8n_chat_histories ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;"
```

### Query de verificación de limpieza
Luego de correr el flujo de limpieza, esta consulta debe devolver `0` sesiones vencidas:

```sql
SELECT COUNT(*)
FROM (
    SELECT session_id
    FROM n8n_chat_histories
    GROUP BY session_id
    HAVING MAX(created_at) < NOW() - INTERVAL '24 hours'
) AS sesiones_vencidas;
```

---

## 6. Importación y Configuración de Flujos en n8n

1. Ingresa a [http://localhost:5679](http://localhost:5679) y crea tu cuenta de administrador local.
2. **Importación (un workflow por archivo):**
   > **Importante:** Crea un flujo nuevo para cada archivo JSON. Si importas un archivo sobre un flujo ya existente, n8n duplicará los nodos.
   * Haz clic en **Create workflow**.
   * Abre el menú superior (`...`) > **Import** > **From file**.
   * Selecciona el primer archivo dentro de `/flujos-n8n`.
   * Repite el proceso para los demás archivos:
     1. **`chat-rag-tesisV2.json`**: Flujo principal del agente. Incluye un nodo *Edit Fields* para separar `mensaje` y `usuario` (usado como `session_id` en la memoria de Postgres) y un *System Prompt* que guía al alumno en su propuesta de tesis.
     2. **`limpieza-chats-antiguos.json`**: Flujo con disparador *Schedule* configurado para ejecutarse diariamente y borrar historiales > 24 hs. Verifica que `TIMEZONE` en el `.env` esté en `America/Argentina/Buenos_Aires` (por defecto n8n usa Nueva York).
     3. **Flujo de ingesta (Google Drive -> Qdrant)** *(Opcional)*: Solo necesario si deseas vectorizar nuevos PDFs. Para la instancia de evaluación con la base ya cargada, no requiere ejecución.

---

## 7. Guía de Credenciales y APIs Externas

Por seguridad y portabilidad, las credenciales deben vincularse manualmente en los nodos tras importar los flujos. Ve a **Credentials** en el menú lateral de n8n y configura los siguientes servicios:

### A. Ollama (LLM Principal Local)
* **Tipo de credencial:** `Ollama API`
* **Base URL:** `http://ollama:11434` *(no usar `localhost`, ya que n8n debe resolver el contenedor a través de la red interna de Docker)*.
* **API Key:** Dejar **vacío**.
* **En el nodo `Ollama Chat Model`:** Selecciona como *Model Name* el modelo descargado (`llama3.1` o `qwen2.5:14b`).

### B. PostgreSQL (Memoria de Chat y Limpieza)
* **Tipo de credencial:** `Postgres`
* **Host:** `postgres_tesis`
* **Database:** `chat_historial` *(o el valor definido en tu `.env`)*
* **User / Password:** Los definidos en `POSTGRES_USER` y `POSTGRES_PASSWORD`.
* **Port:** `5432` *(puerto interno dentro de Docker)*.

### C. Qdrant (Base de Datos Vectorial - RAG)
* **Panel de gestión:** [Qdrant Cloud Dashboard](https://cloud.qdrant.io/)
* **Tipo de credencial:** `QdrantApi`
* **Qdrant URL:** URL de tu clúster (sin la barra final ni rutas de dashboard).
* **API Key:** Clave generada desde el panel de Qdrant Cloud.

### D. Google Gemini (Exclusivo para Embeddings)
* **Gestor de claves:** [Google AI Studio](https://aistudio.google.com/projects)
* **Uso:** Su única tarea es transformar los textos/PDFs y consultas en vectores numéricos para Qdrant.
* **Tipo de credencial:** `Google Gemini (PaLM) Api`
* **API Key:** Clave generada en Google AI Studio.

### E. Google Drive OAuth2 *(Opcional — Solo para flujo de ingesta)*
Si necesitas volver a cargar documentos desde Drive:

**1. En [Google Cloud Console](https://console.cloud.google.com/):**
1. Crea un proyecto nuevo y ve a **APIs & Services > Library**. Busca y habilita **Google Drive API**.
2. Ve a **Google Auth Platform / OAuth consent screen**, selecciona tipo **External (Externo)**, asigna un nombre a la app y agrega tu correo de Gmail en **Test users (Usuarios de prueba)**.
3. Ve a **Clients / Credentials > Create Credentials > OAuth client ID** y elige **Web application**.
4. En **Authorized redirect URIs**, agrega exactamente:
   ```text
   http://localhost:5679/rest/oauth2-credential/callback
   ```
5. Guarda y copia el **Client ID** y el **Client Secret**.

**2. En n8n:**
1. Crea una credencial de tipo **Google Drive OAuth2 API**.
2. Pega el **Client ID** y el **Client Secret**.
3. Haz clic en **Sign in with Google**, inicia sesión con tu cuenta de prueba y acepta los permisos *(si aparece el aviso de aplicación no verificada, selecciona **Configuración avanzada > Ir a la app (no seguro)**)*.
4. Confirma que el estado cambie a **Connected**.

---

## 8. Configuración del Frontend (Producción vs. Testeo y Usuarios Temporales)

### Gestión de Usuarios Temporales
Al cargar `frontend/index.html`, la aplicación genera automáticamente un identificador aleatorio de 6 dígitos en memoria:

```javascript
const USUARIO_ID = `Usuario${Math.floor(100000 + Math.random() * 900000)}`;
```

Cada mensaje se envía vía `POST` al webhook de n8n con el formato `{ mensaje, usuario: USUARIO_ID }`. Esto permite atender a múltiples usuarios en simultáneo sin mezclar historiales. Al recargar la página, se asigna un nuevo usuario temporal.

### Alternar entre Modo Producción y Modo Testeo
Abre `frontend/index.html` y edita la constante `IS_PRODUCTION` al final del script:

```javascript
// ==========================================
// CONFIGURACIÓN DE ENTORNO
// ==========================================
const IS_PRODUCTION = true; // Cambiar a false para modo de pruebas
```

*   **Modo Producción (`IS_PRODUCTION = true`)** — *Recomendado para la entrega y evaluación:*
    1. Abre tus flujos en n8n (`http://localhost:5679`) y actívalos haciendo clic en **Publish / Active**.
    2. El frontend apuntará a `/webhook/...` y funcionará de forma automática y continua.
*   **Modo Testeo (`IS_PRODUCTION = false`)** — *Recomendado para depuración:*
    1. En n8n, abre el flujo y haz clic en **Execute Workflow** (o *Listen for test event* en el nodo Webhook).
    2. El frontend enviará la petición a `/webhook-test/...`, permitiéndote inspeccionar los datos nodo por nodo en tiempo real.

---

## 9. Verificación y Comandos Útiles

*   **Levantar todo el entorno:**
    ```bash
    docker compose up -d
    ```
*   **Apagar todos los servicios (sin borrar datos ni modelos):**
    ```bash
    docker compose down
    ```
*   **Aplicar cambios en `docker-compose.yml` o `.env`:**
    ```bash
    docker compose up -d --force-recreate
    ```
*   **Ver logs de n8n en tiempo real:**
    ```bash
    docker logs -f n8n_tesis
    ```
*   **Listar modelos descargados en Ollama:**
    ```bash
    docker exec -it ollama_tesis ollama list
    ```

---
**Autor:** Franco León Costantini — *Licenciatura en Sistemas, Universidad Nacional de General Sarmiento (UNGS)*
