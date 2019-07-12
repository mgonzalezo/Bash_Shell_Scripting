#!/bin/bash
dir=/ZZZZ/XXX/pcrf_split
today=`date +%Y%m%d`
tomorrow=`date --date="next day" +%Y%m%d`
yesterday=`date --date="yesterday" +%Y%m%d`
old=`date --date='4 day ago' +%Y%m%d`
date
mysql -uXXX -pXXX -D XXX << EOF
CREATE TABLE BASEPCRFPKG$today (idx int(15) NOT NULL AUTO_INCREMENT,MSISDN varchar(11) DEFAULT NULL,IMSI varchar(15) DEFAULT NULL,SUBSCRIBERIDENTIFIER varchar(15) DEFAULT NULL,STATUS varchar(15) DEFAULT NULL,PAIDTYPE varchar(15) DEFAULT NULL,SERVICENAME varchar(32) DEFAULT NULL,SERVICESUBSCRIBEDATETIME varchar(25) DEFAULT NULL,SERVICEVALIDFROMDATETIME archar(25) DEFAULT NULL,SERVICEEXPIREDDATETIME varchar(25) DEFAULT NULL,SVCPKGNAME varchar(32) DEFAULT NULL,SVCPKGSUBSCRIBEDATETIME varchar(25) DEFAULT NULL,SVCPKGVALIDFROMDATETIME varchar(25) DEFAULT NULL,SVCPKGEXPIREDATETIME varchar(25) DEFAULT NULL,QUOTANAME varchar(32) DEFAULT NULL,INITIALVALUE varchar(20) DEFAULT NULL,BALANCE varchar(25) DEFDEFAULT NULL,CONSUMPTION varchar(25) DEFAULT NULL,QUOTAUNIT varchar(25) DEFAULT NULL,PRIMARY KEY (idx)) ENGINE=MyISAM DEFAULT CHARSET=latin1;
CREATE INDEX msisdn_BASPCRFPKG ON BASEPCRFPKG$today(MSISDN);
CREATE INDEX srvpkg_BASEPCRFPKG ON BASEPCRFPKG$today(SVCPKGNAME);
CREATE INDEX srv_BASEPCRFPKG ON BASEPCRFPKG$today(SERVICENAME);
CREATE INDEX imsi_BASEPCRFPKG ON BASEPCRFPKG$today(SUBSCRIBERIDENTIFIER);
DROP TABLE BASEPCRFPKG$old;
quit;
EOF

cd $dir
##First we get files from FTP server##
sftp root@XX.YY.ZZ.WW <<EOF
cd /zzzzz/xxxx/aaaa/bbbb/prod_new
get OK_UPCC_15_$today*
#get OK_UPCC_102_$today*
quit
EOF
(ls -ls|grep OK_UPCC_15_$today|awk '{print $10}')> file.txt
archive="/zzzzz/xxxx/aaaa/bbbb/file.txt"
###Next we unzip tar.gz files ###
while IFS= read line
do
  	tar -zxvf "$line"
done <"$archive"
###Then we remove headers in the first line##
ls -l|grep "EntelUserSubscriptionInfo"|awk '{print $9}')> temp1
while IFS= read line
do

        sed '1d' $line > tmpfile; mv tmpfile $line
        rm tmpfile
done <temp1
###Finally we load files into a Table###
while IFS= read line
do
mysql -u xxxx -pxxxx -D AAAA <<EOF
LOAD DATA INFILE '/zzzzz/xxxx/aaaa/bbbb//$line' replace into table BASEPCRFPKG$today FIELDS TERMINATED BY ',' LINES terminated by '\n' (MSISDN,IMSI,SUBSCRIBERIDENTIFIER,STATUS,PAIDTYPE,SERVICENAME,SERVICESUBSCRIBEDATETIME,SERVICEVALIDFROMDATETIME,SERVICEEXPIREDDATETIME,SVCPKGNAME,SVCPKGSUBSCRIBEDATETIME,SVCPKGVALIDFROMDATETIME,SVCPKGEXPIREDATETIME,QUOTANAME,INITIALVALUE,BALANCE,CONSUMPTION,QUOTAUNIT) set IDX=NULL;
EOF
done < temp1
cd $dir
rm *.txt
rm *.tar.gz
rm temp1
date
