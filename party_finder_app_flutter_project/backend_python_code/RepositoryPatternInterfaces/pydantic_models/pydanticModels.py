from pydantic import BaseModel
import datetime

class PosterDetails(BaseModel):
    id : str
    nameOfTheEvent : str
    dateAndTime: datetime.datetime
    entryFee : float