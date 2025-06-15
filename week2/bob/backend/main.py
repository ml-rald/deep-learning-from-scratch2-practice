from typing import Union

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from nlp import *

app = FastAPI()


@app.get("/morphs")
def extract_morphs(input: Union[str, None] = None):
    if input is not None:
        content = get_morphs(input=input)
        return JSONResponse(content=content, media_type="application/json; charset=utf-8")
    else:
        raise HTTPException(status_code=400, detail="No input")


@app.get("/tags")
def extract_morphs(input: Union[str, None] = None):
    if input is not None:
        content = get_tags(input=input)
        return JSONResponse(content=content, media_type="application/json; charset=utf-8")
    else:
        raise HTTPException(status_code=400, detail="No input")
