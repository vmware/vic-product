# Creating Custom Certificates for Virtual Container Hosts

It's a simple tutorial on how to use openssl to create custom certificates and Certificate Signing Requests (CSR) to be used with Virtual Container Hosts (VCH).

_Bear in mind it's not intended to be a definitive guide, different companies have different needs for their certificates usage._

The certificate requirements for VCH are: 
* an X.509 certificate
* KeyEncipherment 
* DigitalSignature 
* KeyAgreement 
* ServerAuth
    
**Create an RSA Private Key**

`openssl genrsa -des3 -out fullkey.key 2048 pkcs8`
    
**Remove passphrase from key**

`openssl rsa -in fullkey.key -out mykey.key`
    
**Generate CSR**

`openssl req -new -key mykey.key -out server.csr -config template.cnf`
    
###    Optional - generate a self signed certificate
`openssl x509 -req -days 365 -in server.csr -signkey mykey.key -out server.pem`

Full tutorial with examples can be found at [justait.net](http://www.justait.net/2017/11/vic-custom-cert.html)
