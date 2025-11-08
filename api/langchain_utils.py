from langchain_huggingface import HuggingFaceEndpoint, ChatHuggingFace
import os
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.chains import create_history_aware_retriever, create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from typing import List
from langchain_core.documents import Document
import os
from chroma_utils import vectorstore
retriever = vectorstore.as_retriever(search_kwargs={"k": 2})

output_parser = StrOutputParser()
from dotenv import load_dotenv
load_dotenv()
hf_key = os.getenv("HF_TOKEN")




# Set up prompts and chains
contextualize_q_system_prompt = (
    "Given a chat history and the latest user question "
    "which might reference context in the chat history, "
    "formulate a standalone question which can be understood "
    "without the chat history. Do NOT answer the question, "
    "just reformulate it if needed and otherwise return it as is."
)

contextualize_q_prompt = ChatPromptTemplate.from_messages([
    ("system", contextualize_q_system_prompt),
    MessagesPlaceholder("chat_history"),
    ("human", "{input}"),
])



qa_prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful AI assistant. Use the following context to answer the user's question."),
    ("system", "Context: {context}"),
    MessagesPlaceholder(variable_name="chat_history"),
    ("human", "{input}")
])



def get_rag_chain(model_name="meta-llama/Meta-Llama-3-8B-Instruct"):
    hf_llm = HuggingFaceEndpoint(
    repo_id=model_name,
    api_key=hf_key,
    task="chat-completion",        # crucial for instruct-style models
    temperature=0.0,
    max_new_tokens=100
)

# ② Wrap that endpoint in ChatHuggingFace
    chat_llm = ChatHuggingFace(llm=hf_llm)
    history_aware_retriever = create_history_aware_retriever(chat_llm, retriever, contextualize_q_prompt)
    question_answer_chain = create_stuff_documents_chain(chat_llm, qa_prompt)
    rag_chain = create_retrieval_chain(history_aware_retriever, question_answer_chain)    
    return rag_chain
