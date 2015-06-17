FROM ubuntu:14.04
MAINTAINER nabezokodaikon

ENV DEBIAN_FRONTEND noninteractive

# リポジトリを日本語向けに変更します。
RUN sed -e 's;http://archive;http://jp.archive;' -e 's;http://us\.archive;http://jp.archive;' -i /etc/apt/sources.list
RUN [ ! -x /usr/bin/wget ] && apt-get update && \
    apt-get install -y wget && \
    touch /.get-wget
RUN wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | apt-key add - && \
    wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | apt-key add - && \
    wget https://www.ubuntulinux.jp/sources.list.d/trusty.list -O /etc/apt/sources.list.d/ubuntu-ja.list

# システムを更新します。
RUN apt-get update && \
    apt-get dist-upgrade -y
RUN apt-get upgrade

# タイムゾーンを日本標準時刻に設定します。
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN echo 'Asia/Tokyo' > /etc/timezone

# ハードウェアクロックをローカルタイムに設定します。
RUN sed -e 's;UTC=yes;UTC=no;' -i /etc/default/rcS

# java をインストールします。
RUN apt-get install -q -y openjdk-7-jre-headless
RUN apt-get clean

RUN wget https://github.com/takezoe/gitbucket/releases/download/3.3/gitbucket.war -P /opt

RUN mkdir /root/.gitbucket
RUN echo "#`date`" > /root/.gitbucket/gitbucket.conf
RUN echo gravatar=true >> /root/.gitbucket/gitbucket.conf
RUN echo ssh=false >> /root/.gitbucket/gitbucket.conf
RUN ldap_authentication=false >> /root/.gitbucket/gitbucket.conf
RUN notification=false >> /root/.gitbucket/gitbucket.conf
RUN allow_account_registration=false >> /root/.gitbucket/gitbucket.conf
RUN base_url=https\://133.242.167.158\:58080 >> /root/.gitbucket/gitbucket.conf
RUN echo base_url=https\\://`ip addr show eth0 | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | grep -o [0-9].*`\\:58080 >> /root/.gitbucket/gitbucket.conf

VOLUME /root/.gitbucket
EXPOSE 8080

CMD ["java", "-jar", "/opt/gitbucket.war"]

