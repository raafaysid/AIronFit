import anthropic
import json
import os
from dotenv import load_dotenv
from models import (
    WorkoutRecommendationRequest,
    ExerciseSuggestionRequest,
    WorkoutRecommendationResponse,
    ExerciseSuggestionResponse,
    ExerciseRecommendation
)

load_dotenv()

client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

def build_workout_history_summary(workouts: list) -> str:
    if not workouts:
        return "No recent workout history available."
    
    summary = []
    for workout in workouts:
        date = workout.date
        exercises_done = []
        for exercise in workout.exercises:
            sets_info = f"{len(exercise.sets)} sets"
            exercises_done.append(
                f"{exercise.name} ({exercise.targetMuscle}, {sets_info})"
            )
        if exercises_done:
            summary.append(f"Date: {date}\nExercises: {', '.join(exercises_done)}")
    
    return "\n\n".join(summary)

def build_available_exercises_summary(exercises: list) -> str:
    if not exercises:
        return "No exercise database provided."
    
    by_muscle = {}
    for ex in exercises:
        muscle = ex.get("muscleGroup", "Unknown")
        if muscle not in by_muscle:
            by_muscle[muscle] = []
        by_muscle[muscle].append(
            f"{ex.get('name')} (targets: {ex.get('targetMuscle')}, equipment: {ex.get('equipmentType')})"
        )
    
    summary = []
    for muscle, exercises_list in by_muscle.items():
        summary.append(f"{muscle}:\n" + "\n".join(f"  - {e}" for e in exercises_list))
    
    return "\n\n".join(summary)

def get_workout_recommendation(request: WorkoutRecommendationRequest) -> WorkoutRecommendationResponse:
    history_summary = build_workout_history_summary(request.recentWorkouts)
    available_exercises = build_available_exercises_summary(request.availableExercises)
    
    if request.mode == "full_day":
        muscle_groups = ", ".join(request.selectedMuscleGroups)
        mode_instruction = f"""The user wants to train these muscle groups today: {muscle_groups}
        
Recommend 3-5 exercises per muscle group selected, choosing exercises that:
1. Target different parts of each muscle group to avoid redundancy
2. Avoid exercises that heavily overlap with what was trained recently
3. Only use exercises from the available exercise database provided"""

    else:  # what_needs_work
        mode_instruction = """Analyze the workout history and identify which muscles across the ENTIRE body 
haven't been trained recently or are undertrained. 

Recommend 6-10 exercises total across different muscle groups that:
1. Target the most neglected muscles based on recent history
2. Create a balanced workout despite being from different muscle groups
3. Only use exercises from the available exercise database provided"""

    preferences_note = ""
    if request.preferences:
        avoided = request.preferences.get("avoidedExercises", [])
        busy_equipment = request.preferences.get("busyEquipment", [])
        if avoided:
            preferences_note += f"\nAvoid these exercises: {', '.join(avoided)}"
        if busy_equipment:
            preferences_note += f"\nThis equipment is currently busy/unavailable: {', '.join(busy_equipment)}"

    prompt = f"""You are an expert fitness coach with deep knowledge of muscle anatomy and exercise science.

RECENT WORKOUT HISTORY:
{history_summary}

AVAILABLE EXERCISES IN USER'S GYM:
{available_exercises}

TASK:
{mode_instruction}
{preferences_note}

IMPORTANT RULES:
- Only recommend exercises that exist EXACTLY in the available exercises list above
- Consider which specific muscle heads have been trained recently (e.g. triceps long head vs lateral head)
- Suggest appropriate sets (3-4 for compound, 2-3 for isolation)
- For each exercise explain briefly WHY you're recommending it

Respond ONLY with a valid JSON object in this exact format, no other text:
{{
  "exercises": [
    {{
      "name": "exact exercise name from database",
      "muscleGroup": "muscle group",
      "targetMuscle": "specific muscle targeted",
      "equipmentType": "equipment type",
      "suggestedSets": 3,
      "reason": "brief reason why this exercise is recommended"
    }}
  ],
  "summary": "2-3 sentence overview of the recommendation"
}}"""

    message = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=2000,
        messages=[{"role": "user", "content": prompt}]
    )
    
    response_text = message.content[0].text
    
    try:
        clean_text = response_text.strip()
        if clean_text.startswith("```"):
            clean_text = clean_text.split("```")[1]
            if clean_text.startswith("json"):
                clean_text = clean_text[4:]
        
        data = json.loads(clean_text)
        exercises = [ExerciseRecommendation(**ex) for ex in data["exercises"]]
        
        return WorkoutRecommendationResponse(
            exercises=exercises,
            summary=data["summary"],
            mode=request.mode
        )
    except Exception as e:
        print(f"Error parsing Claude response: {e}")
        print(f"Raw response: {response_text}")
        raise ValueError(f"Failed to parse AI response: {e}")


def get_exercise_suggestion(request: ExerciseSuggestionRequest) -> ExerciseSuggestionResponse:
    
    current_exercises = []
    for ex in request.currentSessionExercises:
        sets_done = len(ex.sets)
        current_exercises.append(
            f"{ex.name} — {ex.targetMuscle} — {sets_done} sets done"
        )
    
    available_exercises = build_available_exercises_summary(request.availableExercises)
    
    preferences_note = ""
    if request.preferences:
        avoided = request.preferences.get("avoidedExercises", [])
        busy_equipment = request.preferences.get("busyEquipment", [])
        if avoided:
            preferences_note += f"\nAvoid these exercises: {', '.join(avoided)}"
        if busy_equipment:
            preferences_note += f"\nThis equipment is currently busy: {', '.join(busy_equipment)}"

    prompt = f"""You are an expert fitness coach helping someone mid-workout.

EXERCISES DONE THIS SESSION SO FAR:
{chr(10).join(current_exercises)}

CURRENT MUSCLE GROUP BEING TRAINED: {request.currentMuscleGroup}

AVAILABLE EXERCISES:
{available_exercises}
{preferences_note}

TASK:
Suggest 2-3 exercises the user could do next that:
1. Avoid redundancy with what they've already done this session
2. Target different muscle heads within the same muscle group if possible
3. Only use exercises from the available exercises list
4. If all parts of the current muscle group are covered suggest a complementary muscle group

Respond ONLY with a valid JSON object in this exact format, no other text:
{{
  "suggestions": [
    {{
      "name": "exact exercise name from database",
      "muscleGroup": "muscle group",
      "targetMuscle": "specific muscle targeted",
      "equipmentType": "equipment type",
      "suggestedSets": 3,
      "reason": "why this avoids redundancy"
    }}
  ],
  "reason": "brief explanation of the overall suggestion logic"
}}"""

    message = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=1000,
        messages=[{"role": "user", "content": prompt}]
    )
    
    response_text = message.content[0].text
    
    try:
        clean_text = response_text.strip()
        if clean_text.startswith("```"):
            clean_text = clean_text.split("```")[1]
            if clean_text.startswith("json"):
                clean_text = clean_text[4:]
        
        data = json.loads(clean_text)
        suggestions = [ExerciseRecommendation(**ex) for ex in data["suggestions"]]
        
        return ExerciseSuggestionResponse(
            suggestions=suggestions,
            reason=data["reason"]
        )
    except Exception as e:
        print(f"Error parsing Claude response: {e}")
        print(f"Raw response: {response_text}")
        raise ValueError(f"Failed to parse AI response: {e}")