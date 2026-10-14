# ESCUELA POLITÉCNICA NACIONAL
### Facultad de Ingeniería de Sistemas

**Asignatura:** Business Intelligence | **Paralelo:** GR2SW | **Integrantes:** Chanatasig Garzón Juan Francisco, Chimarro Bermeo Marlon Xavier, Dávalos Cedeño Martín Alejandro, De La Cruz Cañar Kevin Santiago | **Fecha:** martes 13 de octubre, 2026

---

## Índice

1. [Objetivo del proceso](#1-objetivo-del-proceso)
2. [Fuentes de datos utilizadas](#2-fuentes-de-datos-utilizadas)
3. [Problemas encontrados en los datos](#3-problemas-encontrados-en-los-datos)
4. [Transformaciones aplicadas](#4-transformaciones-aplicadas)
5. [Flujo ETL desarrollado](#5-flujo-etl-desarrollado)
6. [Evidencia del resultado](#6-evidencia-del-resultado)
7. [Relación con una arquitectura de Data Warehouse](#7-relación-con-una-arquitectura-de-data-warehouse)
8. [Referencias Bibliográficas](#8-referencias-bibliográficas)
9. [Declaración de uso de IA](#9-declaración-de-uso-de-ia)

---

## 1. Objetivo del proceso
Implementar un flujo ETL (*Extract, Transform, Load*) y un área temporal de ensayo (*Staging Area*) utilizando la herramienta gráfica Spoon de Pentaho Data Integration (Hitachi Vantara, 2023). Su propósito es extraer, limpiar y estandarizar la información de los estudiantes proveniente de múltiples orígenes, asegurando la calidad y consistencia de los datos para su posterior integración en una solución de Business Intelligence.

## 2. Fuentes de datos utilizadas
Para cumplir con la integración de múltiples orígenes heterogéneos, se utilizaron dos tipos diferentes de fuentes de datos:
- **Fuente 1 (Archivo Principal - Excel):** Archivo `Caso Estudiantes Fechas Cedula.xls` que contiene los registros operacionales originales de los alumnos (IDs, nombres, apellidos, cédulas, modalidad, nivel, fechas de admisión y estados).
- **Fuente 2 (Archivo Secundario - CSV):** Archivo `estudiantes_contacto.csv` que proporciona información complementaria de contacto (correos electrónicos y teléfonos asociados a cada identificador).

En la **Tabla 1** se detallan las características técnicas, el formato y los campos de cada fuente empleada en la etapa de extracción.

**Tabla 1.** *Especificación técnica de las fuentes de datos utilizadas en el proceso ETL.*

| Fuente | Archivo de Origen | Componente en Pentaho | Campos Extraídos | Rol en el Flujo |
| :--- | :--- | :--- | :--- | :--- |
| **Fuente 1 (Principal)** | `Caso Estudiantes Fechas Cedula.xls` | `Microsoft Excel input` | `ID`, `NOMBRES`, `APELLIDOS`, `CEDULA`, `MODALIDAD`, `NIVEL`, `FECHA ADMISION`, `ESTADO ACTUAL`, `FECHA ESTADO` | Datos académicos base cargados en el *Staging Area*. |
| **Fuente 2 (Secundaria)** | `estudiantes_contacto.csv` | `CSV file input` | `ID`, `CORREO`, `TELEFONO` | Datos complementarios de contacto para cruce relacional por `ID`. |

## 3. Problemas encontrados en los datos
Durante la etapa de análisis y extracción en el *Staging Area* se detectaron las siguientes inconsistencias de calidad de datos, las cuales se sintetizan en la **Tabla 2**:
- **Errores de codificación:** Presencia de símbolos como `~` o `||` en lugar de tildes y eñes en los campos de texto correspondientes a `NOMBRES` y `APELLIDOS`.
- **Espacios excedentes:** Cadenas de texto con espacios en blanco innecesarios al inicio o al final.
- **Anomalías en fechas:** Presencia de caracteres extraños o apóstrofes al inicio de los valores en la columna `FECHA ESTADO` (por ejemplo, `♦12/06/2014`), así como formatos de fecha heterogéneos.
- **Representaciones heterogéneas de estado:** Variaciones de escritura y abreviaturas en la columna `ESTADO ACTUAL` (`Egresado`, `egresado`, `EGR`, `Graduado`, `graduado`, `GRD`).

**Tabla 2.** *Resumen de problemas identificados en los datos y reglas de estandarización aplicadas.*

| Campo Afectado | Problema Detectado | Ejemplo Original | Transformación en PDI | Valor Estandarizado |
| :--- | :--- | :--- | :--- | :--- |
| `NOMBRES` y `APELLIDOS` | Caracteres corruptos de codificación (`~`, doble barra) y espacios | `Mu~oz Molina` | `Replace in string` y recorte de espacios (`Trim`) | `Muñoz Molina` |
| `FECHA ESTADO` | Símbolos no numéricos al inicio del registro | `♦12/06/2014` | `Replace in string` con RegEx (`^[^\d]+`) | `12/06/2014` |
| `ESTADO ACTUAL` | Múltiples variantes para un mismo estado | `Egresado`, `egresado`, `EGR`, `GRD` | `Replace in string` (homologación de dominio) | `EGRESADO`, `GRADUADO` |
| `CORREO` y `TELEFONO` | Información dispersa en un archivo externo | *(En fuente CSV secundaria)* | `Stream lookup` mediante llave primaria `ID` | Campos integrados al registro del alumno |

## 4. Transformaciones aplicadas
Para dar solución a los problemas de calidad identificados en la **Tabla 2**, se configuraron las siguientes etapas en el flujo:

- **Limpieza de Nombres y Apellidos:** Uso de un paso *Replace in string* para buscar y reemplazar los caracteres corruptos (`~` por `ñ`, `||` por vocales acentuadas) y estandarizar los campos textuales. En la **Figura 1** se muestra la parametrización detallada de las reglas de búsqueda y reemplazo aplicadas sobre dichos campos.

![Transformación Nombres y Apellidos][fig1]

**Figura 1.** *Limpieza de errores identificados en los campos de NOMBRE y APELLIDO.*

- **Validación y Limpieza de Fechas:** Uso de un segundo paso secuencial *Replace in string* empleando expresiones regulares (`^[^\d]+`) para eliminar de forma automática los caracteres inválidos iniciales y homologar los valores del estado académico. En la **Figura 2** se observa la configuración de esta transformación sobre la columna `FECHA ESTADO`.

![Transformación Fecha estado][fig2]

**Figura 2.** *Limpieza de errores identificados en el campo FECHA ESTADO.*

- **Combinación de Fuentes (Stream lookup):** Empleo de este componente para actuar como mecanismo de búsqueda en flujo, utilizando el campo `ID` como llave relacional para recuperar y adjuntar dinámicamente los campos de correo y teléfono al conjunto de datos principal, tal como se aprecia en la **Figura 3**.

![Configuracion Stream Lookup][fig3]

**Figura 3.** *Configuración para recuperar campos usando ID del estudiante.*

## 5. Flujo ETL desarrollado
En la **Figura 4** (del diagrama completo) se detalla el proceso ETL implementado en la interfaz gráfica de Pentaho Data Integration (Spoon). Se observa claramente la etapa de extracción hacia el *Staging Area* desde las dos fuentes (Excel y CSV), las dos transformaciones secuenciales de limpieza y validación (`Replace in string`), la unión e integración mediante *Stream lookup* y la etapa de carga hacia el archivo final (`Microsoft Excel writer`).

![Flujo ETL en Pentaho][fig4]

**Figura 4.** *Diagrama completo del flujo ETL implementado en Pentaho Data Integration.*

## 6. Evidencia del resultado
Tras la ejecución exitosa del flujo sin errores (marcando `E=0` en las métricas del sistema), se validó el procesamiento completo de los registros. En la **Tabla 3** se presentan las métricas de rendimiento y validación obtenidas en la pestaña *Step Metrics* de Pentaho Data Integration, confirmando que todas las filas extraídas fueron transformadas y cargadas íntegramente.

**Tabla 3.** *Métricas de ejecución y validación de pasos (Step Metrics) en Pentaho Data Integration.*

| Paso del Flujo (Step Name) | Entrada (I) | Leídos (R) | Escritos (W) | Salida (O) | Errores (E) | Estado |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `Staging (Excel Input)` | 99 | 0 | 99 | 0 | 0 | Finalizado |
| `Contacto (CSV Input)` | 99 | 0 | 99 | 0 | 0 | Finalizado |
| `Transformación Nombres y Apellidos` | 0 | 99 | 99 | 0 | 0 | Finalizado |
| `Transformación Fechas` | 0 | 99 | 99 | 0 | 0 | Finalizado |
| `Stream lookup` | 99 | 99 | 99 | 0 | 0 | Finalizado |
| `Microsoft Excel writer` | 0 | 99 | 99 | 100 | 0 | Finalizado |

En la **Figura 5** se aprecia el estado inicial de los registros antes de aplicar las transformaciones de limpieza, donde aún persisten los caracteres corruptos y formatos irregulares.

![Evidencia de datos limpios en Excel][fig5]

**Figura 5.** *Archivo de salida Excel antes de realizar la limpieza.*

Por su parte, como se evidencia en la **Figura 6**, el archivo de salida final presenta una correcta depuración de caracteres en nombres y apellidos, fechas estandarizadas y la integración exitosa de los campos de contacto multiorigen (`CORREO` y `TELEFONO`).

![Evidencia de datos limpios en Excel][fig6]

**Figura 6.** *Archivo de salida Excel mostrando los datos consolidados y estandarizados.*

## 7. Relación con una arquitectura de Data Warehouse
En el contexto de Business Intelligence, el proceso ETL junto con el *Staging Area* constituye la columna vertebral que garantiza la integridad de la información:
1. **Desacoplamiento y Persistencia (Staging Area):** Sirve como espacio intermedio que aísla los sistemas de origen. Refleja una copia exacta de las fuentes para que las fases de transformación se ejecuten sin comprometer el rendimiento de los sistemas transaccionales (OLTP), cumpliendo con los principios de integración de datos de un repositorio corporativo (Inmon, 2005).
2. **Data Cleansing:** Las transformaciones ejecutadas mediante Pentaho Data Integration (Hitachi Vantara, 2023) garantizan la consistencia semántica y sintáctica, así como la correcta resolución de entidades (cruce de fuentes).
3. **Integración Dimensional:** Estas labores de limpieza y homologación son el paso previo e indispensable para alimentar correctamente las **Tablas de Dimensiones** (como la dimensión Estudiante consolidada) y las **Tablas de Hechos** dentro de un modelo dimensional de un Data Warehouse analítico (Kimball & Ross, 2013).

## 8. Referencias Bibliográficas
- Inmon, W. H. (2005). *Building the Data Warehouse* (4th ed.). John Wiley & Sons.
- Kimball, R., & Ross, M. (2013). *The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling* (3rd ed.). John Wiley & Sons.
- Hitachi Vantara. (2023). *Pentaho Data Integration (Spoon) User Guide*. Documentación oficial de la plataforma.

## 9. Declaración de uso de IA
**Porcentaje de uso de IA declarado:** 15%

**Detalle de uso:** Se utilizó asistencia de Inteligencia Artificial (LLM) de forma complementaria para la revisión ortográfica, gramatical y como medio de consulta, la síntesis de la fundamentación teórica sobre arquitecturas Data Warehouse y la estructuración del formato Markdown de este informe. El diseño técnico, configuración de los bloques, ejecución del flujo en Pentaho y validación de resultados fueron realizados en su totalidad de manera manual e intelectual por los autores del documento.

**Evidencia:** https://share.gemini.google/4nwPu2KJ8DDB

[fig1]: Recursos/Imagenes/Transfromacion_nombres_apellidos.png
[fig2]: Recursos/Imagenes/Transformacion_fechas.png
[fig3]: Recursos/Imagenes/Configuracion_strem_look_up.png
[fig4]: Recursos/Imagenes/Diagrama_Final.png
[fig5]: Recursos/Imagenes/Resultado_Antes.png
[fig6]: Recursos/Imagenes/Resultado_Final.png
