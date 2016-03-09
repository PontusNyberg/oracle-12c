FROM wscherphof/oracle-linux-7
MAINTAINER Pontus Nyberg <Pontus.Nyberg@ist.com>

### Step 1 ###
ADD step1/linuxamd64_12102_database_1of2.zip /tmp/install/linuxamd64_12102_database_1of2.zip
ADD step1/linuxamd64_12102_database_2of2.zip /tmp/install/linuxamd64_12102_database_2of2.zip
RUN yum -y install unzip binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33.i686 gcc gcc-c++ glibc.i686 glibc glibc-devel glibc-devel.i686 ksh libgcc.i686 libgcc libstdc++ libstdc++.i686 libstdc++-devel libstdc++-devel.i686 libaio libaio.i686 libaio-devel libaio-devel.i686 libXext libXext.i686 libXtst libXtst.i686 libX11 libX11.i686 libXau libXau.i686 libxcb libxcb.i686 libXi libXi.i686 make sysstat vte3 smartmontools
RUN cd /tmp/install && unzip linuxamd64_12102_database_1of2.zip && unzip linuxamd64_12102_database_2of2.zip && rm *.zip

RUN groupadd -g 54321 oinstall && groupadd -g 54322 dba
RUN userdel oracle && rm -rf /home/oracle && rm /var/spool/mail/oracle
RUN useradd -m -u 54321 -g oinstall -G dba oracle
RUN echo "oracle:oracle" | chpasswd

ENV ORACLE_BASE /u01/app/oracle

RUN mkdir -p $ORACLE_BASE && chown -R oracle:oinstall $ORACLE_BASE && chmod -R 775 $ORACLE_BASE
RUN mkdir -p /u01/app/oraInventory && chown -R oracle:oinstall /u01/app/oraInventory && chmod -R 775 /u01/app/oraInventory
ADD step1/oraInst.loc /etc/oraInst.loc
RUN chmod 664 /etc/oraInst.loc

ADD step1/sysctl.conf /etc/sysctl.conf
RUN echo "oracle soft stack 10240" >> /etc/security/limits.conf

ENV CVUQDISK_GRP oinstall
RUN cd /tmp/install/database/rpm && rpm -iv cvuqdisk-1.0.9-1.rpm

ADD step1/db_install.rsp /tmp/db_install.rsp
ADD step1/install /tmp/install/install
RUN sed -i "s/-ignorePrereq/-ignorePrereq -waitforcompletion/" /tmp/install/install

RUN /tmp/install/install
RUN rm -rf /tmp/install

### Step 2 ###
ENV ORACLE_SID ORCL
ENV ORACLE_HOME $ORACLE_BASE/product/12.1.0/dbhome_1
ENV PATH $ORACLE_HOME/bin:$PATH

RUN $ORACLE_HOME/root.sh

RUN mkdir -p $ORACLE_BASE/oradata && chown -R oracle:oinstall $ORACLE_BASE/oradata && chmod -R 775 $ORACLE_BASE/oradata
RUN mkdir -p $ORACLE_BASE/fast_recovery_area && chown -R oracle:oinstall $ORACLE_BASE/fast_recovery_area && chmod -R 775 $ORACLE_BASE/fast_recovery_area

ADD step2/initORCL.ora $ORACLE_HOME/dbs/initORCL.ora
ADD step2/createdb.sql $ORACLE_HOME/config/scripts/createdb.sql
ADD step2/conf_finish.sql $ORACLE_HOME/config/scripts/conf_finish.sql
ADD step2/create /tmp/create

VOLUME "/u01/app/oracle/oradata/external_tablespaces"

RUN /tmp/create
RUN rm /tmp/create

### Step 3 ###
# Exposes the default TNS port, as well as the Enterprise Manager Express HTTP
# (8080) and HTTPS (5500) ports. 
EXPOSE 1521 5500 8080

ADD step3/startdb.sql $ORACLE_HOME/config/scripts/startdb.sql
ADD step3/start /tmp/start
CMD /tmp/start