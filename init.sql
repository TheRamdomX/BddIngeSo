CREATE EXTENSION IF NOT EXISTS pg_prewarm;
CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE DATABASE asistencia_db;

\c asistencia_db

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
CREATE EXTENSION IF NOT EXISTS pg_cron;

ALTER SYSTEM SET shared_preload_libraries = 'pg_cron';
SELECT pg_reload_conf();

CREATE TABLE IF NOT EXISTS Profesores (
  ID int PRIMARY KEY,
  Rut int UNIQUE,
  Nombre varchar,
  Apellido varchar,
  Rol int
);

CREATE TABLE IF NOT EXISTS Alumnos (
  ID int PRIMARY KEY,
  Rut int UNIQUE,
  Nombre varchar,
  Apellido varchar
);

CREATE TABLE IF NOT EXISTS Asignaturas (
  ID int PRIMARY KEY,
  Nombre varchar,
  Codigo varchar
);

CREATE TABLE IF NOT EXISTS Secciones (
  ID int PRIMARY KEY,
  AsignaturaID int,
  ProfesorID int,
  Ubicacion varchar
);

CREATE TABLE IF NOT EXISTS Modulos (
  ID int PRIMARY KEY,
  Fecha date,
  HoraInicio time,
  HoraFin time
);

CREATE TABLE IF NOT EXISTS ProgramacionClases (
  ID int PRIMARY KEY,
  SeccionID int,
  ModuloID int,
  TipoSesion int
);

CREATE TABLE IF NOT EXISTS Inscripciones (
  ID int PRIMARY KEY,
  AlumnoID int,
  SeccionID int
);

CREATE TABLE IF NOT EXISTS Asistencia (
  ID bigserial PRIMARY KEY,
  AlumnoID int NOT NULL,
  SeccionID int NOT NULL,
  ModuloID int NOT NULL,
  ProfesorID int NOT NULL,
  FechaRegistro timestamp NOT NULL,
  ManualInd int NOT NULL
) PARTITION BY RANGE (SeccionID);

CREATE TABLE IF NOT EXISTS ReporteAsistencia (
  ID bigserial PRIMARY KEY,
  AlumnoID int NOT NULL,
  SeccionID int NOT NULL,
  ModuloID int NOT NULL,
  EstadoSesion varchar
) PARTITION BY RANGE (SeccionID);

-- [Resto de tablas...]
CREATE TABLE IF NOT EXISTS QRGenerado (
  ID int PRIMARY KEY,
  ProfesorID int,
  ModuloID int,
  FechaRegistro timestamp,
  MAC varchar
);

CREATE TABLE IF NOT EXISTS LogIn (
  ID int PRIMARY KEY,
  Rol varchar,
  FechaRegistro timestamp,
  Rut int,
  MAC varchar
);

CREATE TABLE IF NOT EXISTS AUTH (
  ID int PRIMARY KEY,
  User varchar,
  Password varchar,
  Rol varchar,
  Rut int
);

CREATE TABLE IF NOT EXISTS MACs (
  ID int PRIMARY KEY,
  AlumnoID int,
  FechaRegistro timestamp,
  MAC varchar
);

ALTER TABLE Secciones ADD FOREIGN KEY (AsignaturaID) REFERENCES Asignaturas(ID);
ALTER TABLE Secciones ADD FOREIGN KEY (ProfesorID) REFERENCES Profesores(ID);
ALTER TABLE ProgramacionClases ADD FOREIGN KEY (SeccionID) REFERENCES Secciones(ID);
ALTER TABLE ProgramacionClases ADD FOREIGN KEY (ModuloID) REFERENCES Modulos(ID);
ALTER TABLE Inscripciones ADD FOREIGN KEY (AlumnoID) REFERENCES Alumnos(ID);
ALTER TABLE Inscripciones ADD FOREIGN KEY (SeccionID) REFERENCES Secciones(ID);
ALTER TABLE Asistencia ADD FOREIGN KEY (AlumnoID) REFERENCES Alumnos(ID);
ALTER TABLE Asistencia ADD FOREIGN KEY (SeccionID) REFERENCES Secciones(ID);
ALTER TABLE Asistencia ADD FOREIGN KEY (ModuloID) REFERENCES Modulos(ID);
ALTER TABLE Asistencia ADD FOREIGN KEY (ProfesorID) REFERENCES Profesores(ID);
ALTER TABLE QRGenerado ADD FOREIGN KEY (ProfesorID) REFERENCES Profesores(ID);
ALTER TABLE QRGenerado ADD FOREIGN KEY (ModuloID) REFERENCES Modulos(ID);
ALTER TABLE ReporteAsistencia ADD FOREIGN KEY (AlumnoID) REFERENCES Alumnos(ID);
ALTER TABLE ReporteAsistencia ADD FOREIGN KEY (SeccionID) REFERENCES Secciones(ID);
ALTER TABLE ReporteAsistencia ADD FOREIGN KEY (ModuloID) REFERENCES Modulos(ID);
ALTER TABLE MACs ADD FOREIGN KEY (AlumnoID) REFERENCES Alumnos(ID);

-- Insertar datos?
