using dotnet_func.Models;

namespace dotnet_func.Utilities;

public static class UserHealthCalculator
{
    /// <summary>
    /// Calculates BMI (Body Mass Index).
    /// </summary>
    public static double CalculateBmi(double weightKg, double heightCm)
    {
        double heightM = heightCm / 100.0;
        return Math.Round(weightKg / (heightM * heightM), 2);
    }

    /// <summary>
    /// Estimates user's age from Date of Birth.
    /// </summary>
    public static int CalculateAge(DateTime dateOfBirth)
    {
        var today = DateTime.UtcNow;
        int age = today.Year - dateOfBirth.Year;
        if (today < dateOfBirth.AddYears(age)) age--;
        return age;
    }

    /// <summary>
    /// Estimates the daily calorie goal based on Mifflin-St Jeor equation.
    /// </summary>
    public static int CalculateDailyCalorieGoal(string gender, double weightKg, double heightCm, DateTime dateOfBirth)
    {
        int age = CalculateAge(dateOfBirth);

        // Basal Metabolic Rate (BMR)
        double bmr = gender.ToLower() switch
        {
            "male" => 10 * weightKg + 6.25 * heightCm - 5 * age + 5,
            "female" => 10 * weightKg + 6.25 * heightCm - 5 * age - 161,
            _ => 10 * weightKg + 6.25 * heightCm - 5 * age
        };

        // Default activity factor: moderate activity (1.55)
        double calorieGoal = bmr * 1.55;
        return (int)Math.Round(calorieGoal);
    }

    /// <summary>
    /// Suggests dietary preference based on BMI.
    /// </summary>
    public static string SuggestDietaryPreference(double bmi)
    {
        if (bmi < 18.5)
            return "High Protein";
        else if (bmi < 24.9)
            return "Balanced";
        else
            return "Low Carb";
    }

    /// <summary>
    /// Suggests default activity level based on age and BMI.
    /// </summary>
    public static string SuggestActivityLevel(double bmi, int age)
    {
        if (bmi < 25 && age < 35)
            return ActivityLevel.VeryActive.ToString();
        if (bmi >= 25)
            return ActivityLevel.Sedentary.ToString();
        return ActivityLevel.VeryActive.ToString();
    }

    /// <summary>
    /// Suggests a target weight based on height and ideal BMI of 22.
    /// </summary>
    public static double SuggestTargetWeight(double heightCm)
    {
        double idealBmi = 22;
        double heightM = heightCm / 100.0;
        return Math.Round(idealBmi * heightM * heightM, 1);
    }

    /// <summary>
    /// Generates all derived health data for a user.
    /// </summary>
    public static (double Bmi, int DailyCalorieGoal, string DietaryPreference, string ActivityLevel, double TargetWeight)
        GenerateHealthData(string gender, double weightKg, double heightCm, DateTime dateOfBirth)
    {
        double bmi = CalculateBmi(weightKg, heightCm);
        int calorieGoal = CalculateDailyCalorieGoal(gender, weightKg, heightCm, dateOfBirth);
        string dietaryPref = SuggestDietaryPreference(bmi);
        int age = CalculateAge(dateOfBirth);
        string activityLevel = SuggestActivityLevel(bmi, age);
        double targetWeight = SuggestTargetWeight(heightCm);

        return (bmi, calorieGoal, dietaryPref, activityLevel, targetWeight);
    }
}
