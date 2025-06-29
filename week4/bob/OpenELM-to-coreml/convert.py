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
for module in torch_model.modules():
    module.eval()

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
mlmodel.save("OpenELM.mlpackage")
