FROM ruby:2.4.6-stretch
RUN apt-get update && apt-get install -y \
      build-essential \
      nodejs
RUN mkdir -p /rmd
WORKDIR /rmd
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5
COPY . ./
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]