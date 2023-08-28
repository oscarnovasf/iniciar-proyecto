Script para iniciar un proyecto
===

>Este script permite inicializar un proyecto con todas las configuraciones
>necesarias para VSCode y archivos auxiliares.

[![version][version-badge]][changelog]
[![Licencia][license-badge]][license]
[![Código de conducta][conduct-badge]][conduct]
[![wakatime](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/09364109-bce0-4a78-a0f4-a9a6c06f56f1.svg)](https://wakatime.com/badge/user/236d57da-61e8-46f2-980b-7af630b18f42/project/09364109-bce0-4a78-a0f4-a9a6c06f56f1)
[![Donate][donate-badge]][donate-url]

## Requisitos
- GIT instalado en nuestra máquina.
- Node.js instalado en nuestra máquina (^18).
- Paquete [Degit](https://www.npmjs.com/package/degit) instalado globalmente.
- RSYNC.
- CURL.
- Creación previa del archivo .env a partir de .env.sample.
- Tener acceso a los repositorios remotos que se usen como base para
  generar el nuevo proyecto (sólo si se desea usar el repositorio remoto en
  lugar de una copia local del mismo).

## Información
El objetivo de este script es inicializar, dentro de una carpeta en nuestro
disco duro, un proyecto (módulo, Drupal completo, script...) con todas las
configuraciones necesarias para nuestro VSCode.

El script también se encargará de inicializar el repositorio remoto y enviar
el **commit** inicial (si así se desea).

## Configuración
- Tras descargar este proyecto es recomendable crear un alias al script para poder
  ser usado en cualquier carpeta del sistema
- Se debe realizar una copia del archivo .env.sample con el nombre .env y rellenar
  todos los valores por defecto.
- El archivo .env.sample provee de unos repositorios base para que puedas hacer
  un fork y usarlos tu mismo. Inicialmente no funcionarán ya que no se dispone
  de los permisos suficientes para realizar el clonado.

## Ejecución
- Crear una carpeta en el disco local con el nombre máquina que queremos dar al
  proyecto.
- Ejecutar el script (ver Configuración y Requisitos).
- Seguir los pasos indicados en el script.

---
⌨️ con ❤️ por [Óscar Novás][mi-web] 😊

[mi-web]: https://oscarnovas.com "for developers"

[version]: v2.1.0
[version-badge]: https://img.shields.io/badge/Versión-2.1.0-blue.svg

[license]: LICENSE.md
[license-badge]: https://img.shields.io/badge/Licencia-GPLv3+-green.svg "Leer la licencia"

[conduct]: CODE_OF_CONDUCT.md
[conduct-badge]: https://img.shields.io/badge/C%C3%B3digo%20de%20Conducta-2.0-4baaaa.svg "Código de conducta"

[changelog]: CHANGELOG.md "Histórico de cambios"

[donate-badge]: https://img.shields.io/badge/Donaci%C3%B3n-PayPal-red.svg
[donate-url]: https://paypal.me/oscarnovasf "Haz una donación"
