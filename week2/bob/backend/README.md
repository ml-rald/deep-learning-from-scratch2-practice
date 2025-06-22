# 백엔드

## 파이썬 3.10 (권장) 설치

```bash
brew install pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init - zsh)"' >> ~/.zshrc

pyenv install 3.9
pyenv global 3.9
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
pip install wheel

pip install -r requirements.txt
```

## tensorflow 수동 설치

```bash
curl -O https://storage.googleapis.com/tensorflow/versions/2.19.0/tensorflow-2.19.0-cp39-cp39-macosx_12_0_arm64.whl
pip install tensorflow-2.19.0-cp39-cp39-macosx_12_0_arm64.whl
rm tensorflow-2.19.0-cp39-cp39-macosx_12_0_arm64.whl
```

## mxnet 빌드

- apple silicon + macos에서는 직접 빌드 필요 (https://stackoverflow.com/questions/61080629/how-to-fix-libmxnet-so-cannot-open-shared-object-file-no-such-file-or-direct)
- 참고: https://mseagle.tistory.com/133

```bash
# 가상환경 활성화해둔 상태로 진행

# 빌드를 위한 디렉토리 생성
mkdir ~/mlstudy
pushd ~/mlstudy

# 빌드 준비
brew install cmake ninja ccache opencv coreutils
git clone https://github.com/apache/incubator-mxnet.git mxnet
pushd mxnet
git switch v1.9.1 # 최신 커밋으로는 빌드는 가능하지만 인터페이스가 바뀌었는지 원할하게 작동이 안됨. v1.9.1로 시도.
git submodule update --init --recursive
cp config/darwin.cmake config.cmake

# 빌드
rm -rf build
mkdir -p build && pushd build
cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DUSE_F16C=OFF -DUSE_SSE=OFF # 애플 실리콘(arm64)를 위한 바이너리를 빌드하므로 F16C, SSE 비활성화
cmake --build .
popd

# 파이썬 패키지 설치
pushd python
pip install -e .

popd
popd
```

## numpy 이전 버전으로 덮어쓰기

```bash
pip install numpy==1.23.1
```

## pytorch-bert-crf-net 세팅

### pytorch-crf 설치

```bash
pip install pytorch-crf==0.7.2
```

### sentencepiece 설치 중 오류나면 직접 설치

```bash
pip install sentencepiece==0.1.96 # 실패하는 경우 아래 실행...

git clone https://github.com/google/sentencepiece.git
git checkout v0.1.96
pushd sentencepiece
mkdir build
cd build
cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_CXX_FLAGS="-Wno-enum-constexpr-conversion"
make -j $(nproc)
sudo make install
# sudo ldconfig -v # not for macos

cd ../python
pip install .

popd
popd # backend/
```

### pytorch-bert-crf-net 코드 수정

- https://malin.tistory.com/63 참고

### pytorch-bert-crf-net 모델 다운로드

- https://works.do/FhKyyNr 접속
- `best-epoch-12-step-1000-acc-0.960.bin` 파일 다운로드
- `pytorch-bert-crf-net/experiments/base_model_with_crf_val/` 위치에 파일 복사

### 테스트

```bash
export DYLD_LIBRARY_PATH=/usr/local/lib:$DYLD_LIBRARY_PATH # ref: https://stackoverflow.com/a/77824220
cd pytorch-bert-crf-net
python inference.py
```

- ❌ 여전히 문제... 실행은 되지만 추론이 전혀 되지 않는다...
    ```
    문장을 입력하세요: 지난달 28일 수원에 살고 있는 윤주성 연구원은 코엑스(서울 삼성역)에서 개최되는 DEVIEW 2019 Day1에 참석했다.
    len: 38, input_token:['[CLS]', '▁지난달', '▁28', '일', '▁수원', '에', '▁살', '고', '▁있는', '▁윤', '주', '성', '▁연구원은', '▁코', '엑스', '(', '서울', '▁삼성', '역', ')', '에서', '▁개최', '되는', '▁D', 'E', 'V', 'I', 'E', 'W', '▁20', '19', '▁D', 'ay', '1', '에', '▁참석했다', '.', '[SEP]']
    len: 1, pred_ner_tag:['[CLS]']
    list_of_ner_word: []
    decoding_ner_sentence: [CLS]
    ```

## 서버 시작

```bash
fastapi dev main.py --host 0.0.0.0 # 시뮬레이터에서 접근할 수 있도록 호스트를 0.0.0.0으로 지정
```
