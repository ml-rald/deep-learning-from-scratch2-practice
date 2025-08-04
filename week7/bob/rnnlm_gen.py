import sys
import numpy as np
from common.functions import softmax
from ch6.rnnlm import Rnnlm
from ch6.better_rnnlm import BetterRnnlm

'''
RNN을 이용해 문장을 생성하는 클래스
ch6에서 만든 Rnnlm을 상속한다.
'''
class RnnlmGen(Rnnlm):
    '''
    시작 단어로부터 문장을 생성하는 메서드
    start_id: 시작 단어 id
    skip_ids: 스킵할 단어 id 배열. PTB 데이터셋의 전처리 단어 등을 제외하고 싶을 때 지정한다
    sample_size: 결과 데이터 크기
    '''
    def generate(self, start_id, skip_ids=None, sample_size=100):
        word_ids = [start_id]

        x = start_id # 일단 x를 시작 단어 id로 세팅한다
        while len(word_ids) < sample_size: # 샘플링 크기만큼 반복한다
            x = np.array(x).reshape(1, 1) # predict 메서드에 넘길 수 있는 2차원 배열로 만든다. [[x]]
            score = self.predict(x) # 추론한다 ex> [[0, 1, 2]]
            p = softmax(score.flatten()) # 1차원으로 만들고 softmax 함수를 통해 각각을 확률로 만든다

            sampled = np.random.choice(len(p), size=1, p=p) # p 배열의 각 인덱스에 대해, 각 확률을 고려해 랜덤으로 한 개를 뽑아낸다.
            if (skip_ids is None) or (sampled not in skip_ids):
                x = sampled # x는 지금 뽑힌 단어의 id로 설정한다
                word_ids.append(int(x)) # 단어 id를 모은다

        return word_ids # 샘플링한 단어의 id들을 반환한다

    def get_state(self):
        return self.lstm_layer.h, self.lstm_layer.c

    def set_state(self, state):
        self.lstm_layer.set_state(*state)


'''
RNN을 이용해 문장을 생성하는 클래스 개선
ch6에서 만든 BetterRnnlm을 상속한다.
'''
class BetterRnnlmGen(BetterRnnlm):
    '''
    시작 단어로부터 문장을 생성하는 메서드
    start_id: 시작 단어 id
    skip_ids: 스킵할 단어 id 배열. PTB 데이터셋의 전처리 단어 등을 제외하고 싶을 때 지정한다
    sample_size: 결과 데이터 크기
    '''
    def generate(self, start_id, skip_ids=None, sample_size=100):
        word_ids = [start_id]

        x = start_id # 일단 x를 시작 단어 id로 세팅한다
        while len(word_ids) < sample_size: # 샘플링 크기만큼 반복한다
            x = np.array(x).reshape(1, 1) # predict 메서드에 넘길 수 있는 2차원 배열로 만든다. [[x]]
            score = self.predict(x) # 추론한다 ex> [[0, 1, 2]]
            p = softmax(score.flatten()) # 1차원으로 만들고 softmax 함수를 통해 각각을 확률로 만든다

            sampled = np.random.choice(len(p), size=1, p=p) # p 배열의 각 인덱스에 대해, 각 확률을 고려해 랜덤으로 한 개를 뽑아낸다.
            if (skip_ids is None) or (sampled not in skip_ids):
                x = sampled # x는 지금 뽑힌 단어의 id로 설정한다
                word_ids.append(int(x)) # 단어 id를 모은다

        return word_ids # 샘플링한 단어의 id들을 반환한다

    def get_state(self):
        return self.lstm_layer.h, self.lstm_layer.c

    def set_state(self, state):
        self.lstm_layer.set_state(*state)
