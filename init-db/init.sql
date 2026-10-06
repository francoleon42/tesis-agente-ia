-- Este script se ejecutará automáticamente al levantar el contenedor 
-- de Postgres por primera vez si el volumen está vacío.

CREATE TABLE IF NOT EXISTS n8n_chat_histories (
    id SERIAL PRIMARY KEY,
    session_id TEXT NOT NULL, -- Columna como TEXT para evitar el error de 255 caracteres
    message JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Crear un índice para búsquedas más rápidas por sesión
CREATE INDEX IF NOT EXISTS idx_session_id ON n8n_chat_histories(session_id);