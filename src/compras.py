import pandas as pd
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv
from urllib.parse import quote_plus

# Carregar variáveis de ambiente
load_dotenv()

caminho = "compras_click.csv"

# Ler CSV
df = pd.read_csv(caminho, sep=",")

# Garantir conversão correta das colunas numéricas com vírgula
df["preco"] = df["preco"].astype(str).str.replace(",", ".", regex=False)
df["valor_total"] = df["valor_total"].astype(str).str.replace(",", ".", regex=False)

# Converter tipos
tipo_de_dados = {
    "numero": "int64",
    "codigo": "string",
    "descricao": "string",
    "saldo": "float64",
    "preco": "float64",
    "valor_total": "float64"
}

df["data_entrega"] = pd.to_datetime(df["data_entrega"], errors="coerce")
df = df.astype(tipo_de_dados)

# Credenciais do banco
USERNAME_POSTGRE = os.getenv("USER_POSTGRES")
PASSWORD_POSTGRE = quote_plus(os.getenv("PASSWORD_POSTGRES", ""))
HOST_POSTGRE = os.getenv("HOST_POSTGRES", "localhost")
DB_POSTGRE = os.getenv("DB_POSTGRES")
PORT_POSTGRE = os.getenv("PORT_POSTGRES", "5432")
SCHEMA = os.getenv("SCHEMA", "public")

# String de conexão
connection_string = f"postgresql+psycopg2://{USERNAME_POSTGRE}:{PASSWORD_POSTGRE}@{HOST_POSTGRE}:{PORT_POSTGRE}/{DB_POSTGRE}"
target_engine = create_engine(connection_string)

# Dropar tabela e recriar
with target_engine.begin() as conn:
    conn.execute(text(f'DROP TABLE IF EXISTS "{SCHEMA}"."COMPRAS" CASCADE'))

# Inserir dados
df.to_sql(
    name="COMPRAS",
    con=target_engine,
    schema=SCHEMA,
    if_exists="append",
    index=False
)

print("✅ Dados carregados no banco com sucesso!")
