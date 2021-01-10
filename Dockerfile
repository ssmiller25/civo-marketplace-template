FROM alpine:3.12.1

RUN apk --update add --no-cache make && \
  apk --update add --no-cache curl && \
  apk --update add --no-cache jq

RUN curl -sLS https://dl.get-arkade.dev | sh
RUN  arkade get kubectl && \
  mv /root/.arkade/bin/kubectl /usr/local/bin/ 
RUN  arkade get krew && \
  mv /root/.arkade/bin/krew /usr/local/bin/ 
RUN arkade get civo && \
  mv /root/.arkade/bin/civo /usr/local/bin/ 
# Install Kuttl
#RUN kubectl krew install kuttl



