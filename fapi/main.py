from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, Base, engine
from auth import verify_kakao_token
from crud import get_user_by_kakao_id, create_user
from schemas import OAuthToken, UserResponse
from models import User


app = FastAPI()

# 테이블 생성
Base.metadata.create_all(bind=engine)

# Dependency: DB 세션
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"message": "Server is running"}

@app.get("/users")
def read_root():
    return {"message": "Server is running"}


@app.post("/users/login", response_model=UserResponse)
def login_or_register_with_kakao(token: OAuthToken, db: Session = Depends(get_db)):
    kakao_user_info = verify_kakao_token(token.oauth_token)

    user = get_user_by_kakao_id(db, kakao_id=kakao_user_info["id"])
    if not user:
        user = create_user(
            db,
            kakao_id=kakao_user_info["id"],
            connected_at=kakao_user_info.get("connected_at"),
            email=kakao_user_info.get("kakao_account", {}).get("email"),
            nickname=kakao_user_info.get("properties", {}).get("nickname"),
            profile_image=kakao_user_info.get("properties", {}).get("profile_image"),
            thumbnail_image=kakao_user_info.get("properties", {}).get("thumbnail_image"),
            profile_nickname_needs_agreement=kakao_user_info.get("kakao_account", {}).get(
                "profile_nickname_needs_agreement"
            ),
            profile_image_needs_agreement=kakao_user_info.get("kakao_account", {}).get(
                "profile_image_needs_agreement"
            ),
            is_default_image=kakao_user_info.get("kakao_account", {}).get("profile", {}).get(
                "is_default_image"
            ),
            is_default_nickname=kakao_user_info.get("kakao_account", {}).get("profile", {}).get(
                "is_default_nickname"
            ),
        )

    return UserResponse(
        id=user.id,
        kakao_id=user.kakao_id,
        connected_at=user.connected_at,
        email=user.email,
        nickname=user.nickname,
        profile_image=user.profile_image,
        thumbnail_image=user.thumbnail_image,
        profile_nickname_needs_agreement=user.profile_nickname_needs_agreement,
        profile_image_needs_agreement=user.profile_image_needs_agreement,
        is_default_image=user.is_default_image,
        is_default_nickname=user.is_default_nickname,
    )
