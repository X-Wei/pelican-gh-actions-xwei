FROM debian:stretch

LABEL "com.github.actions.name"="Github Actions for x-wei's pelican blog"
LABEL "com.github.actions.description"="Builds and deploys X-Wei's pelican blogs to GitHub Pages."
LABEL "com.github.actions.icon"="home"
LABEL "com.github.actions.color"="red"

LABEL "Name"="Pelican for X-Wei's blog"
LABEL "Version"="0.0.3"

COPY requirements.txt .

# Main reference: https://github.com/farseerfc/farseerfc/blob/master/.travis.yml
RUN apt-get update && \
    apt-get install -y wget git locales python-pip sed && \
    apt-get install -y ditaa parallel graphviz fonts-noto-cjk && \
    pip install -r requirements.txt && \
    pelican --version

# Install plantuml
RUN wget "http://downloads.sourceforge.net/project/plantuml/plantuml.jar?r=&ts=1424308684&use_mirror=jaist" -O plantuml.jar && \
    mkdir -p /opt/plantuml && \
    cp plantuml.jar /opt/plantuml && \
    echo "#! /bin/sh" > plantuml && \
    echo 'exec java -jar /opt/plantuml/plantuml.jar "$@"' >> plantuml && \
    install -m 755 -D plantuml /usr/bin/plantuml && \
    plantuml -version

# Install opencc
RUN git clone --depth 1 https://github.com/farseerfc/opencc-bin opencc-bin && \
    cd opencc-bin && \
    install -t /usr/bin src/opencc && \
    install -t /usr/lib src/libopencc.so && \
    install -t /usr/lib src/libopencc.so.1.0.0 && \
    install -t /usr/lib src/libopencc.so.2 && \
    mkdir -p /usr/share/opencc && \
    cp data/*.ocd /usr/share/opencc/ && \
    cd .. && \
    opencc --version

# Add locales
# Copied from https://stackoverflow.com/a/38553499
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
RUN locale-gen zh_CN.UTF-8 && \
    locale-gen zh_HK.UTF-8 && \
    locale-gen en_US.UTF-8 && \
    locale-gen ja_JP.UTF-8 && \
    locale -a

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]