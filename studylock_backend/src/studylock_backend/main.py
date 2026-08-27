from fastapi import FastAPI, status, UploadFile, HTTPException
from google import genai
import tempfile
import os
import asyncio
from dotenv import load_dotenv

load_dotenv()
app = FastAPI()
ai_client = genai.Client() 

@app.get('/', status_code=status.HTTP_200_OK)
def ping():
    return {'status': 200}

@app.post('/upload-pdf', status_code=status.HTTP_200_OK)
async def upload_pdf(file: UploadFile):
    contents = await file.read()
    
    with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as temp_file:
        temp_file.write(contents)
        temp_file_path = temp_file.name

    try:
        gemini_file = await asyncio.to_thread(
            ai_client.files.upload, file=temp_file_path
        )
        
        return {
            "filename": file.filename,
            "file_uri": gemini_file.name, 
            "message": "PDF uploaded and ready for chat!"
        }
    except Exception as e:
        print(f"DEV_ERROR_LOG: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while uploading the file. Please try again later."
        )
    finally:
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)

@app.post('/chat', status_code=status.HTTP_200_OK)
async def chat_with_pdf(file_uri: str, question: str):
    try:
        file_obj = await asyncio.to_thread(
            ai_client.files.get, name=file_uri
        )
        
        chat = ai_client.chats.create(
            model='gemini-3.5-flash'
        )
        
        response = await asyncio.to_thread(
            chat.send_message,
            [file_obj, question]
        )
        
        return {
            "question": question,
            "answer": response.text
        }
    except Exception as e:
        print(f"DEV_ERROR_LOG: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while processing your chat request. Please try again later."
        )
        
        sdasdasdasdas