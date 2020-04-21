FROM ruby:2.6.6

MAINTAINER bbarber@bpl.org

ENV BUNDLER_VERSION=2.1.2

RUN apt-get update -qq && apt-get install -y postgresql-client

RUN gem update --system
RUN gem install bundler:2.1.2

RUN mkdir /ark-manager

WORKDIR /ark-manager

COPY Gemfile /ark-manager/Gemfile

COPY Gemfile.lock /ark-manager/Gemfile.lock

RUN bundle config build.nokogiri --use-system-libraries
RUN bundle check || bundle install --jobs 20 --retry 5

COPY . /ark-manager

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/

RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Start the main process.
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
