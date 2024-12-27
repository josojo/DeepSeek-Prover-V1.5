from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import torch
from transformers import AutoTokenizer
from vllm import LLM, SamplingParams
import uvicorn

app = FastAPI()

# Model initialization
MODEL_NAME = "deepseek-ai/DeepSeek-Prover-V1.5-RL"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = LLM(
    model=MODEL_NAME,
    max_num_batched_tokens=8192,
    seed=1,
    trust_remote_code=True
)

# Request body schema
class PromptRequest(BaseModel):
    prompt: str

@app.post("/generate")
async def generate_text(request: PromptRequest):
    try:
        sampling_params = SamplingParams(
            temperature=1.0,
            max_tokens=2048,
            top_p=0.95,
            n=1,
        )

        outputs = model.generate(
            [request.prompt],
            sampling_params,
            use_tqdm=False,
        )

        return {
            "generated_text": outputs[0].outputs[0].text,
            "status": "success"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
