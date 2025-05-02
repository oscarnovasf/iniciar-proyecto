# Histórico de cambios
---
Todos los cambios notables de este proyecto se documentarán en este archivo.

* ## [Sin versión]
  > Ver TODO.md

---
* ## [v2.2.0] - 2025-050-02
  > Revisión

  * #### Añadido:
    - Configuraciones para git.
    - Inicio de proyecto sólo con git, con el código actual del directorio.
    - Opción para crear repositorios públicos y privados en GitHub.
    - FUNDING.yml y plantillas de GitHub.
    - Instalación de archivos para trabajar con Lando.
    - Descarga de configuración para GrumPHP.

  * #### Cambios:
    - Modificado el valor por defecto a las preguntas de descargar configuración
      vscode y de iniciar git (ahora es n en lugar de y).
    - Mejor gestión de la configuración para usar SFTP.
    - Refactorización de algunas funciones para mejorar legibilidad.

  * #### Errores:
    - Error en la asignación del nombre del proyecto.

  * #### Eliminado:
    - Se ha quitado la opción de documentación porque no la uso.
    - Se ha quitado el menú del script, sólo se puede usar pasando los
      parámetros correctos.

---
* ## [v2.1.1] - 2024-01-24
  > Revisión

  * #### Añadido:
    - Descarga de phpstan.neon al crear proyectos.

  * #### Eliminado:
    - Ya no se permite cambiar el directorio de instalación, siempre se usará el
      directorio actual.
    - Opción de abrir vscode al terminar la instalación.

---
* ## [v2.1.0] - 2023-08-28
  > Nuevas funcionalidades.

  * #### Añadido:
    - Se establece que las fusiones con la rama main serán con squash.
    - Nuevo sistema de clonado de repositorios. Esto implica que puede estar
      activo el "git" antes de ejecutar el clonado.

  * #### Cambios:
    - Se ha cambiado la forma de copiar los archivos "locales" de cp a rsync.
    - El script ya no elimina la carpeta .git tras el clonado del repositorio,
      con los cambios introducidos ya no es necesario.
    - Si git ya ha sido inicializado no se pregunta si se quiere iniciar.

---
* ## [v2.0.0] - 2023-05-19
  > Nuevas funcionalidades.

  * #### Añadido:
    - Funcionalidad para crear los proyectos borrando la información de
      copyright (para usar en proyectos anónimos o de otras agencias).
    - Fichero de configuración .env para poder publicar el script protegiendo
      datos confidenciales.
    - Añadidos nuevos tipos de módulos que se pueden crear: API Rest y Básico.
    - Añadida funcionalidad para crear proyectos Drupal completos.
    - Añadida funcionalidad para crear automáticamente el repositorio en GitLab,
      GitHub o Gogs.
    - Añadida funcionalidad para descargar las plantillas desde el repositorio
      oficial en lugar de usar una ruta local.
    - Añadida configuración para conexiones SSH con clave privada.
    - Añadida funcionalidad para poder elegir si se desean descargar las
      configuraciones de .vscode.

  * #### Cambios:
    - Refactor completo del script para poder generar módulos de importación y
      otras opciones.
    - El primer commit sólo incluye los archivos README.md, .gitignore y la
      carpeta .vscode en la rama main y todo lo demás se incluye en la rama
      develop.
    - La plantilla para el archivo sftp.json se ha simplificado por lo que se ha
      adaptado el script a su nueva estructura.
    - Ahora se pide el repo remoto antes de preguntar si se quiere realizar el
      commit inicial.

  * #### Errores:
    - Problema al seleccionar la opción "Otro" que hacía lo mismo que cuando se
      seleccionaba "Script".

  * #### Eliminado:
    - Eliminada la opción de activar standard-version ya que no la uso nunca.

---
* ## [v1.0.2] - 2021-11-26
  > Nuevas funcionalidades (no publicadas).

  * #### Añadido:
    - Descarga de nuevos snippets.
    - Control de tiempo de ejecución del script.

  * #### Cambios:
    - Apertura del proyecto en VSCode opcional.
    - Al solicitar los datos de git ahora muestra los valores actuales.
    - Ahora la rama principal para git es "main".
    - Nombre en español para el script.

---
* ## [v1.0.1] - 2021-10-05
  > Nuevas funcionalidades (no publicadas).

  * #### Añadido:
    - Configuración para ESLint.

---
* ## [v1.0.0] - 2021-09-14
  > Versión inicial (no publicada)