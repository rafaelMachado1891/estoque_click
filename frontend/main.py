import streamlit as st
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os
from urllib.parse import quote_plus
import pandas as pd

load_dotenv()

USERNAME_POSTGRE = os.getenv("USER_POSTGRES")
PASSWORD_POSTGRE = quote_plus(os.getenv("PASSWORD_POSTGRES"))
HOST_POSTGRE = os.getenv("HOST_POSTGRES")
DB_POSTGRE = os.getenv("DB_POSTGRES")
PORT_POSTGRE = os.getenv("PORT_POSTGRES")

connection_string = f"postgresql://{USERNAME_POSTGRE}:{PASSWORD_POSTGRE}@{HOST_POSTGRE}:{PORT_POSTGRE}/{DB_POSTGRE}"

target_engine = create_engine(connection_string)

st.set_page_config(page_title='Parametros de estoque', layout="wide")

st.title("Parametros de estoque")
   
exp2 = st.expander("Grupos")
#df_instituicao = df.pivot_table(index="codigo", columns="descricao", values="estoque_minimo")

with exp2:
    grupo_injetado, grupo_elaboracao, grupo_susepe, grupo_embalagens, grupo_diversos = st.tabs(
        ['injetados','elaboracao_ax1','montados', 'embalagem', 'diversos']
 )
    
    with grupo_injetado:
        with target_engine.connect() as connection:
            result = connection.execute(text("""
                                                SELECT 
                                                  codigo,
                                                  descricao,
                                                  estoque_minimo,
                                                  tempo_reposicao,
                                                  calculo_estoque,
                                                  media_mensal,
                                                  media_movel_3_meses,
                                                  media_movel_6_meses,
                                                  observacao
                                                FROM public.marts_injetados
                                                """)
                                        )
            df=pd.DataFrame(result.fetchall(), columns=result.keys())
        st.dataframe(df,hide_index=True)
        
    with grupo_elaboracao:
        with target_engine.connect() as connection:
            result = connection.execute(text("""
                                             SELECT 
                                                  codigo,
                                                  descricao,
                                                  estoque_minimo,
                                                  tempo_reposicao,
                                                  calculo_estoque,
                                                  media_mensal,
                                                  media_movel_3_meses,
                                                  media_movel_6_meses,
                                                  observacao
                                             FROM public.marts_elaboracao
                                             """)
                                        )
            df=pd.DataFrame(result.fetchall(), columns=result.keys())
        st.dataframe(df,hide_index=True)

    with grupo_susepe:
        with target_engine.connect() as connection:
            result = connection.execute(text("""
                                             SELECT
                                                codigo,
                                                descricao,
                                                estoque_minimo,
                                                tempo_reposicao,
                                                calculo_estoque,
                                                media_mensal,
                                                media_movel_3_meses,
                                                media_movel_6_meses,
                                                observacao
                                             FROM public.marts_susepe
                                             """)
                                        )
            df=pd.DataFrame(result.fetchall(), columns=result.keys())
        st.dataframe(df,hide_index=True)
        
    with grupo_embalagens:
        with target_engine.connect() as connection:
            result = connection.execute(text("""
                                             SELECT
                                                codigo,
                                                descricao,
                                                estoque_minimo,
                                                tempo_reposicao,
                                                calculo_estoque,
                                                media_mensal,
                                                media_movel_3_meses,
                                                media_movel_6_meses,
                                                observacao
                                             FROM public.marts_embalagens
                                             """))
            df=pd.DataFrame(result.fetchall(), columns=result.keys())
        st.dataframe(df, hide_index=True)
        
    with grupo_diversos:
        with target_engine.connect() as connection:
            result = connection.execute(text("""
                                             SELECT
                                                codigo,
                                                descricao,
                                                grupo,
                                                estoque_minimo,
                                                tempo_reposicao,
                                                calculo_estoque,
                                                media_mensal,
                                                media_movel_3_meses,
                                                media_movel_6_meses,
                                                observacao
                                             FROM public.marts_diversos
                                             """))
            df=pd.DataFrame(result.fetchall(), columns=result.keys())
        st.dataframe(df,hide_index=True)
        
        st.title("Analise compras")       

compras= st.expander("compras")
#df_instituicao = df.pivot_table(index="codigo", columns="descricao", values="estoque_minimo") 

with compras:
    Fornecedores, = st.tabs(
        ['fornecedores']
    )
    with Fornecedores:
            with target_engine.connect() as connection:
                result = connection.execute(text("""
                                                SELECT
                                                    data_entrega,
                                                    numero_oc,
                                                    codigo_produto,
                                                    descricao,
                                                    check_oc,
                                                    quantidade,
                                                    calculo_estoque
                                                FROM public.marts_analise_compras
                                                """))
                df=pd.DataFrame(result.fetchall(), columns=result.keys())
            st.dataframe(df,hide_index=True)
            
        