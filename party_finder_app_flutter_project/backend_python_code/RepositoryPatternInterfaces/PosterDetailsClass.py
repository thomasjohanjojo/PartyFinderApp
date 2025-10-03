from pymongo import MongoClient
from pymongo.collection import Collection
from pymongo.errors import PyMongoError
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