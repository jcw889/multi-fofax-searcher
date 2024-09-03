#!/bin/bash

# 定义日志文件
log_file="search_log.txt"

# 清空或创建日志文件
> "$log_file"

# 定义 API 密钥数组
api_keys=(
    "your_first_api_key_here"
    "your_second_api_key_here"
    # 添加更多 API 密钥...
)

# 定义查询
declare -A queries
queries[JP]='domain="co.jp" && country="JP"'
queries[KR]='domain="co.kr" && country="KR"'
queries[SG]='domain="com.sg" && country="SG"'
queries[TW]='domain="com.tw" && country="TW"'
queries[US]='domain=".edu" && country="US"'

# 创建结果目录
mkdir -p results

# 执行查询
for country in "${!queries[@]}"; do
    query="${queries[$country]}"
    echo "Searching for $country..." | tee -a "$log_file"
    
    for key in "${api_keys[@]}"; do
        echo "Using API key: ${key:0:5}..." | tee -a "$log_file"
        result=$(fofax -fk "$key" -q "$query" -fs 1000 -e -ffi -fto -debug 2>&1)
        if [ $? -eq 0 ]; then
            echo "$result" | jq '.' > "results/${country}_results.json"
            echo "Query successful, results saved to results/${country}_results.json" | tee -a "$log_file"
            break  # 如果成功，就不再使用其他 API 密钥
        else
            echo "Error occurred: $result" | tee -a "$log_file"
        fi
        sleep 5  # 在请求之间添加延迟
    done
done

# 运行 git 命令
git config --local user.email "action@github.com"
git config --local user.name "GitHub Action"
git add results/* "$log_file"
git commit -m "Update search results and log" || echo "No changes to commit"
git push

echo "Search completed. Results and log have been pushed to GitHub."
