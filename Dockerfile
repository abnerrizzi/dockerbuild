FROM jboss/base-jdk:7
#FROM ubuntu:14.04
#FROM openjdk:7u91-jre-alpine

ENV JBOSS_HOME /opt/jboss
ENV JBOSS_VERSION 7.1.1.Final
ENV JBOSS_URL https://download.jboss.org/jbossas/7.1/jboss-as-${JBOSS_VERSION}/jboss-as-${JBOSS_VERSION}.zip
USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
ADD $JBOSS_URL $HOME
RUN mv jboss-as-${JBOSS_VERSION}.zip $HOME \
    && cd $HOME \
    && unzip -q jboss-as-$JBOSS_VERSION.zip

RUN mv $HOME/jboss-as-$JBOSS_VERSION/* $JBOSS_HOME

RUN rm -rf $HOME/jboss-as-${JBOSS_VERSION}* \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME} \
    && ls -al /opt

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss
EXPOSE 8080 9990

RUN curl -L -o ${JBOSS_HOME}/jboss-modules.jar https://repo1.maven.org/maven2/org/jboss/modules/jboss-modules/1.1.5.GA/jboss-modules-1.1.5.GA.jar
COPY cache/jboss-modules.sh /tmp/jboss-modules.sh
RUN /tmp/jboss-modules.sh

COPY cache/standalone-prod.xml $JBOSS_HOME/standalone/configuration/standalone.xml
RUN /opt/jboss/bin/add-user.sh --silent=true admin admin123

# Set the default command to run on boot
# This will boot WildFly in standalone mode and bind to all interfaces
CMD ["/opt/jboss/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

