# Investigación: Replicación de Bases de Datos
## Aplicación Específica al Proyecto "TurnosYA"

### 1. Introducción: ¿Qué es la Replicación?

La replicación es el proceso de crear y mantener múltiples copias (réplicas) de una misma base de datos en diferentes servidores. Una base de datos "Maestra" recibe las escrituras (`INSERT`, `UPDATE`) y propaga los cambios a las "Réplicas".

El objetivo de esta investigación es analizar cómo esta arquitectura puede solucionar problemas de rendimiento y disponibilidad en "TurnosYA" a medida que el sistema crece.

---

### 2. Propósitos Clave de la Replicación en "TurnosYA"

Basado en los objetivos estratégicos, la replicación no es solo un backup; es una solución directa a los cuellos de botella que "TurnosYA" inevitablemente enfrentará.

#### 2.1 Escalabilidad y Rendimiento (El caso de uso principal)

Este es el beneficio más importante para "TurnosYA". Debemos analizar nuestro tipo de "carga de trabajo" (Workload):

* **Muchas Lecturas (Reads):** Tendremos docenas de jugadores navegando el calendario, viendo canchas disponibles. Estas son consultas `SELECT`.
* **Pocas Escrituras (Writes):** En comparación, el número de reservas reales transacciones que ejecutan serán mucho menores.

**El Problema:** Si 100 jugadores consultan el calendario (`SELECT`) al mismo tiempo en la misma base de datos donde 1 jugador intenta reservar (`INSERT`), las lecturas pueden bloquear o ralentizar la escritura. El sistema se sentirá lento.

**La Solución (Balanceo de Carga):**
Implementamos una arquitectura **Maestro-Esclavo**:

1.  **Servidor Maestro (Primario):** Maneja **todas las escrituras**. Cuando alguien reserva, el `INSERT` se ejecuta aquí.
2.  **Servidor Réplica (Esclavo):** Maneja **todas las lecturas**. Cuando los jugadores cargan el calendario, la aplicación apunta un `SELECT` que se ejecuta en este servidor.

**Impacto:** El servidor Maestro está libre de consultas pesadas y puede procesar nuevas reservas (`INSERT`) de forma instantánea. El servidor Réplica maneja la carga pesada de las consultas del calendario, asegurando que la web se sienta rápida.

#### 2.2 Análisis de Datos (Reportes del "Canchero")

**El Problema:** El "Canchero" (administrador) querrá ejecutar reportes pesados, como "Calcular las ganancias totales del mes" o "Ver el porcentaje de ocupación de la Cancha 3". Estas consultas analíticas (OLAP) pueden ser lentas y consumir muchos recursos.

**La Solución:** Se puede dedicar una segunda Réplica exclusivamente para **Análisis de Datos**.

**Impacto:** El "Canchero" puede ejecutar los reportes más complejos que necesite en la "Réplica de Analytics" sin afectar el rendimiento del Servidor Maestro (donde se hacen las reservas) ni de la "Réplica de Lectura" (donde los jugadores ven el calendario).

#### 2.3 Alta Disponibilidad (Evitar que el sistema se caiga)

**El Problema:** Si el servidor de la base de datos principal falla (ej. se quema el disco duro), "TurnosYA" deja de funcionar. Nadie puede reservar y el canchero no puede ver quién debe jugar.

**La Solución:** La Réplica (que está en otro servidor) puede tomar el control automáticamente. Este proceso se llama **"failover"**.

**Impacto:** El sistema puede seguir operando con un tiempo de inactividad mínimo, quizás solo unos segundos, en lugar de horas.

---

### 3. Arquitectura Recomendada para "TurnosYA"

Para nuestro proyecto, no todas las arquitecturas tienen sentido.

#### 3.1 Modelo: Maestro-Esclavo
Como se detalló en el punto 2.1, este es el modelo ideal. "TurnosYA" tiene una separación clara de cargas de trabajo (lecturas vs. escrituras) que se adapta perfectamente a este modelo.

#### 3.2 Método: Replicación Asíncrona
Aquí decidimos *cuándo* el servidor Maestro le confirma la reserva al jugador:

* **Síncrona:** El jugador hace clic en "Reservar". El Maestro escribe el `INSERT`, lo envía a la Réplica, la Réplica confirma, y *solo entonces* el Maestro le dice al jugador "Reserva confirmada".
    * *Desventaja:* Es lento. Si la Réplica de reportes está ocupada, la reserva del jugador se queda "colgada".
* **Asíncrona:** El jugador hace clic en "Reservar". El Maestro escribe el `INSERT` y le responde al jugador **inmediatamente**. Luego, en segundo plano (milisegundos después), envía el cambio a la Réplica.
    * *Ventaja:* **Alto rendimiento**. El jugador tiene una confirmación instantánea.
    * *Riesgo (mínimo):* Existe un "replication lag". Si el Maestro falla en el milisegundo exacto *antes* de enviar el dato a la Réplica, esa reserva podría perderse.

**Decisión para "TurnosYA":** Consideramos que la **Replicación Asíncrona** es la indicada  para un sistema de turnos como este, la velocidad y la experiencia del usuario al reservar (alto rendimiento) son más importantes que la garantía de consistencia total e inmediata que ofrece la síncrona.

---

### 4. Tipo de Implementación (SQL Server)

Dados los tipos que existen en SQL Server:

1.  **Snapshot (Instantáneas):** No sirve. Toma una "foto" de la base de datos. Si se hace una vez al día, los jugadores no verían las reservas nuevas hasta el día siguiente.
2.  **Merge (Mezcla):** No sirve. Es para sistemas desconectados, como apps móviles que sincronizan datos una vez al día. "TurnosYA" está siempre online.
3.  **Transaccional (Recomendado):** Es la solución perfecta. Captura las transacciones (como el `INSERT` o el `UPDATE`) del log y las aplica en las réplicas casi en tiempo real. Es el estándar de la industria para alta disponibilidad y balanceo de carga.

### 5. Conclusión

Para un entorno de producción de "TurnosYA" que necesita soportar múltiples jugadores y administradores, la arquitectura elegida es:

* **Arquitectura:** Maestro-Esclavo (con una o más réplicas).
* **Método:** Asíncrono (para máximo rendimiento en las reservas).
* **Tipo:** Replicación Transaccional (para actualizaciones casi en tiempo real).
