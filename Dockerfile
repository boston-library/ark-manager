FROM ruby:3.1.5

MAINTAINER bbarber@bpl.org

ENV LANG=C.UTF-8 \
    BUNDLER_VERSION=2.5.9

RUN apt-get update -qq \
  && apt-get install -y build-essential apt-utils postgresql-client libpq-dev

RUN gem update --system --no-document --quiet --silent
RUN gem install bundler:$BUNDLER_VERSION --no-document --quiet --silent

RUN mkdir /ark-manager-app

WORKDIR /ark-manager-app

COPY Gemfile Gemfile.* /ark-manager-app/

RUN bundle config build.nokogiri --use-system-libraries
RUN bundle check || bundle install --jobs 5 --retry 3

COPY . /ark-manager-app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Start the main process.
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
