from abc import ABC, abstractmethod
from typing import List
import datetime
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.pydantic_models.pydanticModels import PosterDetails

class PosterDetailsInterface(ABC):
    @abstractmethod
    def addPosterDetailsToDatabase(self, posterDetailsObject: PosterDetails) -> PosterDetails:
        """
        This function adds the poster details  data contained in the posterDetailsObject to a database,
        as a posterDetailsObject
        """
        pass
    
    @abstractmethod
    def getPosterById(self,posterId: str) -> PosterDetails|None:
        """
        This function retrieves a posterDetailsObject from the database by finding it using its ID
        and returns it
        """
        pass
    
    @abstractmethod
    def getAllPosters(self) -> List[PosterDetails]:
        """
        This method returns a list of all the posterDetailsObjects in the database
        """
        pass

    @abstractmethod
    def deletePoster(self, posterId: str) -> bool:
        """
        This method deletes a poster by finding it using its id
        """
        pass
    
    @abstractmethod
    def getAllPostersByDate(self, date: datetime.date) -> List[PosterDetails]:
        """
        This method returns a list containing all the posters with events on a particular date
        """
        pass

    @abstractmethod
    def getAllPostersAfterSetTime(self, time: datetime.time) -> List[PosterDetails]:
        """
        This method returns a list of all the posters that happen after a particular time, each day
        """
        pass

    @abstractmethod
    def getAllUpcomingPosters(self, date: datetime.date, time: datetime.time) -> List[PosterDetails]:
        """
        This method returns a list of all the posters which are yet to finish from the current date
        and the current time
        """
        pass


