FROM ruby:2.6.6

MAINTAINER bbarber@bpl.org

ENV BUNDLER_VERSION=2.1.2

RUN apt-get update -qq &&  DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y postgresql-client-11

RUN gem update --system 3.1.4
RUN gem install bundler:2.1.4

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
