# Dependencies  templates/extra
* Secret luna-client-certs
```console
apiVersion: v1
data:
  CLIENT.pem:
  CLIENTKey.pem: 
kind: Secret
metadata:
  name: luna-client-certs
  namespace: luna-client-proxy
type: Opaque

```
* Secret chrystoki-config  - https://thalesdocs.com/gphsm/luna/6.3/docs/network/Content/administration/config/config-file_summary.htm
```console
Chrystoki2 = {
   LibUNIX = /usr/safenet/lunaclient/lib/libCryptoki2.so;
   LibUNIX64 = /usr/safenet/lunaclient/lib/libCryptoki2_64.so;
}

Luna = {
  DefaultTimeOut = 500000;
  PEDTimeout1 = 100000;
  PEDTimeout2 = 200000;
  PEDTimeout3 = 20000;
  KeypairGenTimeOut = 2700000;
  CloningCommandTimeOut = 300000;
  CommandTimeOutPedSet = 720000;
}

CardReader = {
  RemoteCommand = 1;
}

Misc = {
   ProtectedAuthenticationPathFlagStatus = 1; # 0 (default): no challenge request •1: check for Crypto Officer challenge request •2: check for Crypto User challenge request
   PE1746Enabled = 0;
   ValidateHost = 0;
   ToolsDir = /usr/safenet/lunaclient/bin;
   PartitionPolicyTemplatePath = /usr/safenet/lunaclient/data/partition_policy_templates;
   ProtectedAuthenticationPathFlagStatus = 0;
   MutexFolder = /usr/safenet/lunaclient/lock;
   PluginModuleDir = /usr/safenet/lunaclient/plugins;
}
LunaSA Client = {
   ReceiveTimeout = 20000;
   SSLConfigFile = /usr/safenet/lunaclient/bin/openssl.cnf;
   ClientPrivKeyFile = /usr/safenet/lunaclient/cert/client/CLIENTKey.pem;
   ClientCertFile = /usr/safenet/lunaclient/cert/client/CLIENT.pem;
   ServerCAFile = /usr/safenet/lunaclient/cert/server/CAFile.pem;
   NetClient = 1;
   TCPKeepAlive = 1;
   ServerName00 = <HSM IP>;
   ServerPort00 = 1792;
   ServerHtl00 = 0;
}
Secure Trusted Channel = {
   ClientTokenLib = /usr/safenet/lunaclient/lib/libSoftToken.so;
   SoftTokenDir = /usr/safenet/lunaclient/configData/token;
   ClientIdentitiesDir = /usr/safenet/lunaclient/data/client_identities;
   PartitionIdentitiesDir = /usr/safenet/lunaclient/data/partition_identities;
}

```

# Dockerfile lunaclient-proxy:10.7.2

```console
FROM python:3.11.4-slim-bullseye as builder
ARG BUILD_ID
LABEL stage=builder
LABEL build=$BUILD_ID
ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update \
&& apt-get install --no-install-recommends --assume-yes \
build-essential \
sudo curl wget nano mc net-tools \
openssl ca-certificates git-core tzdata \
opensc opensc-pkcs11 pcscd libccid libpq5 swig \
libtool libcrypto++ libp11-3 libengine-pkcs11-openssl \
libssl-dev libseccomp-dev \
libengine-pkcs11-openssl libp11-dev libpcsclite-dev libusb-dev \
libsqlite3-dev libbotan-2-dev zlib1g-dev \
libpq-dev musl-dev \
autoconf automake pkg-config \
botan sqlite3 \
llvm gcc cmake
	
RUN pip install --upgrade pip

RUN git clone https://github.com/OpenSC/libp11 && \
    cd libp11 && \
    ./bootstrap && \
    ./configure && \
    make -j8 && make install

RUN git clone https://github.com/SUNET/pkcs11-proxy && \
    cd pkcs11-proxy && \
    cmake . && \
    make && \
    make install

FROM python:3.11.4-slim-bullseye

ENV LANG=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

LABEL vendor=Sargas\ Incorporated \
maintainer="Sorin <sorin@sargas.ro>" \
hsm.is-beta= \
hsm.is-production="" \
hsm.version="0.0.1" \
hsm.release-date="2023-06-12"

USER root

# install base packages -> todo: review minimum requirements
RUN apt-get update \
&& apt-get install --no-install-recommends --assume-yes \
sudo curl wget nano mc net-tools \
openssl opensc opensc-pkcs11 \
pcscd libccid \
&& rm -rf /var/lib/apt/lists/*


# copy only precompiled pkcs11 library from builder stage
COPY --from=builder /usr/local/bin/pkcs11-daemon /usr/local/bin
COPY --from=builder /usr/local/lib/libpkcs11-proxy.so /usr/local/lib



# Set user and group for luna client
ARG user=luna
ARG group=luna
ARG uid=1000
ARG gid=1000
RUN groupadd -g ${gid} ${group}
RUN useradd -u ${uid} -g ${group} -s /bin/sh -m ${user} 

COPY safenet /usr/safenet
RUN mkdir /usr/safenet/lunaclient/config
COPY Chrystoki.conf /usr/safenet/lunaclient/config/
ENV ChrystokiConfigurationPath=/usr/safenet/lunaclient/config
ENV PATH="/usr/safenet/lunaclient/bin:${PATH}"

# Change permissions for luna client
RUN chown -R ${user}:${group} /usr/safenet


USER luna

ENV PORT=5000
ENV PKCS11_DAEMON_SOCKET=tcp://127.0.0.1:5000

EXPOSE 5000
CMD ["pkcs11-daemon", "/usr/safenet/lunaclient/lib/libCryptoki2_64.so"]
```
