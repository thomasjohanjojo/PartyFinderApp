from pydantic import BaseModel
import datetime

class PosterDetails(BaseModel):
    nameOfTheEvent : str
    date : datetime.date
    time : datetime.time
    entryFee : float

    def _init_(self, nameOfTheEvent, date, time, entryFee):
        self.nameOfTheEvent = nameOfTheEvent
        self.date = date
        self.time = time
        self.entryFee = entryFee