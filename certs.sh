mkdir keys



cat > keys/ca.ext <<EOF
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, nonRepudiation, keyCertSign, cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer:always
EOF



cat > keys/user.ext <<EOF
basicConstraints = critical, CA:false
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid, issuer:always
EOF



# Generate root rsa
openssl genrsa -aes256 -passout pass:changeit -out keys/ca-key.pem 2048


# Generate root csr
openssl req -new -key keys/ca-key.pem -passin pass:changeit -subj "/CN=UAT2 Root Certificate Authority/OU=Symphony Team/O=Goldman Sachs/ST=New York/C=US" -out keys/ca-req.pem


# Generate root cer
openssl x509 -req -sha256 -days 3650 -in keys/ca-req.pem -signkey keys/ca-key.pem -passin pass:changeit -out ca-cert.cer -CAcreateserial -CAserial keys/serialnumber.seq -extfile keys/ca.ext

# Mark root cert
openssl x509 -in ca-cert.cer -serial -issuer -subject -dates -noout

# View cer
openssl x509 -in ca-cert.cer -text




# Generate inter rsa
openssl genrsa -aes256 -passout pass:changeit -out keys/int-key.pem 2048


# Generate inter csr
openssl req -new -key keys/int-key.pem -passin pass:changeit -subj "/CN=UAT2 Intermediate Certificate Authority/OU=Symphony Team/O=Goldman Sachs/ST=New York/C=US" -out keys/int-req.pem

# Verify intermediate csr
openssl req -verify -in keys/int-req.pem -text -noout

# Generate inter cer
openssl x509 -req -sha256 -days 3650 -in keys/int-req.pem -CA ca-cert.cer -CAkey keys/ca-key.pem -passin pass:changeit -out int-cert.cer -CAcreateserial -CAserial keys/serialnumber.seq -extfile keys/ca.ext


# Mark intermediate cert
openssl x509 -in int-cert.cer -serial -issuer -subject -dates -noout

# Create certificate chain
cat ca-cert.cer int-cert.cer > ca-cert-chain.cer





# Generate user rsa
openssl genrsa -aes256 -passout pass:changeit -out keys/janedoe-key.pem 2048

# Generate user csr
openssl req -new -key keys/janedoe-key.pem -passin pass:changeit -subj "/CN=janedoe/OU=Symphony Team/O=Goldman Sachs/ST=New York/C=US" -out keys/janedoe-req.pem


# Generate user cer
openssl x509 -req -sha256 -days 3650 -in keys/janedoe-req.pem -CA ca-cert.cer -CAkey keys/ca-key.pem -passin pass:changeit -out janedoe-cert.cer -CAcreateserial -CAserial keys/serialnumber.seq -extfile keys/user.ext


# Generate user PKCS12
openssl pkcs12 -export -out janedoe.p12 -aes256 -in janedoe-cert.cer -inkey keys/janedoe-key.pem -passin pass:changeit -certfile ca-cert-chain.cer -passout pass:changeit


