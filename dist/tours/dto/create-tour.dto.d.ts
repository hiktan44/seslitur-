export declare enum TourStatus {
    UPCOMING = "upcoming",
    ACTIVE = "active",
    COMPLETED = "completed",
    CANCELLED = "cancelled"
}
export declare class CreateTourDto {
    name: string;
    code: string;
    destination: string;
    guide_id: string;
    start_date: string;
    end_date: string;
    status: TourStatus;
    description?: string;
}
