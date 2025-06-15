from konlpy.tag import Komoran

komoran = Komoran()

def get_morphs(input: str):
    return komoran.morphs(input)

def get_tags(input: str):
    return komoran.pos(input)

if __name__ == "__main__":
    print(get_morphs("토큰화 테스트입니다"))
    print(get_tags("품사 태깅 테스트입니다"))
