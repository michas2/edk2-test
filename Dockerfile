FROM base/archlinux

RUN pacman -Sy --noconfirm archlinux-keyring pacman
RUN pacman-db-upgrade
RUN pacman -Suy --noconfirm git base-devel python2 nasm iasl
RUN trust extract-compat

WORKDIR /tiano
RUN git clone https://github.com/tianocore/edk2
RUN make -C edk2/BaseTools
ADD edk2.diff edk2.diff
RUN cd edk2; git apply ../edk2.diff

SHELL ["/bin/bash", "-c"]

RUN export WORKSPACE=$PWD;export PACKAGES_PATH=$WORKSPACE/edk2;. edk2/edksetup.sh


RUN echo -e "ACTIVE_PLATFORM = OvmfPkg/OvmfPkgX64.dsc\n\
TARGET                = DEBUG\n\
TARGET_ARCH           = X64\n\
TOOL_CHAIN_CONF       = Conf/tools_def.txt\n\
TOOL_CHAIN_TAG        = GCC49\n\
MAX_CONCURRENT_THREAD_NUMBER = 1\n\
BUILD_RULE_CONF = Conf/build_rule.txt " >edk2/Conf/target.txt
RUN export WORKSPACE=$PWD;export PACKAGES_PATH=$WORKSPACE/edk2;. edk2/edksetup.sh; build

RUN pacman -Sy --noconfirm grub qemu dnsmasq bridge-utils net-tools
RUN grub-mkstandalone -O x86_64-efi -o grub.efi
RUN mkdir /etc/qemu
RUN echo "allow br0" >/etc/qemu/bridge.conf

ADD test.sh test.sh
CMD ./test.sh
