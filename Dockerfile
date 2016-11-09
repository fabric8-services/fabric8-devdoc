FROM fedora:24
MAINTAINER "Max Rydahl Andersen <manderse@redhat.com>"

# Prevent encoding errors
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Some packages might seem weird but they are required by the
# RVM installer
RUN dnf install -y \
      curl \
      findutils \
      git \
      graphviz \
      java-1.8.0-openjdk-headless \
      procps-ng \
      python-blockdiag \
      libpng \
      libpng-devel \
      libjpeg \
      libjpeg-devel \
      tar \
      which \
    && dnf clean all

#easy_install blockdiag

# Add RVM keys
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

# Install RVM
RUN curl -L get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements && rvm autolibs enable"

# Add RVM keys
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

# Install RVM
RUN curl -L get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements && rvm autolibs enable"

# Install Ruby and its gems
#ADD ./.ruby-version /tmp/
ADD ./.ruby-gemset /tmp/
ADD ./Gemfile /tmp/
ADD ./Gemfile.lock /tmp/
ADD ./Rakefile  /tmp/

WORKDIR /tmp/
# tell rvm to install ruby instead of complaining it is missing.
RUN /bin/bash -l -c "echo rvm_install_on_use_flag=1 > ~/.rvmrc"
# rvm will get version from Gemfile
RUN /bin/bash -l -c "rvm install ."
RUN /bin/bash -l -c "gem install bundler"
# install base gem's, if any changes user only need to install differences.
RUN /bin/bash -l -c "bundle install"

# Enable GPG support
VOLUME /gnupg
ENV GNUPGHOME /gnupg
RUN touch /tmp/gpg-agent.conf
RUN echo 'export GPG_TTY=$(tty); eval $(gpg-agent --daemon --no-use-standard-socket --options /tmp/gpg-agent.conf );' >> ~/.bash_profile

# Add the volume for the actual project
VOLUME /almighty-devdoc
WORKDIR /almighty-devdoc

EXPOSE 35729 4000

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD [ "rake" ]
