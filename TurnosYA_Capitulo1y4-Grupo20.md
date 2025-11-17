# Gestion de Canchas "TurnosYA"

**Asignatura**: Bases de Datos I (FaCENA-UNNE)

**Integrantes**:
 - Galarza, Juan Cruz
 - Gauna, Lucia Carolina
 - Gimenez, Lautaro Nicolas
 - Gimenez, Tomas

**Año**: 2025

## ÍNDICE O SUMARIO

* [CAPÍTULO I: INTRODUCCIÓN](#1-cap%C3%ADtulo-i-introducci%C3%B3n)
    * [1.2 Caso de estudio](#12-caso-de-estudio)
    * [1.3 Objetivos y Fundamentación](#13-objetivos-y-fundamentaci%C3%B3n)
* [CAPÍTULO II: MARCO CONCEPTUAL REFERENCIAL](#cap%C3%ADtulo-ii-marco-conceptual-referencial)
    * [2.1 Estado del Arte (Situación del Problema)](#21-estado-del-arte-situaci%C3%B3n-del-problema)
    * [2.2 Conceptos Teóricos de Bases de Datos](#22-conceptos-te%C3%B3ricos-de-bases-de-datos)
* [CAPÍTULO III: METODOLOGÍA SEGUIDA](#cap%C3%ADtulo-iii-metodolog%C3%ADa-seguida)
    * [3.1 Fases del Proyecto](#31-fases-del-proyecto)
    * [3.2 Método de Educción de Requisitos](#32-m%C3%A9todo-de-educci%C3%B3n-de-requisitos)
    * [3.3 Requisitos Funcionales (RF) Relevantes para la BD](#33-requisitos-funcionales-rf-relevantes-para-la-bd)
    * [3.4 Herramientas Utilizadas](#34-herramientas-utilizadas)
* [CAPÍTULO IV: DESARROLLO DEL TEMA / PRESENTACIÓN DE RESULTADOS](#cap%C3%ADtulo-iv-desarrollo-del-tema--presentaci%C3%B3n-de-resultados)
    * [4.1 Diagrama de Entidad-Relación (DER)](#41-diagrama-de-entidad-relaci%C3%B3n-der)
    * [4.2 Diagrama Relacional](#42-diagrama-relacional)
    * [4.3 Diccionario de Datos](#43-diccionario-de-datos)
* [CAPÍTULO V: CONCLUSIONES](#cap%C3%ADtulo-v-conclusiones)
* [CAPÍTULO VI: BIBLIOGRAFÍA](#cap%C3%ADtulo-vi-bibliograf%C3%ADa)

---

## 1. CAPÍTULO I: INTRODUCCIÓN

El presente proyecto tiene como objetivo el desarrollo de una base de datos para la gestión de turnos en canchas deportivas. El sistema está diseñado para facilitar la reserva de turnos por parte de la administración para un manejo eficiente de las mismas. La base de datos tendra funcionalidades específicas para los distintos tipos de usuarios, y utilizará una base de datos actualizada para garantizar disponibilidad en tiempo real y seguridad en las reservas y pagos.

### 1.2 Caso de estudio

Hoy en día, hay una gran variedad de sistemas y aplicaciones dedicados a la gestión de reservas de canchas de pádel, fútbol y otros espacios deportivos. Sin embargo, muchas de estas soluciones no se adaptan a las necesidades específicas de los usuarios locales o resultan demasiado complicadas para que pequeños centros deportivos las utilicen de forma práctica en su día a día. Las soluciones más utilizadas dependen aún de interacciones manuales vía redes sociales o llamadas telefónicas, generando demoras, errores y dificultades para los administradores. Nuestro proyecto busca mejorar esa experiencia con una solución simple, eficiente y accesible.

### 1.3 Objetivos y Fundamentación
#### 1.3.1 Objetivo General

Desarrollar una base de datos que permita automatizar el proceso de reserva de canchas deportivas y la gestión de pagos, optimizando el trabajo y mejorando la experiencia.

#### 1.3.2 Objetivos específicos
* Permitir a los jugadores reservar turnos según disponibilidad.
* Facilitar al administrador la visualización, modificación y cancelación de turnos.
* Integrar métodos de pago para una gestión financiera más eficaz.
* Asegurar que toda la información esté centralizada y actualizada en tiempo real.

#### 1.3.3 Fundamentación
La necesidad de automatizar el proceso de gestión de canchas se basa en las dificultades reportadas por usuarios, quienes manifestaron problemas en la coordinación manual de turnos, errores en la disponibilidad y falta de control sobre pagos. El desarrollo de esta herramienta responde a esas demandas reales, mejorando la eficiencia operativa y la satisfacción de los usuarios.

## CAPÍTULO II: MARCO CONCEPTUAL REFERENCIAL

Este capítulo sitúa el problema dentro de un conjunto de conocimientos que permiten orientar la búsqueda y ofrecen una conceptualización adecuada de los términos utilizados.

### 2.1 Estado del Arte (Situación del Problema)

Como se mencionó en el caso de estudio, existe una amplia gama de aplicaciones para la gestión de espacios deportivos. Sin embargo, se detecta una brecha en soluciones que sean simultáneamente simples, accesibles para pequeños centros y que resuelvan los problemas centrales de la gestión manual. Los sistemas actuales a menudo fallan por depender de comunicación manual (redes sociales, teléfono), lo que introduce errores de disponibilidad, demoras en la confirmación y una gestión de pagos deficiente. Este proyecto se enfoca en resolver estos puntos débiles mediante una base de datos centralizada.

### 2.2 Conceptos Teóricos de Bases de Datos

El desarrollo de este proyecto, como requisito de la asignatura, debe involucrar los conceptos teóricos de los motores de bases de datos aplicados a un caso práctico. Los pilares conceptuales de este trabajo son:

* *Modelo Entidad-Relación (MER):* Es una herramienta para el modelado de datos que permite representar las entidades relevantes de un sistema de información (como Jugador, Cancha, Reserva) y las relaciones entre ellas.
* *Modelo Relacional:* Es el modelo de base de datos en el que se basa el diseño. Consiste en representar los datos en tablas (relaciones) compuestas por filas (tuplas) y columnas (atributos). Este modelo garantiza la integridad y consistencia de los datos mediante el uso de claves primarias (PK) y claves foráneas (FK).
* *Sistema Gestor de Base de Datos (SGBD):* Es el software que permite definir, construir y manipular la base de datos, proporcionando mecanismos de control de acceso, concurrencia y recuperación de fallos.
* *SQL (Structured Query Language):* Es el lenguaje estándar utilizado para gestionar y consultar bases de datos relacionales.

---
## CAPÍTULO III: METODOLOGÍA SEGUIDA

En este capítulo se presenta el plan seguido y las acciones llevadas a cabo para realizar el trabajo, describiendo los pasos, actividades e instrumentos utilizados.

### 3.1 Fases del Proyecto

El desarrollo del proyecto de base de datos se estructuró en las siguientes fases:

1.  *Educción de Requisitos:* Se investigaron las necesidades y problemas de los usuarios clave.
2.  *Especificación de Requisitos:* Se documentaron los requisitos funcionales y no funcionales que la base de datos debe soportar.
3.  *Diseño Conceptual y Lógico:* Se creó el Diagrama Entidad-Relación y el Diagrama Relacional.
4.  *Implementación:* Se generó el Diccionario de Datos como paso previo a la creación de los scripts SQL para la implementación física.

### 3.2 Método de Educción de Requisitos

Para obtener los datos sobre las necesidades del sistema, se empleó la técnica de *entrevistas estructuradas*, dirigidas a los dos perfiles clave:

* *Jugadores* (usuarios finales de las reservas).
* *Cancheros* (administradores del sistema).

Esta técnica permitió obtener información precisa sobre los problemas de la gestión manual. Se incluyeron preguntas abiertas, cerradas y bipolares.

#### 3.2.1 Preguntas a jugadores
* ¿Con qué frecuencia reservas una cancha?
* ¿Qué dificultades enfrentan al reservar?
* ¿Te gustaría recibir confirmaciones automáticas?

#### 3.2.2 Preguntas a cancheros
* ¿Cómo gestionan actualmente los turnos?
* ¿Qué problemas surgen en la administración diaria?
* ¿Necesitás ver reportes o estadísticas?
* ¿Te interesaría agregar reservas manuales?

### 3.3 Requisitos Funcionales (RF) Relevantes para la BD

A partir de la educción, se definieron los requisitos funcionales que la base de datos debe ser capaz de soportar. Los más relevantes para el diseño de datos son:

| $N^{\circ}$ | Descripción |
| :--- | :--- |
| *RF#1* | El sistema deberá permitir a los jugadores visualizar un calendario de turnos. |
| *RF#2* | El sistema deberá permitir seleccionar cancha, fecha y horario entre los disponibles. |
| *RF#3* | El sistema deberá registrar reservas con confirmación automática. |
| *RF#4* | El sistema deberá permitir al canchero modificar, cancelar o agregar reservas manualmente. |
| *RF#5* | El sistema deberá mostrar el estado de pago de cada reserva. |
| *RF#6* | El sistema deberá permitir al jugador elegir el método de pago. |
| *RF#8* | El sistema deberá validar conflictos de horarios antes de confirmar reservas. |
| *RF#9* | El sistema deberá mostrar un resumen diario de reservas al canchero. |

### 3.4 Herramientas Utilizadas

Para la gestión y diseño del proyecto se utilizaron las siguientes herramientas:

* *Herramientas de modelado de datos:* Se utilizaron herramientas gráficas para la creación del Diagrama Entidad-Relación y el Diagrama Relacional.
* *Trello:* Para la organización de tareas y seguimiento del proyecto.
* *Procesadores de texto y hojas de cálculo:* Para la elaboración del Diccionario de Datos y la documentación del informe.

---

## CAPÍTULO IV: DESARROLLO DEL TEMA / PRESENTACIÓN DE RESULTADOS 


### Diagrama relacional
![diagrama_relacional](https://github.com/lautarogimenezx/TurnosYA/blob/main/docs/TurnosYA_relacional.png)

### Diccionario de datos

Acceso al documento [PDF](https://github.com/lautarogimenezx/TurnosYA/blob/main/docs/Diccionario_de_Datos-TurnosYA.pdf) del diccionario de datos.

## CAPÍTULO V: CONCLUSIONES

En este capítulo se interpreta el sentido de los resultados encontrados en el capítulo anterior y se evalúa el cumplimiento de los objetivos del Trabajo Práctico.

El desarrollo del proyecto ha permitido *alcanzar el objetivo general* de diseñar una base de datos robusta para automatizar el proceso de reserva de canchas. La información recogida durante la investigación, plasmada en los requisitos (Capítulo III), se ha traducido exitosamente en un modelo de datos (Capítulo IV) que responde a las necesidades detectadas.

Analizando los *objetivos específicos* (Sección 1.3.2):

1.  *Reservar turnos:* El diseño lo permite mediante la relación entre las tablas Jugador, Reserva y Cancha.
2.  *Gestión del administrador:* Se cumple al incluir la entidad Canchero y relacionarla con la Reserva, permitiendo la modificación, cancelación (actualizando el campo estado en Estado_Reserva) y visualización de turnos.
3.  *Integrar métodos de pago:* La tabla Estado_Reserva satisface este requisito al incluir los campos metodo_pago y estado_pago.
4.  *Información centralizada:* El modelo relacional propuesto logra centralizar toda la información operativa en una única base de datos, garantizando la disponibilidad en tiempo real y respondiendo a la fundamentación inicial.

En conclusión, el diseño de la base de datos "TurnosYA" soluciona los problemas de coordinación manual, errores de disponibilidad y falta de control de pagos identificados en el caso de estudio.

---


