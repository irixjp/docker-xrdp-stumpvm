FROM fedora:24
MAINTAINER @irix_jp

RUN dnf install -y crudini \
 && crudini --set /etc/dnf/dnf.conf main fastestmirror true

RUN dnf clean all \
 && dnf --setopt=deltarpm=false update -y \
 && dnf --setopt=deltarpm=false install -y git sbcl make autoconf texinfo \
 && dnf --setopt=deltarpm=false install -y passwd which sudo supervisor xrdp \
 && dnf clean all

RUN cd /root && curl -O http://beta.quicklisp.org/quicklisp.lisp
ADD install-quicklisp.lisp /root
RUN cd /root && sbcl --script install-quicklisp.lisp

RUN cd /root \
 && git clone https://github.com/stumpwm/stumpwm.git \
 && cd stumpvm \
 && autoconf \
 && ./configure \
 && make \
 && make install \

RUN dnf --setopt=deltarpm=false install -y vim firefox emacs ibus-mozc \
 && dnf clean all

ADD supervisord.d/xrdp.ini  /etc/supervisord.d
ADD skel/                   /etc/skel/

RUN useradd fedora \
 && echo fedora:fedora | chpasswd \
 && echo "fedora   ALL=(ALL)   NOPASSWD: ALL" >> /etc/sudoers

EXPOSE 3389
CMD supervisord -n
