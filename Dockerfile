FROM jboss/base-jdk:7

ENV JBOSS_HOME /opt/jboss
ENV JBOSS_VERSION 7.1.1.Final
ENV JBOSS_URL https://download.jboss.org/jbossas/7.1/jboss-as-${JBOSS_VERSION}/jboss-as-${JBOSS_VERSION}.zip
USER root

ADD $JBOSS_URL $HOME
RUN mv jboss-as-${JBOSS_VERSION}.zip $HOME \
    && cd $HOME \
    && unzip -q jboss-as-$JBOSS_VERSION.zip \
    && mv $HOME/jboss-as-$JBOSS_VERSION/* $JBOSS_HOME
ADD cache/spring-3.2.8.zip ${JBOSS_HOME}/modules/org/springframework/spring/main/
RUN cd ${JBOSS_HOME}/modules/org/springframework/spring/main/ && unzip spring-3.2.8.zip && rm spring-3.2.8.zip
RUN rm -rf $HOME/jboss-as-${JBOSS_VERSION}* \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME} \
    && ls -al /opt

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss
EXPOSE 8080 9990

RUN curl -L -o ${JBOSS_HOME}/jboss-modules.jar https://repo1.maven.org/maven2/org/jboss/modules/jboss-modules/1.1.5.GA/jboss-modules-1.1.5.GA.jar
COPY cache/jboss-modules.sh ${JBOSS_HOME}/jboss-modules.sh
RUN ${JBOSS_HOME}/jboss-modules.sh \
    && /opt/jboss/bin/add-user.sh --silent=true admin admin123 \
    && rm ${JBOSS_HOME}/jboss-modules.sh -f

# Set the default command to run on boot
# This will boot WildFly in standalone mode and bind to all interfaces

COPY cache/standalone-homo.xml $JBOSS_HOME/standalone/configuration/standalone.xml
CMD ["/opt/jboss/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

