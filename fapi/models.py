from sqlalchemy import Column, Integer, String, Boolean, Text
from database import Base

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
