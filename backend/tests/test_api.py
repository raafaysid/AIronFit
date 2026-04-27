import pytest
from fastapi.testclient import TestClient
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)

# Fixtures 
@pytest.fixture
def sample_workout():
    return {
        "date": "2026-04-13",
        "duration": 3600,
        "exercises": [
            {
                "name": "Barbell Bench Press",
                "muscleGroup": "Chest",
                "targetMuscle": "Pectoralis Major",
                "equipmentType": "Barbell",
                "sets": [
                    {"weight": 185.0, "reps": 8.0},
                    {"weight": 185.0, "reps": 7.0},
                    {"weight": 175.0, "reps": 8.0}
                ]
            },
            {
                "name": "Cable Tricep Pushdown",
                "muscleGroup": "Upper Arms",
                "targetMuscle": "Triceps Lateral Head",
                "equipmentType": "Cable",
                "sets": [
                    {"weight": 50.0, "reps": 12.0},
                    {"weight": 50.0, "reps": 10.0}
                ]
            }
        ]
    }

@pytest.fixture
def sample_exercises():
    return [
        {
            "name": "Incline Dumbbell Press",
            "muscleGroup": "Chest",
            "targetMuscle": "Upper Pectoralis",
            "equipmentType": "Dumbbell"
        },
        {
            "name": "Pec Deck Machine",
            "muscleGroup": "Chest",
            "targetMuscle": "Pectoralis Major",
            "equipmentType": "Leverage Machine"
        },
        {
            "name": "Cable Overhead Tricep Extension",
            "muscleGroup": "Upper Arms",
            "targetMuscle": "Triceps Long Head",
            "equipmentType": "Cable"
        },
        {
            "name": "Dumbbell Lateral Raise",
            "muscleGroup": "Shoulders",
            "targetMuscle": "Lateral Deltoid",
            "equipmentType": "Dumbbell"
        },
        {
            "name": "Machine Leg Press",
            "muscleGroup": "Upper Legs",
            "targetMuscle": "Quadriceps",
            "equipmentType": "Leverage Machine"
        },
        {
            "name": "Lat Pulldown",
            "muscleGroup": "Back",
            "targetMuscle": "Lats",
            "equipmentType": "Cable"
        }
    ]

#health Check 

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "AIronFit API"

# recommend Workout 

def test_recommend_workout_full_day(sample_workout, sample_exercises):
    payload = {
        "recentWorkouts": [sample_workout],
        "selectedMuscleGroups": ["Chest", "Upper Arms"],
        "mode": "full_day",
        "availableExercises": sample_exercises,
        "preferences": {}
    }
    response = client.post("/recommend-workout", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "exercises" in data
    assert "summary" in data
    assert "mode" in data
    assert data["mode"] == "full_day"
    assert len(data["exercises"]) > 0

def test_recommend_workout_what_needs_work(sample_workout, sample_exercises):
    payload = {
        "recentWorkouts": [sample_workout],
        "selectedMuscleGroups": [],
        "mode": "what_needs_work",
        "availableExercises": sample_exercises,
        "preferences": {}
    }
    response = client.post("/recommend-workout", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "exercises" in data
    assert len(data["exercises"]) > 0
    assert data["mode"] == "what_needs_work"

def test_recommend_workout_response_structure(sample_workout, sample_exercises):
    payload = {
        "recentWorkouts": [sample_workout],
        "selectedMuscleGroups": ["Back"],
        "mode": "full_day",
        "availableExercises": sample_exercises,
        "preferences": {}
    }
    response = client.post("/recommend-workout", json=payload)
    assert response.status_code == 200
    data = response.json()

    for exercise in data["exercises"]:
        assert "name" in exercise
        assert "muscleGroup" in exercise
        assert "targetMuscle" in exercise
        assert "equipmentType" in exercise
        assert "suggestedSets" in exercise
        assert "reason" in exercise
        assert isinstance(exercise["suggestedSets"], int)
        assert exercise["suggestedSets"] > 0

def test_recommend_workout_with_preferences(sample_workout, sample_exercises):
    payload = {
        "recentWorkouts": [sample_workout],
        "selectedMuscleGroups": ["Chest"],
        "mode": "full_day",
        "availableExercises": sample_exercises,
        "preferences": {
            "busyEquipment": ["Cable"],
            "avoidedExercises": ["Barbell Bench Press"]
        }
    }
    response = client.post("/recommend-workout", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert len(data["exercises"]) > 0

def test_recommend_workout_no_history(sample_exercises):
    payload = {
        "recentWorkouts": [],
        "selectedMuscleGroups": ["Legs"],
        "mode": "full_day",
        "availableExercises": sample_exercises,
        "preferences": {}
    }
    response = client.post("/recommend-workout", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert len(data["exercises"]) > 0

def test_recommend_workout_invalid_payload():
    payload = {
        "invalidField": "this should fail"
    }
    response = client.post("/recommend-workout", json=payload)
    assert response.status_code == 422

# suggest Next Exercise 

def test_suggest_next_exercise(sample_exercises):
    payload = {
        "currentSessionExercises": [
            {
                "name": "Cable Tricep Pushdown",
                "muscleGroup": "Upper Arms",
                "targetMuscle": "Triceps Lateral Head",
                "equipmentType": "Cable",
                "sets": [
                    {"weight": 50.0, "reps": 12.0},
                    {"weight": 50.0, "reps": 10.0}
                ]
            }
        ],
        "currentMuscleGroup": "Upper Arms",
        "availableExercises": sample_exercises,
        "preferences": {}
    }
    response = client.post("/suggest-next-exercise", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "suggestions" in data
    assert "reason" in data
    assert len(data["suggestions"]) > 0

def test_suggest_next_exercise_response_structure(sample_exercises):
    payload = {
        "currentSessionExercises": [
            {
                "name": "Lat Pulldown",
                "muscleGroup": "Back",
                "targetMuscle": "Lats",
                "equipmentType": "Cable",
                "sets": [{"weight": 100.0, "reps": 8.0}]
            }
        ],
        "currentMuscleGroup": "Back",
        "availableExercises": sample_exercises,
        "preferences": {}
    }
    response = client.post("/suggest-next-exercise", json=payload)
    assert response.status_code == 200
    data = response.json()

    for suggestion in data["suggestions"]:
        assert "name" in suggestion
        assert "muscleGroup" in suggestion
        assert "targetMuscle" in suggestion
        assert "equipmentType" in suggestion
        assert "suggestedSets" in suggestion
        assert "reason" in suggestion

def test_suggest_next_exercise_invalid_payload():
    payload = {"invalidField": "bad data"}
    response = client.post("/suggest-next-exercise", json=payload)
    assert response.status_code == 422