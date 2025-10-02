from pydantic import BaseModel
import datetime

class PosterDetails(BaseModel):
    nameOfTheEvent : str
    date : datetime.date
    time : datetime.time
    entryFee : float