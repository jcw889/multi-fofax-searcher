#!/bin/bash

set -e
set -x

echo "脚本开始执行时间: $(date)"

echo "正在设置 API 密钥..."
api_keys=(1 2 3 4 5 6)

echo "设置了 ${#api_keys[@]} 个 API 密钥配置"

queries=(
    'server=="cloudflare" && port=="443" && country=="SG" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="JP" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="TW" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="KR" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="US" && asn!="13335" && asn!="209242"'
)

echo "设置了 ${#queries[@]} 个查询"

output_file="results/fofa_results_$$(date +%Y%m%d_%H%M%S).csv"
mkdir -p results
echo "ip,port,country,region,city,server,title" > "$output_file"
echo "创建了输出文件: $output_file"

key_index=0
for query in "${queries[@]}"; do
    echo "正在执行查询: $query"
    current_key="FOFA_API_KEY_${api_keys[$key_index]}"
    echo "使用 API 密钥: $current_key"
    api_key_value=$(eval echo \$${current_key})
    if [ -z "$api_key_value" ]; then
        echo "错误：API 密钥 $current_key 未设置"
        exit 1
    fi
    
    echo "执行 fofax 命令..."
    if ! FOFA_KEY="$$api_key_value" fofax -q "$query" -fs 2000 -fields ip,port,country,region,city,server,title | tail -n +2 >> "$output_file"; then        
        echo "查询失败，请检查 API 密钥和网络连接"
        exit 1
    fi
    
    echo "查询完成，结果已追加到 $output_file"
    file_size=$(wc -c < "$output_file")
    echo "当前输出文件大小: $file_size 字节"
    
    key_index=$(( (key_index + 1) % ${#api_keys[@]} ))
    echo "切换到下一个 API 密钥，索引: $key_index"
    sleep 1
done

echo "所有查询已完成"
echo "最终输出文件大小: $(wc -c < "$output_file") 字节"
echo "结果已保存到 $output_file"

echo "脚本结束执行时间: $(date)"
