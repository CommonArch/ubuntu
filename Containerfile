ARG CORE_BRANCH=main

FROM ubuntu:rolling

ARG CORE_BRANCH=main
ARG VARIANT=general
ARG DESKTOP=nogui

RUN apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -yq linux-generic dracut systemd systemd-container

RUN if [ "$DESKTOP" == gnome ]; then apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -yq ubuntu-desktop; \
  elif [ "$DESKTOP" == plasma ]; then apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -yq kubuntu-desktop; fi

RUN if [ "$VARIANT" == nvidia ]; then apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -yq linux-modules-nvidia-570-generic nvidia-driver-570; fi

RUN apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -yq grub2-common

RUN apt-get update; DEBIAN_FRONTEND=noninteractive apt-get install -yq python3-yaml python3-click python3-fasteners skopeo umoci jq libnotify-bin wget

COPY overlays/common /

ENV CORE_BRANCH=$CORE_BRANCH

RUN wget -O /usr/bin/system https://github.com/CommonArch/system-cli/raw/refs/heads/$CORE_BRANCH/usr/bin/system; chmod 755 /usr/bin/system; \
    mkdir -p /usr/lib/dracut/modules.d/10commonarch; \
    wget -O /usr/lib/dracut/modules.d/10commonarch/handle-update.sh https://github.com/CommonArch/system-cli/raw/refs/heads/$CORE_BRANCH/usr/lib/dracut/modules.d/10commonarch/handle-update.sh; chmod 755 /usr/lib/dracut/modules.d/10commonarch/handle-update.sh; \
    wget -O /usr/lib/dracut/modules.d/10commonarch/module-setup.sh https://github.com/CommonArch/system-cli/raw/refs/heads/$CORE_BRANCH/usr/lib/dracut/modules.d/10commonarch/module-setup.sh; chmod 755 /usr/lib/dracut/modules.d/10commonarch/module-setup.sh

RUN systemctl enable commonarch-update-cleanup
RUN systemctl enable --global commonarch-update-check
