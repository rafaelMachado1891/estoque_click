import pandas as pd
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv
from urllib.parse import quote_plus


caminho = "movimento_estoque_click.csv"


df = pd.read_csv(caminho, sep=",")

df['total_movimento'] = df['total_movimento'].str.replace(',', '.').astype(float)
   
tipo_dados = {
    'codigo': str,
    'descricao': str,
    'data_baixa':'datetime64[ns]',
    'mes': int,
    'ano': int,
    'total_movimento': int,
    'grupo': str,
    'estoque_minimo': int,
    'tempo_reposicao': int
}

df = df.astype(tipo_dados)

selecao_colunas = ["codigo", "descricao" ,"data_baixa", "total_movimento", "grupo", "estoque_minimo", "tempo_reposicao" ]

df = df[selecao_colunas]
selecao = df.copy()

agregacao_mensal = df.copy()

agregacao_mensal['mes_ano'] = agregacao_mensal['data_baixa'].dt.to_period('M')

agregacao_mensal['mes_ano'] = agregacao_mensal['mes_ano'].dt.to_timestamp()

agregacao_mensal = agregacao_mensal.groupby(by=['codigo', 'mes_ano', 'grupo'], as_index=False).agg(total_movimento = ('total_movimento', 'sum'))

agregacao_mensal = agregacao_mensal.groupby(by=['codigo'], as_index=False).agg(
    soma=('total_movimento', 'sum'), 
    minimo_mes=('total_movimento','min'),
    maximo_mes=('total_movimento','max'),
    media__mes=('total_movimento','mean'),
    desvio_padrao_mes=('total_movimento','std'),
    mediana_mes=('total_movimento','median'),
    contagem_mes=('total_movimento','count'),
    q1_mes=('total_movimento', lambda x: x.quantile(0.25)),
    q3_mes=('total_movimento', lambda x: x.quantile(0.75))
)

print(agregacao_mensal)

agregacao = selecao.groupby(by=['codigo'],as_index=False).agg(
    soma=('total_movimento', 'sum'), 
    minimo=('total_movimento','min'),
    maximo=('total_movimento','max'),
    media_dia=('total_movimento','mean'),
    desvio_padrao=('total_movimento','std'),
    mediana=('total_movimento','median'),
    contagem=('total_movimento','count'),
    q1=('total_movimento', lambda x: x.quantile(0.25)),
    q3=('total_movimento', lambda x: x.quantile(0.75))
    )

selecao = agregacao

# conexao com o banco de dados de destino

load_dotenv()

USERNAME_POSTGRE = os.getenv("USER_POSTGRES")
PASSWORD_POSTGRE = quote_plus(os.getenv("PASSWORD_POSTGRES"))
HOST_POSTGRE = os.getenv("HOST_POSTGRES")
DB_POSTGRE = os.getenv("DB_POSTGRES")
PORT_POSTGRE = os.getenv("PORT_POSTGRES")

connection_string = f"postgresql://{USERNAME_POSTGRE}:{PASSWORD_POSTGRE}@{HOST_POSTGRE}:{PORT_POSTGRE}/{DB_POSTGRE}"

target_engine = create_engine(connection_string)

with target_engine.execution_options(isolation_level="AUTOCOMMIT").connect() as connection:
    connection.execute(text('DROP TABLE IF EXISTS "MOVIMENTO" CASCADE'))    
    connection.execute(text('DROP TABLE IF EXISTS "ESTATISTICAS_DIA" CASCADE'))
    connection.execute(text('DROP TABLE IF EXISTS "ESTATISTICAS_MENSAL" CASCADE'))
        
df.to_sql(
        name='MOVIMENTO',         
        con=target_engine,           
        schema=os.getenv('SCHEMA'),  
        if_exists='append',          
        index=False                  
)

selecao.to_sql(
        name='ESTATISTICAS_DIA',
        con=target_engine,           
        schema=os.getenv('SCHEMA'),  
        if_exists='append',          
        index=False  
)

agregacao_mensal.to_sql(
        name='ESTATISTICAS_MENSAL',
        con=target_engine,           
        schema=os.getenv('SCHEMA'),  
       if_exists='append',          
       index=False  
)