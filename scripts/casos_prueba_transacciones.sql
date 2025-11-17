/* TEST 1: TRANSACCI�N PARA CREAR RESERVA*/

/* CASO EXITOSO: CREAR RESERVA*/

EXEC sp_crear_reserva
    @idJugador = 2,
    @idEstado = 1,        
    @idCancha = 1,
    @fecha = '2030-01-01',
    @hora = '10:00',
    @duracion = '60 min';


 /* CASO ERR�NEO: INTENTO DE RESERVA DUPLICADA*/

EXEC sp_crear_reserva
    @idJugador = 2,
    @idEstado = 1,
    @idCancha = 1,
    @fecha = '2030-01-01',
    @hora = '10:00',
    @duracion = '60 min';

/*TEST 2: TRANSACCI�N PARA ACTUALIZAR ESTADO + M�TODO DE PAGO*/

 /* CASO EXITOSO: ACTUALIZAR ESTADO Y REGISTRAR M�TODO DE PAGO*/

DECLARE @ultimaReserva INT = (SELECT MAX(id_reserva) FROM reserva);

EXEC sp_actualizar_estado_pago
    @idReserva = @ultimaReserva,  
    @idEstadoNuevo = 2,  
    @idPagoNuevo = 1;     

 /* CASO ERR�NEO: RESERVA INEXISTENTE*/
EXEC sp_actualizar_estado_pago
    @idReserva = 9999999,
    @idEstadoNuevo = 2,
    @idPagoNuevo = 1;

