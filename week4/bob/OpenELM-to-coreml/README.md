# OpenELM-to-coreml

## 가상환경 구성

```bash
### 파이썬 버전 확인
python --version

# 3.9가 아니라면 3.9 설치
pyenv install 3.9
pyenv global 3.9

### 가상환경 구성
python -m venv .venv
source .venv/bin/activate

### pytorch, coremltools 설치
pip install torch==2.5.0
pip install transformers
pip install coremltools
```
