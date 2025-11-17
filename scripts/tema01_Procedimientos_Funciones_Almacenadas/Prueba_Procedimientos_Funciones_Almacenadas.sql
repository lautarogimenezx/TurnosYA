
CREATE OR ALTER FUNCTION fn_VerificarDisponibilidad (
    @id_cancha INT,
    @fecha DATE,
    @hora TIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @disponible BIT = 1;
    -- ID 5 = 'Cancelada'
    DECLARE @id_estado_cancelado INT = 5; 

    IF EXISTS (
        SELECT 1
        FROM reserva
        WHERE id_cancha = @id_cancha
          AND fecha = @fecha
          AND hora = @hora
          AND id_estado != @id_estado_cancelado
    )
    BEGIN
        SET @disponible = 0; -- No está disponible
    END

    RETURN @disponible;
END;
GO

CREATE OR ALTER FUNCTION fn_CalcularPrecioTurno (
    @id_cancha INT,
    @fecha DATE
)
RETURNS DECIMAL(12, 2)
AS
BEGIN
    DECLARE @precio_base DECIMAL(12, 2);
    DECLARE @precio_final DECIMAL(12, 2);
    
    SELECT @precio_base = precio_hora FROM cancha WHERE id_cancha = @id_cancha;
    SET @precio_final = @precio_base;

    RETURN @precio_final;
END;
GO

CREATE OR ALTER FUNCTION fn_ObtenerAgendaPorCancha (
    @id_cancha INT,
    @fecha DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        r.id_reserva,
        r.hora,
        r.duracion,
        e.estado,
        u.nombre AS jugador_nombre,
        u.apellido AS jugador_apellido,
        u.telefono AS jugador_telefono
    FROM reserva r
    JOIN estado e ON r.id_estado = e.id_estado
    JOIN jugador j ON r.id_jugador = j.id_usuario_jugador
    JOIN usuario u ON j.id_usuario_jugador = u.id_usuario
    WHERE r.id_cancha = @id_cancha
      AND r.fecha = @fecha
      AND e.estado != 'Cancelada'
);
GO

CREATE OR ALTER PROCEDURE sp_CrearUsuarioJugador
(
    @nombre VARCHAR(60),
    @apellido VARCHAR(60),
    @email VARCHAR(120),
    @dni VARCHAR(20),
    @telefono VARCHAR(25),
    @contraseña VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @id_rol_jugador INT;
    DECLARE @id_nuevo_usuario INT;
    SELECT @id_rol_jugador = id_rol FROM roles WHERE nombre_rol = 'Jugador';
    IF @id_rol_jugador IS NULL
    BEGIN
        RAISERROR('Error crítico: El rol "Jugador" no existe en la tabla de roles.', 16, 1);
        RETURN -1;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Insertamos en 'usuario'
        INSERT INTO usuario (nombre, apellido, email, contraseña, activo, telefono, dni, id_rol)
        VALUES (@nombre, @apellido, @email, HASHBYTES('SHA2_256', @contraseña), 1, @telefono, @dni, @id_rol_jugador);
        
        SET @id_nuevo_usuario = SCOPE_IDENTITY();

        -- Insertamos en 'jugador'
        INSERT INTO jugador (id_usuario_jugador)
        VALUES (@id_nuevo_usuario);

        COMMIT TRANSACTION;
        PRINT 'Jugador creado con éxito. ID = ' + CAST(@id_nuevo_usuario AS VARCHAR);
        RETURN @id_nuevo_usuario;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        
        IF ERROR_NUMBER() = 2627 OR ERROR_NUMBER() = 2601 -- Violación de UNIQUE KEY
        BEGIN
            IF @ErrorMessage LIKE '%UQ_usuario_email%'
                RAISERROR('El email "%s" ya se encuentra registrado.', 16, 1, @email);
            ELSE IF @ErrorMessage LIKE '%UQ_usuario_dni%'
                RAISERROR('El DNI "%s" ya se encuentra registrado.', 16, 1, @dni);
            ELSE
                RAISERROR(@ErrorMessage, 16, 1);
        END
        ELSE
            RAISERROR(@ErrorMessage, 16, 1);
        
        RETURN -1;
    END CATCH
END;
GO
PRINT 'PROCEDIMIENTO: sp_CrearUsuarioJugador creado/alterado.';

CREATE OR ALTER PROCEDURE sp_RegistrarReserva
    (
    @id_jugador INT,
    @id_cancha INT,
    @fecha DATE,
    @hora TIME,
    @duracion VARCHAR(50) = '60 min'
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id_estado_pendiente INT = 1; 
    DECLARE @mensaje_error NVARCHAR(4000);

    BEGIN TRY
        
        IF NOT EXISTS (SELECT 1 FROM jugador WHERE id_usuario_jugador = @id_jugador)
        BEGIN
            RAISERROR('El ID de jugador proporcionado no es válido.', 16, 1);
            RETURN;
        END
        -- Usamos nuestra función de validación
        IF dbo.fn_VerificarDisponibilidad(@id_cancha, @fecha, @hora) = 0
        BEGIN
            RAISERROR('El turno para esa cancha, fecha y hora ya no está disponible.', 16, 1);
            RETURN;
        END

        INSERT INTO reserva (fecha, hora, duracion, id_jugador, id_estado, id_cancha)
        VALUES (@fecha, @hora, @duracion, @id_jugador, @id_estado_pendiente, @id_cancha);
        
        SELECT * FROM reserva WHERE id_reserva = SCOPE_IDENTITY(); 

    END TRY
    BEGIN CATCH
        SET @mensaje_error = ERROR_MESSAGE();
        -- Si el error es de la UQ_reserva_momento (por si acaso fn_VerificarDisponibilidad falla)
        IF ERROR_NUMBER() = 2627 OR ERROR_NUMBER() = 2601
        BEGIN
             RAISERROR('El turno para esa cancha, fecha y hora ya no está disponible (Error de Concurrencia).', 16, 1);
        END
        ELSE
        BEGIN
            RAISERROR(@mensaje_error, 16, 1);
        END
    END CATCH
END;
GO
PRINT 'PROCEDIMIENTO: sp_RegistrarReserva creado/alterado.';

CREATE OR ALTER PROCEDURE sp_ConfirmarPagoReserva
(
    @id_reserva INT,
    @id_metodo_pago INT -- (1=Efectivo, 2=Tarjeta, 3=Transferencia)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @id_estado_nuevo INT;
    
    IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = @id_reserva)
    BEGIN
        RAISERROR('La reserva con ID %d no existe.', 16, 1, @id_reserva);
        RETURN;
    END

    -- Busca el estado (ID 2, 3 o 4) que coincida con el id_pago (1, 2 o 3)
    SELECT @id_estado_nuevo = id_estado
    FROM estado
    WHERE id_pago = @id_metodo_pago AND estado LIKE 'Confirmada%';

    IF @id_estado_nuevo IS NULL
    BEGIN
        RAISERROR('No se encontró un estado "Confirmada" para el método de pago ID %d.', 16, 1, @id_metodo_pago);
        RETURN;
    END

    UPDATE reserva
    SET id_estado = @id_estado_nuevo
    WHERE id_reserva = @id_reserva;

    PRINT 'Reserva ID ' + CAST(@id_reserva AS VARCHAR) + ' actualizada a estado Confirmado.';
END;
GO
PRINT 'PROCEDIMIENTO: sp_ConfirmarPagoReserva creado/alterado.';

CREATE OR ALTER PROCEDURE sp_CancelarReserva
(
    @id_reserva INT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ID 5 = 'Cancelada'
    DECLARE @id_estado_cancelado INT = 5; 
    DECLARE @id_reserva_actual INT;

    SELECT @id_reserva_actual = id_reserva 
    FROM reserva 
    WHERE id_reserva = @id_reserva AND id_estado != @id_estado_cancelado;

    IF @id_reserva_actual IS NULL
    BEGIN
        RAISERROR('La reserva ID %d no existe o ya se encuentra cancelada.', 16, 1, @id_reserva);
        RETURN;
    END
    
    UPDATE reserva
    SET id_estado = @id_estado_cancelado
    WHERE id_reserva = @id_reserva;

    PRINT 'Reserva ID ' + CAST(@id_reserva AS VARCHAR) + ' cancelada con éxito.';
END;
GO
PRINT 'PROCEDIMIENTO: sp_CancelarReserva creado/alterado.';
PRINT '--- Todas las Funciones y SPs han sido creados/alterados ---';

PRINT '--- INICIANDO LOTE DE PRUEBAS ADAPTATIVO ---';
GO

PRINT '--- Pruebas de Funciones ---';

-- Prueba 1 (Función): Verificar turno OCUPADO (Debe devolver 0)
-- Tomamos un turno aleatorio que NO esté cancelado
PRINT 'Prueba 1: Verificando un turno ocupado al azar...';
DECLARE @TestReservaOcupada TABLE (cancha INT, fecha DATE, hora TIME);
INSERT INTO @TestReservaOcupada 
    SELECT TOP 1 id_cancha, fecha, hora FROM reserva WHERE id_estado != 5 ORDER BY NEWID();

SELECT dbo.fn_VerificarDisponibilidad(
    (SELECT cancha FROM @TestReservaOcupada), 
    (SELECT fecha FROM @TestReservaOcupada), 
    (SELECT hora FROM @TestReservaOcupada)
) AS TurnoOcupado_DebeSer_0;


-- Prueba 2 (Función): Verificar turno LIBRE (Debe devolver 1)
PRINT 'Prueba 2: Verificando un turno заведомо libre...';
SELECT dbo.fn_VerificarDisponibilidad(1, '1900-01-01', '12:00:00') AS TurnoLibre_DebeSer_1;


-- Prueba 3 (Función): Calcular precio en Fin de Semana (Cancha 1)
PRINT 'Prueba 3: Calculando precio de fin de semana...';
DECLARE @FechaSabado DATE;
SET @FechaSabado = GETDATE();
WHILE DATEPART(dw, @FechaSabado) != 7 BEGIN
    SET @FechaSabado = @FechaSabado + 1;
END
SELECT dbo.fn_CalcularPrecioTurno(1, @FechaSabado) AS PrecioFinDeSemana_Cancha1;
GO
PRINT '--- Pruebas de Creación de Jugador ---';

-- Prueba 4 (Éxito): Crear un nuevo jugador (con DNI/Email únicos)
PRINT 'Prueba 4: Creando jugador con datos únicos...';
DECLARE @email_exito VARCHAR(120) = 'exito.prueba.' + CAST(NEWID() AS VARCHAR(36)) + '@turnosya.com';
DECLARE @dni_exito VARCHAR(20) = CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR);

EXEC sp_CrearUsuarioJugador
    @nombre = 'PruebaExito',
    @apellido = 'Test',
    @email = @email_exito,
    @dni = @dni_exito,
    @telefono = '123456789',
    @contraseña = 'Password123';
DECLARE @id_jugador_exito INT = (SELECT id_usuario FROM usuario WHERE email = @email_exito);
PRINT 'Jugador de prueba creado con ID: ' + CAST(@id_jugador_exito AS VARCHAR);

-- Prueba 5 (Error): Intentar crear con DNI duplicado
PRINT 'Prueba 5: Intentando crear con DNI duplicado...';
BEGIN TRY
    EXEC sp_CrearUsuarioJugador
        @nombre = 'PruebaErrorDNI',
        @apellido = 'Test',
        @email = 'otro.email.distinto@turnosya.com',
        @dni = @dni_exito, -- DNI Repetido de la prueba 4
        @telefono = '123',
        @contraseña = 'Password123';
END TRY
BEGIN CATCH
    PRINT 'Error capturado (DNI duplicado): ' + ERROR_MESSAGE();
END CATCH

-- Prueba 6 (Error): Intentar crear con Email duplicado
PRINT 'Prueba 6: Intentando crear con Email duplicado...';
BEGIN TRY
    EXEC sp_CrearUsuarioJugador
        @nombre = 'PruebaErrorEmail',
        @apellido = 'Test',
        @email = @email_exito, -- Email Repetido de la prueba 4
        @dni = '00000001', -- DNI distinto
        @telefono = '123',
        @contraseña = 'Password123';
END TRY
BEGIN CATCH
    PRINT 'Error capturado (Email duplicado): ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '--- Pruebas de Registro de Reserva ---';


DECLARE @id_jugador_prueba INT = (SELECT TOP 1 id_usuario_jugador FROM jugador ORDER BY id_usuario_jugador); -- Tomamos el primer jugador
DECLARE @fecha_libre DATE = '1900-01-01';
DECLARE @hora_libre TIME = '12:00:00';
DECLARE @id_cancha_prueba INT = 1;

-- Prueba 7 (Éxito): Reservar un turno libre
PRINT 'Prueba 7: Registrando reserva en turno libre...';
EXEC sp_RegistrarReserva
    @id_jugador = @id_jugador_prueba,
    @id_cancha = @id_cancha_prueba,
    @fecha = @fecha_libre,
    @hora = @hora_libre;
-- (Debería devolver la fila de la reserva creada)

-- Prueba 8 (Error): Intentar reservar el mismo turno (conflicto)
PRINT 'Prueba 8: Intentando registrar en el mismo turno (debe fallar)...';
BEGIN TRY
    EXEC sp_RegistrarReserva
        @id_jugador = @id_jugador_prueba,
        @id_cancha = @id_cancha_prueba,
        @fecha = @fecha_libre,
        @hora = @hora_libre;
END TRY
BEGIN CATCH
    PRINT 'Error capturado (Conflicto de turno): ' + ERROR_MESSAGE();
END CATCH

-- Prueba 9 (Error): Intentar reservar con un Jugador ID inválido
PRINT 'Prueba 9: Intentando registrar con jugador inexistente...';
BEGIN TRY
    EXEC sp_RegistrarReserva
        @id_jugador = -99, -- No existe
        @id_cancha = 2,
        @fecha = '1900-01-02', -- Otra fecha libre
        @hora = '12:00:00';
END TRY
BEGIN CATCH
    PRINT 'Error capturado (Jugador inválido): ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '--- Pruebas de SPs Administrativos y Reportes ---';

-- Obtenemos IDs de prueba al azar desde la BDD masiva
DECLARE @id_reserva_pendiente INT;
DECLARE @id_reserva_a_cancelar INT;
DECLARE @id_cancha_reporte INT;
DECLARE @fecha_reporte DATE;

-- Tomamos una reserva 'Pendiente' (ID 1)
SELECT TOP 1 @id_reserva_pendiente = id_reserva, 
             @id_cancha_reporte = id_cancha, 
             @fecha_reporte = fecha
FROM reserva WHERE id_estado = 1 ORDER BY NEWID();

-- Tomamos una reserva que NO esté 'Cancelada' (ID 5)
SELECT TOP 1 @id_reserva_a_cancelar = id_reserva
FROM reserva WHERE id_estado != 5 ORDER BY NEWID();

PRINT 'ID Pendiente seleccionada: ' + ISNULL(CAST(@id_reserva_pendiente AS VARCHAR), 'NINGUNA (TEST OMITIDO)');
PRINT 'ID a Cancelar seleccionada: ' + ISNULL(CAST(@id_reserva_a_cancelar AS VARCHAR), 'NINGUNA (TEST OMITIDO)');

IF @id_reserva_pendiente IS NOT NULL
BEGIN
    -- Prueba 10 (Reporte): Ver la agenda ANTES de confirmar
    PRINT 'Prueba 10: Agenda (ANTES de confirmar):';
    SELECT * FROM dbo.fn_ObtenerAgendaPorCancha(@id_cancha_reporte, @fecha_reporte)
    WHERE id_reserva = @id_reserva_pendiente;

    -- Prueba 11 (SP Admin): Confirmar el pago de la reserva con 'Tarjeta' (ID Pago 2)
    PRINT 'Prueba 11: Confirmando pago de reserva...';
    EXEC sp_ConfirmarPagoReserva @id_reserva = @id_reserva_pendiente, @id_metodo_pago = 2;

    -- Prueba 12 (Reporte): Ver la agenda DESPUÉS de confirmar
    PRINT 'Prueba 12: Agenda (DESPUÉS de confirmar):';
    SELECT * FROM dbo.fn_ObtenerAgendaPorCancha(@id_cancha_reporte, @fecha_reporte)
    WHERE id_reserva = @id_reserva_pendiente;
END
ELSE
BEGIN
    PRINT 'OMITIENDO Pruebas 10-12 (No se encontraron reservas Pendientes).';
END

IF @id_reserva_a_cancelar IS NOT NULL
BEGIN
    -- Prueba 13 (SP Admin): Cancelar la reserva
    PRINT 'Prueba 13: Cancelando reserva...';
    EXEC sp_CancelarReserva @id_reserva = @id_reserva_a_cancelar;

    -- Prueba 14 (Error SP Admin): Intentar cancelar la reserva DE NUEVO
    PRINT 'Prueba 14: Intentando cancelar de nuevo (debe fallar)...';
    BEGIN TRY
        EXEC sp_CancelarReserva @id_reserva = @id_reserva_a_cancelar;
    END TRY
    BEGIN CATCH
        PRINT 'Error capturado (Ya cancelada): ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
BEGIN
    PRINT 'OMITIENDO Pruebas 13-14 (No se encontraron reservas para cancelar).';
END
GO

PRINT '--- LOTE DE PRUEBAS FINALIZADO ---';