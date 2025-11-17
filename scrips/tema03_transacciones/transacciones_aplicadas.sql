/* Transaccion: Actualizar estado de reserva y registrar pago */

CREATE PROCEDURE sp_actualizar_estado_pago
(
    @idReserva INT,       
    @idEstadoNuevo INT,    
    @idPagoNuevo INT        
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* Validamos que la reserva exista*/
        IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = @idReserva)
        BEGIN
            RAISERROR ('La reserva indicada no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        /* Actualizamos el estado de la reserva*/
        UPDATE reserva
        SET id_estado = @idEstadoNuevo
        WHERE id_reserva = @idReserva;


        /* Registramos m�todo de pago asociado al estado*/
        UPDATE estado
        SET id_pago = @idPagoNuevo
        WHERE id_estado = @idEstadoNuevo;


        /* Confirmamos la transacci�n*/
        COMMIT TRANSACTION;
        PRINT 'Estado de reserva actualizado y m�todo de pago registrado correctamente.';
    END TRY


    BEGIN CATCH
        /* Revertimos todo si ocurre un error*/
        ROLLBACK TRANSACTION;

        PRINT 'ERROR al actualizar el estado y el m�todo de pago.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
