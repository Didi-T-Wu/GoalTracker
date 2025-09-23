namespace GoalTracker.Models
{
    public class Goal
    {
        public required string Name { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime TargetDate { get; set; }
        public double Progress { get; set; }   // 0.0 – 1.0
        public required string Motivation { get; set; }
        public Goal() // new parameterless ctor
        {
            StartDate = DateTime.Now;
            TargetDate = StartDate.AddDays(30);
        }

        public Goal(string name, string motivation)
        {
            Name = name;
            Motivation = motivation;
            StartDate = DateTime.Now;
            TargetDate = StartDate.AddDays(30);
        }

        public string ProgressPercent => $"{(int)(Progress * 100)}%";
    }
}