export function calculateBMI(
  weight?: number,
  height?: number
): number | undefined {
  if (!weight || !height) return undefined;
  const heightMeters = height / 100;
  return +(weight / (heightMeters * heightMeters)).toFixed(2);
}

export function calculateBMR(
  gender: string,
  weight?: number,
  height?: number,
  age?: number
): number | undefined {
  if (!weight || !height || !age) return undefined;
  if (gender === "male") {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  } else if (gender === "female") {
    return 10 * weight + 6.25 * height - 5 * age - 161;
  }
  return undefined;
}

export function getActivityFactor(level?: string): number {
  switch (level) {
    case "sedentary":
      return 1.2;
    case "light":
      return 1.375;
    case "moderate":
      return 1.55;
    case "active":
      return 1.725;
    case "very_active":
      return 1.9;
    default:
      return 1.2;
  }
}

export function calculateDailyCalories(
  gender: string,
  weight?: number,
  height?: number,
  age?: number,
  activityLevel?: string
): number | undefined {
  const bmr = calculateBMR(gender, weight, height, age);
  if (!bmr) return undefined;
  return Math.round(bmr * getActivityFactor(activityLevel));
}
