#!/usr/bin/env bash

set -eu

# Move execution to realpath of script
cd $(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

########################################
## Command Line Options
########################################
declare CONFIG_FILE=""
for switch in $@; do
    case $switch in
        *)
            CONFIG_FILE="${switch}"
            if [[ "${CONFIG_FILE}" =~ ^.+$ ]]; then
              if [[ ! -f "${CONFIG_FILE}" ]]; then
                >&2 echo "Error: Invalid config file given"
                exit -1
              fi
            fi
            ;;
    esac
done
if [[ $# < 1 ]]; then
  echo "An argument was not specified:"
  echo " <config_filename>    Specify config file to use to override default configs."
  echo ""
  echo "Exampe: install-magento.sh config_stage.json"
  exit;
fi






# Config Files
CONFIG_DEFAULT="config_default.json"
CONFIG_OVERRIDE="${CONFIG_FILE}"
[[ "${CONFIG_OVERRIDE}" != "" && -f ${CONFIG_OVERRIDE} ]] || CONFIG_OVERRIDE=""


# Read merged config JSON files
declare CONFIG_NAME=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.CONFIG_NAME')
declare SITE_HOSTNAME=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SITE_HOSTNAME')
declare SITE_ADMIN_DOMAIN=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SITE_ADMIN_DOMAIN')

declare ENV_ROOT_DIR=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.ENV_ROOT_DIR')
declare MAGENTO_ROOT_DIR=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.MAGENTO_ROOT_DIR')
declare SITE_ROOT_DIR=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SITE_ROOT_DIR')

declare MAGENTO_COMPOSER_PROJECT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.MAGENTO_COMPOSER_PROJECT')
declare MAGENTO_REL_VER=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.MAGENTO_REL_VER')
declare MAGENTO_DEPLOY_MODE=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.MAGENTO_DEPLOY_MODE')
declare MAGENTO_FPC=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.MAGENTO_FPC')
declare MAGENTO_BACKEND_FRONTNAME=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.MAGENTO_BACKEND_FRONTNAME')
declare MAGENTO_DEMONOTICE=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.MAGENTO_DEMONOTICE')

declare REDIS_OBJ_HOST=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_OBJ_HOST')
declare REDIS_OBJ_PORT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_OBJ_PORT')
declare REDIS_OBJ_DB=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_OBJ_DB')
declare REDIS_SES_HOST=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_SES_HOST')
declare REDIS_SES_PORT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_SES_PORT')
declare REDIS_SES_DB=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_SES_DB')
declare REDIS_SES_MAX_CONCURRENCY=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_SES_MAX_CONCURRENCY')
declare REDIS_SES_BREAK_AFTER_FRONT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_SES_BREAK_AFTER_FRONT')
declare REDIS_SES_BREAK_AFTER_ADMIN=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_SES_BREAK_AFTER_ADMIN')
declare REDIS_SES_DISABLE_LOCKING=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_SES_DISABLE_LOCKING')
declare REDIS_FPC_HOST=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_FPC_HOST')
declare REDIS_FPC_PORT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_FPC_PORT')
declare REDIS_FPC_DB=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.REDIS_FPC_DB')

declare VARNISH_HOST=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.VARNISH_HOST')
declare VARNISH_PORT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.VARNISH_PORT')

declare SEARCH_ENGINE=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SEARCH_ENGINE')
declare ELASTIC_HOST=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.ELASTIC_HOST')
declare ELASTIC_PORT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.ELASTIC_PORT')
declare ELASTIC_ENABLE_AUTH=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.ELASTIC_ENABLE_AUTH')
declare ELASTIC_USERNAME=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.ELASTIC_USERNAME')
declare ELASTIC_PASSWORD=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.ELASTIC_PASSWORD')
declare ELASTIC_INDEX_PREFIX=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.ELASTIC_INDEX_PREFIX')

declare SHOULD_SETUP_SAMPLE_DATA=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SHOULD_SETUP_SAMPLE_DATA')
declare SHOULD_SETUP_VENIA_SAMPLE_DATA=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SHOULD_SETUP_VENIA_SAMPLE_DATA')
declare SHOULD_RUN_CUSTOM_SCRIPT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SHOULD_RUN_CUSTOM_SCRIPT')
declare SHOULD_USE_CUSTOM_ADMIN_DOMAIN=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SHOULD_USE_CUSTOM_ADMIN_DOMAIN')
declare SHOULD_SETUP_TFA=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.SHOULD_SETUP_TFA')
declare VENIA_SAMPLE_DATA_VERSION=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.VENIA_SAMPLE_DATA_VERSION')
declare VENIA_SAMPLE_DATA_FROM=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.VENIA_SAMPLE_DATA_FROM')

declare PHP_MEMORY_LIMIT=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.PHP_MEMORY_LIMIT')

declare LOCK_DB_PREFIX=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.LOCK_DB_PREFIX')
declare N98_MAGERUN2_BIN=$(cat ${CONFIG_DEFAULT} ${CONFIG_OVERRIDE} | jq -s add | jq -r '.N98_MAGERUN2_BIN')

if [[ "$SHOULD_SETUP_VENIA_SAMPLE_DATA" == "true" && "$SHOULD_SETUP_SAMPLE_DATA" == "true" ]]; then
    echo "----: PWA sample data cannot be installed with Magento Sample Data, you need to set 'SHOULD_SETUP_SAMPLE_DATA' to 'false' before installing Venia Sample Data"
    exit -1
fi

# Dynamic Variables
COMPOSER_AUTH_USER=$(composer config -g http-basic.repo.magento.com | jq -r '.username')
COMPOSER_AUTH_PASS=$(composer config -g http-basic.repo.magento.com | jq -r '.password')

DB_HOST=$(echo $(grep "^\s*host " ~/.my.cnf | cut -d= -f2 | perl -p -e 's/^\s*(.*?)\s*$/$1/'))
DB_USER=$(echo $(grep "^\s*user " ~/.my.cnf | cut -d= -f2 | perl -p -e 's/^\s*(.*?)\s*$/$1/'))
DB_PASS=$(echo $(grep "^\s*password " ~/.my.cnf | cut -d= -f2 | perl -p -e 's/^\s*(.*?)\s*$/$1/'))
DB_NAME=$(echo $(grep "^\s*database " ~/.my.cnf | cut -d= -f2 | perl -p -e 's/^\s*(.*?)\s*$/$1/'))

BASE_URL="https://${SITE_HOSTNAME}"

BACKEND_FRONTNAME="admin"
if [[ "${MAGENTO_BACKEND_FRONTNAME}" == "" ]]; then
  echo "----: Generating Backend Frontname"
  BACKEND_FRONTNAME="admin_$(printf "%s%s%s" \
      $(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z0-9' | fold -w 6 | head -n1))"
  echo "BACKEND_FRONTNAME: ${BACKEND_FRONTNAME}"
else
  echo "----: Overriding Generated Backend Frontname From Config"
  BACKEND_FRONTNAME="${MAGENTO_BACKEND_FRONTNAME}"
fi

ADMIN_USER="admin_$(printf "%s%s%s" \
    $(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z0-9' | fold -w 6 | head -n1))"
ADMIN_EMAIL=demouser@example.lan
ADMIN_FIRST=Demo
ADMIN_LAST=User
ADMIN_PASS="$(printf "%s%s%s%s%s" \
    $(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1) \
    $(cat /dev/urandom | env LC_CTYPE=C tr -dc '0-9' | fold -w 2 | head -n1) \
    $(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 11 | head -n1) \
    $(cat /dev/urandom | env LC_CTYPE=C tr -dc '0-9' | fold -w 2 | head -n1) \
    $(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n1))"

# Setup Directories
mkdir -p ${MAGENTO_ROOT_DIR}
# Moving to Magento Install Directory
echo "----: Move to Magento Install Directory ${MAGENTO_ROOT_DIR}"
cd ${MAGENTO_ROOT_DIR}

# Deploy install files
export COMPOSER_MEMORY_LIMIT=${PHP_MEMORY_LIMIT}
composer config -g http-basic.repo.magento.com ${COMPOSER_AUTH_USER} ${COMPOSER_AUTH_PASS}
echo "----: Creating composer project"
composer create-project \
  --repository-url https://repo.magento.com/ ${MAGENTO_COMPOSER_PROJECT} ${MAGENTO_ROOT_DIR} ${MAGENTO_REL_VER} \
  -s stable \
  --no-interaction \
  --prefer-dist \
  --no-dev \
  --no-install
echo
composer config allow-plugins.magento/* true
composer config allow-plugins.laminas/laminas-dependency-plugin true
composer config allow-plugins.cweagans/composer-patches true
composer config allow-plugins.dealerdirect/phpcodesniffer-composer-installer true
composer config -a http-basic.repo.magento.com ${COMPOSER_AUTH_USER} ${COMPOSER_AUTH_PASS}
composer install
chmod +x bin/magento

# Conditionally install sample data
if [[ "$SHOULD_SETUP_SAMPLE_DATA" == "true" ]]; then
  echo "----: Including Magento Sample Data"
  php -d memory_limit=${PHP_MEMORY_LIMIT} bin/magento sampledata:deploy
fi


# Run installation
echo "----: Magento setup:install"
MAGENTO_INSTALL_OPTIONS=$(cat <<SHELL_COMMAND
  --backend-frontname=${BACKEND_FRONTNAME} \
  --admin-user=${ADMIN_USER} \
  --admin-firstname=${ADMIN_FIRST} \
  --admin-lastname=${ADMIN_LAST} \
  --admin-email=${ADMIN_EMAIL} \
  --admin-password=${ADMIN_PASS} \
  --db-host=${DB_HOST} \
  --db-user=${DB_USER} \
  --db-password=${DB_PASS} \
  --db-name=${DB_NAME} 
SHELL_COMMAND
)

if [[ "${MAGENTO_REL_VER}" =~ ^2\.4\. && "${SEARCH_ENGINE}" != "mysql" ]]; then
  echo "----: Magento setup:install (with elasticsearch)"
MAGENTO_INSTALL_OPTIONS=$(cat <<SHELL_COMMAND
${MAGENTO_INSTALL_OPTIONS} \
  --search-engine=${SEARCH_ENGINE} \
  --elasticsearch-host=${ELASTIC_HOST} \
  --elasticsearch-port=${ELASTIC_PORT} \
  --elasticsearch-enable-auth=${ELASTIC_ENABLE_AUTH} \
  --elasticsearch-username=${ELASTIC_USERNAME} \
  --elasticsearch-password=${ELASTIC_PASSWORD} \
  --elasticsearch-index-prefix=${ELASTIC_INDEX_PREFIX}
SHELL_COMMAND
)
fi

MAGENTO_INSTALL_OPTIONS=$(cat <<SHELL_COMMAND
${MAGENTO_INSTALL_OPTIONS} \
  --session-save=redis \
  --session-save-redis-host=${REDIS_SES_HOST} \
  --session-save-redis-port=${REDIS_SES_PORT} \
  --session-save-redis-db=${REDIS_SES_DB} \
  --session-save-redis-max-concurrency=${REDIS_SES_MAX_CONCURRENCY} \
  --session-save-redis-break-after-frontend=${REDIS_SES_BREAK_AFTER_FRONT} \
  --session-save-redis-break-after-adminhtml=${REDIS_SES_BREAK_AFTER_ADMIN} \
  --session-save-redis-disable-locking=${REDIS_SES_DISABLE_LOCKING} \
  --cache-backend=redis \
  --cache-backend-redis-server=${REDIS_OBJ_HOST} \
  --cache-backend-redis-port=${REDIS_OBJ_PORT} \
  --cache-backend-redis-db=${REDIS_OBJ_DB} \
  --page-cache=redis \
  --page-cache-redis-server=${REDIS_FPC_HOST} \
  --page-cache-redis-port=${REDIS_FPC_PORT} \
  --page-cache-redis-db=${REDIS_FPC_DB} \
  --http-cache-hosts=${VARNISH_HOST}:${VARNISH_PORT} \
  --lock-db-prefix=${LOCK_DB_PREFIX} \
  --magento-init-params=MAGE_MODE=${MAGENTO_DEPLOY_MODE}
SHELL_COMMAND
)

# Display command
echo "php -d memory_limit=${PHP_MEMORY_LIMIT} bin/magento setup:install ${MAGENTO_INSTALL_OPTIONS}"
# Execute bin/magento setup:install
php -d memory_limit=${PHP_MEMORY_LIMIT} bin/magento setup:install ${MAGENTO_INSTALL_OPTIONS}

# Configure Magento
echo "----: Magento Configuration Settings"

if [[ ! "${MAGENTO_REL_VER}" =~ ^2\.4\. && "${SEARCH_ENGINE}" != "mysql" ]]; then
  echo "----: Magento Configuration Settings (elasticsearch)"
  bin/magento config:set --lock-env catalog/search/engine ${SEARCH_ENGINE}
  bin/magento config:set --lock-env catalog/search/${SEARCH_ENGINE}_server_hostname ${ELASTIC_HOST}
  bin/magento config:set --lock-env catalog/search/${SEARCH_ENGINE}_server_port ${ELASTIC_PORT}
  bin/magento config:set --lock-env catalog/search/${SEARCH_ENGINE}_enable_auth ${ELASTIC_ENABLE_AUTH}
  bin/magento config:set --lock-env catalog/search/${SEARCH_ENGINE}_username ${ELASTIC_USERNAME}
  bin/magento config:set --lock-env catalog/search/${SEARCH_ENGINE}_password ${ELASTIC_PASSWORD}
  bin/magento config:set --lock-env catalog/search/${SEARCH_ENGINE}_index_prefix ${ELASTIC_INDEX_PREFIX}
fi

if [[ "${MAGENTO_FPC}" == "varnish" ]]; then

  # Use Varnish for FPC
  bin/magento config:set --lock-env system/full_page_cache/caching_application 2
  bin/magento config:set --lock-env system/full_page_cache/ttl 604800
  
else

  # Use Built-In for FPC
  bin/magento config:set --lock-env system/full_page_cache/caching_application 1
  bin/magento config:set --lock-env system/full_page_cache/ttl 604800
fi

bin/magento config:set --lock-env web/seo/use_rewrites 1
bin/magento config:set --lock-env web/secure/use_in_frontend 1
bin/magento config:set --lock-env web/secure/use_in_adminhtml 1

bin/magento config:set --lock-env web/unsecure/base_url ${BASE_URL}/
bin/magento config:set --lock-env web/secure/base_url ${BASE_URL}/
# bin/magento config:set --lock-env web/unsecure/base_static_url ${BASE_URL}/static/
# bin/magento config:set --lock-env web/secure/base_static_url ${BASE_URL}/static/
# bin/magento config:set --lock-env web/unsecure/base_media_url ${BASE_URL}/media/
# bin/magento config:set --lock-env web/secure/base_media_url ${BASE_URL}/media/

bin/magento config:set --lock-env dev/front_end_development_workflow/type server_side_compilation
bin/magento config:set --lock-env dev/template/allow_symlink 0
bin/magento config:set --lock-env dev/template/minify_html 0
bin/magento config:set --lock-env dev/js/merge_files 0
bin/magento config:set --lock-env dev/js/minify_files 0
bin/magento config:set --lock-env dev/js/enable_js_bundling 0
bin/magento config:set --lock-env dev/css/merge_css_files 0
bin/magento config:set --lock-env dev/css/minify_files 0

if [[ "${MAGENTO_DEPLOY_MODE}" == "production" ]]; then
  
  # Signing of static assets
  bin/magento config:set --lock-env dev/static/sign 1
  
  # Set all indexers to rebuild from cron
  bin/magento indexer:set-mode schedule
  
else
  
  # Signing of static assets
  bin/magento config:set --lock-env dev/static/sign 0
  
  # Set all indexers to rebuild from cron
  bin/magento indexer:set-mode realtime
fi

bin/magento config:set --lock-env admin/security/session_lifetime 28800

if [[ "${MAGENTO_DEMONOTICE}" == "1" ]]; then
  echo "----: Enabling Magento Demo Notice Banner"
  
  # Use MageRun2 to set env.php custom config value as config path is not identified
  ${N98_MAGERUN2_BIN} config:env:set system.default.design.head.demonotice 1
fi

# Conditionally install Venia sample data for PWA
if [[ "$SHOULD_SETUP_VENIA_SAMPLE_DATA" == "true" ]]; then

  echo "----: Installing Venia Sample Data for PWA"
  
  echo "----: Running setup:upgrade"
  bin/magento setup:upgrade
  
  if [[ "${VENIA_SAMPLE_DATA_FROM}" == "GITHUB" ]]
  then
    echo "----: Installing Venia Sample Data from GITHUB script"
      curl -LsS https://raw.githubusercontent.com/magento/pwa-studio/v${VENIA_SAMPLE_DATA_VERSION}/packages/venia-concept/deployVeniaSampleData.sh | bash -s -- --yes
  elif [[ "${VENIA_SAMPLE_DATA_FROM}" == "ARTIFACT" ]]
  then
    echo "----: Installing Venia Sample Data from ARTIFACT via composer"
    SCRIPT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
    mkdir -p ${MAGENTO_ROOT_DIR}/artifacts
    unzip ${SCRIPT_DIR}/venia-sample-data-modules-main.zip -d ${MAGENTO_ROOT_DIR}/artifacts
    composer config --no-interaction --ansi repositories.venia-sample-data-modules-main path "./artifacts/venia-sample-data-modules-main/*"
    composer config minimum-stability dev
    composer require --no-interaction --ansi magento/venia-sample-data
  else
    echo "----: Installing Venia Sample Data from repo.magento.com via composer"
    # https://magento.github.io/pwa-studio/venia-pwa-concept/install-sample-data/
    composer config --no-interaction --ansi repositories.venia-sample-data composer https://repo.magento.com
    composer require --no-interaction --ansi magento/venia-sample-data:0.0.1
  fi
  
  echo "----: Running setup:upgrade"
  bin/magento setup:upgrade
  echo "----: Reindexing"
  bin/magento indexer:status
  bin/magento indexer:reset
  bin/magento indexer:reindex
  echo "----: Finished Reindex"
  
fi




# Conditionally set custom admin domain
ADMIN_BASE_URL="https://${SITE_HOSTNAME}"
if [[ "$SHOULD_USE_CUSTOM_ADMIN_DOMAIN" == "true" ]]; then

  echo "----: Running admin at separate domain"
  # Enforce base_url redirect
  bin/magento config:set --lock-env web/url/redirect_to_base 1

  # Admin
  ADMIN_BASE_URL="https://${SITE_ADMIN_DOMAIN}"
  bin/magento config:set --lock-env admin/url/custom ${ADMIN_BASE_URL}/
  bin/magento config:set --lock-env admin/url/use_custom 1
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/secure/base_url ${ADMIN_BASE_URL}/
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/unsecure/base_url ${ADMIN_BASE_URL}/
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/secure/base_link_url ${ADMIN_BASE_URL}/
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/unsecure/base_link_url ${ADMIN_BASE_URL}/
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/unsecure/base_static_url ${ADMIN_BASE_URL}/static/
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/secure/base_static_url ${ADMIN_BASE_URL}/static/
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/unsecure/base_media_url ${ADMIN_BASE_URL}/media/
  bin/magento config:set --scope=store --scope-code=admin --lock-env web/secure/base_media_url ${ADMIN_BASE_URL}/media/

fi



echo "----: Import configs"
bin/magento app:config:import
echo "----: Enable cache and flush"
bin/magento cache:enable
bin/magento cache:flush

echo "----: Magento Deployment Mode"
bin/magento deploy:mode:set ${MAGENTO_DEPLOY_MODE}
bin/magento cache:flush

# Two Factor Auth Support
TFA_SECRET=""
OTPAUTH_URL=""
if [[ "${SHOULD_SETUP_TFA}" == "true" ]]; then
  echo "----: Initialize TFA for admin user"
  
  # Generate random secret for OTP use
  SECRET=$(pwgen -1 -s -n 32)
  # Detect Python version available - base32 encode and strip padding
  if command -v python3 >/dev/null 2>&1; then
    TFA_SECRET=$(python3 -c "import base64; print(base64.b32encode(bytearray('${SECRET}', 'ascii')).decode('utf-8'))" | sed 's/=*$//')
  else
    TFA_SECRET=$(python -c "import base64; print base64.b32encode('${SECRET}')" | sed 's/=*$//')
  fi
  # Build otpauth URI
  OTPAUTH_URL="otpauth://totp/${SITE_HOSTNAME}:${ADMIN_USER}?secret=${TFA_SECRET}&issuer=${SITE_HOSTNAME}&algorithm=SHA1&digits=6&period=30"
  
  # Set Google TFA as the forced provider
  bin/magento config:set twofactorauth/general/force_providers google

  # Set the TFA secret for admin user
  bin/magento security:tfa:google:set-secret "${ADMIN_USER}" "${TFA_SECRET}"
fi

# Create SymLink for site root
echo "----: Creating Site Root Symlink to Magento Root"
ln -s ${MAGENTO_ROOT_DIR} ${SITE_ROOT_DIR}

# Save admin credentials as indicator that script completed successfully
echo "----: Saving Magento Credentials"
ADMIN_CREDENTIALS=$(cat <<CONTENTS_HEREDOC
{
  "install_path": "${MAGENTO_ROOT_DIR}",
  "base_url": "${BASE_URL}",
  "admin_url": "${ADMIN_BASE_URL}/${BACKEND_FRONTNAME}",
  "admin_user": "${ADMIN_USER}",
  "admin_pass": "${ADMIN_PASS}",
  "admin_tfa_secret": "${TFA_SECRET}",
  "admin_tfa_optauth_url": "${OTPAUTH_URL}"
}
CONTENTS_HEREDOC
)
echo "${ADMIN_CREDENTIALS}" > ${ENV_ROOT_DIR}/magento_admin_credentials.json

cat ${ENV_ROOT_DIR}/magento_admin_credentials.json | jq .

echo "----: TFA OTP code script"
echo '
oathtool --time-step-size=30 --window=0 --totp=sha1 --base32 "$(cat magento_admin_credentials.json | jq -r .admin_tfa_secret)"
' > ${ENV_ROOT_DIR}/magento_tfa_otp_code.sh
chmod +x ${ENV_ROOT_DIR}/magento_tfa_otp_code.sh


# Custom script
if [[ "${SHOULD_RUN_CUSTOM_SCRIPT}" == "true" ]]; then
  # CONFIG_NAME
  # SHOULD_RUN_CUSTOM_SCRIPT
  echo "----: Execute custom config script (custom_script_${CONFIG_NAME}.sh)"
  # Move execution to realpath of script
  cd $(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
  custom_script_${CONFIG_NAME}.sh
fi

echo "----: Magento Install Finished"
