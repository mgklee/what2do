from sqlalchemy.orm import Session
from models import User,Todo, Friend
from typing import Optional

#카카오 로그인 및 회원 가입 관련 crud 정리
def get_user_by_kakao_id(db: Session, kakao_id: str) -> Optional[User]:
    """
    주어진 kakao_id를 가진 사용자를 데이터베이스에서 검색합니다.
    """
    return db.query(User).filter(User.kakao_id == kakao_id).first()


def create_user(
    db: Session,
    kakao_id: str,
    connected_at: str,
    email: Optional[str],
    nickname: Optional[str],
    profile_image: Optional[str],
    thumbnail_image: Optional[str],
    profile_nickname_needs_agreement: Optional[bool],
    profile_image_needs_agreement: Optional[bool],
    is_default_image: Optional[bool],
    is_default_nickname: Optional[bool],
) -> User:
    """
    주어진 정보를 바탕으로 새로운 사용자를 생성하고 데이터베이스에 저장
    """
    user = User(
        kakao_id=kakao_id,
        connected_at=connected_at,
        email=email,
        nickname=nickname,
        profile_image=profile_image,
        thumbnail_image=thumbnail_image,
        profile_nickname_needs_agreement=profile_nickname_needs_agreement,
        profile_image_needs_agreement=profile_image_needs_agreement,
        is_default_image=is_default_image,
        is_default_nickname=is_default_nickname,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

#todo 테이블 관련 crud 정리
def create_todo(db: Session, user_id: int, date_created, category: str, task: str):
    todo = Todo(
        user_id=user_id,
        date_created=date_created,
        category=category,
        task=task
    )
    db.add(todo)
    db.commit()
    db.refresh(todo)
    return todo

def get_todos_by_user(db: Session, user_id: int):
    return db.query(Todo).filter(Todo.user_id == user_id).all()

def get_todos_by_friends(db: Session, user_id: int, limit: int = 10, offset: int = 0):
    # 1. 친구 ID 가져오기
    friends = db.query(Friend.friend_id).filter(Friend.user_id == user_id).all()
    friend_ids = [friend[0] for friend in friends]

    # 친구 ID로 User 정보 가져오기
    friends_data = db.query(User).filter(User.id.in_(friend_ids)).all()

    # 2. 각 친구의 todos 가져오기 (is_locked == True 조건 추가)
    result = []
    for friend in friends_data:
        # 해당 친구의 모든 todos 가져오기
        todos = db.query(Todo).filter(
            Todo.user_id == friend.id,
            Todo.is_locked == True
        ).all()

        # 3. 카테고리별로 그룹화
        categories = {}
        for todo in todos:
            if todo.category not in categories:
                categories[todo.category] = []
            categories[todo.category].append({
                "task": todo.task,
                "date_created": todo.date_created
            })

        # 카테고리별 데이터를 리스트 형태로 변환
        categories_list = [{"category": category, "todos": todos} for category, todos in categories.items()]

        # 최종 결과에 추가
        result.append({
            "nickname": friend.nickname,
            "profile_image": friend.profile_image,
            "categories": categories_list
        })

    return result


#friend 테이블 관련 crud 정리

def create_friend(db: Session, user_id: int, friend_id: int):
    """
    친구 추가
    """
    if user_id == friend_id:
        raise HTTPException(status_code=400, detail="You cannot add yourself as a friend.")

    # 중복된 관계 확인
    existing_friendship = db.query(Friend).filter_by(user_id=user_id, friend_id=friend_id).first()
    if existing_friendship:
        raise HTTPException(status_code=400, detail="Friendship already exists.")

    # 새로운 친구 관계 추가
    new_friend1 = Friend(user_id=user_id, friend_id=friend_id)
    new_friend2 = Friend(user_id=friend_id, friend_id=user_id)
    db.add(new_friend1)
    db.add(new_friend2)
    db.commit()
    db.refresh(new_friend1)
    db.refresh(new_friend2)
    
    return new_friend


def get_friends_by_user_id(db: Session, user_id: int):
    """
    특정 사용자의 모든 친구 조회
    """
    friends = db.query(Friend).filter_by(user_id=user_id).all()
    return friends


def update_friend(db: Session, friend_id: int, user_id: int, new_friend_id: int):
    """
    친구 정보 업데이트 (예: 기존 친구 관계를 다른 사용자로 변경)
    """
    friend_relationship = db.query(Friend).filter_by(user_id=user_id, friend_id=friend_id).first()

    if not friend_relationship:
        raise HTTPException(status_code=404, detail="Friendship not found.")

    # 업데이트 (기존 friend_id -> new_friend_id)
    friend_relationship.friend_id = new_friend_id
    db.commit()
    db.refresh(friend_relationship)

    return friend_relationship


def delete_friend(db: Session, user_id: int, friend_id: int):
    """
    친구 삭제
    """
    friend_relationship = db.query(Friend).filter_by(user_id=user_id, friend_id=friend_id).first()

    if not friend_relationship:
        raise HTTPException(status_code=404, detail="Friendship not found.")

    # 친구 관계 삭제
    db.delete(friend_relationship)
    db.commit()

    return {"message": "Friend deleted successfully"}
