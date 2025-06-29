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

# Export
example_input_ids = torch.zeros((1, 32), dtype=torch.int32)
sequence_length = torch.export.Dim(name="sequence_length", min=1, max=128)
dynamic_shapes = {"input_ids": {1: sequence_length}}
exported_program = torch.export.export(
    torch_model,
    (example_input_ids,),
    dynamic_shapes=dynamic_shapes,
)

mlmodel = ct.convert(exported_program)

# Inference
max_sequence_length = 64
input_ids = np.int32(tokenized_prompt.detach().numpy())
# extend sentence (sequence) word-by-word (token-by-token)
# until reach max sequence length
for i in range(max_sequence_length):
    logits = list(mlmodel.predict({"input_ids": input_ids}).values())[0]
    # determine the next token by greedily choosing the one with highest logit (probability)
    output_id = np.argmax(logits, -1)[:, -1 :]
    # append the next token to sequence
    input_ids = np.concat((input_ids, output_id), dtype=np.int32, axis=-1)
# decode tokens back to text
output_text = tokenizer.decode(input_ids[0].tolist(), skip_special_tokens=True)
print("Output text from the converted Core ML model:")
print(output_text)
