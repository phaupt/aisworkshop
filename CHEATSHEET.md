AIS Worskshop - OpenSSL Cheat Sheet
===========

### Decode Signature Object

Calculate a digest and get the Base64 encoded value
```
openssl dgst -binary -SHA256 sample.pdf | openssl enc -base64 -A
DrUko7j8wA2NdscB5AMNUMGbvb0HbgZGZR9oaKWU9gE=
```

Display raw hex digest value (little endian); Content of `<DigestValue>...</DigestValue>`
```
$ echo DrUko7j8wA2NdscB5AMNUMGbvb0HbgZGZR9oaKWU9gE= | base64 --decode | hexdump -C
00000000  0e b5 24 a3 b8 fc c0 0d  8d 76 c7 01 e4 03 0d 50  |..$......v.....P|
00000010  c1 9b bd bd 07 6e 06 46  65 1f 68 68 a5 94 f6 01  |.....n.Fe.hh....|
00000020
```

Decode detached CMS Signature response into DER; Content of `<Base64Signature Type="urn:ietf:rfc:3369">...</Base64Signature>`
```
$ openssl enc -base64 -d -A -in sample.base64 -out sample.der
```

Decode detached signature as PKCS7 (PEM) content
```
$ openssl pkcs7 -inform der -in sample.der -out sample.p7s
```

Extract the x509 certificates from the signature and save as PEM file
```
$ openssl pkcs7 -inform pem -in sample.p7s -out sample_certs.pem -print_certs > /dev/null 2>&1
```

Split the certificate list into separate certificates of number 0..x
```
$ awk -v tmp=sample_certs.number -v c=-1 '/-----BEGIN CERTIFICATE-----/{inc=1;c++} inc {print > (tmp c ".pem")}/---END CERTIFICATE-----/{inc=0}' sample_certs.pem
```

Check Cert Details of level0..x 
```
$ openssl x509 -subject -issuer -serial -startdate -enddate -nameopt utf8 -nameopt sep_comma_plus -noout -in sample_certs.number1.pem
subject= C=ch,O=Swisscom,OU=Digital Certificate Service,CN=Swisscom TSA 3
issuer= C=ch,O=Swisscom,OU=Digital Certificate Services,CN=Swisscom TSS CA 2
serial=A83D8AFE62CD91C2420D7BA3D3EBE7C9
notBefore=Aug  7 12:23:58 2012 GMT
notAfter=Jan 11 09:55:58 2022 GMT
```

Look for the OCSP URI
```
$ openssl x509 -in sample_certs.number1.pem -ocsp_uri -noout
http://ocsp.swissdigicert.ch/sdcs-tss2
```

Get Public Key Modulus from the x509 Cert
```
$ openssl x509 -noout -modulus -in sample_certs.number1.pem
```

Extract signed SignatureData from ASN1 Dump
```
$ openssl cms -cmsout -noout -inform pem -in sample.p7s -print | sed -n '/signerInfos:/,/unsignedAttrs:/p'
```

Convert the PKCS7 (PEM) to DER, because this format is supported for both verifications (CMS / TSA)
```
$ openssl pkcs7 -inform pem -in sample.p7s -out sample.der -outform der > /dev/null 2>&1
```

### Revocation Information (OCSP/CRL)

Decode OCSP Object; Content of `<sc:OCSP>...</sc:OCSP>`
```
$ echo -n <data> | openssl enc -base64 -d -A -out ocsp.der
```

Decode CRL Object; Content of `<sc:CRL>...</sc:CRL>`
```
$ echo -n <data> | openssl enc -base64 -d -A -out crl.crl
```

ASN1 Dump of CRL information
```
$ openssl asn1parse -inform DER -in crl.crl
```

ASN1 Dump of OCSP information
```
$ openssl asn1parse -inform DER -in ocsp.der
```

