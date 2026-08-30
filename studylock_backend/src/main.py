from fastapi import FastAPI, status, UploadFile, HTTPException
from google import genai
from google.genai import types
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
        
        system_instruction = """
            You are an expert study assistant and friendly tutor. Your goal is to explain concepts derived from the provided document as clearly as possible.
            - Break down complex thoughts into simple, digestible terms.
            - Use the easiest methods, real-world analogies, or step-by-step bullet points to explain questions.
            - Avoid overly dense academic jargon unless you define it immediately in simple words.
            """

        chat = ai_client.chats.create(
            model='gemini-3.5-flash',
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.3, 
            ),
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


if __name__ == '__main__':
  port = int(os.environ.get('PORT', 8000))
  uvicorn.run('main:app', host='0.0.0.0', port=port)