using Godot;

public partial class World : Node2D
{
    [Export]
    public PackedScene MobScene;

    private HUD _hud;
    private const int MaxMobs = 14;

    public override void _Ready()
    {
        if (HasNode("HUD"))
            _hud = GetNode<HUD>("HUD");

        if (HasNode("MobTimer"))
            GetNode<Timer>("MobTimer").Timeout += OnMobTimerTimeout;

        LoadGame();
    }

    public void StartSpawning()
    {
        if (HasNode("MobTimer"))
            GetNode<Timer>("MobTimer").Start();
    }

    private void OnMobTimerTimeout()
    {
        if (HasNode("Level") && Enemy.Count <= MaxMobs)
        {
            var mob = ResourceLoader.Load<PackedScene>("res://Enemy.tscn").Instantiate() as Enemy;
            //var mob = (Node2D)MobScene.Instance();
            var mobSpawnLocation = GetNode<PathFollow2D>("Level/SpawnPath/SpawnLocation");
            mobSpawnLocation.ProgressRatio = GD.Randf();

            mob.Position = mobSpawnLocation.GlobalPosition;
            GD.Print(mob.Position);

            AddChild(mob);
        }
    }

    public void AddKill()
    {
        _hud?.AddKill();
    }

    public Godot.Collections.Dictionary<string, Variant> Save()
    {
        if (_hud == null) return null;

        return new Godot.Collections.Dictionary<string, Variant>
        {
            ["best"] = _hud.BestScore
        };
    }

    public void LoadGame()
    {
        if (_hud == null || !FileAccess.FileExists("user://savegame.save")) return;

        // var saveFile = new File();
        //saveFile.Open("user://savegame.save", File.ModeFlags.Read);

        using var saveFile = FileAccess.Open("user://savegame.save", FileAccess.ModeFlags.Read);

        while (!saveFile.EofReached())
        {
            string jsonString = saveFile.GetLine();

            if (string.IsNullOrEmpty(jsonString))
            {
                continue;
            }

            GD.Print("JSON: " + jsonString);

            var json = new Json();
            var parseResult = json.Parse(jsonString);

            if (parseResult != Error.Ok)
            {
                GD.PrintErr("Error parsing JSON: " + parseResult.ToString());
                return;
            }

            // Get the data from the JSON object
            var nodeData = new Godot.Collections.Dictionary<string, Variant>((Godot.Collections.Dictionary)json.Data);

            if (nodeData.Keys.Contains("best"))
            {
                _hud.BestScore = (int)nodeData["best"];
                GD.Print("Best score: " + _hud.BestScore);
            }
        }
        saveFile.Close();
    }

    public void SaveGame()
    {
        if (_hud == null) return;

        var bestScore = Save();
        if (bestScore == null) return;

        //var saveFile = new File();
        //saveFile.Open("user://savegame.save", FileAccess.ModeFlags.Write);

        using var saveFile = FileAccess.Open("user://savegame.save", FileAccess.ModeFlags.Write);

        string jsonString = Json.Stringify(bestScore);
        saveFile.StoreLine(jsonString);
    }

    public override void _ExitTree()
    {
        SaveGame();
    }
}
