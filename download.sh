#!/bin/bash

curl -s http://apply.sztb.gov.cn/apply/app/status/norm/person | grep 'option' | sed '1d' | awk -F'>|<' '{print $3}' | sort | while read month
do
	./fetch_bingos.sh -m ${month} 
done
