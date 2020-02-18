FROM ruby:2.6.3-alpine

LABEL maintainer="Al-waleed Shihadeh <wshihadeh.dev@gmail.com>"

ENV PORT 8080
ENV RACK_ENV=production
ENV LOG_TO_STDOUT=true

EXPOSE 8080

RUN addgroup -g 501 rubygems && \
    adduser -S -G rubygems -u 501 -h /application rubygems && \
    chown -R rubygems /usr/local/bundle && \
    apk update && \
    apk add linux-headers build-base curl openldap-dev git && \
    rm -rf /var/cache/apk/*

RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.8/main' >> /etc/apk/repositories && \
    echo 'http://dl-cdn.alpinelinux.org/alpine/v3.8/community' >> /etc/apk/repositories

RUN apk update && \
    apk add --no-cache libssl1.0

USER root
ADD . /application
RUN chown -R rubygems:rubygems /application

USER rubygems
WORKDIR /application

RUN gem install bundler && \
    rm -rf /usr/lib/lib/ruby/gems/*/cache/*

RUN bundle install --deployment --local --quiet --frozen

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["web"]
