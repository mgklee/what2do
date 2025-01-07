from sqlalchemy import Column, Integer, String, Boolean, Text, Date, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from database import Base

# 데이터베이스  모델을 정의함

class User(Base):
    __tablename__ = "users"

    # 기본 필드
    id = Column(Integer, primary_key=True, index=True)
    kakao_id = Column(String, unique=True, nullable=False)  # 카카오 사용자 ID
    connected_at = Column(String, nullable=True)  # 카카오와 연결된 시간
    email = Column(String, unique=True, nullable=True)  # 이메일 (카카오에서 필수 제공 아님)
    
    # properties 필드
    nickname = Column(String, nullable=True)  # 닉네임
    profile_image = Column(Text, nullable=True)  # 프로필 이미지 URL
    thumbnail_image = Column(Text, nullable=True)  # 썸네일 이미지 URL

    # kakao_account 필드
    profile_nickname_needs_agreement = Column(Boolean, nullable=True)  # 닉네임 동의 필요 여부
    profile_image_needs_agreement = Column(Boolean, nullable=True)  # 프로필 이미지 동의 필요 여부
    is_default_image = Column(Boolean, nullable=True)  # 기본 이미지 여부
    is_default_nickname = Column(Boolean, nullable=True)  # 기본 닉네임 여부

    # Relationship with Todo table
    todos = relationship("Todo", back_populates="user")

class Todo(Base):
    __tablename__="todo"

    """users 테이블에서 id 를 외래키로 받는게 primary 키, 어떤 날에 생성한건지 날짜 DATE 타입,
    어떤 category인지 TEXT 타입, 각각의 category마다 할 일 적기 TEXT 타입, 보여줄지 말지 결정 lock 이거는 boolean타입 (잠그면 0, 보여주면 1), 할 일 수행 후 완료 체크 이것도 boolean 타입"""

    # 필드 정의
    id = Column(Integer, primary_key=True, index=True)  # 고유 ID
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # User 테이블의 id를 외래키로 참조
    date_created = Column(Date, nullable=False)  # 생성된 날짜
    category = Column(Text, nullable=False)  # 카테고리
    task = Column(Text, nullable=False)  # 할 일
    is_locked = Column(Boolean, default=False, nullable=False)  # 잠금 상태 (잠김=0, 보여줌=1)
    is_completed = Column(Boolean, default=False, nullable=False)  # 완료 여부 (미완료=0, 완료=1)

    # Relationship with User table
    user = relationship("User", back_populates="todos")

class Friend(Base):
    __tablename__ = "friend"

    """일단 프론트엔드 쪽에서 현재 사용자의 마이페이지 내에 있는 입력창에 다른 사람의 user.id를 입력하면 현재 사용자의 친구로 지정되게 할거야. """

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # 현재 사용자 ID
    friend_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # 친구 사용자 ID

    # UniqueConstraint를 통해 동일한 사용자 간 중복된 관계 방지
    __table_args__ = (UniqueConstraint('user_id', 'friend_id', name='unique_friendship'),)

    # Relationship 정의
    user = relationship("User", foreign_keys=[user_id], backref="friends")  # 현재 사용자
    friend = relationship("User", foreign_keys=[friend_id])  # 친구 사용자

# class Timetable(Base):
#     __tablename__="Timetable"

#     """일단 이 테이블은 ㅇㅇ"""
#     #필드 정의
#     id = Column(Integer, primary_key=True, index=True)
#     year = Column(Integar)
#     season = Column(Integar)
#     url = 


