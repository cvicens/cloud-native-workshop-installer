FROM registry.redhat.io/ubi8/ubi-minimal

COPY content_sets_epel7.repo /etc/yum.repos.d/

ENV OC_CLI_VERSION 4.1.14

RUN microdnf install -y bash git gzip tar findutils jq python3-six python3-pip && \
    microdnf -y clean all && rm -rf /var/cache/yum && echo "Installed Packages" && rpm -qa | sort -V && echo "End Of Installed Packages" && \
    # install yq (depends on jq and pyyaml - if jq and pyyaml not already installed, this will try to compile it)
    /usr/bin/pip3.6 install --user yq && \
    # could be installed in /opt/app-root/src/.local/bin or /root/.local/bin
    for d in /opt/app-root/src/.local /root/.local; do \
      if [[ -d ${d} ]]; then \
        cp ${d}/bin/yq /usr/local/bin/; \
        pushd ${d}/lib/python3.6/site-packages/ >/dev/null; \
          cp -r PyYAML* xmltodict* yaml* yq* /usr/lib/python3.6/site-packages/; \
        popd >/dev/null; \
      fi; \
    done && \
    chmod +x /usr/local/bin/yq && \
    ln -s /usr/bin/python3.6 /usr/bin/python

WORKDIR /tmp

RUN curl -OL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_CLI_VERSION}/openshift-client-linux-${OC_CLI_VERSION}.tar.gz && \
    tar xvzf openshift-client-linux-${OC_CLI_VERSION}.tar.gz -C /usr/local/bin oc && \
    rm openshift-client-linux-${OC_CLI_VERSION}.tar.gz


