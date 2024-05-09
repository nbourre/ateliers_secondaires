using Godot;
using System;

public partial class HUD : CanvasLayer
{
    private int _bestScore = 0;
    private int _killCount = 0;

    public int BestScore
    { 
        get { return _bestScore; }
        set
        {
            if (value > _bestScore)
            {
                _bestScore = value;
                GetNode<HBoxContainer>("VBoxContainer/HBoxBestScore").Visible = true;
                GetNode<Label>("VBoxContainer/HBoxBestScore/killCount").Text = _bestScore.ToString();
            }
        }
    }

    public void AddKill()
    {
        _killCount += 1;
        BestScore = _killCount;
        GetNode<Label>("VBoxContainer/HBoxKillCount/killCount").Text = _killCount.ToString();
    }

    public void Reset()
    {
        _killCount = 0;
        GetNode<Label>("VBoxContainer/HBoxKillCount/killCount").Text = "0";
    }
}
