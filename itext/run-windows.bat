@echo off
REM SUPPORTED DN ATTRIBUTES:
REM commonName/cn 
REM countryName/c 
REM emailAddress 
REM givenName 
REM localityName/l 
REM organizationalUnitName/ou 
REM organizationName/o 
REM serialNumber 
REM stateOrProvinceName/st 
REM surname/sn 

chcp 1252>NUL

echo Bitte warten. Bitte führen Sie den Prozess auf Ihrem Mobile weiter.

java -cp ".;./lib/*;./jar/*" com.swisscom.ais.itext.SignPDF -v -config=signpdf.properties -type=sign -infile=sample.pdf -outfile=signed-ondemand-mid.pdf -dn="cn=Hans Muster,c=CH,emailAddress=Hans.Muster@swisscom.com,givenName=Hans,surname=Muster" -reason="Signiert von Hans Muster" -location="Zürich, Schweiz" -contact=Hans.Muster@swisscom.com -msisdn=41791234567 -lang=de -msg="Möchten Sie das PDF signieren?"

pause
