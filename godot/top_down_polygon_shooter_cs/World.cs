using Godot;
using System;
using System.Collections.Generic;

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
            var mob = (Node2D)MobScene.Instance();
            var mobSpawnLocation = GetNode<PathFollow2D>("Level/SpawnPath/SpawnLocation");
            mobSpawnLocation.UnitOffset = GD.Randf();

            mob.Position = mobSpawnLocation.GlobalPosition;
            GD.Print(mob.Position);

            AddChild(mob);
        }
    }

    public void AddKill()
    {
        _hud?.AddKill();
    }

    public Dictionary<string, object> Save()
    {
        if (_hud == null) return null;

        return new Dictionary<string, object>
        {
            ["best"] = _hud.GetBestScore()
        };
    }

    public void LoadGame()
    {
        if (_hud == null || !File.Exists("user://savegame.save")) return;

        var saveFile = new File();
        saveFile.Open("user://savegame.save", File.ModeFlags.Read);

        while (!saveFile.EofReached())
        {
            string jsonString = saveFile.GetLine();
            var json = new Godot.Collections.Dictionary(JSON.Parse(jsonString).Result);

            if (json.Contains("best"))
            {
                _hud.SetBestScore((int)json["best"]);
                GD.Print("Best score: " + json["best"]);
            }
        }
        saveFile.Close();
    }

    public void SaveGame()
    {
        if (_hud == null) return;

        var bestScore = Save();
        if (bestScore == null) return;

        var saveFile = new File();
        saveFile.Open("user://savegame.save", File.ModeFlags.Write);

        string jsonString = JSON.Print(bestScore);
        saveFile.StoreLine(jsonString);
        saveFile.Close();
    }

    public override void _ExitTree()
    {
        SaveGame();
    }
}
