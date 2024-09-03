#!/bin/bash

set -e  # 遇到错误立即退出
set -x  # 打印执行的每一行命令

# 检查配置文件
config_file="config.yaml"
if [ ! -f "$config_file" ]; then
    echo "错误：找不到 config.yaml 文件"
    exit 1
fi

# 读取 API 密钥
echo "正在读取 API 密钥..."
api_keys=(1 2 3 4 5 6)  # 直接使用数字1-6，因为我们知道有6个密钥

echo "找到 $${#api_keys[@]} 个 API 密钥配置"

# 查询列表
queries=(
    'server=="cloudflare" && port=="443" && country=="SG" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="JP" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="TW" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="KR" && asn!="13335" && asn!="209242"'
    'server=="cloudflare" && port=="443" && country=="US" && asn!="13335" && asn!="209242"'
)

# 创建输出文件
output_file="fofa_results_$$(date +%Y%m%d_%H%M%S).csv"
echo "ip,port,country,region,city,server,title" > "$output_file"

# 执行查询
key_index=0
for query in "${queries[@]}"; do
    echo "正在查询: $query"
    # 选择当前的 API 密钥
    current_key="FOFA_API_KEY_$${api_keys[$key_index]}"
    
    echo "使用 API 密钥: $current_key"
    
    # 使用当前的 API 密钥执行查询
    if ! FOFA_KEY="${!current_key}" fofax -q "$query" -fs 10000 -fi -fields ip,port,country,region,city,server,title | tail -n +2 >> "$output_file"; then
        echo "查询失败，请检查 API 密钥和网络连接"
        exit 1
    fi
    
    # 切换到下一个 API 密钥
    key_index=$(( (key_index + 1) % ${#api_keys[@]} ))
    sleep 1  # 避免频繁请求
done

echo "结果已保存到 $$output_file"
