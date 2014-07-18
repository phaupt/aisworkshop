AIS Worskshop - OpenSSL Cheat Sheet
===========

### Signature Decoding

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

Decode detached CMS Signature response into DER; Content of `<Base64Signature>...</Base64Signature>`
```
$ openssl enc -base64 -d -A -in sample.base64 -out sample.der
```

Decode detached signature as PKCS7 (PEM) content
```
$ openssl pkcs7 -inform der -in sample.der -out sample.p7s
```

Extract the x509 certificates from the signature and save as PEM file
```
$ openssl pkcs7 -inform pem -in sample.p7s -out sample_certs.pem -print_certs
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

### Signature Verification

Convert the PKCS7 (PEM) to DER, because this format is supported for both verifications (CMS / TSA)
```
$ openssl pkcs7 -inform pem -in sample.p7s -out sample.der -outform der
```

CMS Signatures: Verify the detached signature against original file
-noverify: don't verify signers certificate to avoid expired certificate error for OnDemand
```
$ openssl cms -verify -inform der -in sample.der -content sample.pdf -out sample.sig -CAfile ais-ca-signature.crt -noverify
```

TSA Timestamp: Verify the detached signature against original file
-token_in: indicates that the input is a DER encoded time stamp token (ContentInfo) instead of a time stamp response
```
openssl ts -verify -data sample.pdf -in sample.der -token_in -CAfile ais-ca-signature.crt
```

Verify the revocation status over OCSP
-no_cert_verify: don't verify the OCSP response signers certificate at all
URL for Timestamp: http://ocsp.swissdigicert.ch/sdcs-tss2
URL for CMS: http://ocsp.swissdigicert.ch/sdcs-saphir2
```
openssl ocsp -CAfile ais-ca-signature.crt -issuer sample_certs.number2.pem -nonce -url http://ocsp.swissdigicert.ch/sdcs-tss2 -cert sample_certs.number1.pem -no_cert_verify  
```

OCSP: CMS Advanced Electronic Signatures revocation-values
object: id-smime-aa-ets-revocationValues (1.2.840.113549.1.9.16.2.24)
```
$ openssl cms -cmsout -noout -inform pem -in sample.p7s -print | grep 1.2.840.113549.1.9.16.2.24
```

OCSP: PDF signature certificate revocation information attribute
object: undefined (1.2.840.113583.1.1.8)
```
$ openssl cms -cmsout -noout -inform pem -in sample.p7s -print | grep 1.2.840.113583.1.1.8
```

TSA: object: id-smime-aa-timeStampToken (1.2.840.113549.1.9.16.2.14)
```
$ openssl cms -cmsout -noout -inform pem -in sample.p7s -print | grep 1.2.840.113549.1.9.16.2.14
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

