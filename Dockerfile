FROM centos:7

MAINTAINER Louis P. Santillan <lpsantil@gmail.com>

WORKDIR /tmp

# Run as root
USER 0

# Add our init script
ADD startsiab.sh /opt/startsiab.sh
# Fix up the Reverse coloring
ADD black-on-white.css /usr/share/shellinabox/black-on-white.css
# Add nano syntax highlighting for Dockerfiles
ADD dockerfile.nanorc /usr/share/nano/dockerfile.nanorc
# Add nano syntax highlighting for JS
ADD javascript.nanorc /usr/share/nano/javascript.nanorc
# Enable nano syntax highlighting
ADD nanorc /tmp/nanorc

# Install EPEL
# Install our developer tools (tmux, ansible, nano, vim, bash-completion, wget)
# Free up some space
# Install oc
# Add our developer user
# Bring in nano's user config
# Give nano's user config the correct ownership
# Set the default password for our 'developer' user
# Randomize root's password
# Be sure to remove login's lock file
RUN echo "" && \
    cat /opt/siab.logo.txt && \
    echo "=== Installing EPEL ===" && \
    yum install -y http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm && \
    echo "\n=== Installing developer tools ===" && \
    yum install -y jq vim screen which hostname passwd tmux nano wget git bash-completion openssl shellinabox util-linux expect --enablerepo=epel && \
    yum clean all && \
    cd /tmp/ && \
    echo "\n=== Installing oc ===" && \
    wget https://github.com/openshift/origin/releases/download/v3.10.0/openshift-origin-client-tools-v3.10.0-dd10d17-linux-64bit.tar.gz && \
    ls -lah /tmp/ && \
    echo "\n=== Untar'ing 'oc' ===" && \
    tar zxvf /tmp/openshift-origin-client-tools-v3.10.0-dd10d17-linux-64bit.tar.gz && \
    echo "\n=== Copying 'oc' ===" && \
    mv -v /tmp/openshift-origin-client-tools-v3.10.0-dd10d17-linux-64bit/oc /usr/local/bin/ && \
    echo "\n=== Installing 'developer' user ===" && \
    useradd -u 1001 developer -m && \
    mkdir -pv /home/developer/bin /home/developer/tmp && \
    echo "\n=== Bringing in nano's user config ===" && \
    mv -v /tmp/nanorc /home/developer/.nanorc && \
    echo "\n=== Giving nano's user config the correct ownership ===" && \
    chown -R 1001:1001 /home/developer && \
    echo "\n=== Setting the default password for our 'developer' user ===" && \
    ( echo "developer" | passwd developer --stdin ) && \
    echo "\n=== Randomizing root's password ===" && \
    ( cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 128 | head -n 1 | passwd root --stdin ) && \
    echo "\n=== Removing login's lock file ===" && \
    rm -f /var/run/nologin && \
    echo "*** Done building siab container ***" && \
    cat /opt/siab.logo.txt

# shellinabox will listen on 8080
EXPOSE 8080

# Run as developer
USER 1001

# Run our init script
CMD /opt/startsiab.sh
