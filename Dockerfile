FROM jboss/base-jdk:7

ENV JBOSS_HOME /opt/jboss
ENV JBOSS_VERSION 7.1.1.Final
ENV JBOSS_URL https://download.jboss.org/jbossas/7.1/jboss-as-${JBOSS_VERSION}/jboss-as-${JBOSS_VERSION}.zip
USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
ADD $JBOSS_URL $HOME
RUN mv jboss-as-${JBOSS_VERSION}.zip $HOME \
    && cd $HOME \
    && unzip jboss-as-$JBOSS_VERSION.zip \
    && mv $HOME/jboss-as-$JBOSS_VERSION /opt

RUN rm $HOME/jboss-as-$JBOSS_VERSION.zip \
    && ln -s /opt/jboss-as-$JBOSS_VERSION $JBOSS_HOME \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME} \
    && ls -al /opt

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss





