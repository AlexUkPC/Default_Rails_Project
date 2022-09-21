FROM ruby:<ruby_version> AS <project_name>-development
LABEL maintainer="alexrogna@yahoo.com"

<node_and_yarn>
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends<node_and_yarn_install> netcat

ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user

ENV INSTALL_PATH /opt/app/
RUN mkdir -p $INSTALL_PATH
COPY /<project_name>/Gemfile* $INSTALL_PATH
WORKDIR $INSTALL_PATH
ENV BUNDLE_PATH /gems

RUN bundle install
COPY <project_name>/ $INSTALL_PATH

RUN chown -R user:user $INSTALL_PATH
#USER $USER_ID
ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD [ "bin/<rails_dev>" ]