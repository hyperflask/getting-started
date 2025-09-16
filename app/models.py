from hyperflask.factory import db
from hyperflask_users import UserMixin, UserRelatedMixin
import datetime

class User(UserMixin, db.Model):
    pass

class Room(db.Model):
    name: str

class Message(UserRelatedMixin, db.Model):
    __macro__ = "ChatMessage(message)"
    message: str
    timestamp: datetime.datetime = db.Column(default=datetime.datetime.utcnow)
    room_id: int = db.Column(references=Room.id)
    room = db.Relationship(Room, "id", "room_id", single=True)
