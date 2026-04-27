from pydantic import BaseModel
from typing import Optional

class WorkoutSet(BaseModel):
    weight: float
    reps: float

class Exercise(BaseModel):
    name: str
    muscleGroup: str
    targetMuscle: str
    equipmentType: str
    sets: list[WorkoutSet] = []

class Workout(BaseModel):
    date: str
    duration: float
    exercises: list[Exercise] = []

class WorkoutRecommendationRequest(BaseModel):
    recentWorkouts: list[Workout]
    selectedMuscleGroups: list[str] = []
    mode: str  # "full_day" or "what_needs_work"
    availableExercises: list[dict] = []
    preferences: dict = {}

class ExerciseSuggestionRequest(BaseModel):
    currentSessionExercises: list[Exercise]
    currentMuscleGroup: str
    availableExercises: list[dict] = []
    preferences: dict = {}

class ExerciseRecommendation(BaseModel):
    name: str
    muscleGroup: str
    targetMuscle: str
    equipmentType: str
    suggestedSets: int
    reason: str

class WorkoutRecommendationResponse(BaseModel):
    exercises: list[ExerciseRecommendation]
    summary: str
    mode: str

class ExerciseSuggestionResponse(BaseModel):
    suggestions: list[ExerciseRecommendation]
    reason: str