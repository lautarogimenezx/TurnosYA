CREATE DATABASE TurnosYa; 
use TurnosYa; 

-- TABLA ROLES
-- Tabla para definir los roles de los usuarios (ej: Administrador, Canchero).
CREATE TABLE roles (
    id_rol          INT IDENTITY(1,1)   NOT NULL,
    nombre_rol      VARCHAR(60)         NOT NULL, -- Nombre del rol (ej: 'Admin', 'Canchero')

    -- RESTRICCIONES
    CONSTRAINT PK_roles PRIMARY KEY (id_rol),
    CONSTRAINT UQ_roles_nombre UNIQUE (nombre_rol) -- El nombre del rol debe ser único.
);
GO

-- TABLA USUARIO
-- Tabla para almacenar la información de los usuarios (login).
CREATE TABLE usuario (
    id_usuario      INT IDENTITY(1,1)   NOT NULL,
    nombre          VARCHAR(60)         NOT NULL,
    Apellido        VARCHAR(60)         NOT NULL,
    email           VARCHAR(120)        NOT NULL,
    contraseña      VARBINARY(256)      NULL,    -- Almacenar como HASH.
    activo          INT                 NOT NULL, -- 1 para activo, 0 para inactivo.
    id_rol          INT                 NOT NULL, -- FK de roles.

    -- RESTRICCIONES
    CONSTRAINT PK_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT FK_usuario_rol
        FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    CONSTRAINT UQ_usuario_email UNIQUE (email), -- El email debe ser único.
    CONSTRAINT CK_usuario_email CHECK (email LIKE '%@%.%') -- Validación de formato de email.
);
GO

-- TABLA JUGADOR
-- Tabla para almacenar datos adicionales específicos de los jugadores (contacto).
CREATE TABLE jugador (
    id_jugador      INT IDENTITY(1,1)   NOT NULL,
    nombre          VARCHAR(60)         NOT NULL,
    apellido        VARCHAR(60)         NOT NULL,
    telefono        VARCHAR(25)         NULL,

    -- RESTRICCIONES
    CONSTRAINT PK_jugador PRIMARY KEY (id_jugador)
);
GO

-- TABLA METODO_PAGO
-- Tabla para definir los métodos de pago aceptados.
CREATE TABLE metodo_pago (
    id_pago         INT IDENTITY(1,1)   NOT NULL,
    descripcion     VARCHAR(60)         NOT NULL,

    -- RESTRICCIONES
    CONSTRAINT PK_metodo_pago PRIMARY KEY (id_pago),
    CONSTRAINT UQ_metodo_pago_desc UNIQUE (descripcion) -- La descripción del método de pago debe ser única.
);
GO

-- TABLA ESTADO
-- Tabla que define el estado de una reserva (ej: Pendiente, Confirmada, Cancelada).
CREATE TABLE estado (
    id_estado       INT IDENTITY(1,1)   NOT NULL,
    estado          VARCHAR(40)         NOT NULL,
    id_pago         INT                 NULL,     -- FK de metodo_pago (NULL si no está pagado).

    -- RESTRICCIONES
    CONSTRAINT PK_estado PRIMARY KEY (id_estado),
    CONSTRAINT FK_estado_pago
        FOREIGN KEY (id_pago) REFERENCES metodo_pago(id_pago)
);
GO

-- TABLA TIPO_CANCHA
-- Tabla que define los tipos de canchas (ej: Fútbol 5, Vóley).
CREATE TABLE tipo_cancha (
    id_tipo         INT IDENTITY(1,1)   NOT NULL,
    descripcion     VARCHAR(80)         NOT NULL,
    
    -- RESTRICCIONES
    CONSTRAINT PK_tipo_cancha PRIMARY KEY (id_tipo),
    CONSTRAINT UQ_tipo_cancha_desc UNIQUE (descripcion) -- La descripción del tipo de cancha debe ser única.
);
GO

-- TABLA CANCHA
-- Tabla para registrar las canchas disponibles, su ubicación y precio.
CREATE TABLE cancha (
    id_cancha       INT IDENTITY(1,1)   NOT NULL,
    nro_cancha      INT                 NOT NULL,
    ubicacion       VARCHAR(150)        NOT NULL,
    precio_hora     DECIMAL(12,2)       NOT NULL,
    id_tipo         INT                 NOT NULL, -- FK de tipo de cancha.

    -- RESTRICCIONES
    CONSTRAINT PK_cancha PRIMARY KEY (id_cancha),
    CONSTRAINT FK_cancha_tipo
        FOREIGN KEY (id_tipo) REFERENCES tipo_cancha(id_tipo),
    CONSTRAINT UQ_cancha_nro UNIQUE (nro_cancha), -- El número de cancha debe ser único.
    CONSTRAINT CK_cancha_nro CHECK (nro_cancha > 0), -- El número de cancha debe ser positivo.
    CONSTRAINT CK_cancha_precio CHECK (precio_hora >= 0) -- El precio no puede ser negativo.
);
GO

-- TABLA RESERVA
-- Tabla para almacenar cada reserva o turno realizado.
CREATE TABLE reserva (
    id_reserva      INT IDENTITY(1,1)   NOT NULL,
    fecha           DATE                NOT NULL,
    hora            TIME(0)             NOT NULL,
    duracion        VARCHAR(50)         NOT NULL, 
    id_usuario      INT                 NOT NULL, -- FK de usuario (quien reserva o administra).
    id_estado       INT                 NOT NULL, -- FK de estado.
    id_jugador      INT                 NOT NULL, -- FK de jugador (datos de contacto).
    id_cancha       INT                 NOT NULL, -- FK de cancha.

    -- RESTRICCIONES
    CONSTRAINT PK_reserva PRIMARY KEY (id_reserva),
    CONSTRAINT FK_reserva_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT FK_reserva_estado
        FOREIGN KEY (id_estado) REFERENCES estado(id_estado),
    CONSTRAINT FK_reserva_jugador
        FOREIGN KEY (id_jugador) REFERENCES jugador(id_jugador),
    CONSTRAINT FK_reserva_cancha
        FOREIGN KEY (id_cancha) REFERENCES cancha(id_cancha),
    CONSTRAINT UQ_reserva_momento UNIQUE (fecha, hora, id_cancha) --Una misma cancha no pueda tener dos reservas en la misma fecha y hora.
);
GO
