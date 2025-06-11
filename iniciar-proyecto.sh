#!/usr/bin/env bash

# ##############################################################################
#
# Script que permite inicializar un proyecto con todas las configuraciones
# necesarias para VSCode y archivos auxiliares.
#
#  @author    Óscar Novás
#  @version   v2.0.0
#  @license   GNU/GPL v3+
# ##############################################################################

# Cierro el script en caso de error.
set -e


# ##############################################################################
# VARIABLES AUXILIARES.
# ##############################################################################

# Colores.
RESET="\033[0m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
GREEN="\033[0;32m"

# Ubicación del script.
BASEDIR=$(dirname "$0")


################################################################################
# CONFIGURACIÓN DEL SCRIPT.
################################################################################

# Parámetros que no necesitan ser modificados.
CUSTOM_MACHINE_NAME=$(basename "$(pwd)")
CUSTOM_MACHINE_NAME_AUX=$(basename "$(pwd)")
CUSTOM_NAME=$(basename "$(pwd)")
CUSTOM_NAME_AUX=$(basename "$(pwd)")
PROJECT_TYPE=''
DOWNLOAD_VSCODE='n'


################################################################################
# FUNCIONES AUXILIARES.
################################################################################

# Simplemente imprime una línea por pantalla.
function linea() {
  echo '--------------------------------------------------------------------------------'
}

# Lee archivo de configuración.
function load_env() {
  ENV_FILE="${BASEDIR}/.env"
  if [ ! -f "${ENV_FILE}" ]; then
    clear
    linea
    echo -e " ${RED}No existe el archivo de variables de entorno (.env).${RESET}"
    linea
    exit 1
  else
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
  fi
}

# Comprueba todas las dependencias necesarias.
function check_dependencies() {
  # degit
  package_name='degit'
  if [[ "$(npm list -g $package_name)" =~ "empty" ]]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta DEGIT.${RESET}"
    linea
    exit 2
  fi

  # rsync
  if ! [ -x "$(command -v rsync)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta RSYNC.${RESET}"
    linea
    exit 2
  fi

  # CURL
  if ! [ -x "$(command -v curl)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta RSYNC.${RESET}"
    linea
    exit 2
  fi
}

# Muestra la cabecera de algunas respuestas del script.
function show_header() {
  linea
  echo -e " ${GREEN}Script que permite la creación de un proyecto nuevo.${RESET}"
  linea
  echo " "
}

# Muestra la ayuda del script.
function show_usage() {
  clear
  show_header
  echo "
    Sintaxis del script:
      $0 [argumentos]

    Lista de parámetros aceptados:

    - current: Inicia un proyecto con los datos actuales, no genera ningún
      código adicional (sólo añade configuraciones si se solicitan).
    - drupal: Genera un proyecto completo de Drupal a partir de la plantilla que
      hemos definido.
    - lando: Añade los archivos necesarios para la configuración de Lando al
      proyecto actual.
    - module: Genera un módulo de Drupal a partir de la plantilla
      que nosotros hemos definido.
    - module_api: Genera un módulo de Drupal a partir de la plantilla
      definada para ser usada como módulo de consumo de API-REST.
    - module_bas: Genera un módulo de Drupal a partir de la plantilla definida
      para ser usada como módulo básico
    - module_import: Genera un módulo de Drupal a partir de la plantilla
      definida para ser usada como módulo de importación.
    - script: Genera los archivos necesarios para generar un proyecto de tipo
      script.
    - other: Genera los archivos necesarios para crear cualquier proyecto.

  "
  linea
  exit 0
}

# Comprueba si se ha pasado el parámetro para mostrar la ayuda.
function check_help_param() {
  if [[ ( $* == "--help") || $* == "-h" ]]; then
    show_usage
    exit 0
  fi
}

# Obtiene el nombre para el proyecto.
function get_project_name() {
  echo ''
   case "$PROJECT_TYPE" in

    "other"|"script"|"drupal"|"lando")
      read -r -p "Nombre de máquina para el proyecto [$CUSTOM_MACHINE_NAME_AUX]: " CUSTOM_MACHINE_NAME
      CUSTOM_MACHINE_NAME=${CUSTOM_MACHINE_NAME:-$CUSTOM_MACHINE_NAME_AUX}
      ;;

    *)
      ;;
  esac

  read -r -p "Nombre para el proyecto [$CUSTOM_NAME_AUX]: " CUSTOM_NAME
  CUSTOM_NAME=${CUSTOM_NAME:-$CUSTOM_NAME_AUX}
}

# Elimina archivos que no son necesarios.
function eliminar_archivos_innecesarios() {
  case "$PROJECT_TYPE" in

    "drupal")
      unlink .env || echo "No se ha podido eliminar .env"
      ;;

    *)
      unlink README.md || echo "No se ha podido eliminar README.md"
      unlink .env || echo "No se ha podido eliminar .env"
      unlink phpcs.xml || echo "No se ha podido eliminar phpcs.xml"
      unlink phpmd.xml || echo "No se ha podido eliminar phpmd.xml"
      unlink phpstan.neon || echo "No se ha podido eliminar phpstan.neon"
      ;;
  esac

  unlink CHANGELOG.md || echo "No se ha podido eliminar CHANGELOG.md"
  unlink TODO.md || echo "No se ha podido eliminar TODO.md"
  unlink .wakatime-project || echo "No se ha podido eliminar .wakatime-project"

  # Elimino carpetas innecesarias.
  rm -rf .vscode || echo "No se ha podido eliminar ./.vscode"
  rm -rf .gitlab || echo "No se ha podido eliminar ./.gitlab"
  rm -rf .github || echo "No se ha podido eliminar ./.github"
}

# Descarga archivos necesarios desde mi cuenta de github.
function download_vscode_files() {
  DOWNLOAD_VSCODE='y'
  # clear
  echo " "
  echo -e " ${YELLOW}Descargando archivos adicionales desde GitHub (.vscode)...${RESET}"
  linea
  echo " "

  # Descargo los archivos de .vscode (snippets).
  mkdir -p .vscode
  case "$PROJECT_TYPE" in

    "current"|"other"|"script")
      ;;

    *)
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_clases.code-snippets -o .vscode/drupal_clases.code-snippets
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_form.code-snippets -o .vscode/drupal_form.code-snippets
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_js.code-snippets -o .vscode/drupal_js.code-snippets
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_routing.code-snippets -o .vscode/drupal_routing.code-snippets
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_uses.code-snippets -o .vscode/drupal_uses.code-snippets
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/utils.code-snippets -o .vscode/utils.code-snippets
      ;;
  esac

  # Descargo el diccionario de cspell.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/cspell.json -o .vscode/cspell.json

  # Descargo los archivos de .vscode (otras configuraciones).
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/extensions.json -o .vscode/extensions.json
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/launch.json -o .vscode/launch.json
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/settings.json -o .vscode/settings.json
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/tasks.json -o .vscode/tasks.json
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/copilot-instructions.md -o .vscode/copilot-instructions.md
}

# Descarga archivos necesarios desde mi cuenta de github.
function download_other_files() {
  # clear
  echo " "
  echo -e " ${YELLOW}Descargando archivos adicionales desde GitHub (no .vscode)...${RESET}"
  linea
  echo " "

  case "$PROJECT_TYPE" in

    "drupal"|"lando")
      # Descargo otros componentes de la documentación.
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/phpcs.xml -o phpcs.xml
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/phpmd.xml -o phpmd.xml
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/phpstan.neon -o phpstan.neon
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/grumphp.yml -o grumphp.yml
      ;;

    "module_import")
      # Descargo las librerías necesarias.
      mkdir -p src/lib/general
      curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/FileFunctions.php > src/lib/general/FileFunctions.php
      curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/ResponseFunctions.php > src/lib/general/ResponseFunctions.php
      curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/ValidateFunctions.php > src/lib/general/ValidateFunctions.php
      curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/StringFunctions.php > src/lib/general/StringFunctions.php
      curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/MarkdownParser.php > src/lib/general/MarkdownParser.php
      ;;

    "module"|"module_api")
      # Descargo las librerías necesarias.
      mkdir -p src/lib/general
      curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/MarkdownParser.php > src/lib/general/MarkdownParser.php
      ;;

    *)
      ;;
  esac

  # Descargo archivos de git.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.gitattributes -o .gitattributes
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.gitignore_tasks -o .gitignore
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.editorconfig -o .editorconfig

  # Descargo configuración WakaTime.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.wakatime-project_tasks -o .wakatime-project

  if [ "$PROJECT_TYPE" != "current" ]; then
    if [ "$PROJECT_TYPE" != "drupal" ]; then
      # Descargo el archivo README.md y README.
      curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/README.md -o README.md
      curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/README_anonimo.md -o README_anonimo.md
    fi

    # Archivos .md.
    curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/CODE_OF_CONDUCT.md -o CODE_OF_CONDUCT.md
    curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/LICENSE.md -o LICENSE.md
    curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/CHANGELOG.md -o CHANGELOG.md
    curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/TODO.md -o TODO.md
  fi
}

# Modifica algunas cadenas con los datos del proyecto.
function change_internal_strings() {
  grep -Rl module_template_import_name .|xargs sed -i -e "s/module_template_import_name/$CUSTOM_NAME/g"
  grep -Rl module_template_import .|xargs sed -i -e "s/module_template_import/$CUSTOM_MACHINE_NAME/g"

  grep -Rl module_template_name .|xargs sed -i -e "s/module_template_name/$CUSTOM_NAME/g"
  grep -Rl module_template .|xargs sed -i -e "s/module_template/$CUSTOM_MACHINE_NAME/g"

  grep -Rl module_rest_api_calls_name .|xargs sed -i -e "s/module_rest_api_calls_name/$CUSTOM_NAME/g"
  grep -Rl module_rest_api_calls .|xargs sed -i -e "s/module_rest_api_calls/$CUSTOM_MACHINE_NAME/g"

  grep -Rl NOMBRE_PROYECTO\] .|xargs sed -i -e "s/\[NOMBRE_PROYECTO\]/$CUSTOM_MACHINE_NAME/g"

  grep -Rl PROYECTO\] .|xargs sed -i -e "s/\[PROYECTO\]/$CUSTOM_MACHINE_NAME/g"
  grep -Rl DESCRIPCION\] .|xargs sed -i -e "s/\[DESCRIPCION\]/$CUSTOM_NAME/g"

  # Descargo de nuevo el archivo tasks.json para evitar los cambios anteriores.
  if [ "$DOWNLOAD_VSCODE" == "y" ]; then
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/tasks.json -o .vscode/tasks.json
  fi
}

# Elimina cualquier referencia a mi persona en los archivos.
function eliminar_mi_rastro() {
  clear
  read -r -p "¿Deseas eliminar todo rastro del desarrollador [y]?: " ELIMINAR_RASTRO
  ELIMINAR_RASTRO=${ELIMINAR_RASTRO:-y}

  if [ "$ELIMINAR_RASTRO" == "y" ]; then
    if [ "$PROJECT_TYPE" != "current" ] && [ "$PROJECT_TYPE" != "drupal" ]; then
      # Elimino README.md y lo cambio por la versión anónima.
      unlink README.md || true
      mv README_anonimo.md README.md
    fi

    # Elimino ocurrencias con mi correo.
    grep -Rl "hola@oscarnovas.com" .|xargs sed -i -e "s/hola@oscarnovas.com//g"

    # Elimino ocurrencias con mi nombre o url.
    grep -Rl "Óscar Novás" .|xargs sed -i -e "s/Óscar Novás/Developer/g"
    grep -Rl "oscarnovas.com" .|xargs sed -i -e "s/oscarnovas.com/example.com/g"

    # Vuelvo a descargar el archivo settings.json.
    if [ "$DOWNLOAD_VSCODE" == "y" ]; then
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/settings.json -o .vscode/settings.json
    fi
  else
    # Elimino README_anonimo.md
    unlink README_anonimo.md || true
  fi
}

# Configura la conexión del módulo SFTP.
function config_sftp() {
  # Pregunto si se va a usar SFTP.
  echo ''
  read -r -p "¿Deseas activar el plugin SFTP [y]: " ACTIVATE_SFTP
  ACTIVATE_SFTP=${ACTIVATE_SFTP:-y}

  if [ "$ACTIVATE_SFTP" == "y" ]; then
    # Descargo el archivo sftp.json.
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/sftp.json -o .vscode/sftp.json
    clear
    echo " "
    echo -e " ${YELLOW}Indica a que servidor te quieres conectar:${RESET}"
    linea
    echo " "

    DEFAULT_BASE_ROUTE='/var/www/vhost/example.com'
    select server in "SERVIDOR" "PERSONAL" "CUSTOM" "CUSTOM SSH"
    do
      case $server in
        "SERVIDOR")
          DEFAULT_BASE_ROUTE="$SERVER_BASE_ROUTE"

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ip\]/$SERVER_IP/g"
          grep -l "\[server_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_user\]/$SERVER_USER/g"
          grep -l "\[server_password\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_password\]/$SERVER_PASS/g"

          # Establezco el servidor por defecto.
          if [ "$SERVER_SSH" == "s" ]; then
            grep -l "\[server_profile\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_profile\]/server_ssh/g"
          else
            grep -l "\[server_profile\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_profile\]/server_sftp/g"
          fi
          break;
          ;;

        "PERSONAL")
          DEFAULT_BASE_ROUTE="$PERSONAL_BASE_ROUTE"

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ip\]/$PERSONAL_IP/g"
          grep -l "\[server_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_user\]/$PERSONAL_USER/g"
          grep -l "\[server_password\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_password\]/$PERSONAL_PASS/g"

          # Establezco el servidor por defecto.
          if [ "$PERSONAL_SSH" == "s" ]; then
            grep -l "\[server_profile\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_profile\]/server_ssh/g"
          else
            grep -l "\[server_profile\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_profile\]/server_sftp/g"
          fi
          break;
          ;;

        "CUSTOM")
          # Pregunto IP, usuario y contraseña.
          read -r -p "Indica la IP del servidor [xxx.xxx.xxx.xxx]?: " CUSTOM_IP
          CUSTOM_IP=${CUSTOM_IP:-xxx.xxx.xxx.xxx}
          read -r -p "Indica el usuario del servidor [root]?: " CUSTOM_USER
          CUSTOM_USER=${CUSTOM_USER:-root}
          read -r -s -p "Indica la contraseña del servidor [pass]?: " CUSTOM_PASS
          CUSTOM_PASS=${CUSTOM_PASS:-pass}

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ip\]/$CUSTOM_IP/g"
          grep -l "\[server_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_user\]/$CUSTOM_USER/g"
          grep -l "\[server_password\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_password\]/$CUSTOM_PASS/g"

          # Establezco el servidor por defecto.
          grep -l "\[server_profile\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_profile\]/server_sftp/g"
          break;
          ;;

        "CUSTOM SSH")
          # Pregunto IP, usuario, contraseña y ruta de la clave privada.
          read -r -p "Indica la IP del servidor [xxx.xxx.xxx.xxx]?: " CUSTOM_IP
          CUSTOM_IP=${CUSTOM_IP:-xxx.xxx.xxx.xxx}
          read -r -p "Indica el usuario del servidor [root]?: " CUSTOM_USER
          CUSTOM_USER=${CUSTOM_USER:-root}

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ssh_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ssh_ip\]/$CUSTOM_IP/g"
          grep -l "\[ssh_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[ssh_user\]/$CUSTOM_USER/g"

          # Establezco el servidor por defecto.
          grep -l "\[server_profile\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_profile\]/server_ssh/g"
          break;
          ;;

        *)
          echo "Vuelve a intentarlo."
          ;;
      esac
    done

    # Solicito el nombre del directorio remoto.
    read -r -p "Directorio remoto (ruta completa del directorio padre) (ej. ${DEFAULT_BASE_ROUTE}): " DIR_SFTP
    DIR_SFTP=${DIR_SFTP:-$DEFAULT_BASE_ROUTE}

    # Modifico / por \/.
    DIR_SFTP="$(echo $DIR_SFTP | sed -e 's/\//\\\//g')"

    # Establezco la ruta remota.
    grep -l "\[remote_path\]" .vscode/sftp.json|xargs sed -i -e "s/\[remote_path\]/$DIR_SFTP\/$CUSTOM_MACHINE_NAME/g"

  fi
}


################################################################################
# GESTIÓN DE REPOSITORIOS.
################################################################################

# Generación de repositorio remoto.
function git_crear_repo() {
  clear
  echo " "
  echo -e " ${YELLOW}Indica el tipo de servidor a usar:${RESET}"
  linea
  echo " "

  type="GitHub"
  select type in "GitLab" "GitHub" "Gogs"
  do
    case $type in
      "GitLab")
        clear
        select repo in "GitLab.com" "Custom GitLab"
        do
          case $repo in
            "GitLab.com")
              CURRENT_TOKEN=${GITLAB_TOKEN}
              CURRENT_API=${GITLAB_API}
              break;
              ;;

            "Custom GitLab")
              CURRENT_TOKEN=${GITLAB_CUSTOM_TOKEN}
              CURRENT_API=${GITLAB_CUSTOM_API}
              break;
              ;;

            *)
              echo "Vuelve a intentarlo."
              ;;
          esac
        done

        echo " "
        read -r -p "Indica el ID del grupo (ej. 52341225): " GITLAB_NAMESPACE_ID

        # https://docs.gitlab.com/ee/api/projects.html#create-project
        REPOSITORIO_REMOTO=$(curl -f -X POST \
          -H "PRIVATE-TOKEN: ${CURRENT_TOKEN}" -H "Content-Type:application/json" \
          "${CURRENT_API}" -d \
            "{\"name\": \"${CUSTOM_MACHINE_NAME}\", \
            \"visibility\": \"internal\", \
            \"namespace_id\": ${GITLAB_NAMESPACE_ID}, \
            \"analytics_access_level\": \"disabled\", \
            \"auto_devops_enabled\": \"false\", \
            \"builds_access_level\": \"disabled\", \
            \"jobs_enabled\": \"false\", \
            \"container_registry_access_level\": \"disabled\", \
            \"container_registry_enabled\": \"false\", \
            \"forking_access_level\": \"disabled\", \
            \"lfs_enabled\": \"false\", \
            \"merge_method\": \"ff\", \
            \"merge_pipelines_enabled\": \"false\", \
            \"operations_access_level\": \"disabled\", \
            \"packages_enabled\": \"false\", \
            \"snippets_access_level\": \"disabled\", \
            \"snippets_enabled\": \"false\", \
            \"squash_option\": \"always\", \
            \"wiki_access_level\": \"disabled\", \
            \"wiki_enabled\": \"false\" \
            }")
        # Obtengo la dirección del repositorio.
        GIT_REMOTE_URL=$(echo "${REPOSITORIO_REMOTO}" | sed 's/"http_url_to_repo"/\n"http_url_to_repo"/g' | grep -o '"http_url_to_repo":"[^"]*' | grep -o '[^"]*$')
        if [ -z "$GIT_REMOTE_URL" ]; then
          exit 1
        else
          git remote add origin "${GIT_REMOTE_URL}"
        fi
        break;
        ;;

      "GitHub")
        # https://johnsiu.com/blog/github-api-create-repo/
        read -r -p "¿Deseas que el repositorio sea público [n]?: " REPO_GITHUB_PUBLICO
        REPO_GITHUB_PUBLICO=${REPO_GITHUB_PUBLICO:-n}

        if [ "$REPO_GITHUB_PUBLICO" == "n" ]; then
          REQ="{\"name\":\"${CUSTOM_MACHINE_NAME}\", \"private\":true}"
        else
          REQ="{\"name\":\"${CUSTOM_MACHINE_NAME}\"}"
        fi
        REPOSITORIO_REMOTO=$(curl -f -X POST \
          -H "Authorization: token ${GITHUB_TOKEN}" -H "Content-Type:application/json" \
          ${GITHUB_API}/user/repos -d \
          "${REQ}")

        # Obtengo la dirección del repositorio.
        GIT_REMOTE_URL=$(echo "${REPOSITORIO_REMOTO}" | grep '"clone_url"' | cut -d ":" -f2- | cut -d "\"" -f2)
        if [ -z "$GIT_REMOTE_URL" ]; then
          exit 1
        else
          git remote add origin "${GIT_REMOTE_URL}"
        fi
        break;
        ;;

      "Gogs")
        echo " "
        read -r -p "Indica la organización (ej. empresa): " GOGS_ORGANIZACION

        # https://johnsiu.com/blog/github-api-create-repo/
        REQ="{\"name\":\"${CUSTOM_MACHINE_NAME}\", \"description\":\"${CUSTOM_NAME}\", \"private\":true}"
        REPOSITORIO_REMOTO=$(curl -f -X POST \
          -H "Authorization: token ${GOGS_TOKEN}" -H "Content-Type:application/json" \
          ${GOGS_API}/api/v1/admin/users/${GOGS_ORGANIZACION}/repos -d \
          "${REQ}")

        # Obtengo la dirección del repositorio.
        GIT_REMOTE_URL=$(echo "${REPOSITORIO_REMOTO}" | sed 's/"clone_url"/\n"clone_url"/g' | grep -o '"clone_url":"[^"]*' | grep -o '[^"]*$')
        if [ -z "$GIT_REMOTE_URL" ]; then
          exit 1
        else
          git remote add origin "${GIT_REMOTE_URL}"
        fi
        break;
        ;;

      *)
        echo "Vuelve a intentarlo."
        ;;
    esac
  done
}

# Menú con opciones para la conexión al repositorio remoto.
function git_remoto_menu() {
  clear
  echo " "
  echo -e " ${YELLOW}Indica como quieres conectarte:${RESET}"
  linea
  echo " "

  select type in "Crear un repositorio" "Conectarme a repositorio"
  do
    case $type in
      "Crear un repositorio")
        git_crear_repo
        break;
        ;;

      "Conectarme a repositorio")
        echo ""
        read -r -p "Indica la URL del repositorio: " GIT_REMOTE_URL
        git remote add origin "${GIT_REMOTE_URL}"
        break;
        ;;

      *)
        echo "Vuelve a intentarlo."
        ;;
    esac
  done
}

# Iniciar git.
function init_git() {
  # Si ya existe la carpeta .git no hago nada.
  if [ ! -d .git ]; then
    clear
    read -r -p "¿Deseas iniciar git [n]?: " GIT_INIT
    GIT_INIT=${GIT_INIT:-n}

    if [ "$GIT_INIT" == "y" ]; then
      # Compruebo que exista .gitignore.
      if [ ! -f .gitignore ]; then
        read -r -p "No se ha encontrado el archivo .gitignore ¿Deseas descargarlo [y]?: " DOWNLOAD_GITIGNORE
        DOWNLOAD_GITIGNORE=${DOWNLOAD_GITIGNORE:-y}

        if [ "$DOWNLOAD_GITIGNORE" == "y" ]; then
          curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.gitattributes -o .gitattributes
          curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.gitignore_tasks -o .gitignore
        fi
      fi

      # Me aseguro que la rama principal sea la main.
      git init --initial-branch=main

      # Configuración de git.
      git config core.precomposeunicode false
      git config core.autocrlf true
      # git config branch.main.mergeOptions "--squash"
      git config help.autocorrect 50
      git config status.short true
      git config commit.gpgSign true
      echo ""

      read -r -p "Indica el usuario ($(git config user.name)): " GIT_USER
      GIT_USER=${GIT_USER:-$(git config user.name)}

      read -r -p "Indica el correo ($(git config user.email)): " GIT_MAIL
      GIT_MAIL=${GIT_MAIL:-$(git config user.email)}

      git config user.name "${GIT_USER}"
      git config user.email "${GIT_MAIL}"

      # Solicito URL del repositorio remoto.
      read -r -p "¿Deseas inicializar el repositorio remoto [y]?: " GIT_REMOTE
      GIT_REMOTE=${GIT_REMOTE:-y}

      if [ "$GIT_REMOTE" == "y" ]; then
        git_remoto_menu
      fi

      # Pregunto si quiero realizar el primer commit.
      read -r -p "¿Deseas realizar el primer commit [y]?: " GIT_COMMIT
      GIT_COMMIT=${GIT_COMMIT:-y}

      if [ "$GIT_COMMIT" == "y" ]; then

        if [ "$PROJECT_TYPE" == "current" ]; then
          # Commit inicial (todos los archivos).
          git add .
        else
          # Commit inicial (sólo README.md, .gitignore y .vscode).
          git add README.md .gitignore .vscode
        fi
        git commit -m "init: Inicio del proyecto"

        # Creo rama develop y realizo commit completo.
        git switch -c develop

        # Si el tipo de proyecto es "current" no tengo nada que enviar.
        if [ "$PROJECT_TYPE" != "current" ]; then
          git add .
          git commit -m "init: Inicio desarrollo"
        fi

      else
        # Creo la rama develop y me cambio a ella.
        git switch -c develop
      fi

      # Envío todos los cambios al repositorio remoto.
      if [ "$GIT_REMOTE" == "y" ]; then
        # Me cambio a main antes de enviar las ramas.
        git switch main

        # Enviamos todas las ramas.
        git push -u origin --all

        # Me cambio a develop de nuevo.
        git switch develop
      fi
    fi
  fi
}


################################################################################
# GENERADORES.
################################################################################

# Generación de módulo completo.
function create_module() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='module'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Copio los archivos del módulo.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${MODULE_TEMPLATE_GIT}" --force
  else
    rsync -av --progress --stats "$MODULE_TEMPLATE_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Cambio los nombres de los archivos.
  for file in *module_template.*; do mv $file ${file//module_template/$CUSTOM_MACHINE_NAME}; done
  for file in config/*/*module_template*; do mv $file ${file//module_template/$CUSTOM_MACHINE_NAME}; done

  # Descargo archivos de configuración.
  download_other_files

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # Eliminar datos que vinculen el proyecto conmigo.
  eliminar_mi_rastro

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Módulo creado correctamente.${RESET}"
  echo " "
  echo " Recuerda:"
  echo " - Debes revisar los permisos establecidos por defecto en la plantilla."
  echo " - Debes revisar las rutas de los menús establecidos por defecto."
  echo " - Asegúrate de eliminar todos aquellos archivos que no necesites;"
  echo "   recuerda que esta es una plantilla global y puede que te sobren algunas"
  echo "   funcionalidades."
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Generación de módulo para APIs.
function create_module_api() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='module_api'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Copio los archivos del módulo.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${MODULE_TEMPLATE_API_DIR}" --force
  else
    rsync -av --progress --stats "$MODULE_TEMPLATE_API_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Cambio los nombres de los archivos.
  for file in *module_rest_api_calls.*; do mv $file ${file//module_rest_api_calls/$CUSTOM_MACHINE_NAME}; done
  for file in config/*/*module_rest_api_calls*; do mv $file ${file//module_rest_api_calls/$CUSTOM_MACHINE_NAME}; done

  # Descargo archivos de configuración.
  download_other_files

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # Eliminar datos que vinculen el proyecto conmigo.
  eliminar_mi_rastro

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Módulo creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Generación de módulo básico.
function create_module_bas() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='module_bas'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Copio los archivos del módulo.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${MODULE_TEMPLATE_BAS_GIT}" --force
  else
    rsync -av --progress --stats "$MODULE_TEMPLATE_BAS_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Cambio los nombres de los archivos.
  for file in *module_template.*; do mv $file ${file//module_template/$CUSTOM_MACHINE_NAME}; done

  # Descargo archivos de configuración.
  download_other_files

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # Eliminar datos que vinculen el proyecto conmigo.
  eliminar_mi_rastro

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Módulo creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Generación de módulo de importación de datos.
function create_module_import() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='module_import'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Copio los archivos del módulo.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${MODULE_TEMPLATE_IMPORT_GIT}" --force
  else
    rsync -av --progress --stats "$MODULE_TEMPLATE_IMPORT_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Cambio los nombres de los archivos.
  for file in *module_template_import.*; do mv $file ${file//module_template_import/$CUSTOM_MACHINE_NAME}; done
  for file in config/*/*module_template_import*; do mv $file ${file//module_template_import/$CUSTOM_MACHINE_NAME}; done

  # Descargo archivos de configuración.
  download_other_files

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # Eliminar datos que vinculen el proyecto conmigo.
  eliminar_mi_rastro

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Módulo creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Generación de un proyecto completo de Drupal (composer).
function create_drupal() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='drupal'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Copio los archivos del módulo.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${DRUPAL_TEMPLATE_GIT}" --force
  else
    rsync -av --progress --stats "$DRUPAL_TEMPLATE_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Descargo archivos de configuración.
  download_vscode_files
  download_other_files
  config_sftp

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # Genero el archivo .env
  cp .env.example .env

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Inicio git.
  init_git

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Proyecto Drupal descargado correctamente.${RESET}"
  echo " "
  echo " - Ahora debes seguir las instrucciones del archivo README.md para terminar"
  echo "   la instalación."
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Generación de proyecto en blanco.
function create_current() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='current'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Descargo archivos de configuración.
  download_vscode_files
  download_other_files
  config_sftp

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Inicio git.
  init_git

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Script creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Generación de script.
function create_script() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='script'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Copio los archivos del módulo.
  if [ -n "$SCRIPT_TEMPLATE_GIT" ]; then
    npx degit "${SCRIPT_TEMPLATE_GIT}" --force
  else
    rsync -av --progress --stats "$SCRIPT_TEMPLATE_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Cambio los nombres de los archivos.
  for file in *base_script.*; do mv $file ${file//base_script/$CUSTOM_MACHINE_NAME}; done

  # Descargo archivos de configuración.
  download_vscode_files
  download_other_files
  config_sftp

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # Eliminar datos que vinculen el proyecto conmigo.
  eliminar_mi_rastro

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Inicio git.
  init_git

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Script creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Generación de proyecto en blanco.
function create_other() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='other'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Descargo archivos de configuración.
  download_vscode_files
  download_other_files
  config_sftp

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # Eliminar datos que vinculen el proyecto conmigo.
  eliminar_mi_rastro

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Inicio git.
  init_git

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Script creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}

# Añade los archivos de configuración de Lando.
function create_lando() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='lando'

  clear
  show_header

   # Obtengo el nombre del proyecto.
  get_project_name

  # Copio los archivos.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${LANDO_TEMPLATE_GIT}" --force
  else
    rsync -av --progress --stats "$LANDO_TEMPLATE_DIR/" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Descargo archivos de configuración.
  download_vscode_files
  download_other_files
  config_sftp

  # Modifico nombres internos de los ficheros.
  change_internal_strings

  # En MAC me está creado archivos terminados en "-e", así que los elimino.
  find . -name '*.*-e' -type f -delete

  # Inicio git.
  init_git

  # Calculo el tiempo de ejecución y muestro mensaje de final del script.
  end=$(date +%s)
  runtime=$((end-start))

  clear
  echo " "
  linea
  echo -e " ${YELLOW}Se ha añadido Lando a su proyecto.${RESET}"
  echo " "
  echo " - Recuerda que debes configurar la conexión a la base de datos en el archivo"
  echo "   settings.php y revisar las credenciales de la base de datos en .lando.yml."
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  exit 0
}


################################################################################
# COMPROBACIONES PREVIAS.
################################################################################

# Verifico existencia de las variables de entorno.
load_env

# Compruebo parámetros del script.
check_help_param "$@"

# Compruebo que están instaladas todas las herramientas necesarias.
check_dependencies


################################################################################
# CUERPO PRINCIPAL DEL SCRIPT.
################################################################################

# Compruebo si se han pasado argumentos al script.
if [ $# -eq 0 ]; then
  show_usage
else
  case $1 in

    "current")
      create_current
      ;;

    "drupal")
      create_drupal
      ;;

    "lando")
      create_lando
      ;;

    "module")
      create_module
      ;;

    "module_api")
      create_module_api
      ;;

    "module_bas")
      create_module_bas
      ;;

    "module_import")
      create_module_import
      ;;

    "other")
      create_other
      ;;

    "script")
      create_script
      ;;

    *)
      show_usage
      ;;
  esac
fi