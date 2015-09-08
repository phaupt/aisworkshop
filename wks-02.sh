#!/bin/sh
#
# Workshop Script to sign a PDF document (ElDI-V static certificate)
# Arguments: <infile> <outfile>
# Example:   ./wks-02.sh sample.pdf sample-static.pdf

# Remove existing target file
[ -f "$2" ] && rm -f $2

# Call iText Java application
java -cp ".:./itext/lib/*:./itext/jar/*" com.swisscom.ais.itext.SignPDF -vv -config=./itext/signpdf.properties -type=sign -infile=$1 -outfile=$2 -reason="AIS Workshop Test" -location="Zürich"
