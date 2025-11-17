# Procedimientos y Funciones Almacenadas en "TurnosYa"

---

## 1. Introducción

Este documento describe el marco teórico y la estrategia de implementación de Procedimientos Almacenados (Stored Procedures - SP) y Funciones Almacenadas (Stored Functions - SF) en la base de datos del proyecto "TurnosYa".

El objetivo es centralizar la lógica de negocio, mejorar la seguridad y optimizar el rendimiento de la base de datos (SQL Server), creando una capa de abstracción entre la aplicación (ya sea web, móvil o de escritorio) y las tablas de datos.

---

## 2. Definiciones Conceptuales

### 2.1. Procedimientos Almacenados (Stored Procedures)

Un Procedimiento Almacenado (SP) es un conjunto de declaraciones SQL (lógica, consultas, `INSERT`, `UPDATE`, `DELETE`) que se agrupan, se nombran y se almacenan compiladas dentro del motor de la base de datos.

* **Propósito Principal:** Realizar **acciones** y ejecutar lógica de negocio. Son el "verbo" de la base de datos.
* **Analogía:** Piense en un SP como un **método o una función en un lenguaje de programación** (como `void RegistrarReserva()`).
* **Ejecución:** Se invocan explícitamente mediante el comando `EXEC` (o `EXECUTE`).
* **Retorno:** Pueden devolver o no valores, conjuntos de resultados (filas de una tabla) o mensajes de estado.

### 2.2. Funciones Almacenadas (Stored Functions)

Una Función Almacenada (SF) es similar a un SP en que es un bloque de código reutilizable, pero tiene una diferencia fundamental: su propósito es **realizar un cálculo y siempre debe devolver un valor**.

* **Propósito Principal:** Realizar **cálculos** o consultas. Son el "calculador" de la base de datos.
* **Restricción Clave:** No están diseñadas para modificar datos (no deben contener `INSERT`, `UPDATE` o `DELETE`).
* **Ejecución:** No se llaman con `EXEC`. Se utilizan *dentro* de otras consultas SQL (como en un `SELECT` o `WHERE`).
* **Tipos Principales:**
    * **Escalares:** Devuelven un único valor (un número, un texto, una fecha).
    * **De Tabla:** Devuelven un conjunto de resultados (una tabla virtual).

---

## 3. Ventajas y Desventajas de su Implementación

La decisión de usar SPs y SFs introduce beneficios significativos, pero también consideraciones a tener en cuenta.

### 3.1. Ventajas Clave

1.  **Seguridad (Prevención de Inyección SQL):**
    * Esta es la ventaja más importante. Al usar parámetros (ej. `@id_jugador`), la entrada del usuario se trata siempre como un valor, no como código ejecutable. Esto elimina la principal vía de ataque de Inyección SQL.

2.  **Rendimiento y Optimización:**
    * Los SPs y SFs se **compilan una vez** (la primera vez que se ejecutan) y SQL Server almacena el "plan de ejecución" optimizado. Las llamadas subsecuentes son mucho más rápidas que enviar una consulta de texto plano, que debe ser analizada y compilada cada vez.

3.  **Mantenimiento y Reusabilidad (Centralización Lógica):**
    * Si la regla de negocio para "registrar una reserva" cambia (ej. se requiere una seña mínima), solo se modifica el SP `sp_RegistrarReserva` en un lugar. Todas las partes de la aplicación (web, móvil, admin) que lo utilicen adoptarán el cambio automáticamente, sin necesidad de redistribuir la aplicación.

4.  **Reducción del Tráfico de Red:**
    * En lugar de enviar un script de 50 líneas de SQL por la red para una lógica compleja, la aplicación solo envía una línea: `EXEC sp_MiProcedimiento @param1 = 'valor'`.

5.  **Gestión de Permisos (Abstracción de Seguridad):**
    * Podemos dar permiso a un rol (ej. 'Canchero') para `EJECUTAR` un procedimiento (`sp_ConfirmarPagoReserva`) sin necesidad de darle permisos directos de `UPDATE` sobre la tabla `reserva`. El usuario solo puede modificar los datos de la manera específica que el SP define.

### 3.2. Desventajas y Consideraciones

1.  **Carga en el Servidor de Base de Datos:**
    * Mover lógica de negocio de la aplicación al servidor de base de datos (CPU) puede aumentar la carga sobre este último. En sistemas de escala masiva, esto debe ser monitoreado para evitar cuellos de botella.

2.  **Complejidad de Depuración (Debugging):**
    * Depurar la lógica dentro de T-SQL puede ser menos intuitivo que depurar en un entorno de desarrollo de aplicación (como Visual Studio para C# o VS Code para Node.js).

---

## 4. Aplicación Estratégica en "TurnosYa"

Así es como esta teoría se traduce en acciones de diseño para el proyecto "TurnosYa", dividiendo las responsabilidades lógicas.

### 4.1. Responsabilidades de los Procedimientos Almacenados (SP)

Los SPs manejarán todas las **acciones** y **modificaciones de datos**. La aplicación nunca ejecutará un `INSERT` o `UPDATE` directamente; en su lugar, llamará a estos "métodos".

* **Para la Gestión de Reservas:**
    * Crearemos un `sp_RegistrarReserva`. La aplicación le enviará el ID del jugador, el ID de la cancha, la fecha y la hora. El SP internamente validará la disponibilidad (usando una función) y, si es exitoso, insertará el registro en la tabla `reserva` con el `id_estado` correspondiente a "Pendiente".
    * Manejará los errores (ej. "Horario ocupado", "Jugador no existe") y los devolverá a la aplicación de forma controlada.

* **Para la Gestión Administrativa:**
    * Crearemos un `sp_ConfirmarPagoReserva`. Un "Canchero" o "Admin" usará esto. Recibirá el ID de la reserva y el ID del método de pago. El SP buscará el estado "Confirmado" correcto (ej. 'Confirmada (Efectivo)') y actualizará la reserva.
    * Crearemos un `sp_CancelarReserva`. Este SP cambiará el `id_estado` de la reserva a "Cancelada". Es crucial que **no borre** el registro (`DELETE`), para mantener un historial de cancelaciones.

* **Para la Gestión de Usuarios:**
    * Un `sp_CrearUsuarioJugador` podría manejar el registro de nuevos jugadores, asegurando que se cree la entrada en `usuario` y la entrada correspondiente en la tabla `jugador` de forma transaccional (o todo o nada).

### 4.2. Responsabilidades de las Funciones Almacenadas (SF)

Las Funciones manejarán todas las **consultas de cálculo** y **validaciones** que devuelvan un valor.

* **Para Validación de Lógica (Función Escalar):**
    * Crearemos una `fn_VerificarDisponibilidad`. Esta será la función más utilizada. Recibirá cancha, fecha y hora, y devolverá un `1` (true) o `0` (false). El `sp_RegistrarReserva` la usará internamente antes de insertar. La aplicación también puede usarla para mostrar visualmente (ej. en color rojo) los horarios ya ocupados en un calendario.

* **Para Reportes (Función de Tabla):**
    * Crearemos una `fn_ObtenerAgendaPorDia` o `fn_ObtenerAgendaPorCancha`. Esta función recibirá una fecha (y opcionalmente una cancha) y devolverá una tabla completa con todas las reservas activas de ese día, uniendo la información del jugador y el estado del pago. Esto simplifica enormemente las consultas de reportes en la aplicación.

* **Para Cálculos (Función Escalar):**
    * Si el precio de la cancha fuera dinámico (ej. más caro los fines de semana), una `fn_CalcularPrecioTurno` recibiría el ID de la cancha y la fecha, y devolvería el `precio_hora` correcto a aplicar.

## 5. Conclusión

La implementación de Procedimientos y Funciones Almacenadas crea una "API" interna para la base de datos "TurnosYa". Esta estrategia blinda la integridad de los datos, optimiza el rendimiento y hace que el sistema sea más seguro y mantenible a largo plazo, al asegurar que la lógica de negocio resida en un único lugar controlado.
