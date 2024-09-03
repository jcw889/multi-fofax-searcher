#!/bin/bash

# 检查配置文件
config_file="config.yaml"
if [ ! -f "$config_file" ]; then
    echo "错误：找不到 config.yaml 文件"
    exit 1
fi

# 读取 API 密钥（假设密钥直接写在配置文件中）
api_keys=($(grep 'FOFA_API_KEY_' "$config_file" | cut -d ':' -f2 | tr -d ' '))

if [ ${#api_keys[@]} -eq 0 ]; then
    echo "错误：未找到有效的 API 密钥"
    exit 1
fi

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
    current_key=${api_keys[$key_index]}
    
    # 使用当前的 API 密钥执行查询
    FOFA_KEY="$$current_key" fofax -q "$query" -fs 10000 -fi -fields ip,port,country,region,city,server,title | tail -n +2 >> "$output_file"
    
    # 切换到下一个 API 密钥
    key_index=$(( (key_index + 1) % ${#api_keys[@]} ))
    sleep 1  # 避免频繁请求
done

echo "结果已保存到 $output_file"
