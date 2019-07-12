#!/bin/bash
dir=/ftp/archivossftp/dumpsPS/tdeuser/prod_new
today=`date +%Y%m%d`
tomorrow=`date --date="next day" +%Y%m%d`
yesterday=`date --date="yesterday" +%Y%m%d`

cd $dir
#First we get files from FTP server#
(ls -ls|grep OK_UPCC_15_$today|awk '{print $10}') > temp1
#archive="/HSSdb/PSCORE/pcrf_split/file.txt"

#Next we unzip tar.gz files #
while IFS= read line
do
  	tar -zxvf $line
done <temp1

#Then we remove headers in the first line#

(ls -l|grep "EntelUserSubscriptionInfo"|awk '{print $9}')> temp2
while IFS= read line
do

        sed '1d' $line > tmpfile; mv tmpfile $line
        rm tmpfile
done <temp2
#Then we concatenate the files into a single one

touch PCRF01_$today.txt
while IFS= read line
do

         cat $line >> PCRF01_$today.txt
done <temp2
#Gzip file
tar -czf PCRF01_$today.tar.gz PCRF01_$today.txt

#Export to IT path
pcrf_dump=$(ls -ls|grep PCRF01_$today.tar.gz|awk '{print $10}')
cp $pcrf_dump /ftp/archivossftp/dumpsPS/titdeuser/
chown -R "tdeuser:sftpusers" /ftp/archivossftp/dumpsPS/titdeuser/

#Export to TDE server
scp PCRF01_${fecha}.tar.gz eperedestde@10.84.x.x:/XX/AA/BBB
scp PCRF01_${fecha}.tar.gz eperedestde@10.84.x.y:/XX/AA/BBB

rm *.txt
rm temp1
rm temp2
