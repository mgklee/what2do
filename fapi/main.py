from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal, Base, engine, get_db
from auth import verify_kakao_token
from crud import get_user_by_kakao_id, create_user, get_todos_by_user
from schemas import OAuthToken, UserResponse
from models import User, Todo, Friend


app = FastAPI()

# 테이블 생성
Base.metadata.create_all(bind=engine)


@app.get("/")
def read_root():
    return {"message": "Server is running"}

@app.get("/users")
def read_root():
    return {"message": "Server is running"}

#로그인 화면
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

# 개인 todo 목록 볼 수 있는 tab1 의 엔드포인트 정리

@app.get("/users/{user_id}/todos")
def get_user_todos(user_id: int, db: Session = Depends(get_db)):
    todos = get_todos_by_user(db, user_id)
    if not todos:
        raise HTTPException(status_code=404, detail="No todos found for the user")
    return todos

# 개인 friend 목록 볼 수 있는 tab4 의 엔드포인트 정리

@app.get("/users/{user_id}/friends")
def get_user_friends(user_id: int, db: Session = Depends(get_db)):
    """
    특정 사용자의 친구 목록을 반환합니다.
    """
    friends = db.query(Friend).filter(Friend.user_id == user_id).all()
    if not friends:
        raise HTTPException(status_code=404, detail="No friends found for the user")
    
    # 친구 목록 데이터를 반환
    friend_list = []
    for friend in friends:
        friend_user = db.query(User).filter(User.id == friend.friend_id).first()
        if friend_user:
            friend_list.append({
                "id": friend_user.id,
                "nickname": friend_user.nickname,
                "profile_image": friend_user.profile_image,
                "email": friend_user.email,
            })

    return {"friends": friend_list}


