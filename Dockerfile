FROM ubuntu:14.04

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6 \
    && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y build-essential ca-certificates curl libffi-dev libreadline6-dev \
        libssl-dev libyaml-dev locales zlib1g-dev ruby2.2 ruby2.2-dev
RUN gem install bundler
WORKDIR /app/
ADD Gemfile* /app/
RUN bundle config --global silence_root_warning 1
RUN bundle install

RUN apt-get install -y python

ADD . /app
RUN ln -s /app/start-crawl /usr/sbin/start-crawl
RUN ln -s /app/list-spiders /usr/sbin/list-spiders
