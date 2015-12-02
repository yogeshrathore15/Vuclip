#!/bin/bash
log_file=/home/ubuntu/websym/chef-repo/upload.log
cat /dev/null > $log_file

start_time=$(date +"%d-%m-%y-%T")
echo "Start Time:$start_time" >> $log_file

if [ -f final.out ]
then
	echo "final.out is present"
else
	echo "final.out is not present at /home/ubuntu/websym/chef-repo/"
	exit 1
fi

copy_final_out()
{
DATE=$(date +"%d-%m-%y-%T")
bucket_name=websym
config_dir_name=Config
env_name_qa=QA
env_name_prod=Production
env_name_staging=Staging


grep -i 'qa' final.out > /dev/null 
if [ $? -eq 0 ]
then
	echo "Generating Instance id file for $env_name_qa" | tee -a $log_file
	cat final.out | grep -i "instance id" | awk -F ':' '{print $3}' | sed -e 's/^ //' > $env_name_qa-final.out

	echo "Uploading $env_name_qa-final.out to $env_name_qa bucket" | tee -a $log_file
	aws s3 cp $env_name_qa-final.out s3://$bucket_name/$config_dir_name/$env_name_qa/$env_name_qa-final.out_$DATE

	echo "Removing temporary $env_name_qa-final.out file."
 	rm -f $env_name_qa-final.out
	
fi	

grep -i 'prod' final.out > /dev/null
if [ $? -eq 0 ]
then
	echo "Generating Instance id file for $env_name_prod" | tee -a $log_file
        cat final.out | grep -i "instance id" | awk -F ':' '{print $3}' | sed -e 's/^ //' > $env_name_prod-final.out

        echo "Uploading $env_name_prod-final.out to $env_name_prod bucket" | tee -a $log_file
        aws s3 cp $env_name_prod-final.out s3://$bucket_name/$config_dir_name/$env_name_prod/$env_name_prod-final.out_$DATE

	echo "Removing temporary $env_name_prod-final.out file."
 	rm -f $env_name_prod-final.out
        
fi

grep -i 'stag' final.out > /dev/null
if [ $? -eq 0 ]
then
	echo "Generating Instance id file for $env_name_staging" | tee -a $log_file
        cat final.out | grep -i "instance id" | awk -F ':' '{print $3}' | sed -e 's/^ //' > $env_name_staging-final.out

        echo "Uploading $env_name_staging-final.out to $env_name_staging bucket" | tee -a $log_file
        aws s3 cp $env_name_staging-final.out s3://$bucket_name/$config_dir_name/$env_name_staging/$env_name_staging-final.out_$DATE

	echo "Removing temporary $env_name_staging-final.out file."
 	rm -f $env_name_staging-final.out
        
fi

}

copy_final_out
end_time=$(date +"%d-%m-%y-%T")
echo "End Time:$end_time" >> $log_file
