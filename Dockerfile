FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m crave

ENV DAEMON_RELEASE="v2.5.0.1"
ENV CRAVE_DATA=/home/crave/.crave
    
USER crave

RUN cd /home/crave && \
    mkdir /home/crave/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/CooleRRSA/crave-ng.git craved && \
    cd /home/crave/craved/ && \
    chmod 777 autogen.sh share/genbuild.sh src/leveldb/build_detect_platform && \
    ./autogen.sh && \
    ./configure && \
    make && \
    cd /home/crave/craved/src && \
#    make -f makefile.unix USE_UPNP= && \
    strip craved crave-cli crave-tx && \
    mv craved crave-cli crave-tx /home/crave/bin && \
    rm -rf /home/crave/craved
    
EXPOSE 30104 30105

#VOLUME ["/home/crave/.crave"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    echo "\n# Some aliases to make the crave clients/tools easier to access\nalias craved='/usr/bin/craved -conf=/home/crave/.crave/crave.conf'\nalias crave-cli='/usr/bin/crave-cli -conf=/home/crave/.crave/crave.conf'\n\n[ ! -z \"\$TERM\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc && \
    echo "Crave (CRAVE) Cryptocoin Daemon\n\nUsage:\n crave-cli help - List help options\n crave-cli listtransactions - List Transactions\n\n" > /etc/motd && \
    chmod 755 /home/crave/bin/craved && \
    chmod 755 /home/crave/bin/crave-cli && \
    chmod 755 /home/crave/bin/crave-tx && \
    mv /home/crave/bin/craved /usr/bin/craved && \
    mv /home/crave/bin/crave-cli /usr/bin/crave-cli && \
    mv /home/crave/bin/crave-tx /usr/bin/crave-tx && \
    ln -s /usr/bin/craved /usr/bin/crave

ENTRYPOINT ["/entrypoint.sh"]

CMD ["craved"]
