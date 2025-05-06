DO $$
DECLARE
    sec_id int;
    tabla text;
BEGIN
    FOR sec_id IN SELECT ID FROM Secciones LOOP
    tabla := format('Asistencia_id_%s', sec_id);
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF Asistencia
        FOR VALUES FROM (%s) TO (%s);',
        tabla, sec_id, sec_id + 1
    );

    EXECUTE format(
        'CREATE INDEX IF NOT EXISTS idx_%I_alumno ON %I(AlumnoID);',
        tabla, tabla
    );

    EXECUTE format(
        'CREATE INDEX IF NOT EXISTS idx_%I_modulo ON %I(ModuloID);',
        tabla, tabla
    );

    tabla := format('ReporteAsistencia_id_%s', sec_id);
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I PARTITION OF ReporteAsistencia
        FOR VALUES FROM (%s) TO (%s);',
        tabla, sec_id, sec_id + 1
    );

    EXECUTE format(
        'CREATE INDEX IF NOT EXISTS idx_%I_alumno ON %I(AlumnoID);',
        tabla, tabla
    );

    EXECUTE format(
        'CREATE INDEX IF NOT EXISTS idx_%I_modulo ON %I(ModuloID);',
        tabla, tabla
    );
    END LOOP;
END $$;
