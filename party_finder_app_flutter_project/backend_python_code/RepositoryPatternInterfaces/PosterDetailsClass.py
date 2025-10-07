from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.errors import PyMongoError
from bson.objectid import ObjectId
from typing import List, Optional
import datetime
from pymongo.errors import ConnectionFailure
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.pydantic_models.pydanticModels import PosterDetails
from .PosterDetailsInterface import PosterDetailsInterface

class DatabaseConnectionError(Exception): pass

class PosterDetailsClass(PosterDetailsInterface):

    #  CONFIGURATION INFORMATION
    MONGO_DATABASE_URI = "mongodb://localhost:27017/" #The uri to the server where mongodb is running
    NAME_OF_MONGO_DATABASE = "PartyAppDatabase"
    NAME_OF_POSTER_DETAILS_COLLECTION = "PosterDetailsCollection"
    
    #Collection object
    posterDetailsCollection: Optional[Collection] = None

    def __init__(self):
        try:
            clientToAccessMongoDBDatabase = MongoClient(self.MONGO_DATABASE_URI)
            if clientToAccessMongoDBDatabase.admin.command('ping'):
                print(f"Successfully connected to MongoDB server at {self.MONGO_DATABASE_URI}.")

            mongoDatabase = clientToAccessMongoDBDatabase[self.NAME_OF_MONGO_DATABASE]
            self.posterDetailsCollection = mongoDatabase[self.NAME_OF_POSTER_DETAILS_COLLECTION]

        except ConnectionFailure as e:
            raise DatabaseConnectionError(
                "Could not connect to MongoDB server. "
                "Please ensure MongoDB is running locally on port 27017."
            ) from e
        except Exception as e:
            # Catch all other unexpected errors during initialization
            raise DatabaseConnectionError(
                f"An unexpected error occurred during database setup: {e}"
            ) from e
    
    def addPosterDetailsToDatabase(self, posterDetailsObject: PosterDetails) -> PosterDetails|None:
        if self.posterDetailsCollection is None:
            raise DatabaseConnectionError("Collection object is not initialized. Cannot perform operation.")
        
        posterDetailsAsPythonDictionary = Optional[dict]
        posterDetailsAsPythonDictionary = posterDetailsObject.model_dump(exclude={"id"})
        try:
            resultAsPymongoResult = self.posterDetailsCollection.insert_one(posterDetailsAsPythonDictionary)
            if resultAsPymongoResult.inserted_id:
                posterDetailsObject.id = str(resultAsPymongoResult.inserted_id)
                return posterDetailsObject
            else:
                raise RuntimeError
                return None
        except PyMongoError as e:
            # Catch specific pymongo operational errors
            print(f"Database insertion error: {e}")
            # Raise a runtime error for operational failures
            raise RuntimeError(f"MongoDB insertion operation failed: {e}") from e
        except Exception as e:
            # Catch any other unexpected exception
            print(f"Unexpected error during insertion: {e}")
            return None

    def getPosterById(self, posterId: str) -> PosterDetails|None:
        if self.posterDetailsCollection is None:
            raise DatabaseConnectionError("Collection object is not initialized. Cannot perform operation.")
        try:
            idObjectConvertedToBsonObjectId = ObjectId(posterId)
            mongoDBretrievedObject = self.posterDetailsCollection.find_one(
                {"_id": idObjectConvertedToBsonObjectId}
                )
            
            if mongoDBretrievedObject is None:
                print(f"PosterId does not exist: {posterId}")
                return None
            
            mongoDBretrievedObject["id"] = str(mongoDBretrievedObject.pop("_id"))
            posterDetailsObject = PosterDetails.model_validate(mongoDBretrievedObject)
            return posterDetailsObject
        
        except PyMongoError as e:
            # Operational database error (e.g., query failure)
            raise RuntimeError(f"MongoDB retrieval operation failed: {e}") from e
        except Exception as e:
            # Catch errors like invalid ObjectId format (ValueError)
            raise RuntimeError(f"An unexpected error occurred during retrieval: {e}") from e
    
    def getAllPosters(self) -> List[PosterDetails]:
        if self.posterDetailsCollection is None:
            raise DatabaseConnectionError("Collection Object is not initialized. Cannot perform operation.")
        try:
            listOfPosterDetailsObjects: List[PosterDetails] = []
            pymongoCursor = self.posterDetailsCollection.find({})
            for posterObjectInCursor in pymongoCursor:
                posterObjectInCursor["id"] = str(posterObjectInCursor.pop("_id"))
                pydanticVerifiedPosterDetailsObject = PosterDetails.model_validate(posterObjectInCursor)
                listOfPosterDetailsObjects.append(pydanticVerifiedPosterDetailsObject)
            
            return listOfPosterDetailsObjects
        
        except Exception as e:
            raise RuntimeError(f"MongoDB bulk retrieval operation failed: {e}") from e
                
    def deletePoster(self, posterId: str) -> bool:
        if self.posterDetailsCollection is None:
            raise DatabaseConnectionError("Collection Object is not initialized. Cannot perform operation.")
        try:
            objectIdInBson = ObjectId(posterId)
            queryFilter = {"_id": objectIdInBson}
            resultWithDeletionCount = self.posterDetailsCollection.delete_one(queryFilter)
            if resultWithDeletionCount.deleted_count == 1:
                deletionSuccessStatus = True
                return deletionSuccessStatus
            else:
                deletionSuccessStatus = False
                return deletionSuccessStatus
        except Exception as e:
            raise RuntimeError(f"MongoDB deletion operation failed: {e}") from e
    
    def getAllPostersByDate(self, date: datetime.date) -> List[PosterDetails]:
        if self.posterDetailsCollection is None:
            raise DatabaseConnectionError("Collection Object is not initialized. Cannot perform operation")
        try:
            listOfPosterDetailsObjects: List[PosterDetails] = []
            
            startOfTheDay = datetime.datetime(date.year, date.month, date.day, 0, 0, 0 )
            startOfTheNextDay = datetime.datetime(
                (date + datetime.timedelta(days=1)).year,
                (date + datetime.timedelta(days=1)).month,
                (date + datetime.timedelta(days=1)).day,
                0, # Hour
                0, # Minute
                0 #second
                )
            pymongoCursor = self.posterDetailsCollection.find({
                "dateAndTime": {
                    "$gte": startOfTheDay,
                    "$lt": startOfTheNextDay
                    }})
            for posterObjectInCursor in pymongoCursor:
                posterObjectInCursor["id"] = str(posterObjectInCursor.pop("_id"))
                pydanticVerifiedPosterDetailsObject = PosterDetails.model_validate(posterObjectInCursor)
                listOfPosterDetailsObjects.append(pydanticVerifiedPosterDetailsObject)
            
            return listOfPosterDetailsObjects
        except Exception as e:
            raise RuntimeError(f"MongoDB bulk retrieval operation failed: {e}") from e
    
    def getAllPostersAfterSetTime(self, time: datetime.time) -> List[PosterDetails]:
        if self.posterDetailsCollection is None:
            raise DatabaseConnectionError("Collection object is not initialized. Cannot perform operation")
        try:
            listOfPosterDetailsObjects: List[PosterDetails] = []
            pymongoCursor = self.posterDetailsCollection.find({})
            for posterObjectInCursor in pymongoCursor:
                posterObjectInCursor["id"] = str(posterObjectInCursor.pop("_id"))
                pydanticVerifiedPosterDetailsObject = PosterDetails.model_validate(posterObjectInCursor)
                if pydanticVerifiedPosterDetailsObject.dateAndTime.time() > time:
                    listOfPosterDetailsObjects.append(pydanticVerifiedPosterDetailsObject)
            
            return listOfPosterDetailsObjects
        except Exception as e:
            raise RuntimeError(f"MongoDB bulk retrieval operation failed: {e}") from e