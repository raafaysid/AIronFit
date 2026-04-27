from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import (
    WorkoutRecommendationRequest,
    WorkoutRecommendationResponse,
    ExerciseSuggestionRequest,
    ExerciseSuggestionResponse
)
from recommendation import get_workout_recommendation, get_exercise_suggestion
import uvicorn

app = FastAPI(
    title="AIronFit API",
    description="AI-powered workout recommendation backend for AIronFit",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "AIronFit API"}

@app.post("/recommend-workout", response_model=WorkoutRecommendationResponse)
def recommend_workout(request: WorkoutRecommendationRequest):
    try:
        result = get_workout_recommendation(request)
        return result
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.post("/suggest-next-exercise", response_model=ExerciseSuggestionResponse)
def suggest_next_exercise(request: ExerciseSuggestionRequest):
    try:
        result = get_exercise_suggestion(request)
        return result
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)