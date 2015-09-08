#!/bin/sh
#
# Workshop Script to sign a PDF document (timestamp only)
# Arguments: <infile> <outfile>
# Example:   ./wks-08.sh sample.pdf sample-timestamp.pdf

# Remove existing target file
[ -f "$2" ] && rm -f $2

# Call iText Java application
java -cp ".:./itext/lib/*:./itext/jar/*" com.swisscom.ais.itext.SignPDF -vv -config=./itext/signpdf.properties -type=timestamp -infile=$1 -outfile=$2 -reason="AIS Workshop Test" -location="Zürich"
