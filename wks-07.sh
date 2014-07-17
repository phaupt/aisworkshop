#!/bin/sh
#
# Workshop Script to produce a batch of detached trusted timestamps
# Arguments: <infile1> <infile2> <infile3>
# Example:   ./wks-07.sh sample.pdf sample2.pdf sample3.pdf

# CLAIMED_ID used to identify to AIS (provided by Swisscom)
CLAIMED_ID="IAM-Test"

# Swisscom AIS credentials
CERT_FILE=$PWD/mycert.crt                       # The certificate that is allowed to access the service
CERT_KEY=$PWD/mycert.key                        # The related key of the certificate
SSL_CA=$PWD/ais-ca-ssl.crt                      # Root CA Certificate (Swisscom Root CA 2)

# Create temporary request
REQUESTID=WKS.$(date +%Y-%m-%dT%H:%M:%S.%N%:z)  # Request ID
TMP=$(mktemp -u /tmp/_tmp.XXXXXX)               # Request goes here
TIMEOUT_CON=90                                  # Timeout of the client connection

# Files to be signed
FILE_1=$1
FILE_2=$2
FILE_3=$3
[ -r "${FILE_1}" ] || ( echo "File to be signed ($FILE_1) missing or not readable" && exit 1 )
[ -r "${FILE_2}" ] || ( echo "File to be signed ($FILE_2) missing or not readable" && exit 1 )
[ -r "${FILE_3}" ] || ( echo "File to be signed ($FILE_3) missing or not readable" && exit 1 )

# Calculate the hash to be signed
DIGEST_VALUE_1=$(openssl dgst -binary -SHA256 $FILE_1 | openssl enc -base64 -A)
DIGEST_VALUE_2=$(openssl dgst -binary -SHA256 $FILE_2 | openssl enc -base64 -A)
DIGEST_VALUE_3=$(openssl dgst -binary -SHA256 $FILE_3 | openssl enc -base64 -A)

# SignRequest
REQ_XML='
  <SignRequest RequestID="'$REQUESTID'" Profile="http://ais.swisscom.ch/1.0"
               xmlns="urn:oasis:names:tc:dss:1.0:core:schema"
               xmlns:dsig="http://www.w3.org/2000/09/xmldsig#"
               xmlns:sc="http://ais.swisscom.ch/1.0/schema">
     <OptionalInputs>
          <ClaimedIdentity>
              <Name>'$CLAIMED_ID'</Name>
          </ClaimedIdentity>
          <SignatureType>urn:ietf:rfc:3161</SignatureType>
          <AdditionalProfile>urn:oasis:names:tc:dss:1.0:profiles:timestamping</AdditionalProfile>
          <AdditionalProfile>http://ais.swisscom.ch/1.0/profiles/batchprocessing</AdditionalProfile>
      </OptionalInputs>
      <InputDocuments>
          <DocumentHash ID="'$FILE_1'">
              <dsig:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
              <dsig:DigestValue>'$DIGEST_VALUE_1'</dsig:DigestValue>
          </DocumentHash>
          <DocumentHash ID="'$FILE_2'">
              <dsig:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
              <dsig:DigestValue>'$DIGEST_VALUE_2'</dsig:DigestValue>
          </DocumentHash>
          <DocumentHash ID="'$FILE_3'">
              <dsig:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
              <dsig:DigestValue>'$DIGEST_VALUE_3'</dsig:DigestValue>
          </DocumentHash>
      </InputDocuments>
  </SignRequest>'

# Store into file
echo "$REQ_XML" > $TMP.req

# Call the service
curl --output $TMP.rsp --silent \
     --request POST --data @$TMP.req \
     --header "Accept: application/xml" --header "Content-Type: application/xml;charset=utf-8" \
     --cert $CERT_FILE --cacert $SSL_CA --key $CERT_KEY \
     --connect-timeout $TIMEOUT_CON \
     https://ais.swisscom.com/AIS-Server/rs/v1.0/sign

# Print Request/Response content
echo ""
[ -f "$TMP.req" ] && cat $TMP.req | xmllint --format -
echo ""
[ -f "$TMP.rsp" ] && cat $TMP.rsp | xmllint --format -
echo ""

# Cleanup
[ -f "$TMP.req" ] && rm $TMP.req
[ -f "$TMP.rsp" ] && rm $TMP.rsp
