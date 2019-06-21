#!/bin/sh

#
# Workshop Script to produce a detached signature (OnDemand certificate)
# Arguments: <infile> <outfile> <dn> <msisdn> <message> <en|de|fr|it>
# Example: ./wks-06a.sh sample.pdf sample-ondemand.pdf 'cn=Hans Mustermann, organizationalUnitName=For test purposes only!, organizationName=Swisscom AG TEST, countryName=CH' 41791234567 'Sign sample.pdf? (#TRANSID#)' en

# CLAIMED_ID used to identify to AIS (provided by Swisscom)
CLAIMED_ID="AIS-Demo:OnDemand-Advanced"

# Swisscom AIS credentials
CERT_FILE=~/keys/mycert.crt                       # The certificate that is allowed to access the service
CERT_KEY=~/keys/mycert.key                        # The related key of the certificate
SSL_CA=$PWD/ais-ca-ssl.crt                      # Root CA Certificate (Swisscom Root CA 2)

# Create temporary request
REQUESTID=WKS.$(date +%Y-%m-%dT%H:%M:%S.%N%:z)  # Request ID
TMP=$(mktemp -u /tmp/_tmp.XXXXXX)               # Request goes here
TIMEOUT_CON=90                                  # Timeout of the client connection

# File to be signed
FILE=$1
[ -r "${FILE}" ] || ( echo "File to be signed ($FILE) missing or not readable" && exit 1 )

# Target PKCS7 file
PKCS7_RESULT=$2
[ -f "$PKCS7_RESULT" ] && rm -f "$PKCS7_RESULT"

# OnDemand Arguments
ONDEMAND_DN=$3
MID_MSISDN=$4
MID_MSG=$5
MID_LANG=$6

# Calculate the hash to be signed
DIGEST_VALUE=$(openssl dgst -binary -SHA256 $FILE | openssl enc -base64 -A)

# SignRequest
REQ_XML='
  <SignRequest RequestID="'$REQUESTID'" Profile="http://ais.swisscom.ch/1.1"
               xmlns="urn:oasis:names:tc:dss:1.0:core:schema"
               xmlns:dsig="http://www.w3.org/2000/09/xmldsig#"
               xmlns:sc="http://ais.swisscom.ch/1.0/schema">
     <OptionalInputs>
          <ClaimedIdentity>
              <Name>'$CLAIMED_ID'</Name>
          </ClaimedIdentity>
          <AdditionalProfile>urn:oasis:names:tc:dss:1.0:profiles:asynchronousprocessing</AdditionalProfile>
          <AdditionalProfile>http://ais.swisscom.ch/1.0/profiles/ondemandcertificate</AdditionalProfile>    
	  <AdditionalProfile>http://ais.swisscom.ch/1.1/profiles/redirect</AdditionalProfile>
          <sc:CertificateRequest>
              <sc:DistinguishedName>'$ONDEMAND_DN'</sc:DistinguishedName>
              <sc:StepUpAuthorisation>
                  <sc:Phone>
                      <sc:MSISDN>'$MID_MSISDN'</sc:MSISDN>
                      <sc:Message>'$MID_MSG'</sc:Message>
                      <sc:Language>'$MID_LANG'</sc:Language>
                  </sc:Phone>
              </sc:StepUpAuthorisation>
          </sc:CertificateRequest>
          <SignatureType>urn:ietf:rfc:3369</SignatureType>
          <AddTimestamp Type="urn:ietf:rfc:3161"/>
          <sc:AddRevocationInformation Type="BOTH"/>
      </OptionalInputs>
      <InputDocuments>
          <DocumentHash>
              <dsig:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
              <dsig:DigestValue>'$DIGEST_VALUE'</dsig:DigestValue>
          </DocumentHash>
      </InputDocuments>
  </SignRequest>'

# Store into file
echo "$REQ_XML" > $TMP.req

# Call the service
curl -k --output $TMP.rsp --silent \
     --request POST --data @$TMP.req \
     --header "Accept: application/xml" --header "Content-Type: application/xml;charset=utf-8" \
     --cert $CERT_FILE --cacert $SSL_CA --key $CERT_KEY \
     --connect-timeout $TIMEOUT_CON \
     https://ais.swisscom.com/AIS-Server/rs/v1.0/sign

# SOAP/XML Parse Result
sed -n -e 's/.*<RFC3161TimeStampToken>\(.*\)<\/RFC3161TimeStampToken>.*/\1/p' $TMP.rsp > $TMP.sig.base64 

# Decode signature if present
#openssl enc -base64 -d -A -in $TMP.sig.base64 -out $TMP.sig.der
# Save PKCS7 content to target
#openssl pkcs7 -inform der -in $TMP.sig.der -out $PKCS7_RESULT

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
