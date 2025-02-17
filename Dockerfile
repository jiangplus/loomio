#
# Warning: this image is designed to be used with docker-compose as
# instructed at https://github.com/loomio/loomio-deploy
#
# It is not a standalone image.
#
FROM ruby:2.7.6
ENV REFRESHED_AT 2020-12-22
ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV MALLOC_ARENA_MAX=2

RUN gem update --system
RUN apt-get update -qq && apt-get install -y build-essential sudo apt-utils

# for activestorage previews
RUN apt-get install -y imagemagick ffmpeg mupdf libvips libvips42 libvips-dev libpng-dev libjpeg-dev libwebp-dev libheif-dev

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for node
# RUN apt-get install -y python python-dev python-pip python-virtualenv

# install node
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN apt-get install -y nodejs

RUN gem install bundler

# RUN mkdir /loomio
WORKDIR /loomio
ADD . /loomio
RUN bundle install

WORKDIR /loomio/vue
RUN npm install
RUN npm run build
WORKDIR /loomio

EXPOSE 3000

# source the config file and run puma when the container starts
CMD /loomio/docker_start.sh
