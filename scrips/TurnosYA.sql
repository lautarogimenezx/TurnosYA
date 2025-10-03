CREATE DATABASE TurnosYa; -- Crea la base de datos
use TurnosYa; -- Usa la base de datos recién creada


-- TABLA JUGADOR
-- Tabla para almacenar la información de los usuarios que realizan reservas (jugadores).
CREATE TABLE jugador (
    id_jugador          INT IDENTITY(1,1)     NOT NULL,
    nombre              VARCHAR(60)           NOT NULL,
    apellido            VARCHAR(60)           NOT NULL,
    email               VARCHAR(120)          NOT NULL,
    contrasena          VARBINARY(256)        NULL,
    telefono            VARCHAR(25)           NULL,

    -- RESTRICCIONES
    CONSTRAINT PK_jugador PRIMARY KEY CLUSTERED (id_jugador),
    CONSTRAINT UQ_jugador_email UNIQUE (email),-- El email debe ser único.
    CONSTRAINT CK_jugador_email CHECK (email LIKE '%@%.%')-- Validación de formato de email.
);
GO

-- TABLA CANCHERO
-- Tabla para almacenar la información de los administradores de las canchas (cancheros).
CREATE TABLE canchero (
    id_canchero         INT IDENTITY(1,1)     NOT NULL,
    nombre              VARCHAR(60)           NOT NULL,
    apellido            VARCHAR(60)           NOT NULL,
    email               VARCHAR(120)          NOT NULL,
    contrasena          VARBINARY(256)        NULL,

    -- RESTRICCIONES
    CONSTRAINT PK_canchero PRIMARY KEY CLUSTERED (id_canchero),
    CONSTRAINT UQ_canchero_email UNIQUE (email), -- El email debe ser único.
    CONSTRAINT CK_canchero_email CHECK (email LIKE '%@%.%')-- Validación de formato de email.
);
GO

-- TABLA TIPO_CANCHA
-- Tabla que define los tipos de canchas (ej: Fútbol 5, Vóley).
CREATE TABLE tipo_cancha (
    id_tipo             INT IDENTITY(1,1)     NOT NULL,
    descripcion         VARCHAR(80)           NOT NULL,
    
    -- RESTRICCIONES
    CONSTRAINT PK_tipo_cancha PRIMARY KEY CLUSTERED (id_tipo),
    CONSTRAINT UQ_tipo_cancha_desc UNIQUE (descripcion)-- La descripción del tipo de cancha debe ser única.
);
GO

-- TABLA CANCHA
-- Tabla para registrar las canchas disponibles.
CREATE TABLE cancha (
    id_cancha           INT IDENTITY(1,1)     NOT NULL,
    nro_cancha          INT                   NOT NULL,
    id_tipo             INT                   NOT NULL,-- FK de tipo de cancha.

    -- RESTRICCIONES
    CONSTRAINT PK_cancha PRIMARY KEY CLUSTERED (id_cancha),
    CONSTRAINT FK_cancha_tipo
        FOREIGN KEY (id_tipo) REFERENCES tipo_cancha(id_tipo),
    CONSTRAINT UQ_cancha_nro UNIQUE (nro_cancha),-- El número de cancha debe ser único.
    CONSTRAINT CK_cancha_nro CHECK (nro_cancha > 0)-- El número de cancha debe ser positivo.
);
GO

-- TABLA METODO_PAGO
-- Tabla para definir los métodos de pago aceptados.
CREATE TABLE metodo_pago (
    id_metodo_pago      INT IDENTITY(1,1)     NOT NULL,
    descripcion         VARCHAR(60)           NOT NULL,

    -- RESTRICCIONES
    CONSTRAINT PK_metodo_pago PRIMARY KEY CLUSTERED (id_metodo_pago),
    CONSTRAINT UQ_metodo_pago_desc UNIQUE (descripcion)-- La descripción del método de pago debe ser única.
);
GO

-- TABLA PAGO_RESERVA
-- Tabla que registra el detalle de un pago específico.
CREATE TABLE pago_reserva (
    id_pago             INT IDENTITY(1,1)     NOT NULL,
    monto               DECIMAL(12,2)         NOT NULL,
    id_metodo_pago      INT                   NOT NULL, -- FK de tipo de metodo_pago.

    -- RESTRICCIONES
    CONSTRAINT PK_pago_reserva PRIMARY KEY CLUSTERED (id_pago),
    CONSTRAINT FK_pago_metodo 
        FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago(id_metodo_pago),
    CONSTRAINT CK_pago_monto CHECK (monto >= 0)-- El monto no puede ser negativo.
);
GO

-- TABLA ESTADO_RESERVA
-- Tabla que define el estado de una reserva.
CREATE TABLE estado_reserva (
    id_estado_reserva   INT IDENTITY(1,1)     NOT NULL,
    descripcion         VARCHAR(40)           NOT NULL,-- Descripción del estado (Pendiente, Confirmada, Cancelada).
    id_pago             INT                   NULL, -- FK de tipo de pago_reserva (NULL si no está pagado).
    id_metodo_pago      INT                   NULL, -- FK de tipo de metodo_pago (NULL si no está pagado).

    -- RESTRICCIONES
    CONSTRAINT PK_estado_reserva PRIMARY KEY CLUSTERED (id_estado_reserva),
    CONSTRAINT FK_estado_pago
        FOREIGN KEY (id_pago) REFERENCES pago_reserva(id_pago),
    CONSTRAINT FK_estado_metodo
        FOREIGN KEY (id_metodo_pago) REFERENCES metodo_pago(id_metodo_pago)
);
GO

-- TABLA RESERVA
-- Tabla para almacenar cada reserva o turno realizado.
CREATE TABLE reserva (
    id_reserva          INT IDENTITY(1,1)     NOT NULL,
    fecha               DATE                  NOT NULL DEFAULT (CONVERT(date, GETDATE())),-- Por defecto la fecha actual
    hora                TIME(0)               NOT NULL DEFAULT (CONVERT(time, GETDATE())),-- Por defecto la hora actual
    id_jugador          INT                   NOT NULL,-- FK de tipo de jugador.
    id_canchero         INT                   NOT NULL,-- FK de tipo de canchero.
    id_cancha           INT                   NOT NULL,-- FK de tipo de cancha.
    id_estado_reserva   INT                   NOT NULL,-- FK de tipo de estado_reserva.
    
    -- RESTRICCIONES
    CONSTRAINT PK_reserva PRIMARY KEY CLUSTERED (id_reserva),
    CONSTRAINT FK_reserva_jugador
        FOREIGN KEY (id_jugador) REFERENCES jugador(id_jugador),
    CONSTRAINT FK_reserva_canchero
        FOREIGN KEY (id_canchero) REFERENCES canchero(id_canchero),
    CONSTRAINT FK_reserva_cancha
        FOREIGN KEY (id_cancha) REFERENCES cancha(id_cancha),
    CONSTRAINT FK_reserva_estado
        FOREIGN KEY (id_estado_reserva) REFERENCES estado_reserva(id_estado_reserva),
    CONSTRAINT UQ_reserva_momento UNIQUE (fecha, hora, id_cancha) --Una misma cancha no pueda tener dos reservas en la misma fecha y hora.
);
GO