DO $$
DECLARE
    tabla text;
BEGIN
    FOR tabla IN SELECT tablename FROM pg_tables WHERE tablename LIKE 'asistencia_id_%' LOOP
        EXECUTE format('SELECT pg_prewarm(%L, ''buffer'');', tabla);
    END LOOP;
END $$;
