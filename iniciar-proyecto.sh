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
DESTINATION_DIR_BASENAME=$(basename "$(pwd)")
CUSTOM_MACHINE_NAME=$(basename "$(pwd)")
DESTINATION_DIR_NAME="$(pwd)"
ACTIVATE_SFTP='n'
PROJECT_TYPE=''
DOWNLOAD_VSCODE=''


################################################################################
# FUNCIONES AUXILIARES.
################################################################################

# Simplemente imprime una lína por pantalla.
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
    source "$(echo ${ENV_FILE})"
  fi
}

# Comprueba todas las dependencias necesarias.
function check_dependencies() {
  # Degit
  package_name='degit'
  if [[ "$(npm list -g $package_name)" =~ "empty" ]]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta DEGIT.${RESET}"
    linea
    exit 2
  fi

  # Rsync.
  if ! [ -x "$(command -v rsync)" ]; then
    clear
    linea
    echo -e " ${RED}No se ha encontrado la herramienta RSYNC.${RESET}"
    linea
    exit 2
  fi

  # CURL.
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

    - module: Genera un módulo de Drupal a partir de la plantilla
      que nosotros hemos definido.
    - module_bas: Genera un módulo de Drupal a partir de la plantilla definida
      para ser usada como módulo básico
    - module_import: Genera un módulo de Drupal a partir de la plantilla
      definida para ser usada como módulo de importación.
    - module_rest_api: Genera un módulo de Drupal a partir de la plantilla
      definada para ser usada como módulo de consumo de API-REST.
    - drupal: Genera un proyecto completo de Drupal a partir de la plantilla que
      hemos definido.
    - script: Genera los archivos necesarios para generar un proyecto de tipo
      script.
    - other: Genera los archivos necesarios para crear cualquier proyecto.

    Si no se especifica ningún parámetro, el script muestra un menú con las
    opciones disponibles.

  "
  linea
}

# Abre la carpeta actual en VSCode.
function open_vscode() {
  echo " "
  read -r -p "¿Deseas abrir el proyecto en VSCode [n]?: " ABRIR_VSCODE
  ABRIR_VSCODE=${ABRIR_VSCODE:-n}

  if [ "$ABRIR_VSCODE" == "y" ]; then
    if command -v code &> /dev/null
    then
      code .
    else
      echo ""
      echo -e " ${RED}No se puede abrir el proyecto: No se encuentra VSCode.${RESET}"
      sleep 5s
    fi
  fi
}

# Comprueba si se ha pasado el parámetro para mostrar la ayuda.
function check_help_param() {
  if [[ ( $* == "--help") || $* == "-h" ]]; then
    show_usage
    exit 0
  fi
}

# Obtiene el directorio de instalación.
function install_dir() {
  read -r -p "¿Crear proyecto en el directorio actual (${DESTINATION_DIR_NAME})? [y]: " INSTALL_HERE
  INSTALL_HERE=${INSTALL_HERE:-y}
  if [ "$INSTALL_HERE" != "y" ]; then
    echo ''
    read -r -p "Directorio de destino del proyecto (ej. D:\WEB\Gloudify\Plantillas) [./]: " DESTINATION_DIR_NAME
    DESTINATION_DIR_NAME=${DESTINATION_DIR_NAME:-./}

    # FIXME Elimino ":" del nombre del directorio y cambio la dirección de las barras.
    DESTINATION_DIR_NAME="$(echo /"$DESTINATION_DIR_NAME"/"$CUSTOM_MACHINE_NAME"/ | sed -e 's/://g' | sed -e 's/\\/\//g')"

    # Creo el directorio si no existe.
    mkdir -p "$DESTINATION_DIR_NAME"
    cd "$DESTINATION_DIR_NAME" || exit 1
  fi
}

# Descarga archivos necesarios desde mi cuenta de github.
function download_github_files_vscode() {
  clear
  echo " "
  echo -e " ${YELLOW}Descargando archivos adicionales desde GitHub (.vscode)...${RESET}"
  linea
  echo " "

  # Descargo los archivos de .vscode (snippets).
  mkdir -p .vscode
  if [ "$PROJECT_TYPE" != "other" ] && [ "$PROJECT_TYPE" != "script" ]; then
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_clases.code-snippets -o .vscode/drupal_clases.code-snippets
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_form.code-snippets -o .vscode/drupal_form.code-snippets
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_js.code-snippets -o .vscode/drupal_js.code-snippets
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_routing.code-snippets -o .vscode/drupal_routing.code-snippets
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/drupal_uses.code-snippets -o .vscode/drupal_uses.code-snippets
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/utils.code-snippets -o .vscode/utils.code-snippets
  fi

  # Descargo el diccionario de cspell.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/cspell.json -o .vscode/cspell.json

  # Descargo los archivos de .vscode (otras configuraciones).
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/extensions.json -o .vscode/extensions.json
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/launch.json -o .vscode/launch.json
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/settings.json -o .vscode/settings.json
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/tasks.json -o .vscode/tasks.json
}

# Descarga archivos necesarios desde mi cuenta de github.
function download_github_files_no_vscode() {
  clear
  echo " "
  echo -e " ${YELLOW}Descargando archivos adicionales desde GitHub (no .vscode)...${RESET}"
  linea
  echo " "

  # Descargo otros componentes de la documentación.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/phpcs.xml -o phpcs.xml
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/phpmd.xml -o phpmd.xml

  # Descargo archivos de git.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.gitattributes -o .gitattributes
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.gitignore_tasks -o .gitignore

  # Descargo configuración WakaTime.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.wakatime-project_tasks -o .wakatime-project

  # Descargo archivos del editor.
  curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.editorconfig -o .editorconfig

  # Descargo el archivo CODE_OF_CONDUCT.md.
  curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/CODE_OF_CONDUCT.md -o CODE_OF_CONDUCT.md

  # Descargo el archivo LICENSE.md.
  curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/LICENSE.md -o LICENSE.md

  # Descargo el archivo README.md y README.
  if [ "$PROJECT_TYPE" != "drupal" ]; then
    curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/README.md -o README.md
    curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/README_anonimo.md -o README_anonimo.md
  fi

  # Descargo el archivo CHANGELOG.md.
  curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/CHANGELOG.md -o CHANGELOG.md

  # Descargo el archivo TODO.md.
  curl -s https://raw.githubusercontent.com/oscarnovasf/md-doc-files/master/files/TODO.md -o TODO.md

  if [ "$PROJECT_TYPE" == "module" ] || [ "$PROJECT_TYPE" == "module_import" ]; then
    # Descargo las librerías necesarias.
    mkdir -p src/lib/general
    curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/MarkdownParser.php > src/lib/general/MarkdownParser.php
  fi

  if [ "$PROJECT_TYPE" == "module_import" ]; then
    # Descargo las librerías propias de este tipo de proyecto.
    curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/FileFunctions.php > src/lib/general/FileFunctions.php
    curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/ResponseFunctions.php > src/lib/general/ResponseFunctions.php
    curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/ValidateFunctions.php > src/lib/general/ValidateFunctions.php
    curl -s https://raw.githubusercontent.com/oscarnovasf/drupal-aux-libraries/master/src/lib/general/StringFunctions.php > src/lib/general/StringFunctions.php
  fi

  # Descargo los archivos de documentación y genero carpeta temporal.
  if [ "$PROJECT_TYPE" != "drupal" ] && [ "$PROJECT_TYPE" != "other" ] && [ "$PROJECT_TYPE" != "script" ]; then
    read -r -p "¿Descargamos también los archivos para generar documentación? [y]: " DOWNLOAD_DOC
    DOWNLOAD_DOC=${DOWNLOAD_DOC:-y}
    if [ "$DOWNLOAD_DOC" == "y" ]; then
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/phpdox.xml > phpdox.xml
      mkdir -p .tmp-doc
      mkdir -p documentation
    fi
  fi
}

# Obtiene el nombre para el proyecto.
function get_project_name() {
  echo ''
  read -r -p "Nombre de máquina para el proyecto [$DESTINATION_DIR_BASENAME]: " CUSTOM_MACHINE_NAME
  CUSTOM_MACHINE_NAME=${CUSTOM_MACHINE_NAME:-$DESTINATION_DIR_BASENAME}

  read -r -p "Nombre para el proyecto [$DESTINATION_DIR_BASENAME]: " CUSTOM_NAME
  CUSTOM_NAME=${CUSTOM_NAME:-$DESTINATION_DIR_BASENAME}
}

# Modifica algunas cadenas con los datos del proyecto.
function change_internal_strings() {
  grep -Rl module_template_import_name .|xargs sed -i -e "s/module_template_import_name/$CUSTOM_NAME/g"
  grep -Rl module_template_import .|xargs sed -i -e "s/module_template_import/$CUSTOM_MACHINE_NAME/g"

  grep -Rl module_template_name .|xargs sed -i -e "s/module_template_name/$CUSTOM_NAME/g"
  grep -Rl module_template .|xargs sed -i -e "s/module_template/$CUSTOM_MACHINE_NAME/g"

  grep -Rl module_rest_api_calls_name .|xargs sed -i -e "s/module_rest_api_calls_name/$CUSTOM_NAME/g"
  grep -Rl module_rest_api_calls .|xargs sed -i -e "s/module_rest_api_calls/$CUSTOM_MACHINE_NAME/g"

  grep -Rl PROYECTO\] .|xargs sed -i -e "s/\[PROYECTO\]/$CUSTOM_MACHINE_NAME/g"
  grep -Rl DESCRIPCION\] .|xargs sed -i -e "s/\[DESCRIPCION\]/$CUSTOM_NAME/g"

  # Descargo de nuevo el archivo tasks.json para evitar los cambios anteriores.
  if [ "$DOWNLOAD_VSCODE" == "y" ]; then
    curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/tasks.json -o .vscode/tasks.json
  fi
}

# Elimina archivos que no son necesarios.
function eliminar_archivos_innecesarios() {
  # Elimino archivos innecesarios.
  if [ "$PROJECT_TYPE" != "drupal" ]; then
    unlink README.md || echo "No se ha podido eliminar README.md"
    unlink .gitignore || echo "No se ha podido eliminar .gitignore"
    unlink .env || echo "No se ha podido eliminar .env"
    # Elimino carpeta innecesaria.
    rm -rf scripts || echo "No se ha podido eliminar ./scripts"
  fi
  if [ "$PROJECT_TYPE" == "drupal" ]; then
    unlink .env || echo "No se ha podido eliminar .env"
  fi
  unlink CHANGELOG.md || echo "No se ha podido eliminar CHANGELOG.md"
  unlink TODO.md || echo "No se ha podido eliminar TODO.md"
  unlink .versionrc || echo "No se ha podido eliminar .versionrc"
  unlink phpcs.xml || echo "No se ha podido eliminar phpcs.xml"
  unlink phpdox.xml || echo "No se ha podido eliminar phpdox.xml"
  unlink phpmd.xml || echo "No se ha podido eliminar phpmd.xml"
  unlink .wakatime-project || echo "No se ha podido eliminar .wakatime-project"

  # Elimino carpetas innecesarias.
  rm -r .tmp-doc || echo "No se ha podido eliminar ./.tmp-doc"
  rm -r documentation || echo "No se ha podido eliminar ./documentation"
  rm -rf .vscode || echo "No se ha podido eliminar ./.vscode"
  rm -rf .gitlab || echo "No se ha podido eliminar ./.gitlab"
  rm -rf .github || echo "No se ha podido eliminar ./.github"
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
    DOMAIN=''
    clear
    echo " "
    echo -e " ${YELLOW}Indica a que servidor te quieres conectar:${RESET}"
    linea
    echo " "

    select server in "SERVIDOR 1" "SERVIDOR 2" "PERSONAL" "CUSTOM" "CUSTOM SSH"
    do
      case $server in
        "SERVIDOR 1")
          # Establezco el servidor por defecto.
          grep -l \"default_server\", .vscode/sftp.json|xargs sed -i -e "s/\"default_server\"/\"server_1\"/g"

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ip\]/$SERVER_1_IP/g"
          grep -l "\[server_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_user\]/$SERVER_1_USER/g"
          grep -l "\[server_password\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_password\]/$SERVER_1_PASS/g"
          break;
          ;;

        "SERVIDOR 2")
          # Establezco el servidor por defecto.
          grep -l \"default_server\", .vscode/sftp.json|xargs sed -i -e "s/\"default_server\"/\"server_2\"/g"

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ip\]/$SERVER_2_IP/g"
          grep -l "\[server_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_user\]/$SERVER_2_USER/g"
          grep -l "\[server_password\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_password\]/$SERVER_2_PASS/g"
          break;
          ;;

        "PERSONAL")
          # Establezco el servidor por defecto.
          grep -l \"default_server\", .vscode/sftp.json|xargs sed -i -e "s/\"default_server\"/\"personal\"/g"

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ip\]/$PERSONAL_IP/g"
          grep -l "\[server_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_user\]/$PERSONAL_USER/g"
          grep -l "\[server_password\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_password\]/$PERSONAL_PASS/g"
          break;
          ;;

        "CUSTOM")
          # Establezco el servidor por defecto.
          grep -l \"default_server\", .vscode/sftp.json|xargs sed -i -e "s/\"default_server\"/\"custom\"/g"

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
          break;
          ;;

        "CUSTOM SSH")
          # Establezco el servidor por defecto.
          grep -l \"default_server\", .vscode/sftp.json|xargs sed -i -e "s/\"default_server\",/\"server_ssh\"/g"

          # Pregunto IP, usuario, contraseña y ruta de la clave privada.
          read -r -p "Indica la IP del servidor [xxx.xxx.xxx.xxx]?: " CUSTOM_IP
          CUSTOM_IP=${CUSTOM_IP:-xxx.xxx.xxx.xxx}
          read -r -p "Indica el usuario del servidor [root]?: " CUSTOM_USER
          CUSTOM_USER=${CUSTOM_USER:-root}
          read -r -p "Indica la ruta a la clave privada [~/.ssh/id_rsa]?: " CUSTOM_KEY_ROUTE
          CUSTOM_KEY_ROUTE=${CUSTOM_KEY_ROUTE:-~/.ssh/id_rsa}
          read -r -s -p "Indica la contraseña de la clave privada [NULL]?: " CUSTOM_PASS

          # Inicializo los datos de conexión con este servidor.
          grep -l "\[server_ssh_ip\]" .vscode/sftp.json|xargs sed -i -e "s/\[server_ssh_ip\]/$CUSTOM_IP/g"
          grep -l "\[ssh_user\]" .vscode/sftp.json|xargs sed -i -e "s/\[ssh_user\]/$CUSTOM_USER/g"
          grep -l "\[local_path_to_id_rsa_file\]" .vscode/sftp.json|xargs sed -i -e "s/\[local_path_to_id_rsa_file\]/$CUSTOM_KEY_ROUTE/g"
          grep -l "\[password_ssh_file\]" .vscode/sftp.json|xargs sed -i -e "s/\[password_ssh_file\]/$CUSTOM_PASS/g"
          break;
          ;;

        *)
          echo "Vuelve a intentarlo."
          ;;
      esac
    done

    # Solicito el nombre del directorio remoto.
    read -r -p "Directorio remoto (ruta completa) (ej. /var/www/vhost/example.com): " DIR_SFTP

    # Modifico / por \/.
    DIR_SFTP="$(echo $DIR_SFTP | sed -e 's/\//\\\//g')"

    # Establezco la ruta remota.
    grep -l "\[remote_path\]" .vscode/sftp.json|xargs sed -i -e "s/\[remote_path\]/$DIR_SFTP\/$CUSTOM_MACHINE_NAME/g"

  fi
}

# Descarga de archivos de .vscode.
function get_vscode() {
  # Descargo archivos de configuración.
  clear
  read -r -p "¿Descargamos configuraciones .vscode? [y]: " DOWNLOAD_VSCODE
  DOWNLOAD_VSCODE=${DOWNLOAD_VSCODE:-y}
  if [ "$DOWNLOAD_VSCODE" == "y" ]; then
    download_github_files_vscode
    download_github_files_no_vscode
    config_sftp
  else
    download_github_files_no_vscode
    if [ -d ".vscode" ]; then
      rm -rf .vscode
    fi
  fi
}

# Generación de repositorio remoto.
function git_crear_repo() {
  clear
  echo " "
  echo -e " ${YELLOW}Indica el tipo de servidor a usar:${RESET}"
  linea
  echo " "

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
        REQ="{\"name\":\"${CUSTOM_MACHINE_NAME}\"}"
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
    read -r -p "¿Deseas iniciar git [y]?: " GIT_INIT
    GIT_INIT=${GIT_INIT:-y}

    if [ "$GIT_INIT" == "y" ]; then
      # Me aseguro que la rama principal sea la main.
      git init --initial-branch=main
      git config core.precomposeunicode false
      git config branch.main.mergeOptions "--squash"
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

        # Commit inicial (sólo README.md, .gitignore y .vscode).
        git add README.md .gitignore .vscode
        git commit -m "init: Inicio del proyecto"

        # Creo rama develop y realizo commit completo.
        git switch -c develop
        git add .
        git commit -m "init: Inicio desarrollo"

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

# Elimina cualquier referencia a mi persona en los archivos.
function eliminar_mi_rastro() {
  clear
  read -r -p "¿Deseas eliminar todo rastro del desarrollador [y]?: " ELIMINAR_RASTRO
  ELIMINAR_RASTRO=${ELIMINAR_RASTRO:-y}

  if [ "$ELIMINAR_RASTRO" == "y" ]; then
    # Elimino README.md y lo cambio por la versión anónima.
    unlink README.md || true
    mv README_anonimo.md README.md

    # Elimino ocurrencias con mi correo.
    grep -Rl "hola@oscarnovas.com" .|xargs sed -i -e "s/hola@oscarnovas.com//g"

    # Elimino ocurrencias con mi nombre o url.
    grep -Rl "Óscar Novás" .|xargs sed -i -e "s/Óscar Novás/Developer/g"
    grep -Rl "oscarnovas.com" .|xargs sed -i -e "s/oscarnovas.com/example.com/g"

    # Vuelvo a descargar el archivo settings.yml.
    if [ "$DOWNLOAD_VSCODE" == "y" ]; then
      curl -s https://raw.githubusercontent.com/oscarnovasf/VSCode-settings/master/.vscode/settings.json -o .vscode/settings.json
    fi
  else
    # Elimino README_anonimo.md
    unlink README_anonimo.md || true
  fi
}

# Generación de módulo completo.
function create_module() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='module'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Obtengo directorio de instalación.
  install_dir

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
  get_vscode

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

  open_vscode

  exit 0
}

# Generación de módulo básico.
function create_module_bas() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='module'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Obtengo directorio de instalación.
  install_dir

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
  get_vscode

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
  echo -e " ${YELLOW}Módulo creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  open_vscode

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

  # Obtengo directorio de instalación.
  install_dir

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
  get_vscode

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
  echo -e " ${YELLOW}Módulo creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  open_vscode

  exit 0
}

# Generación de módulo para APIs.
function create_module_rest_api() {
  # Control de tiempo de ejecución.
  start=$(date +%s)

  PROJECT_TYPE='module_rest_api'

  clear
  show_header

  # Obtengo el nombre del proyecto.
  get_project_name

  # Obtengo directorio de instalación.
  install_dir

  # Copio los archivos del módulo.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${MODULE_TEMPLATE_API_REST_DIR}" --force
  else
    rsync -av --progress --stats "$MODULE_TEMPLATE_API_REST_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Cambio los nombres de los archivos.
  for file in *module_rest_api_calls.*; do mv $file ${file//module_rest_api_calls/$CUSTOM_MACHINE_NAME}; done
  for file in config/*/*module_rest_api_calls*; do mv $file ${file//module_rest_api_calls/$CUSTOM_MACHINE_NAME}; done

  # Descargo archivos de configuración.
  get_vscode

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
  echo -e " ${YELLOW}Módulo creado correctamente.${RESET}"
  linea
  echo " "
  echo -e " Tiempo de ejecución: ${YELLOW}${runtime}s${RESET}"
  echo " "

  open_vscode

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

  # Obtengo directorio de instalación.
  install_dir

  # Copio los archivos del módulo.
  if [ "$DEFAULT_ORIGIN" == "git" ]; then
    npx degit "${DRUPAL_TEMPLATE_GIT}" --force
  else
    rsync -av --progress --stats "$DRUPAL_TEMPLATE_DIR" . --exclude .git --exclude .vscode
  fi

  # Elimino archivos y carpetas innecesarias.
  eliminar_archivos_innecesarios

  # Descargo archivos de configuración.
  get_vscode

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

  open_vscode

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

  # Obtengo directorio de instalación.
  install_dir

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
  get_vscode

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

  open_vscode

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

  # Obtengo directorio de instalación.
  install_dir

  # Descargo archivos de configuración.
  get_vscode

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

  open_vscode

  exit 0
}

# Menú para elegir el tipo de módulo a crear.
function show_menu_module() {
  clear
  echo " "
  echo -e " ${YELLOW}Indica el tipo de módulo a crear...${RESET}"
  linea

  select type in "Módulo completo" "Módulo básico" "Importador" "ApiRest"
  do
    case $type in
      "Módulo completo")
        create_module
        break;
        ;;

      "Módulo básico")
        create_module_bas
        break;
        ;;

      "Importador")
        create_module_import
        break;
        ;;

      "ApiRest")
        create_module_rest_api
        break;
        ;;

      *)
        echo "Vuelve a intentarlo."
        ;;
    esac
  done

  exit 0
}

# Menú principal.
function show_menu() {
  clear
  echo " "
  echo -e " ${YELLOW}Indica si vas a crear un módulo, un script, un Drupal......${RESET}"
  linea

  select type in Módulo Drupal Script Otro
  do
    case $type in
      "Módulo")
        show_menu_module
        break;
        ;;

      "Drupal")
        create_drupal
        break;
        ;;

      "Script")
        create_script
        break;
        ;;

      "Otro")
        create_other
        break;
        ;;

      *)
        echo "Vuelve a intentarlo."
        ;;
    esac
  done

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
  show_menu
  exit 0
else
  case $1 in
    "module")
      create_module
      exit 0
      ;;

    "module_bas")
      create_module_bas
      exit 0
      ;;

    "module_rest_api")
      create_module_rest_api
      exit 0
      ;;

    "module_import")
      create_module_import
      exit 0
      ;;

    "drupal")
      create_drupal
      exit 0
      ;;

    "script")
      create_script
      exit 0
      ;;

    "other")
      create_other
      exit 0
      ;;

    *)
      show_usage
      exit 0
      ;;
  esac
fi