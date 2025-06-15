# 백엔드

## 파이썬 3.10 (권장) 설치

```bash
brew install pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc

pyenv install 3.10
pyenv global 3.10
```

## 서브모듈 초기화

```bash
git submodule update --init --recursive # pythorch-bert-crf-ner
```

## 가상환경 생성 및 패키지 설치

```bash
python -m venv .venv
source .venv/bin/activate

python -m ensurepip --upgrade
pip install --upgrade pip
pip install --upgrade setuptools

pip install -r requirements.txt
```

## mxnet 빌드

- apple silicon + macos에서는 직접 빌드 필요 (https://stackoverflow.com/questions/61080629/how-to-fix-libmxnet-so-cannot-open-shared-object-file-no-such-file-or-direct)
- 참고: https://mseagle.tistory.com/133

```bash
# 가상환경 활성화해둔 상태로 진행

mkdir ~/temp
pushd ~/temp

# cmake config 만들기
brew install cmake ninja ccache opencv
git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet
pushd mxnet
cp config/darwin.cmake config.cmake

# build
rm -rf build
mkdir -p build && pushd build
cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build .
popd

# 파이썬 패키지 설치
pushd python
pip install -e .

popd
popd
popd
```

## gluonnlp 수정

```python
# .venv/lib/python3.10/site-packages/gluonnlp/model/attention_cell.py", line 26

# AS-IS
from mxnet.contrib.amp import amp

# TO-BE
from mxnet.amp import amp
```


```python
.venv/lib/python3.10/site-packages/gluonnlp/model/lstmpcellwithclip.py", line 20

# AS-IS
from mxnet.gluon.contrib.rnn import LSTMPCell

# TO-BE
from mxnet.gluon.rnn import LSTMPCell
```

## 서버 시작

```bash
fastapi dev main.py --host 0.0.0.0
```