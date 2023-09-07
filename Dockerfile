ARG BASE=ubuntu:20.04
FROM ${BASE}

LABEL maintainer="Steven Leong<howsenpl@hotmail.com>"
LABEL org.opencontainers.image.source=https://github.com/howsen82/docker-omada

ARG OMADA_VER=5.9.31
ARG OMADA_TAR="Omada_SDN_Controller_v${OMADA_VER}_Linux_x64.tar.gz"
ARG OMADA_URL="https://static.tp-link.com/upload/software/2023/202303/20230321/${OMADA_TAR}"
ARG ARCH=amd64

RUN |2 ARCH=amd64 INSTALL_VER=5.9 /bin/sh -c /install.sh &&  /log4j_patch.sh &&  rm /install.sh /log4j_patch.s

COPY entrypoint-5.x.sh /entrypoint.sh
COPY healthcheck.sh install.sh log4j_patch.sh /

# install omada controller (instructions taken from install.sh); then create a user & group and set the appropriate file system permissions
RUN /install.sh && rm /install.sh

WORKDIR /opt/tplink/EAPController/lib
EXPOSE 8088 8043 8843 27001/udp 27002 29810/udp 29811 29812 29813 29814
HEALTHCHECK --start-period=5m CMD /healthcheck.sh
VOLUME ["/opt/tplink/EAPController/data","/opt/tplink/EAPController/work","/opt/tplink/EAPController/logs"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/java", "-server", "-Xms128m", "-Xmx1024m", "-XX:MaxHeapFreeRatio=60", "-XX:MinHeapFreeRatio=30", "-XX:+HeapDumpOnOutOfMemoryError", "-XX:HeapDumpPath=/opt/tplink/EAPController/logs/java_heapdump.hprof", "-Djava.awt.headless=true", "-cp", "/opt/tplink/EAPController/lib/*::/opt/tplink/EAPController/properties:", "com.tplink.smb.omada.starter.OmadaLinuxMain"]
