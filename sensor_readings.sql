-- Script SQL para la tabla sensor_readings en Supabase (SensorTrack)
CREATE TABLE IF NOT EXISTS sensor_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sensor_type TEXT NOT NULL,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    z DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    accuracy DOUBLE PRECISION,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habilitar Row Level Security (RLS)
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;

-- Otorgar permisos al rol anon sobre el esquema y la tabla
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT, INSERT ON TABLE public.sensor_readings TO anon;

-- Politica para permitir lectura publica (rol anon)
CREATE POLICY "Permitir lectura publica"
ON sensor_readings
AS PERMISSIVE
FOR SELECT
TO anon
USING (true);

-- Politica para permitir insercion publica (rol anon)
CREATE POLICY "Permitir insercion publica"
ON sensor_readings
AS PERMISSIVE
FOR INSERT
TO anon
WITH CHECK (true);
