#!/bin/sh
#
# Workshop Script to retrieve a detached timestamp token
# Arguments: <infile> <SHA256|SHA384|SHA512> <outfile>
# Example:   ./wks-01.sh sample.pdf SHA256 sample.p7s

# CUSTOMER used to identify to AIS (provided by Swisscom)
CUSTOMER="IAM-Test"

# Swisscom AIS credentials
CERT_FILE=$PWD/mycert.crt                       # The certificate that is allowed to access the service
CERT_KEY=$PWD/mycert.key                        # The related key of the certificate

# CA certificate file (in PEM format) for curl to verify the peer
SSL_CA=$PWD/ais-ca-ssl.crt

PWD=$(dirname $0)                               # Get the Path of the script

# Create temporary request
INSTANT=$(date +%Y-%m-%dT%H:%M:%S.%N%:z)        # Define instant and request id
REQUESTID=AIS.TEST.$INSTANT
TMP=$(mktemp -u /tmp/_tmp.XXXXXX)               # Request goes here
TIMEOUT_CON=90                                  # Timeout of the client connection

# File to be signed
FILE=$1
[ -r "${FILE}" ] || ( echo "File to be signed ($FILE) missing or not readable" && exit 1 )

# Digest method to be used
DIGEST_METHOD=$2
case "$DIGEST_METHOD" in
  SHA256)
    DIGEST_ALGO='http://www.w3.org/2001/04/xmlenc#sha256' ;;
  SHA384)
    DIGEST_ALGO='http://www.w3.org/2001/04/xmldsig-more#sha384' ;;
  SHA512)
    DIGEST_ALGO='http://www.w3.org/2001/04/xmlenc#sha512' ;;
esac

# Target PKCS7 file
PKCS7_RESULT=$3
[ -f "$PKCS7_RESULT" ] && rm -f "$PKCS7_RESULT"

# Calculate the hash to be signed
DIGEST_VALUE=$(openssl dgst -binary -$DIGEST_METHOD $FILE | openssl enc -base64 -A)

# SignRequest
REQ_XML='
  <SignRequest RequestID="'$REQUESTID'" Profile="http://ais.swisscom.ch/1.0"
               xmlns="urn:oasis:names:tc:dss:1.0:core:schema"
               xmlns:dsig="http://www.w3.org/2000/09/xmldsig#"
               xmlns:sc="http://ais.swisscom.ch/1.0/schema">
     <OptionalInputs>
          <ClaimedIdentity>
              <Name>'$CUSTOMER'</Name>
          </ClaimedIdentity>
          <SignatureType>urn:ietf:rfc:3161</SignatureType>
          <AdditionalProfile>urn:oasis:names:tc:dss:1.0:profiles:timestamping</AdditionalProfile>
          <sc:AddRevocationInformation Type="BOTH"/>
      </OptionalInputs>
      <InputDocuments>
          <DocumentHash>
              <dsig:DigestMethod Algorithm="'$DIGEST_ALGO'"/>
              <dsig:DigestValue>'$DIGEST_VALUE'</dsig:DigestValue>
          </DocumentHash>
      </InputDocuments>
  </SignRequest>'

# Store into file
echo "$REQ_XML" > $TMP.req

# Call the service
curl --write-out '%{http_code}\n' --silent \
     --request POST --data @$TMP.req \
     --header "Accept: application/xml" --header "Content-Type: application/xml;charset=utf-8" \
     --cert $CERT_FILE --cacert $SSL_CA --key $CERT_KEY \
     --output $TMP.rsp \
     --connect-timeout $TIMEOUT_CON \
     https://ais.swisscom.com/AIS-Server/rs/v1.0/sign

# SOAP/XML Parse Result
sed -n -e 's/.*<RFC3161TimeStampToken>\(.*\)<\/RFC3161TimeStampToken>.*/\1/p' $TMP.rsp > $TMP.sig.base64 

# Decode signature if present
openssl enc -base64 -d -A -in $TMP.sig.base64 -out $TMP.sig.der
# Save PKCS7 content to target
openssl pkcs7 -inform der -in $TMP.sig.der -out $PKCS7_RESULT

# Print Request/Response content
echo ""
[ -f "$TMP.req" ] && cat $TMP.req | xmllint --format -
echo ""
[ -f "$TMP.rsp" ] && cat $TMP.rsp | xmllint --format -
echo ""

# Cleanup
[ -f "$TMP.req" ] && rm $TMP.req
[ -f "$TMP.rsp" ] && rm $TMP.rsp
[ -f "$TMP.sig.base64" ] && rm $TMP.sig.base64
[ -f "$TMP.sig.der" ] && rm $TMP.sig.der
