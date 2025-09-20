namespace GoalTracker.Models
{
    public class Goal
    {
        public string Name { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime TargetDate { get; set; }
        public double Progress { get; set; }   // 0.0 – 1.0
        public string Motivation { get; set; }
        public string Details { get; set; } //for now just a string, could be expanded later

        public string ProgressPercent => $"{(int)(Progress * 100)}%";
    }
}