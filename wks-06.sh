#!/bin/sh
#
# Workshop Script to sign a PDF document (OnDemand certificate)
# Arguments: <infile> <outfile> <dn> <msisdn> <message> <en|de|fr|it>
# Example:   ./wks-06.sh sample.pdf sample-ondemand.pdf "cn=Hans Muster,o=ACME,c=CH" 41797895164 "Sign sample.pdf ?" en

# Remove existing target file
[ -f "$2" ] && rm -f $2

# Call iText Java application
java -cp ".:./itext/lib/*:./itext/jar/*" com.swisscom.ais.itext.SignPDF -d -config=./itext/signpdf.properties -type=sign -dn="$3" -msisdn=$4 -msg="$5" -lang=$6 -infile=$1 -outfile=$2 -reason="AIS Workshop Test" -location="Zürich"
