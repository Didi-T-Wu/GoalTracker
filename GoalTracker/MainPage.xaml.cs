
using GoalTracker.Models;

namespace GoalTracker;

public partial class MainPage : ContentPage
{


    public MainPage()
    {
        InitializeComponent();

        var sampleGoals = new List<Goal>
        {
            new Goal { Name="Run a Marathon", Motivation="I want to be healthier." },
            new Goal { Name="Read 12 Books", Motivation="Expand my knowledge." },
            new Goal { Name="Save $5000", Motivation="Build financial security." }
        };

        GoalsCollection.ItemsSource = sampleGoals;

         // Log when Add button is clicked
        AddButton.Clicked += (s, e) =>
        {
            System.Diagnostics.Debug.WriteLine("Hello from MainPage!");
            Console.WriteLine("Add button clicked!");
        };

	}

}
