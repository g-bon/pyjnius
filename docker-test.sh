#!/bin/bash

set -e

OUT=$(dirname $(pwd))/docker-test-out

installer() {
    echo "RUN echo \\"
    case "$1" in
        openjdk-7-jdk)
            echo "&& apt-add-repository -y ppa:openjdk-r/ppa \\"
            echo "&& apt-get update \\"
            echo "&& apt-get install -y openjdk-7-jdk"
            ;;
        openjdk-8-jdk)
            if [ "$2" = "trusty" ]; then
                echo "&& apt-add-repository -y ppa:openjdk-r/ppa \\"
            fi
            echo "&& apt-get update \\"
            echo "&& apt-get install -y openjdk-8-jdk"
            ;;
        oracle-java8-installer)
            echo "&& apt-add-repository -y ppa:webupd8team/java \\"
            echo "&& apt-get update \\"
            echo "&& echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \\"
            echo "&& apt-get install -y oracle-java8-installer"
            ;;
        *)
            echo "I don't know how to build $1" >&2;
            exit 1
            ;;
    esac
}

do_test() {
    UBUNTU="$1"
    JDK="$2"
    DOCKER_TAG="pyjnius-$UBUNTU-$JDK"
    if [ -e "$OUT/$DOCKER_TAG.ok" ] && [ -z "$3" ]; then
        echo "SKIP: $DOCKER_TAG"
        return 0
    fi

cat > Dockerfile <<HERE
FROM ubuntu:${UBUNTU}
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y software-properties-common python-software-properties

RUN apt-get update \
 && apt-get install -y build-essential cython git python-six python-nose python-matplotlib-dbg cython3 python3-six python3-nose python3-matplotlib-dbg


RUN apt-get install -y vim  \
 && sed -i 's,^#force_color_prompt,force_color_prompt,' ~/.bashrc

RUN apt-get install -y ipython ipython3 && ipython profile create && echo "c.TerminalInteractiveShell.confirm_exit = False" >> ~/.ipython/profile_default/ipython_config.py

$(installer "$JDK" "$UBUNTU") && apt-get install -y ant

ADD . /pyjnius

CMD /pyjnius/.test.sh /out/$DOCKER_TAG
HERE

    docker build -t "$DOCKER_TAG" .
    docker run --rm -itv $OUT:/out "$DOCKER_TAG" || echo "FAILED"
}

if [ "$*" ]; then
    do_test "$@" force
else
    do_test trusty openjdk-7-jdk
    do_test trusty openjdk-8-jdk
    
    do_test xenial openjdk-7-jdk
    do_test xenial openjdk-8-jdk
    do_test xenial oracle-java8-installer
    
    do_test artful openjdk-8-jdk
    do_test artful oracle-java8-installer
fi
