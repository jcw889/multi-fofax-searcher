#!/bin/bash

# 读取配置文件
config_file="config.yaml"
mapfile -t api_keys < <(grep "^  - " "$config_file" | sed 's/^  - //')

# 定义搜索查询
declare -A queries
queries["SG"]='server=="cloudflare" && port=="443" && country=="SG" && asn!="13335" && asn!="209242"'
queries["JP"]='server=="cloudflare" && port=="443" && country=="JP" && asn!="13335" && asn!="209242"'
queries["TW"]='server=="cloudflare" && port=="443" && country=="TW" && asn!="13335" && asn!="209242"'
queries["KR"]='server=="cloudflare" && port=="443" && country=="KR" && asn!="13335" && asn!="209242"'
queries["US"]='server=="cloudflare" && port=="443" && country=="US" && asn!="13335" && asn!="209242"'  

# 创建结果目录
mkdir -p results

# 循环执行查询
for country in "${!queries[@]}"; do
  query="${queries[$country]}"
  
  # 使用每个 API 密钥执行查询
  for key in "${api_keys[@]}"; do
    echo "Searching for $country using API key: ${key:0:5}..."
    
    # 执行 FoFaX 查询并将结果追加到对应的文件
    fofax -fk "$key" -q "$query" >> "results/${country}_results.txt"
    # 添加延迟以避免频繁请求
    sleep 5
  done
done

echo "Search completed. Results saved in the 'results' directory."
