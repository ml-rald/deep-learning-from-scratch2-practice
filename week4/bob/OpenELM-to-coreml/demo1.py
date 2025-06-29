import torch
import numpy as np
import coremltools as ct
from transformers import AutoModelForCausalLM, AutoTokenizer

torch_model = AutoModelForCausalLM.from_pretrained(
    "apple/OpenELM-270M-Instruct",
    torch_dtype=torch.float32,
    trust_remote_code=True,
    return_dict=False,
    use_cache=False,
)
torch_model.eval()

tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-2-7b-hf")

# prompt = "Once upon a time there was"
prompt = "I live in South Korea, and"
tokenized_prompt = torch.tensor(tokenizer(prompt)["input_ids"])
# Since model takes input ids in batch,
# create a dummy batch dimension (i.e. size 1) for tokenized prompt
tokenized_prompt = tokenized_prompt.unsqueeze(0)

max_sequence_length = 64

input_ids = tokenized_prompt
print(input_ids)
# extend sentence (sequence) word-by-word (token-by-token)
# until reach max sequence length
for i in range(max_sequence_length):
    logits = torch_model(input_ids)[0]
    # determine the next token by greedily choosing the one with highest logit (probability)
    output_id = torch.argmax(logits, -1)[:, -1 :]
    # append the next token to sequence
    input_ids = torch.cat((input_ids, output_id), axis=-1)
# decode tokens back to text
output_text = tokenizer.decode(input_ids[0].tolist(), skip_special_tokens=True)
print("Output text from the original torch model:")
print(output_text)
