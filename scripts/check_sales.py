# scripts/check_sales.py
import os
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
import snowflake.connector
import pandas as pd

def fetch_monthly_sales():
    print("1. 秘密鍵（rsa_key.p8）を読み込んでいます...")
    private_key_path = r"C:\Users\ayumi\rsa_key.p8"
    
    with open(private_key_path, "rb") as key:
        p_key = serialization.load_pem_private_key(
            key.read(),
            password=None,
            backend=default_backend()
        )
    
    pk_bytes = p_key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )

    print("2. Snowflakeへ接続中...")
    conn = snowflake.connector.connect(
        user="AYUNE28",
        account="XAQFXKA-IQ71801",
        warehouse="tb_de_wh",
        database="tb_101",
        schema="raw_pos",
        role="sysadmin",
        private_key=pk_bytes
    )
    print("3. Snowflakeへの接続に成功しました！")

    try:
        query = """
            SELECT 
                sales_month, 
                total_sales_dollars, 
                order_count, 
                avg_order_value_dollars
            FROM monthly_sales_summary
            ORDER BY sales_month DESC
            LIMIT 5;
        """
        
        print("4. SQLを実行してデータを取得中...")
        df = pd.read_sql(query, conn)
        
        print("\n【直近5ヶ月の売上サマリー】")
        print(df.to_string(index=False))

    except Exception as e:
        print(f"エラーが発生しました: {e}")

    finally:
        conn.close()
        print("\n5. Snowflakeとの接続を切断しました。処理完了です！")

if __name__ == "__main__":
    fetch_monthly_sales()