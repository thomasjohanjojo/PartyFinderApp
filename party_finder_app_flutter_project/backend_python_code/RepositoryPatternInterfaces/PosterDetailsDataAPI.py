from fastapi import FastAPI, APIRouter, Depends, HTTPException
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.pydantic_models.pydanticModels import PosterDetails
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.PosterDetailsInterface import PosterDetailsInterface
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.PosterDetailsClass import PosterDetailsClass
from typing import Annotated, List
from functools import lru_cache #To make the database connection a singlton to prevent re instantiation


app = FastAPI()

# --- 1. THE DEPENDENCY PROVIDER ---
# This function acts as the "Factory". It tells FastAPI:
# "When an endpoint asks for a repository, give them THIS concrete instance."
@lru_cache
def get_poster_repo() -> PosterDetailsInterface:
    print("Creating the poster details class database instance singlton...")
    posterDetailsClassObject = PosterDetailsClass()
    return posterDetailsClassObject

# --- 2. THE ENDPOINT ---
@app.get("/posters/{posterID}", response_model=PosterDetails, summary="Get a poster by its ID")
def getPosterByID(
    posterID: str,
    # DEPENDENCY INJECTION:
    # We type-hint with the Interface (PosterInterface) for better code completion,
    # but we use Depends(get_poster_repo) to inject the actual Concrete class.
    repo: Annotated[PosterDetailsInterface, Depends(get_poster_repo)]
):
    """
    Fetches a poster by ID using the injected repository implementation.
    """

    # Call the function from your interface
    poster = repo.getPosterById(posterID)

    # Handle the 'None' case
    if poster is None:
        raise HTTPException(status_code=404, detail=f"Poster {posterID} not found")
    
    return poster

# --- 3. ANOTHER ENDPOINT ---
@app.get("/posters", response_model= List[PosterDetails], summary="Get a list of all the posters")
def getAllPosters(
    # Reuse the same singleton dependency provider
    repo: Annotated[PosterDetailsInterface, Depends(get_poster_repo)]
):
    """
    Retrieves all available posters from the repository.
    The response will be an array of PosterDetails objects.
    """
    
    # Call your abstract method from the injected concrete class
    all_posters = repo.getAllPosters()

    # Unlike the single-item lookup, you usually don't raise a 404 
    # if the list is empty; you return an empty list ([]).
    
    return all_posters