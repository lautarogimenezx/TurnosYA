# Sistema de Gestión de Canchas: TurnosYA
**Base de Datos I**
**Grupo 20**

**Alumnos:**
- Galarza, Juan Cruz
- Gauna, Lucia Carolina
- Giménez, Lautaro Nicolás
- Giménez, Tomás

**Año Lectivo:** 2025

---

## Diccionario de Datos

Este documento define la estructura de todas las tablas en la base de datos `TurnosYa`, basándose en el script SQL final implementado.

---
**Tabla: `roles`**

* **Módulo:** Gestión de Usuarios
* **Descripción:** Almacena los tipos de perfiles de usuario (Ej: Administrador, Canchero, Jugador).

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_rol** | INT | **PK**, IDENTITY(1,1) | Identificador único del rol. |
| nombre_rol | VARCHAR(60) | NOT NULL, UNIQUE | Nombre descriptivo del rol. |

---
**Tabla: `usuario`**

* **Módulo:** Gestión de Usuarios
* **Descripción:** Almacena la información de todos los usuarios (login y datos personales).

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_usuario** | INT | **PK**, IDENTITY(1,1) | Identificador único del usuario. |
| nombre | VARCHAR(60) | NOT NULL | Nombre del usuario. |
| apellido | VARCHAR(60) | NOT NULL | Apellido del usuario. |
| email | VARCHAR(120) | NOT NULL, UNIQUE, CHECK | Correo electrónico (para login). |
| contraseña | VARBINARY(256) | NULL | Contraseña encriptada (HASH). |
| activo | INT | NOT NULL | 1 para activo, 0 para inactivo. |
| telefono | VARCHAR(25) | NULL | Teléfono de contacto. |
| dni | VARCHAR(20) | NOT NULL, UNIQUE | Documento Nacional de Identidad. |
| **id_rol** | INT | **FK** (roles), NOT NULL | Referencia al rol del usuario. |

---
**Tabla: `jugador`**

* **Módulo:** Gestión de Usuarios
* **Descripción:** Tabla subtipo de `usuario`. Implementa la especialización y asegura que solo los 'Jugadores' puedan tener reservas.

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_usuario_jugador** | INT | **PK**, **FK** (usuario) | Es PK y FK a la vez. Referencia al `id_usuario`. |

---
**Tabla: `metodo_pago`**

* **Módulo:** Gestión de Pagos
* **Descripción:** Tabla para definir los métodos de pago aceptados (Ej: Efectivo, Tarjeta).

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_pago** | INT | **PK**, IDENTITY(1,1) | Identificador único del método. |
| descripcion | VARCHAR(60) | NOT NULL, UNIQUE | Nombre del método de pago. |

---
**Tabla: `estado`**

* **Módulo:** Gestión de Reservas
* **Descripción:** Define el estado de una reserva (Ej: Pendiente, Confirmada, Cancelada).

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_estado** | INT | **PK**, IDENTITY(1,1) | Identificador único del estado. |
| estado | VARCHAR(40) | NOT NULL | Nombre del estado (Ej: 'Pendiente'). |
| **id_pago** | INT | **FK** (metodo_pago), NULL | Método de pago (NULL si no está pagado). |

---
**Tabla: `tipo_cancha`**

* **Módulo:** Gestión de Infraestructura
* **Descripción:** Define los tipos de canchas (Ej: Fútbol 5, Vóley, Pádel).

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_tipo** | INT | **PK**, IDENTITY(1,1) | Identificador único del tipo. |
| descripcion | VARCHAR(80) | NOT NULL, UNIQUE | Nombre del tipo de cancha. |

---
**Tabla: `cancha`**

* **Módulo:** Gestión de Infraestructura
* **Descripción:** Registra las canchas físicas disponibles, su ubicación y precio.

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_cancha** | INT | **PK**, IDENTITY(1,1) | Identificador único de la cancha. |
| nro_cancha | INT | NOT NULL, UNIQUE, CHECK | Número de la cancha (debe ser > 0). |
| ubicacion | VARCHAR(150) | NOT NULL | Descripción de la ubicación. |
| precio_hora | DECIMAL(12,2) | NOT NULL, CHECK | Costo por hora (no puede ser < 0). |
| **id_tipo** | INT | **FK** (tipo_cancha), NOT NULL | Referencia al tipo de cancha. |

---
**Tabla: `reserva`**

* **Módulo:** Gestión de Reservas
* **Descripción:** Tabla principal que almacena cada reserva o turno realizado.

| Campo | Tipo | Restricciones | Significado |
| :--- | :--- | :--- | :--- |
| **id_reserva** | INT | **PK**, IDENTITY(1,1) | Identificador único de la reserva. |
| fecha | DATE | NOT NULL | Fecha del turno. |
| hora | TIME(0) | NOT NULL | Hora de inicio del turno. |
| duracion | VARCHAR(50) | NOT NULL | Duración (Ej: '60 min'). |
| **id_jugador** | INT | **FK** (jugador), NOT NULL | Referencia al jugador que reserva. |
| **id_estado** | INT | **FK** (estado), NOT NULL | Estado actual de la reserva. |
| **id_cancha** | INT | **FK** (cancha), NOT NULL | Cancha que ha sido reservada. |

*(**Restricción Adicional:** `UQ_reserva_momento` en `(fecha, hora, id_cancha)` para evitar reservas duplicadas).*