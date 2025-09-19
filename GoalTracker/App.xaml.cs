namespace GoalTracker;

public partial class App : Application
{
	public App()
	{
		InitializeComponent();
	}

	protected override Window CreateWindow(IActivationState? activationState)
	{
#if DEBUG
		// During development, launch MainPage directly so XAML changes are obvious.
		return new Window(new MainPage());
#else
		return new Window(new AppShell());
#endif
	}
}