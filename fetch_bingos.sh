#!/bin/bash

ISSUE_MONTH='201701'
while getopts :m:h OPTION
do
	case ${OPTION} in
		m) ISSUE_MONTH=${OPTARG};;
		h) echo "Usage: $(basename $0) -m [ISSUE_MONTH] -h [HELP]"
		   exit;;
		:) echo "ERR: -${OPTARG} 缺少参数, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
		?) echo "ERR: 输入参数-${OPTARG}不支持, 详情参考: $(basename $0) -h" 1>&2
		   exit 1;;
	esac
done

GATEWAY='http://apply.sztb.gov.cn/apply/app/status/norm/person'
PAGE_COUNT=10000

num=1
while [ ${num} -le ${PAGE_COUNT} ]
do
	curl -s -d "pageNo=${num}&issueNumber=${ISSUE_MONTH}" ${GATEWAY} > data.txt
	PAGE_COUNT=$(grep 'pageCount[[:space:]]*=[[:space:]]*window.parseInt' data.txt | awk -F\' '{print $2}')
	cat data.txt | awk -v month=${ISSUE_MONTH} 'BEGIN{n=0;f=0}
	{
		i = match($0, /class="content_data"/)
		if (i != 0)
		{
			f = 1
			n = 0
			printf "%s\t", month
			next
		}
		
		if (f == 1)
		{
			if (n < 2)
			{
				split($0, r, />|</)
				printf "%s \t", r[3]
				n++
			}
			else
			{
				f = 0
				printf "\n"
			}
		}
	}'
	
	rm data.txt
	let num=num+1
done