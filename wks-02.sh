#!/bin/sh
#
# Workshop Script to sign a PDF document (timestamp only)
# Arguments: <infile> <outfile>
# Example:   ./wks-02.sh sample.pdf sample-timestamp.pdf

# Remove existing target file
[ -f "$2" ] && rm -f $2

# Call iText Java application
java -cp ".:./itext/lib/*:./itext/jar/*" com.swisscom.ais.itext.SignPDF -d -config=./itext/signpdf.properties -type=timestamp -infile=$1 -outfile=$2
