import requests
import base64
import json
import time
import csv

# FoFa API配置
email = "your_email@example.com"
key = "your_api_key"

# 查询参数
queries = [
    'server=="cloudflare" && port=="443" && country=="SG" && asn!="13335" && asn!="209242"',
    'server=="cloudflare" && port=="443" && country=="JP" && asn!="13335" && asn!="209242"',
    'server=="cloudflare" && port=="443" && country=="TW" && asn!="13335" && asn!="209242"',
    'server=="cloudflare" && port=="443" && country=="KR" && asn!="13335" && asn!="209242"',
    'server=="cloudflare" && port=="443" && country=="US" && asn!="13335" && asn!="209242"'
]
size = 10000  # 每次查询的结果数量
fields = "ip,port,country,region,city,server,title"

def fofa_query(query):
    encoded_query = base64.b64encode(query.encode()).decode()
    api_url = f"https://fofa.so/api/v1/search/all?email={email}&key={key}&qbase64={encoded_query}&size={size}&fields={fields}"
    try:
        response = requests.get(api_url)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"API请求错误: {e}")
        return None

def save_to_csv(data, filename):
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(fields.split(','))  # 写入表头
        for item in data:
            writer.writerow(item)

def main():
    all_results = []
    for query in queries:
        print(f"正在查询: {query}")
        result = fofa_query(query)
        if result and 'results' in result:
            all_results.extend(result['results'])
        time.sleep(1)  # 避免频繁请求

    if all_results:
        filename = f"fofa_results_{time.strftime('%Y%m%d_%H%M%S')}.csv"
        save_to_csv(all_results, filename)
        print(f"结果已保存到 {filename}")
    else:
        print("没有找到结果")

if __name__ == "__main__":
    main()
