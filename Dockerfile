FROM ruby:2.7
RUN apt-get update
RUN gem install bundler --no-document

WORKDIR /active_record-journal
COPY . /active_record-journal
RUN bundle install

ENTRYPOINT ["bash"]