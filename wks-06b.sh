#!/bin/sh
#
# Workshop Script to poll a Response ID (asynchronous mode)
# Arguments: <ResponseID>
# Example:   ./wks-06b.sh bb6035f7-6ef4-419c-a6a4-bf2f6fa476aa

# CLAIMED_ID used to identify to AIS (provided by Swisscom)
CLAIMED_ID="AIS-Demo"

# Swisscom AIS credentials
CERT_FILE=~/keys/mycert.crt                       # The certificate that is allowed to access the service
CERT_KEY=~/keys/mycert.key                        # The related key of the certificate
SSL_CA=$PWD/ais-ca-ssl.crt                      # Root CA Certificate (Swisscom Root CA 2)

# Create temporary request
REQUESTID=WKS.$(date +%Y-%m-%dT%H:%M:%S.%N%:z)  # Request ID
TMP=$(mktemp -u /tmp/_tmp.XXXXXX)               # Request goes here
TIMEOUT_CON=90                                  # Timeout of the client connection

# Response ID
RESPONSEID=$1

# SignRequest
REQ_XML='
  <async:PendingRequest Profile="http://ais.swisscom.ch/1.0"
                        xmlns:async="urn:oasis:names:tc:dss:1.0:profiles:asynchronousprocessing:1.0"
                        xmlns="urn:oasis:names:tc:dss:1.0:core:schema" >
    <OptionalInputs>
      <ClaimedIdentity>
        <Name>'$CLAIMED_ID'</Name>
      </ClaimedIdentity>
      <async:ResponseID>'$RESPONSEID'</async:ResponseID>
    </OptionalInputs>
  </async:PendingRequest>'

# Store into file
echo "$REQ_XML" > $TMP.req

# Call the service
curl --output $TMP.rsp --silent \
     --request POST --data @$TMP.req \
     --header "Accept: application/xml" --header "Content-Type: application/xml;charset=utf-8" \
     --cert $CERT_FILE --cacert $SSL_CA --key $CERT_KEY \
     --connect-timeout $TIMEOUT_CON \
     https://ais.swisscom.com/AIS-Server/rs/v1.0/pending

# Print Request/Response content
echo ""
[ -f "$TMP.req" ] && cat $TMP.req | xmllint --format -
echo ""
[ -f "$TMP.rsp" ] && cat $TMP.rsp | xmllint --format -
echo ""

# Cleanup
[ -f "$TMP.req" ] && rm $TMP.req
[ -f "$TMP.rsp" ] && rm $TMP.rsp
