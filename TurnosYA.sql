CREATE DATABASE TurnosYa

use TurnosYa

CREATE TABLE dbo.jugador (
    id_jugador      INT IDENTITY(1,1)             NOT NULL,
    nombre          VARCHAR(60)                    NOT NULL,
    apellido        VARCHAR(60)                    NOT NULL,
    email           VARCHAR(120)                   NOT NULL,
    contrasena      VARBINARY(256)                 NULL,  -- ideal almacenar hash
    telefono        VARCHAR(25)                    NULL,

    CONSTRAINT PK_jugador PRIMARY KEY CLUSTERED (id_jugador),
    CONSTRAINT UQ_jugador_email UNIQUE (email),
    CONSTRAINT CK_jugador_email CHECK (email LIKE '%@%.%')
);
GO

CREATE TABLE dbo.canchero (
    id_canchero     INT IDENTITY(1,1)             NOT NULL,
    nombre          VARCHAR(60)                    NOT NULL,
    apellido        VARCHAR(60)                    NOT NULL,
    email           VARCHAR(120)                   NOT NULL,
    contrasena      VARBINARY(256)                 NULL,

    CONSTRAINT PK_canchero PRIMARY KEY CLUSTERED (id_canchero),
    CONSTRAINT UQ_canchero_email UNIQUE (email),
    CONSTRAINT CK_canchero_email CHECK (email LIKE '%@%.%')
);
GO

CREATE TABLE dbo.tipo_cancha (
    id_tipo         INT IDENTITY(1,1)             NOT NULL,
    descripcion     VARCHAR(80)                    NOT NULL,
    CONSTRAINT PK_tipo_cancha PRIMARY KEY CLUSTERED (id_tipo),
    CONSTRAINT UQ_tipo_cancha_desc UNIQUE (descripcion)
);
GO

CREATE TABLE dbo.cancha (
    id_cancha       INT IDENTITY(1,1)             NOT NULL,
    nro_cancha      INT                            NOT NULL,
    id_tipo         INT                            NOT NULL,

    CONSTRAINT PK_cancha PRIMARY KEY CLUSTERED (id_cancha),
    CONSTRAINT UQ_cancha_nro UNIQUE (nro_cancha),
    CONSTRAINT CK_cancha_nro CHECK (nro_cancha > 0),
    CONSTRAINT FK_cancha_tipo
        FOREIGN KEY (id_tipo) REFERENCES dbo.tipo_cancha(id_tipo)
);
GO

CREATE TABLE dbo.metodo_pago (
    id_metodo_pago  INT IDENTITY(1,1)             NOT NULL,
    descripcion     VARCHAR(60)                    NOT NULL,
    CONSTRAINT PK_metodo_pago PRIMARY KEY CLUSTERED (id_metodo_pago),
    CONSTRAINT UQ_metodo_pago_desc UNIQUE (descripcion)
);
GO

CREATE TABLE dbo.pago_reserva (
    id_pago         INT IDENTITY(1,1)             NOT NULL,
    id_metodo_pago  INT                            NOT NULL,
    monto           DECIMAL(12,2)                  NOT NULL,
    CONSTRAINT PK_pago_reserva PRIMARY KEY CLUSTERED (id_pago),
    CONSTRAINT FK_pago_metodo FOREIGN KEY (id_metodo_pago) REFERENCES dbo.metodo_pago(id_metodo_pago),
    CONSTRAINT CK_pago_monto CHECK (monto >= 0)
);
GO

CREATE TABLE dbo.estado_reserva (
    id_estado_reserva   INT IDENTITY(1,1)         NOT NULL,
    descripcion         VARCHAR(40)               NOT NULL,   -- p.ej. Pendiente, Confirmada, Cancelada
    id_pago             INT                        NULL,
    id_metodo_pago      INT                        NULL,
    CONSTRAINT PK_estado_reserva PRIMARY KEY CLUSTERED (id_estado_reserva),
    CONSTRAINT FK_estado_pago
        FOREIGN KEY (id_pago) REFERENCES dbo.pago_reserva(id_pago),
    CONSTRAINT FK_estado_metodo
        FOREIGN KEY (id_metodo_pago) REFERENCES dbo.metodo_pago(id_metodo_pago)
);
GO


CREATE TABLE dbo.reserva (
    id_reserva         INT IDENTITY(1,1)  NOT NULL,
    fecha              DATE  NOT NULL CONSTRAINT DF_reserva_fecha DEFAULT (CONVERT(date, GETDATE())),
    hora               TIME(0)   NOT NULL CONSTRAINT DF_reserva_hora  DEFAULT (CONVERT(time, GETDATE())),
    id_jugador         INT   NOT NULL,
    id_canchero        INT   NOT NULL,
    id_cancha          INT   NOT NULL,
    id_estado_reserva  INT   NOT NULL,

    creado_en          DATETIME2(0)   NOT NULL CONSTRAINT DF_reserva_creado DEFAULT (SYSUTCDATETIME()),
    actualizado_en     DATETIME2(0)   NOT NULL CONSTRAINT DF_reserva_act    DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT PK_reserva PRIMARY KEY CLUSTERED (id_reserva),

    CONSTRAINT FK_reserva_jugador
        FOREIGN KEY (id_jugador) REFERENCES dbo.jugador(id_jugador),
    CONSTRAINT FK_reserva_canchero
        FOREIGN KEY (id_canchero) REFERENCES dbo.canchero(id_canchero),
    CONSTRAINT FK_reserva_cancha
        FOREIGN KEY (id_cancha) REFERENCES dbo.cancha(id_cancha),
    CONSTRAINT FK_reserva_estado
        FOREIGN KEY (id_estado_reserva) REFERENCES dbo.estado_reserva(id_estado_reserva),
    CONSTRAINT CK_reserva_hora CHECK (hora >= '00:00:00' AND hora < '24:00:00'),
    CONSTRAINT CK_reserva_fecha CHECK (fecha >= '2000-01-01')
);
GO