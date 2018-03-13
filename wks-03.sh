#!/bin/sh
#
# Workshop Script to sign a PDF document (OnDemand certificate)
# Arguments: <infile> <outfile> <dn> <msisdn> <message> <en|de|fr|it>
# Example: ./wks-03.sh sample.pdf sample-ondemand.pdf 'cn=Hans Mustermann, organizationalUnitName=For test purposes only!, organizationName=Swisscom AG TEST, countryName=CH' 41791234567 'Sign sample.pdf? (#TRANSID#)' en


# Remove existing target file
[ -f "$2" ] && rm -f $2

# Call iText Java application
java -cp ".:./itext/lib/*:./itext/jar/*" com.swisscom.ais.itext.SignPDF -vv -config=./itext/signpdf.properties -type=sign -dn="$3" -midMsisdn=$4 -midMsg="$5" -midLang=$6 -infile=$1 -outfile=$2 -reason="AIS Workshop Test" -location="Zürich"

# Alternative Call with additional SerialNumber-Check: -midSerialNumber=MIDCHEODWD9XJPQ4
# java -cp ".:./itext/lib/*:./itext/jar/*" com.swisscom.ais.itext.SignPDF -vv -config=./itext/signpdf.properties -type=sign -dn="$3" -midMsisdn=$4 -midMsg="$5" -midLang=$6 -midSerialNumber=MIDCHEODWD9XJPQ5 -infile=$1 -outfile=$2 -reason="AIS Workshop Test" -location="Zürich"

