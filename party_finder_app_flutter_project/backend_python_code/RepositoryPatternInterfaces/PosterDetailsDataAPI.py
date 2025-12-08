from fastapi import FastAPI, APIRouter, Depends, HTTPException, status
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.pydantic_models.pydanticModels import PosterDetails
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.PosterDetailsInterface import PosterDetailsInterface
from party_finder_app_flutter_project.backend_python_code.RepositoryPatternInterfaces.PosterDetailsClass import PosterDetailsClass
from typing import Annotated, List
from functools import lru_cache #To make the database connection a singlton to prevent re instantiation
from datetime import date as DateType # Import date and alias it to avoid conflict


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

# --- The Endpoint Definition ---

# 1. Use @app.delete() decorator
# 2. Use the path parameter {poster_id}
# 3. No response_model is strictly required, as the function returns a simple status.
@app.delete("/posters/{poster_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete a poster by its ID")
def delete_poster_by_id(
    poster_id: str,
    # Inject the repository instance
    repo: Annotated[PosterDetailsInterface, Depends(get_poster_repo)]
):
    """
    Deletes a single poster using its unique ID.
    Returns HTTP 204 No Content upon successful deletion.
    """
    
    # Call your abstract method from the injected concrete class
    success = repo.deletePoster(poster_id)

    # Handle the result based on the boolean return
    if not success:
        # If the repository reports the delete failed (likely because the ID wasn't found)
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Poster with ID '{poster_id}' not found or could not be deleted"
        )
    
    # If successful, FastAPI will automatically return the 
    # status_code defined in the decorator (204 No Content).
    return

# --- The Endpoint Definition ---

# 1. Path is /posters/by_date. This is clean and avoids mixing with /posters/{id}
# 2. response_model is List[PosterDetails]
@app.get(
    "/posters/by_date", 
    response_model=List[PosterDetails], 
    summary="Get all posters for a specific date"
)
def get_posters_by_date(
    # Query Parameter: FastAPI automatically looks for '?date=YYYY-MM-DD'
    date: DateType, 
    # Reuse the singleton dependency
    repo: Annotated[PosterDetailsInterface, Depends(get_poster_repo)]
):
    """
    Retrieves all posters that have an event scheduled on the provided date (YYYY-MM-DD).
    If no posters are found, an empty list is returned.
    """
    
    # Call the abstract method from the injected concrete class
    posters = repo.getAllPostersByDate(date)

    # Return the list. An empty list is the correct response if no posters are found.
    return posters