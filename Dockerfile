# based on instructions here: https://docs.docker.com/compose/rails/
FROM ruby:2.6.5
RUN apt-get update -qq && apt-get install -y postgresql-client
RUN gem install bundler:2.0.2
RUN mkdir /ark-manager
WORKDIR /ark-manager
COPY Gemfile /ark-manager/Gemfile
COPY Gemfile.lock /ark-manager/Gemfile.lock
RUN bundle install
COPY . /ark-manager

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
