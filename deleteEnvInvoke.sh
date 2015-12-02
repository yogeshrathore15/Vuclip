#!/bin/bash
remote_script_location=/home/ubuntu/websym/chef-repo
log_file=$remote_script_location/deleteEnvInvoke.log
env_name_qa=QA
env_name_prod=Prod
env_name_staging=Stag
bucket_name=websym
config_dir_name=Config

cat /dev/null > deleteEnvInvoke.log

if [ $# -ne 1 ]
then
	echo "Only one argument is required for the script. Usage: sh deleteEnvInvoke.sh QA|Prod|Stag" | tee -a $log_file

	exit 1
fi

cleanup()
{
echo "Removing $final_out_file from /tmp/" | tee -a $log_file
rm -f /tmp/$final_out_file	
}

delEnvInvoke()
{

echo "Invoking deleteEnvironment" | tee -a deleteEnvInvoke.log
LINE_COUNT=`cat /tmp/$final_out_file | wc -l`
if [ "$LINE_COUNT" -eq 5 ]
then
	instance1=`sed -n '1p' /tmp/$final_out_file`
	instance2=`sed -n '2p' /tmp/$final_out_file`
	instance3=`sed -n '3p' /tmp/$final_out_file`
	instance4=`sed -n '4p' /tmp/$final_out_file` 
	instance5=`sed -n '5p' /tmp/$final_out_file`

	if [ -z "$instance1" ] || [ -z "$instance2" ] || [ -z "$instance3" ] || [ -z "$instance4" ] || [ -z "$instance5" ];then
	echo "Cannot call deleEnvironment because one or more instance id's are missing in final.out file"
	cleanup

	else
	echo "$LINE_COUNT Instance id's found. Calling deleteEnvironment"
	sh $remote_script_location/deleteEnvironment $instance1 $instance2 $instance3 $instance4 $instance5 | tee -a deleteEnvInvoke.log
	cleanup
	fi
fi

if [ "$LINE_COUNT" -eq 7 ]
then
	instance1=`sed -n '1p' /tmp/$final_out_file`
        instance2=`sed -n '2p' /tmp/$final_out_file`
        instance3=`sed -n '3p' /tmp/$final_out_file`
        instance4=`sed -n '4p' /tmp/$final_out_file`
        instance5=`sed -n '5p' /tmp/$final_out_file`
	instance6=`sed -n '6p' /tmp/$final_out_file`
        instance7=`sed -n '7p' /tmp/$final_out_file`

	if [ -z "$instance1" ] || [ -z "$instance2" ] || [ -z "$instance3" ] || [ -z "$instance4" ] || [ -z "$instance5" ] || [ -z "$instance6" ] || [ -z "$instance7" ];then
        echo "Cannot call deleEnvironment because one or more instance id's are missing in final.out file"
        cleanup

        else
        echo "$LINE_COUNT Instance id's found. Calling deleteEnvironment"
        sh $remote_script_location/deleteEnvironment $instance1 $instance2 $instance3 $instance4 $instance5 $instance6 $instance7 | tee -a deleteEnvInvoke.log
        cleanup
        fi
fi
}

#Saving Argument to a variable
env_name_input=$1

if [ "$env_name_input" = "QA" ]
then
	echo "Fetching Latest final.out file from $env_name_qa" | tee -a $log_file
        final_out_file=`aws s3 ls s3://$bucket_name/$config_dir_name/$env_name_qa/ | grep final.out | sort | tail -1 | awk '{print $4}'`
	if [ -z "$final_out_file" ]
	then
	        echo "final.out file not found in $env_name_qa bucket"
	else
        	echo "File Found:$final_out_file"
		aws s3 cp s3://$bucket_name/$config_dir_name/$env_name_qa/$final_out_file /tmp/ | tee -a $log_file
		delEnvInvoke
	fi

else if [ "$env_name_input" = "Prod" ]
then
	echo "Fetching Latest final.out file from Production" | tee -a $log_file
        final_out_file=`aws s3 ls s3://$bucket_name/$config_dir_name/Production/ | grep final.out | sort | tail -1 | awk '{print $4}'`
        if [ -z "$final_out_file" ]
        then
                echo "final.out file not found in Production bucket"
        else
		echo "File Found:$final_out_file"
	        aws s3 cp s3://$bucket_name/$config_dir_name/Production/$final_out_file /tmp/ | tee -a $log_fil
		delEnvInvoke
	fi

else if [ "$env_name_input" = "Stag" ]
then
	echo "Fetching Latest final.out file from Staging" | tee -a $log_file
        final_out_file=`aws s3 ls s3://$bucket_name/$config_dir_name/Staging/ | grep final.out | sort | tail -1 | awk '{print $4}'`
	if [ -z "$final_out_file" ]
        then
                echo "final.out file not found in staging bucket"
        else
		echo "File Found:$final_out_file"
        	aws s3 cp s3://$bucket_name/$config_dir_name/Staging/$final_out_file /tmp/ | tee -a $log_file
		delEnvInvoke
	fi
     fi
   fi
fi
