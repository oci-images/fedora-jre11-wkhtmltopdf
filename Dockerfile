####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
# Before building the container image run:
#
# ./mvnw package -Dquarkus.package.type=legacy-jar
#
# Then, build the image with:
#
# docker build -f src/main/docker/Dockerfile.legacy-jar -t quarkus/cupones-legacy-jar .
#
# Then run the container using:
#
# docker run -i --rm -p 8080:8080 quarkus/cupones-legacy-jar
#
# If you want to include the debug port into your docker image
# you will have to expose the debug port (default 5005) like this :  EXPOSE 8080 5050
#
# Then run the container using :
#
# docker run -i --rm -p 8080:8080 -p 5005:5005 -e JAVA_ENABLE_DEBUG="true" quarkus/cupones-legacy-jar
#
###
#FROM registry.access.redhat.com/ubi8/ubi-minimal:8.4
FROM registry.fedoraproject.org/fedora-minimal:34

ARG JAVA_PACKAGE=java-11-openjdk-headless
ARG RUN_JAVA_VERSION=1.3.8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'
# Install java and the run-java script
# Also set up permissions for user `1001`
RUN microdnf -y install curl ca-certificates ${JAVA_PACKAGE} \
    && microdnf -y install wkhtmltopdf-devel \
    && microdnf -y update \
    && microdnf -y clean all \
    && mkdir /opt/app \
    && chown 1001 /opt/app \
    && chmod "g+rwX" /opt/app \
    && chown 1001:root /opt/app \
    && curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /opt/app/run-java.sh \
    && chown 1001 /opt/app/run-java.sh \
    && chmod 540 /opt/app/run-java.sh \
    && echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/lib/security/java.security

# Configure the JAVA_OPTIONS, you can add -XshowSettings:vm to also display the heap size.
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"


EXPOSE 8080
USER 1001

ENTRYPOINT [ "/opt/app/run-java.sh" ]