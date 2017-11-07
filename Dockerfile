# We are basing our builder image on openshift base-centos7 image
FROM openshift/base-centos7

# Inform users who's the maintainer of this builder image
# nobody :)

# Set labels used in OpenShift to describe the builder images
LABEL io.k8s.description="Platform for building and running C64 sources" \
      io.k8s.display-name="Vice Commodore 8-bit Emulator" \
      io.openshift.tags="builder,c64,cc65,vice"

# Install the required software, namely vice and build-essentials (for make)
RUN yum -y install epel-release && \
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
	yum -y update && \
	rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro && \
	rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm && \
	yum -y update && \
	yum install -y dejavu-lgc-sans-fonts build-essentials vice && \
	# clean yum cache files, as they are not needed and will only make the image bigger in the end
	yum clean all -y

# Defines the location of the S2I
# Although this is defined in openshift/base-centos7 image it's repeated here
# to make it clear why the following COPY operation is happening
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY ./s2i/bin/ /usr/local/s2i

# CC65 compiler has been compiled from source as there is no package readily available
COPY ./cc65/ /home/m68k/git/cc65

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root /home

# Set the default user for the image, the user itself was created in the base image
USER 1001

# Set the default CMD to print the usage of the image, if somebody does docker run
CMD ["usage"]
