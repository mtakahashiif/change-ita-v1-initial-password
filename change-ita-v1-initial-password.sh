#!/bin/bash -x

##############################################################################
# variables

BASE_SCRIPT_NAME=$(basename $0 .sh)

EXASTRO_URL=${EXASTRO_URL:-http://localhost:8080}
EXASTRO_COOKIE_FILE=${TMPDIR:-.}/cookie-${BASE_SCRIPT_NAME}-$$.txt

EXASTRO_USERNAME=${EXASTRO_USERNAME:-administrator}
EXASTRO_INITIAL_PASSWORD=${EXASTRO_INITIAL_PASSWORD:-password}


##############################################################################
# URL encoding (username/password)

function urlencode() {
    python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${1}"
}

EXASTRO_URL_ENCODED_USERNAME=$(urlencode ${EXASTRO_USERNAME})
EXASTRO_URL_ENCODED_INITIAL_PASSWORD=$(urlencode ${EXASTRO_INITIAL_PASSWORD})
EXASTRO_URL_ENCODED_NEW_PASSWORD=$(urlencode ${EXASTRO_NEW_PASSWORD})


##############################################################################
# initialize password

curl \
    --request GET \
    --location \
    --cookie-jar ${EXASTRO_COOKIE_FILE} \
    --output curl-00-${BASE_SCRIPT_NAME}.html \
    ${EXASTRO_URL}'/common/common_auth.php?login&grp=&no='

echo "●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●"

CSRF_TOKEN=$(xmllint --html --xpath 'string(//input[@name="csrf_token"]/@value)' curl-00-${BASE_SCRIPT_NAME}.html)

curl \
    --request POST \
    --location \
    --cookie ${EXASTRO_COOKIE_FILE} \
    --cookie-jar ${EXASTRO_COOKIE_FILE} \
    --header 'Referer: '${EXASTRO_URL}'/common/common_auth.php?login&grp=&no=' \
    --data 'username='${EXASTRO_URL_ENCODED_USERNAME}'&password='${EXASTRO_URL_ENCODED_INITIAL_PASSWORD}'&csrf_token='${CSRF_TOKEN}'&login=%E3%83%AD%E3%82%B0%E3%82%A4%E3%83%B3' \
    ${EXASTRO_URL}'/common/common_auth.php?login&grp=0000000000&no='

echo "●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●"

#curl \
#    --request POST \
#    --location \
#    --cookie ${EXASTRO_COOKIE_FILE} \
#    --cookie-jar ${EXASTRO_COOKIE_FILE} \
#    --header 'Referer: '${EXASTRO_URL}'/default/mainmenu/01_browse.php?grp=0000000000' \
#    --data 'expiry=0&username='${EXASTRO_URL_ENCODED_USERNAME} \
#    ${EXASTRO_URL}'/common/common_change_password_form.php?login&grp=0000000000&no='

echo "●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●"

curl \
    --request POST \
    --location \
    --cookie ${EXASTRO_COOKIE_FILE} \
    --cookie-jar ${EXASTRO_COOKIE_FILE} \
    --header 'Referer: '${EXASTRO_URL}'/common/common_change_password_form.php?login&grp=0000000000&no=\r\n' \
    --data 'old_password='${EXASTRO_URL_ENCODED_INITIAL_PASSWORD}'&new_password='${EXASTRO_URL_ENCODED_NEW_PASSWORD}'&new_password_2='${EXASTRO_URL_ENCODED_NEW_PASSWORD}'&submit=%E5%A4%89%E6%9B%B4&expiry=0' \
    ${EXASTRO_URL}'/common/common_change_password_do.php?grp=0000000000&no='

echo "●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●"


##############################################################################
# test

EXASTRO_API_CREDENTIAL=$(echo -n "${EXASTRO_USERNAME}:${EXASTRO_NEW_PASSWORD}" | base64 | tr '[A-Za-z]' '[N-ZA-Mn-za-m]')

curl \
    --request POST \
    --header "Authorization: ${EXASTRO_API_CREDENTIAL}" \
    --header 'X-Command: INFO' \
    ${EXASTRO_URL}'/default/menu/07_rest_api_ver1.php?no=2100000303' | jq
