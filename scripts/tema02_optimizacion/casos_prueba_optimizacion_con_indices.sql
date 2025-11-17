
/*===============================================================================
   1. CREACIÓN DE TABLAS
===============================================================================*/

-- ROLES
CREATE TABLE roles (
    id_rol INT IDENTITY(1,1) NOT NULL,
    nombre_rol VARCHAR(60) NOT NULL,
    CONSTRAINT PK_roles PRIMARY KEY (id_rol),
    CONSTRAINT UQ_roles_nombre UNIQUE (nombre_rol)
);
GO

-- USUARIO
CREATE TABLE usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    apellido VARCHAR(60) NOT NULL,
    email VARCHAR(120) NOT NULL,
    contraseña VARBINARY(256) NULL,
    activo INT NOT NULL,
    telefono VARCHAR(25) NULL,
    dni VARCHAR(20) NOT NULL,
    id_rol INT NOT NULL,
    CONSTRAINT PK_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT FK_usuario_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    CONSTRAINT UQ_usuario_email UNIQUE (email),
    CONSTRAINT UQ_usuario_dni UNIQUE (dni),
    CONSTRAINT CK_usuario_email CHECK (email LIKE '%@%.%')
);
GO

-- JUGADOR
CREATE TABLE jugador (
    id_usuario_jugador INT NOT NULL,
    CONSTRAINT PK_jugador PRIMARY KEY (id_usuario_jugador),
    CONSTRAINT FK_jugador_usuario FOREIGN KEY (id_usuario_jugador)
        REFERENCES usuario(id_usuario) ON DELETE CASCADE
);
GO

-- METODO_PAGO
CREATE TABLE metodo_pago (
    id_pago INT IDENTITY(1,1) NOT NULL,
    descripcion VARCHAR(60) NOT NULL,
    CONSTRAINT PK_metodo_pago PRIMARY KEY (id_pago),
    CONSTRAINT UQ_metodo_pago_desc UNIQUE (descripcion)
);
GO

-- ESTADO
CREATE TABLE estado (
    id_estado INT IDENTITY(1,1) NOT NULL,
    estado VARCHAR(40) NOT NULL,
    id_pago INT NULL,
    CONSTRAINT PK_estado PRIMARY KEY (id_estado),
    CONSTRAINT FK_estado_pago FOREIGN KEY (id_pago) REFERENCES metodo_pago(id_pago)
);
GO

-- TIPO_CANCHA
CREATE TABLE tipo_cancha (
    id_tipo INT IDENTITY(1,1) NOT NULL,
    descripcion VARCHAR(80) NOT NULL,
    CONSTRAINT PK_tipo_cancha PRIMARY KEY (id_tipo),
    CONSTRAINT UQ_tipo_cancha_desc UNIQUE (descripcion)
);
GO

-- CANCHA
CREATE TABLE cancha (
    id_cancha INT IDENTITY(1,1) NOT NULL,
    nro_cancha INT NOT NULL,
    ubicacion VARCHAR(150) NOT NULL,
    precio_hora DECIMAL(12,2) NOT NULL,
    id_tipo INT NOT NULL,
    CONSTRAINT PK_cancha PRIMARY KEY (id_cancha),
    CONSTRAINT FK_cancha_tipo FOREIGN KEY (id_tipo) REFERENCES tipo_cancha(id_tipo),
    CONSTRAINT UQ_cancha_nro UNIQUE (nro_cancha),
    CONSTRAINT CK_cancha_nro CHECK (nro_cancha > 0),
    CONSTRAINT CK_cancha_precio CHECK (precio_hora >= 0)
);
GO

-- RESERVA
CREATE TABLE reserva (
    id_reserva INT IDENTITY(1,1) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME(0) NOT NULL,
    duracion VARCHAR(50) NOT NULL,
    id_jugador INT NOT NULL,
    id_estado INT NOT NULL,
    id_cancha INT NOT NULL,
    CONSTRAINT PK_reserva PRIMARY KEY (id_reserva),
    CONSTRAINT FK_reserva_jugador FOREIGN KEY (id_jugador) REFERENCES jugador(id_usuario_jugador),
    CONSTRAINT FK_reserva_estado FOREIGN KEY (id_estado) REFERENCES estado(id_estado),
    CONSTRAINT FK_reserva_cancha FOREIGN KEY (id_cancha) REFERENCES cancha(id_cancha),
    CONSTRAINT UQ_reserva_momento UNIQUE (fecha, hora, id_cancha)
);
GO


/*===============================================================================
   2. CARGA MAESTRA DE CATÁLOGOS
===============================================================================*/

PRINT '=== Cargando catálogos iniciales ===';

INSERT INTO roles (nombre_rol) VALUES ('Administrador'), ('Canchero'), ('Jugador');
INSERT INTO metodo_pago (descripcion) VALUES ('Efectivo'), ('Tarjeta'), ('Transferencia');
INSERT INTO estado (estado, id_pago)
VALUES ('Pendiente', NULL), ('Confirmada-Efectivo', 1),
       ('Confirmada-Tarjeta', 2), ('Confirmada-Transf', 3),
       ('Cancelada', NULL);
INSERT INTO tipo_cancha (descripcion) VALUES ('Fútbol 5'), ('Pádel'), ('Vóley'), ('Tenis'), ('Básquet');

PRINT 'Insertando 20 canchas...';
DECLARE @c INT = 1;
WHILE @c <= 20
BEGIN
    INSERT INTO cancha (nro_cancha, ubicacion, precio_hora, id_tipo)
    VALUES (@c, 'Ubicación ' + CAST(@c AS VARCHAR),
            (FLOOR(RAND()*(90-40+1))+40) * 100,
            (SELECT TOP 1 id_tipo FROM tipo_cancha ORDER BY NEWID()));
    SET @c += 1;
END

PRINT 'Insertando usuarios y jugadores...';

INSERT INTO usuario (nombre, apellido, email, contraseña, activo, dni, id_rol)
VALUES ('Admin', 'Sys', 'admin@turnosya.com', HASHBYTES('SHA2_256','admin123'), 1, '1000000', 1);

DECLARE @j INT = 1;
WHILE @j <= 500
BEGIN
    INSERT INTO usuario (nombre, apellido, email, contraseña, activo, dni, id_rol) 
    VALUES (
        'Jugador'+CAST(@j AS VARCHAR),
        'Apellido'+CAST(@j AS VARCHAR),
        'jugador'+CAST(@j AS VARCHAR)+'@mail.com',
        HASHBYTES('SHA2_256','pass123'),
        1,
        CAST(2000000+@j AS VARCHAR),
        3
    );
    SET @j += 1;
END

INSERT INTO jugador (id_usuario_jugador)
SELECT id_usuario FROM usuario WHERE id_rol = 3;


/*===============================================================================
   3. CARGA MASIVA DE 1.000.000 RESERVAS
===============================================================================*/

PRINT '=== INICIANDO CARGA MASIVA DE 1.000.000 RESERVAS ===';
SET NOCOUNT ON;

DECLARE @i INT = 1, @total INT = 1000000, @errores INT = 0;

DECLARE @minJ INT = (SELECT MIN(id_usuario_jugador) FROM jugador);
DECLARE @maxJ INT = (SELECT MAX(id_usuario_jugador) FROM jugador);
DECLARE @minC INT = (SELECT MIN(id_cancha) FROM cancha);
DECLARE @maxC INT = (SELECT MAX(id_cancha) FROM cancha);
DECLARE @minE INT = (SELECT MIN(id_estado) FROM estado);
DECLARE @maxE INT = (SELECT MAX(id_estado) FROM estado);

DECLARE @horas TABLE (h TIME(0));
INSERT INTO @horas VALUES
('08:00'),('09:00'),('10:00'),('11:00'),('12:00'),
('13:00'),('14:00'),('15:00'),('16:00'),('17:00'),
('18:00'),('19:00'),('20:00'),('21:00'),('22:00'),('23:00');

WHILE @i <= @total
BEGIN
    DECLARE @Jugador INT = FLOOR(RAND()*(@maxJ - @minJ + 1)) + @minJ;
    DECLARE @Cancha INT = FLOOR(RAND()*(@maxC - @minC + 1)) + @minC;
    DECLARE @Estado INT = FLOOR(RAND()*(@maxE - @minE + 1)) + @minE;
    DECLARE @Fecha DATE  = DATEADD(DAY, -(ABS(CHECKSUM(NEWID()))%1825), GETDATE());
    DECLARE @Hora  TIME(0) = (SELECT TOP 1 h FROM @horas ORDER BY NEWID());

    BEGIN TRY
        INSERT INTO reserva (fecha, hora, duracion, id_jugador, id_estado, id_cancha)
        VALUES (@Fecha, @Hora, '60 min', @Jugador, @Estado, @Cancha);
        SET @i += 1;
    END TRY
    BEGIN CATCH
        SET @errores += 1;
    END CATCH

    IF @i % 100000 = 0
    BEGIN
        PRINT CAST(@i AS VARCHAR) + ' reservas insertadas... (colisiones: '+CAST(@errores AS VARCHAR)+')';
        SET @errores = 0;
    END
END

SET NOCOUNT OFF;
PRINT '=== CARGA MASIVA COMPLETA ===';



/*===============================================================================
   4. PRUEBAS PROFESIONALES DE OPTIMIZACIÓN
===============================================================================*/

-- Activamos las estadísticas para ver el costo (IO) y el tiempo (TIME)
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/*
================================================================
 PRUEBA 1: Validación de Disponibilidad (RF#8)
 (Índice automático de UQ_reserva_momento)
================================================================
*/
PRINT '=== PRUEBA 1: Validación de Disponibilidad ===';
GO

PRINT '--- 1.1. ANTES (Sin índice - Forzando Clustered Scan) ---';
-- El hint WITH (INDEX(0)) fuerza a SQL a ignorar índices non-clustered
-- y escanear la tabla base (Clustered Index Scan).
DBCC DROPCLEANBUFFERS; -- Limpiamos caché
GO

SELECT * FROM reserva WITH (INDEX(0)) -- Forzamos el SCAN
WHERE fecha='2025-10-20' -- Usar una fecha del rango
  AND hora='21:00'
  AND id_cancha=3;
GO

PRINT '--- 1.2. DESPUÉS (Con índice - Index Seek esperado) ---';
-- El optimizador usará automáticamente el índice de la UQ_reserva_momento.
DBCC DROPCLEANBUFFERS; -- Limpiamos caché
GO

SELECT * FROM reserva
WHERE fecha='2025-10-20'
  AND hora='21:00'
  AND id_cancha=3;
GO


/*
================================================================
 PRUEBA 2: 
================================================================
*/

PRINT '=== PRUEBA 2: Historial de Jugador ===';
GO

-- 2.1. Limpieza
DROP INDEX IF EXISTS IX_reserva_jugador ON reserva;
GO

PRINT '--- 2.1. ANTES (Sin índice - Clustered Index Scan esperado) ---';
DBCC DROPCLEANBUFFERS;
GO

SELECT * FROM reserva WHERE id_jugador = 150;
GO

-- 2.2. Creación del Índice de COBERTURA
PRINT '--- Creando ÍNDICE DE COBERTURA (IX_reserva_jugador_cobertura) ---';
-- Ahora el índice incluye TODAS las columnas del SELECT *
CREATE NONCLUSTERED INDEX IX_reserva_jugador_cobertura
ON reserva(id_jugador) -- Columna del WHERE
INCLUDE (fecha, hora, duracion, id_estado, id_cancha); -- Resto de columnas
GO

PRINT '--- 2.2. DESPUÉS (Con índice de cobertura - Index Seek esperado) ---';

DBCC DROPCLEANBUFFERS;
GO

SELECT * FROM reserva WHERE id_jugador = 150;
GO

-- Limpieza final
DROP INDEX IF EXISTS IX_reserva_jugador_cobertura ON reserva;
GO
/*
================================================================
 PRUEBA 3: Reporte de Estados (RF#5)
 (Demostración de Índice de Cobertura)
================================================================
*/
PRINT '=== PRUEBA 3: Reporte de Estados ===';
GO

-- 3.1. Limpieza
-- Nos aseguramos que cualquier índice de prueba anterior no exista.
DROP INDEX IF EXISTS IX_reserva_estado ON reserva;
DROP INDEX IF EXISTS IX_reserva_estado_cobertura ON reserva;
GO

PRINT '--- 3.1. ANTES (Sin índice - Clustered Index Scan esperado) ---';
DBCC DROPCLEANBUFFERS;
GO

SELECT fecha, hora, id_jugador, id_cancha
FROM reserva WHERE id_estado = 1; -- (Asumimos 1 = Pendiente)
GO

-- 3.2. Creación del Índice de Cobertura
-- Se crea un índice que "cubre" la consulta.
-- Contiene la columna del WHERE (id_estado)
-- E INCLUYE las columnas del SELECT (fecha, hora, etc.)
PRINT '--- Creando ÍNDICE DE COBERTURA (IX_reserva_estado_cobertura) ---';
CREATE NONCLUSTERED INDEX IX_reserva_estado_cobertura
ON reserva(id_estado) -- Columna del WHERE
INCLUDE (fecha, hora, id_jugador, id_cancha); -- Columnas del SELECT
GO

PRINT '--- 3.2. DESPUÉS (Con índice de cobertura - Index Seek esperado) ---';

DBCC DROPCLEANBUFFERS;
GO

SELECT fecha, hora, id_jugador, id_cancha
FROM reserva WHERE id_estado = 1;
GO

-- Limpieza final de todos los índices de prueba
PRINT '--- Limpiando índices de prueba ---';
DROP INDEX IF EXISTS IX_reserva_jugador ON reserva;
DROP INDEX IF EXISTS IX_reserva_estado_cobertura ON reserva;
GO

-- Desactivamos las estadísticas
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


