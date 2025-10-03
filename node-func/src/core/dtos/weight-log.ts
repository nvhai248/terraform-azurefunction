export interface CreateWeightLogDto {
  userId: string;
  weight: number;
  note?: string;
}

export interface UpdateWeightLogDto {
  weight?: number;
  note?: string;
}
